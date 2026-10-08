import 'package:zahradnik_boda/core/sync/sync_remote.dart';
import 'package:zahradnik_boda/core/sync/sync_tables.dart';

/// Paměťový „server“ pro testy synchronizace: poslední zápis vyhrává
/// podle `updated_at`, `server_updated_at` nastavuje server.
class FakeSyncRemote implements SyncRemote {
  final Map<String, Map<String, Map<String, Object?>>> tables = {};
  final Map<String, List<int>> files = {};
  final List<Map<String, Object?>> pushes = [];
  var _tick = 0;

  /// Bez připojení: všechna volání selžou.
  bool offline = false;

  void _check() {
    if (offline) throw const SyncException('offline', offline: true);
  }

  String _now() => DateTime.utc(
    2026,
    10,
    8,
  ).add(Duration(seconds: 10 * ++_tick)).toIso8601String();

  Map<String, Map<String, Object?>> table(String name) => tables[name] ??= {};

  @override
  Future<List<String>> gardenIds() async {
    _check();
    return [
      for (final g in table('gardens').values)
        if (g['deleted_at'] == null) g['id']! as String,
    ];
  }

  @override
  Future<void> push(Map<String, Object?> changes) async {
    _check();
    pushes.add(changes);
    for (final t in syncTables) {
      final rows = changes[t.name] as List<Map<String, Object?>>? ?? const [];
      for (final row in rows) {
        final key = t.pk.map((c) => '${row[c]}').join('|');
        final existing = table(t.name)[key];
        if (existing != null &&
            DateTime.parse(
              existing['updated_at']! as String,
            ).isAfter(DateTime.parse(row['updated_at']! as String))) {
          continue;
        }
        table(t.name)[key] = {
          ...?existing,
          ...row,
          'server_updated_at': _now(),
        };
      }
    }
    for (final d in (changes['deleted'] as List?) ?? const []) {
      final item = d as Map<String, Object?>;
      final t = syncTable(item['table']! as String);
      final keys = item['key']! as Map<String, Object?>;
      final key = t.pk.map((c) => '${keys[c]}').join('|');
      final existing = table(t.name)[key];
      if (existing == null || existing['deleted_at'] != null) continue;
      existing
        ..['deleted_at'] = item['at']
        ..['updated_at'] = item['at']
        ..['server_updated_at'] = _now();
    }
  }

  @override
  Future<List<Map<String, Object?>>> pull(
    String name, {
    required DateTime? since,
    String? gardenColumn,
    String? gardenId,
    int limit = 500,
  }) async {
    _check();
    final rows =
        [
          for (final r in table(name).values)
            if ((since == null ||
                    DateTime.parse(
                      r['server_updated_at']! as String,
                    ).isAfter(since)) &&
                (gardenColumn == null || r[gardenColumn] == gardenId))
              {
                ...r,
                // Server vrací i sloupce, které telefon nezná.
                'owner_id': 'user-1',
              },
        ]..sort(
          (a, b) => (a['server_updated_at']! as String).compareTo(
            b['server_updated_at']! as String,
          ),
        );
    return rows.take(limit).toList();
  }

  @override
  Future<void> uploadPhoto(String path, List<int> bytes) async {
    _check();
    files[path] = bytes;
  }

  @override
  Future<List<int>?> downloadPhoto(String path) async {
    _check();
    return files[path];
  }
}
