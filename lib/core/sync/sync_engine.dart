import 'dart:io';

import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../photos/photo_storage.dart';
import 'sync_remote.dart';
import 'sync_tables.dart';

/// Jak dopadlo spárování zahrady v telefonu s účtem.
sealed class Pairing {
  const Pairing();
}

/// Zahrada v telefonu je zahradou účtu (nebo se do prázdného účtu právě
/// nahrála).
class Paired extends Pairing {
  const Paired();
}

/// Účet už má jinou zahradu; uživatel musí vybrat (DECLOG D70).
class PairingConflict extends Pairing {
  const PairingConflict(this.remoteGardenId);

  final String remoteGardenId;
}

/// Zahrada v telefonu na serveru byla, ale účet k ní už nemá přístup
/// (vlastník uživatele ze sdílené zahrady odebral, DECLOG D89).
class PairingLost extends Pairing {
  const PairingLost();
}

/// Výsledek jednoho kola synchronizace.
class SyncReport {
  const SyncReport({required this.pairing, this.pushed = 0, this.pulled = 0});

  final Pairing pairing;
  final int pushed;
  final int pulled;
}

/// O kolik se stahování vrací před poslední známé razítko serveru:
/// transakce, která začala dřív, se může potvrdit až po ní.
const pullOverlap = Duration(seconds: 5);

/// Synchronizace „poslední zápis vyhrává“ (spec 7.4, DECLOG D69).
///
/// Odesílá frontu změn `sync_outbox` (plní ji triggery) jedním voláním
/// `sync_push`, pak stahuje změny ze serveru podle `server_updated_at`
/// a zapíše je, jen když nejsou starší než verze v telefonu.
class SyncEngine {
  SyncEngine({
    required this.db,
    required this.remote,
    required this.gardenId,
    required this.clock,
    this.photos,
  });

  final AppDatabase db;
  final SyncRemote remote;
  final String gardenId;
  final DateTime Function() clock;

  /// Fotky v telefonu; null = bez fotek (web).
  final PhotoStorage? photos;

  final Map<String, Set<String>> _columns = {};

  /// Jedno kolo: spárovat, odeslat, stáhnout, dotáhnout chybějící fotky.
  Future<SyncReport> sync() async {
    final pairing = await pair();
    if (pairing is! Paired) return SyncReport(pairing: pairing);
    final pushed = await push();
    // Po úspěšném odeslání je zahrada na serveru (řádek zahrady jde ve
    // frontě se spárováním).
    if (await readState('onServer') != gardenId) {
      await writeState('onServer', gardenId);
    }
    final pulled = await pull();
    await downloadMissingPhotos();
    return SyncReport(pairing: pairing, pushed: pushed, pulled: pulled);
  }

  /// Spáruje zahradu v telefonu s účtem. Do prázdného účtu nahraje
  /// všechno, co v telefonu je.
  Future<Pairing> pair() async {
    final paired = await readState('paired') == gardenId;
    final remoteIds = await remote.gardenIds();
    if (remoteIds.contains(gardenId)) {
      if (!paired) {
        await _enqueueAll();
        await writeState('paired', gardenId);
      }
      if (await readState('onServer') != gardenId) {
        await writeState('onServer', gardenId);
      }
      return const Paired();
    }
    if (paired) {
      // Na serveru byla a účet ji už nevidí: přístup skončil. Jinak se
      // jen ještě nenahrála (první odeslání selhalo).
      return await readState('onServer') == gardenId
          ? const PairingLost()
          : const Paired();
    }
    if (remoteIds.isEmpty) {
      await _enqueueAll();
      await writeState('paired', gardenId);
      return const Paired();
    }
    return PairingConflict(remoteIds.first);
  }

  /// Odhlášení: telefon zapomene spárování a razítka stahování. Data
  /// i fronta změn zůstanou.
  Future<void> forget() async {
    await (db.delete(db.syncState)..where(
          (s) =>
              s.name.equals('paired') |
              s.name.equals('onServer') |
              s.name.like('pulled:%'),
        ))
        .go();
  }

  /// Všechny řádky do fronty (první spárování: data z doby před účtem).
  Future<void> _enqueueAll() async {
    for (final t in syncTables) {
      final key = t.pk.map((c) => '"$c"').join(" || '|' || ");
      await db.customStatement(
        'INSERT OR REPLACE INTO sync_outbox (entity, row_key) '
        'SELECT ?, $key FROM "${t.name}"',
        [t.name],
      );
    }
  }

  /// Odešle frontu změn; vrátí počet odeslaných řádků.
  Future<int> push() async {
    final entries = await (db.select(
      db.syncOutbox,
    )..orderBy([(o) => OrderingTerm(expression: o.seq)])).get();
    if (entries.isEmpty) return 0;

    final changes = <String, List<Map<String, Object?>>>{};
    final deleted = <Map<String, Object?>>[];
    final now = clock().toUtc().toIso8601String();
    for (final e in entries) {
      final table = syncTable(e.entity);
      final keys = table.keyValues(e.rowKey);
      final row = await _row(table, keys);
      if (row == null) {
        deleted.add({'table': table.name, 'key': keys, 'at': now});
        continue;
      }
      final server = table.toServer(row);
      if (table.name == 'photos') {
        final garden = row['garden_id'];
        server['storage_path'] = '$garden/${row['id']}.jpg';
        server['thumb_path'] = '$garden/${row['id']}_thumb.jpg';
        server['updated_at'] ??= server['created_at'];
        await _uploadPhoto(row, server['storage_path']! as String);
      }
      (changes[table.name] ??= []).add(server);
    }

    await remote.push({
      for (final t in syncTables)
        if (changes[t.name] case final rows?) t.name: rows,
      if (deleted.isNotEmpty) 'deleted': deleted,
    });

    // Smazat jen záznamy, které se mezitím nezměnily (nová změna má
    // nové pořadí a odešle se příště).
    await db.transaction(() async {
      for (final e in entries) {
        await (db.delete(
          db.syncOutbox,
        )..where((o) => o.seq.equals(e.seq))).go();
      }
    });
    return entries.length;
  }

  Future<void> _uploadPhoto(Map<String, Object?> row, String path) async {
    final storage = photos;
    final id = row['id']! as String;
    if (storage == null || row['deleted_at'] != null) return;
    if (await readState('uploaded:$id') != null) return;
    final file = storage.resolve(row['local_path'] as String?);
    if (file == null || !File(file).existsSync()) return;
    final bytes = await File(file).readAsBytes();
    await remote.uploadPhoto(path, bytes);
    // Náhled zatím stejný soubor (fotky se zmenšují už při pořízení).
    await remote.uploadPhoto(path.replaceFirst('.jpg', '_thumb.jpg'), bytes);
    await writeState('uploaded:$id', '1');
  }

  /// Stáhne změny ze serveru; vrátí počet zapsaných řádků.
  Future<int> pull() async {
    final batches = <SyncTable, List<Map<String, Object?>>>{};
    final marks = <String, String>{};
    for (final table in syncTables) {
      final mark = await readState('pulled:${table.name}');
      var since = mark == null
          ? null
          : DateTime.parse(mark).subtract(pullOverlap);
      final rows = <Map<String, Object?>>[];
      while (true) {
        final page = await remote.pull(
          table.name,
          since: since,
          gardenColumn: table.gardenColumn,
          gardenId: table.gardenColumn == null ? null : gardenId,
        );
        rows.addAll(page);
        if (page.length < 500) break;
        final last = page.last['server_updated_at'];
        if (last is! String) break;
        final next = DateTime.parse(last);
        // Celá stránka se stejným razítkem: dál by se nepohnulo.
        if (since != null && !next.isAfter(since)) break;
        since = next;
      }
      if (rows.isEmpty) continue;
      batches[table] = rows;
      String? newest = mark;
      for (final r in rows) {
        final s = r['server_updated_at'];
        if (s is String &&
            (newest == null ||
                DateTime.parse(s).isAfter(DateTime.parse(newest)))) {
          newest = normalizeTimestamp(s);
        }
      }
      if (newest != null) marks['pulled:${table.name}'] = newest;
    }

    var applied = 0;
    await db.transaction(() async {
      await db.customStatement('PRAGMA defer_foreign_keys = ON');
      await writeState('applying', '1');
      for (final entry in batches.entries) {
        for (final row in entry.value) {
          if (await _apply(entry.key, row)) applied++;
        }
      }
      await (db.delete(
        db.syncState,
      )..where((s) => s.name.equals('applying'))).go();
      for (final m in marks.entries) {
        await writeState(m.key, m.value);
      }
    });
    if (applied > 0) _notifyAll();
    return applied;
  }

  /// Zapíše řádek ze serveru, pokud není starší než verze v telefonu.
  Future<bool> _apply(SyncTable table, Map<String, Object?> server) async {
    final columns = await _localColumns(table.name);
    final local = table.toLocal(server, columns);
    final keys = {for (final c in table.pk) c: '${local[c]}'};
    final existing = await _row(table, keys);
    if (existing != null) {
      final mine = _time(existing['updated_at'] ?? existing['created_at']);
      final theirs = _time(local['updated_at']);
      if (mine != null && theirs != null && mine.isAfter(theirs)) {
        return false;
      }
    }
    if (table.name == 'photos') {
      // Povinný sloupec jen v telefonu; NOT NULL se kontroluje dřív než
      // konflikt, proto i u existujícího řádku.
      local['local_path'] =
          existing?['local_path'] ?? _photoPath(local['id']! as String);
    }
    final names = local.keys.toList();
    final updates = [
      for (final n in names)
        if (!table.pk.contains(n)) '"$n" = excluded."$n"',
    ];
    await db.customStatement(
      'INSERT INTO "${table.name}" (${names.map((n) => '"$n"').join(', ')}) '
      'VALUES (${List.filled(names.length, '?').join(', ')}) '
      'ON CONFLICT (${table.pk.map((c) => '"$c"').join(', ')}) '
      '${updates.isEmpty ? 'DO NOTHING' : 'DO UPDATE SET ${updates.join(', ')}'}',
      [for (final n in names) local[n]],
    );
    return true;
  }

  String _photoPath(String id) =>
      photos?.relativePathFor('$id.jpg') ?? 'activity_photos/$id.jpg';

  /// Fotky stažené jen jako řádek (soubor chybí) se zkusí dotáhnout.
  Future<void> downloadMissingPhotos() async {
    final storage = photos;
    if (storage == null) return;
    final rows = await (db.select(
      db.photos,
    )..where((p) => p.deletedAt.isNull())).get();
    for (final p in rows) {
      final path = storage.resolve(p.localPath);
      if (path != null && File(path).existsSync()) continue;
      final bytes = await remote.downloadPhoto('${p.gardenId}/${p.id}.jpg');
      if (bytes == null) continue;
      final target = await storage.prepareFile('${p.id}.jpg');
      await File(target).writeAsBytes(bytes, flush: true);
      // Soubor se jmenuje podle id; cesta v databázi musí sedět.
      final relative = storage.relativePathFor('${p.id}.jpg');
      if (relative != p.localPath) {
        await db.transaction(() async {
          await writeState('applying', '1');
          await (db.update(db.photos)..where((x) => x.id.equals(p.id))).write(
            PhotosCompanion(localPath: Value(relative)),
          );
          await (db.delete(
            db.syncState,
          )..where((s) => s.name.equals('applying'))).go();
        });
      }
      await writeState('uploaded:${p.id}', '1');
    }
  }

  /// Nahradí data v telefonu zahradou z účtu (DECLOG D70): smaže
  /// synchronizovaná data a frontu, přejmenuje zahradu na [remoteGardenId].
  /// Pak je potřeba aplikaci znovu načíst (nové id zahrady) a stáhnout data.
  Future<void> adoptRemoteGarden(String remoteGardenId) =>
      _replaceGarden(remoteGardenId, adopted: true);

  /// Začne v telefonu novou prázdnou zahradu [newGardenId] (po odchodu
  /// nebo odebrání ze sdílené zahrady, DECLOG D89). Další synchronizace
  /// ji spáruje s účtem jako každou jinou.
  Future<void> startNewGarden(String newGardenId, {required String name}) =>
      _replaceGarden(newGardenId, adopted: false, name: name);

  Future<void> _replaceGarden(
    String id, {
    required bool adopted,
    String name = 'Moje zahrada',
  }) async {
    await db.transaction(() async {
      await db.customStatement('PRAGMA defer_foreign_keys = ON');
      await writeState('applying', '1');
      for (final t in syncTables.reversed) {
        await db.customStatement('DELETE FROM "${t.name}"');
      }
      await db.delete(db.syncOutbox).go();
      await (db.delete(db.syncState)..where(
            (s) =>
                s.name.like('pulled:%') |
                s.name.like('uploaded:%') |
                s.name.equals('paired') |
                s.name.equals('onServer'),
          ))
          .go();
      final now = clock().toUtc();
      await db
          .into(db.gardens)
          .insert(
            GardensCompanion.insert(
              id: id,
              name: name,
              // Převzatá zahrada: starý čas, jméno ze serveru při stažení
              // vyhraje.
              createdAt: adopted ? DateTime.utc(2000) : now,
              updatedAt: adopted ? DateTime.utc(2000) : now,
            ),
          );
      await (db.delete(
        db.syncState,
      )..where((s) => s.name.equals('applying'))).go();
      if (adopted) {
        await writeState('paired', id);
        await writeState('onServer', id);
        await writeState('adoptedAt', now.toIso8601String());
      }
    });
  }

  Future<String?> readState(String name) async {
    final row = await (db.select(
      db.syncState,
    )..where((s) => s.name.equals(name))).getSingleOrNull();
    return row?.value;
  }

  Future<void> writeState(String name, String value) => db
      .into(db.syncState)
      .insertOnConflictUpdate(
        SyncStateCompanion.insert(name: name, value: Value(value)),
      );

  /// Počet změn čekajících na odeslání.
  Future<int> pendingCount() async {
    final count = db.syncOutbox.seq.count();
    final row = await (db.selectOnly(
      db.syncOutbox,
    )..addColumns([count])).getSingle();
    return row.read(count) ?? 0;
  }

  Future<Set<String>> _localColumns(String table) async {
    final cached = _columns[table];
    if (cached != null) return cached;
    final rows = await db.customSelect('PRAGMA table_info("$table")').get();
    return _columns[table] = {for (final r in rows) r.read<String>('name')};
  }

  Future<Map<String, Object?>?> _row(
    SyncTable table,
    Map<String, String> keys,
  ) async {
    final where = keys.keys.map((c) => '"$c" = ?').join(' AND ');
    final rows = await db
        .customSelect(
          'SELECT * FROM "${table.name}" WHERE $where',
          variables: [for (final v in keys.values) Variable.withString(v)],
        )
        .get();
    return rows.isEmpty ? null : rows.first.data;
  }

  DateTime? _time(Object? value) =>
      value is String ? DateTime.tryParse(value) : null;

  /// Řádky zapsané mimo Drift API: obrazovky se mají načíst znovu.
  void _notifyAll() {
    db.notifyUpdates({for (final t in db.allTables) TableUpdate.onTable(t)});
  }
}
