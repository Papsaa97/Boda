import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:drift/drift.dart' show InsertMode, Value;
import 'package:path/path.dart' as p;

import '../../../core/database/app_database.dart';
import '../../../core/photos/photo_storage.dart';
import '../../../core/time/calendar.dart';
import '../../activity/data/drift_activity_repository.dart';
import '../../activity/domain/activity_entity.dart';
import '../../inventory/data/drift_inventory_repository.dart';
import '../../inventory/domain/shopping_item.dart';
import '../../tasks/data/drift_task_repository.dart';
import '../../zones/data/drift_zone_repository.dart';
import '../domain/backup_format.dart';

/// Export a import celého deníku do ZIP (FR-E1, FR-E2, spec 8.4).
///
/// ZIP obsahuje `data.json` a složku `photos/`. Formát popisuje
/// `docs/FORMAT_EXPORTU.md`. Na webu záloha není (chybí souborový
/// systém, DECLOG).
class BackupService {
  BackupService({
    required AppDatabase db,
    required String gardenId,
    required PhotoStorage photos,
    required DateTime Function() clock,
  }) : _db = db,
       _gardenId = gardenId,
       _photos = photos,
       _clock = clock;

  final AppDatabase _db;
  final String _gardenId;
  final PhotoStorage _photos;
  final DateTime Function() _clock;

  /// Název souboru podle spec 8.4: `boda-export-YYYY-MM-DD.zip`.
  static String fileName(DateTime now) =>
      'boda-export-${formatDateKey(now)}.zip';

  /// Načte všechna data z databáze.
  Future<BackupData> collect({required String appVersion}) async {
    final zones = await DriftZoneRepository(
      _db,
      _gardenId,
      _clock,
    ).getAllZones();
    final activities = await DriftActivityRepository(
      _db,
      _gardenId,
      _clock,
    ).getAllActivities();
    final tasks = await DriftTaskRepository(
      _db,
      _gardenId,
      _clock,
    ).getAllTasks();
    final inventory = await DriftInventoryRepository(
      _db,
      _gardenId,
      _clock,
    ).getAll();
    final shopping = await DriftShoppingRepository(
      _db,
      _gardenId,
      _clock,
    ).getAll();
    final materialRows = await (_db.select(
      _db.activityMaterials,
    )..where((m) => m.deletedAt.isNull())).get();
    return BackupData(
      formatVersion: backupFormatVersion,
      exportedAt: _clock(),
      appVersion: appVersion,
      zones: zones,
      // Fotky, jejichž soubor zmizel, se do zálohy nedají přibalit.
      activities: [
        for (final a in activities)
          a.copyWith(
            photos: [
              for (final photo in a.photos)
                if (_fileOf(photo) != null) photo,
            ],
          ),
      ],
      tasks: tasks,
      inventory: inventory,
      shopping: shopping,
      activityMaterials: [
        for (final m in materialRows)
          ActivityMaterialRecord(
            activityId: m.activityId,
            itemId: m.itemId,
            qty: m.qty,
            unit: m.unit,
          ),
      ],
    );
  }

  /// Vytvoří ZIP v [directory] a vrátí cestu k němu.
  Future<String> export({
    required String directory,
    required String appVersion,
  }) async {
    final data = await collect(appVersion: appVersion);
    final path = p.join(directory, fileName(data.exportedAt));
    final zip = ZipFileEncoder()..create(path);
    try {
      zip.addArchiveFile(
        ArchiveFile.string(
          'data.json',
          const JsonEncoder.withIndent('  ').convert(encodeBackup(data)),
        ),
      );
      for (final photo in data.photos) {
        // JPEG se už nekomprimuje, jen ukládá.
        await zip.addFile(_fileOf(photo)!, backupPhotoPath(photo), 0);
      }
    } finally {
      await zip.close();
    }
    return path;
  }

  /// Přečte a zkontroluje zálohu. Nic nemění.
  Future<BackupData> read(String zipPath) async {
    final input = InputFileStream(zipPath);
    try {
      final Archive archive;
      try {
        archive = ZipDecoder().decodeStream(input);
      } catch (_) {
        throw const BackupException(BackupError.notABackup);
      }
      final json = archive.find('data.json');
      if (json == null) throw const BackupException(BackupError.notABackup);
      final Object? decoded;
      try {
        decoded = jsonDecode(utf8.decode(json.content));
      } catch (e) {
        throw BackupException(BackupError.corrupted, '$e');
      }
      if (decoded is! Map) throw const BackupException(BackupError.corrupted);
      final data = decodeBackup(decoded.cast<String, Object?>());
      _validate(data);
      return data;
    } finally {
      await input.close();
    }
  }

  /// Nahradí všechna data obsahem zálohy (varianta „nahradit vše“).
  ///
  /// Fotky se nejdřív vybalí, pak se v jedné transakci vymění data.
  /// Když transakce selže, stará data zůstanou; vybalené fotky navíc
  /// nevadí (smažou se při příští obnově).
  Future<void> restore(String zipPath, BackupData data) async {
    final restored = await _extractPhotos(zipPath, data);
    final now = _clock().toUtc();
    final zoneIds = {for (final z in data.zones) z.id};

    final itemIds = {for (final i in data.inventory) i.id};
    final activityIds = {for (final a in data.activities) a.id};

    await _db.transaction(() async {
      // Pořadí kvůli cizím klíčům: nejdřív tabulky, které odkazují.
      await _db.delete(_db.taskMaterials).go();
      await _db.delete(_db.activityMaterials).go();
      await _db.delete(_db.shoppingItems).go();
      await _db.delete(_db.photos).go();
      await _db.delete(_db.activities).go();
      await _db.delete(_db.tasks).go();
      await _db.delete(_db.inventoryItems).go();
      await _db.delete(_db.zones).go();

      var order = 0;
      for (final z in data.zones) {
        await _db
            .into(_db.zones)
            .insert(
              ZonesCompanion.insert(
                id: z.id,
                gardenId: _gardenId,
                name: z.name,
                type: Value(z.type.name),
                archived: Value(z.archived),
                sortOrder: Value(order++),
                areaM2: Value(z.areaM2),
                soilTexture: Value(z.soilTexture?.name),
                ph: Value(z.ph),
                phMeasuredAt: Value(
                  z.phMeasuredAt == null
                      ? null
                      : formatDateKey(z.phMeasuredAt!),
                ),
                sunExposure: Value(z.sunExposure?.name),
                irrigation: Value(z.irrigation?.name),
                covered: Value(z.covered),
                createdAt: now,
                updatedAt: now,
              ),
            );
      }
      final inventory = DriftInventoryRepository(_db, _gardenId, _clock);
      for (final i in data.inventory) {
        await inventory.save(i);
      }
      final shopping = DriftShoppingRepository(_db, _gardenId, _clock);
      for (final s in data.shopping) {
        await shopping.save(
          s.itemId == null || itemIds.contains(s.itemId)
              ? s
              : ShoppingItem(
                  id: s.id,
                  name: s.name,
                  qty: s.qty,
                  unit: s.unit,
                  done: s.done,
                  source: s.source,
                ),
        );
      }
      final activities = DriftActivityRepository(_db, _gardenId, _clock);
      for (final a in data.activities) {
        await activities.addActivity(
          a.copyWith(
            photos: [
              for (final photo in a.photos)
                if (restored[photo.id] case final path?)
                  PhotoRef(id: photo.id, path: path),
            ],
          ),
        );
      }
      final tasks = DriftTaskRepository(_db, _gardenId, _clock);
      for (final t in data.tasks) {
        final zoneId = t.zoneId;
        // Úkol bez existující zóny se načte bez zóny, materiál bez
        // položky skladu se vynechá.
        await tasks.saveTask(
          t.copyWith(
            zoneId: () =>
                zoneId == null || zoneIds.contains(zoneId) ? zoneId : null,
            materials: [
              for (final m in t.materials)
                if (itemIds.contains(m.itemId)) m,
            ],
          ),
        );
      }
      for (final m in data.activityMaterials) {
        if (!itemIds.contains(m.itemId) ||
            !activityIds.contains(m.activityId)) {
          continue;
        }
        await _db
            .into(_db.activityMaterials)
            .insert(
              ActivityMaterialsCompanion.insert(
                activityId: m.activityId,
                itemId: m.itemId,
                gardenId: _gardenId,
                qty: m.qty,
                unit: m.unit,
                createdAt: now,
                updatedAt: now,
              ),
              mode: InsertMode.insertOrReplace,
            );
      }
    });

    await _photos.deleteAllExcept(restored.values.toSet());
  }

  /// Vybalí fotky ze ZIP do složky aplikace. Vrací photoId → relativní
  /// cesta; fotky, které v ZIP chybí, vynechá.
  Future<Map<String, String>> _extractPhotos(
    String zipPath,
    BackupData data,
  ) async {
    final result = <String, String>{};
    final input = InputFileStream(zipPath);
    try {
      final archive = ZipDecoder().decodeStream(input);
      for (final photo in data.photos) {
        final file = archive.find(photo.path);
        if (file == null || !file.isFile) continue;
        final name = p.posix.basename(photo.path);
        final output = OutputFileStream(await _photos.prepareFile(name));
        try {
          file.decompress(output);
        } finally {
          await output.close();
        }
        result[photo.id] = _photos.relativePathFor(name);
      }
    } finally {
      await input.close();
    }
    return result;
  }

  File? _fileOf(PhotoRef photo) {
    final path = _photos.resolve(photo.path);
    if (path == null) return null;
    final file = File(path);
    return file.existsSync() ? file : null;
  }

  static void _validate(BackupData data) {
    final zoneIds = {for (final z in data.zones) z.id};
    if (zoneIds.length != data.zones.length) {
      throw const BackupException(BackupError.corrupted, 'duplicate zone');
    }
    for (final a in data.activities) {
      if (!zoneIds.contains(a.zoneId)) {
        throw BackupException(BackupError.corrupted, 'zone ${a.zoneId}');
      }
      for (final photo in a.photos) {
        // Cesta uvnitř ZIP nesmí vést mimo složku fotek.
        if (!p.posix.isWithin(
          backupPhotoFolder,
          p.posix.normalize(photo.path),
        )) {
          throw BackupException(BackupError.corrupted, photo.path);
        }
      }
    }
  }
}
