import 'dart:convert';

/// Jak se hodnota sloupce liší mezi SQLite v telefonu a PostgreSQL.
enum SyncKind {
  /// Čas: v telefonu ISO text v UTC, na serveru `timestamptz`.
  timestamp,

  /// Pravdivostní hodnota: v telefonu 0/1, na serveru `boolean`.
  boolean,

  /// JSON uložený jako text, na serveru `jsonb`.
  json,

  /// JSON objekt, na serveru povinný (`null` = `{}`).
  jsonObject,

  /// Pole textů uložené jako JSON text, na serveru `text[]`.
  textList,
}

/// Synchronizovaná tabulka (spec 7.4, DECLOG D69).
class SyncTable {
  const SyncTable(
    this.name, {
    this.pk = const ['id'],
    this.gardenColumn = 'garden_id',
    this.kinds = const {},
    this.localOnly = const {},
    this.renames = const {},
  });

  final String name;
  final List<String> pk;

  /// Sloupec, podle kterého se stahuje jen tahle zahrada; null = jen
  /// podle RLS (rozhovory s Bóďou patří uživateli, ne zahradě).
  final String? gardenColumn;

  /// Sloupce s jiným tvarem než prostý text nebo číslo.
  final Map<String, SyncKind> kinds;

  /// Sloupce jen v telefonu; na server se neposílají.
  final Set<String> localOnly;

  /// Jiný název sloupce na serveru (telefon → server).
  final Map<String, String> renames;

  /// Klíč řádku ve frontě změn (hodnoty primárního klíče spojené `|`).
  String keyOf(Map<String, Object?> row) =>
      pk.map((c) => '${row[c]}').join('|');

  /// Hodnoty primárního klíče z klíče ve frontě.
  Map<String, String> keyValues(String rowKey) {
    final parts = rowKey.split('|');
    return {for (var i = 0; i < pk.length; i++) pk[i]: parts[i]};
  }

  /// Řádek z telefonu ve tvaru pro server.
  Map<String, Object?> toServer(Map<String, Object?> local) {
    final out = <String, Object?>{};
    for (final e in local.entries) {
      if (localOnly.contains(e.key)) continue;
      out[renames[e.key] ?? e.key] = _toServerValue(kinds[e.key], e.value);
    }
    return out;
  }

  /// Řádek ze serveru ve tvaru pro telefon; jen sloupce [localColumns].
  Map<String, Object?> toLocal(
    Map<String, Object?> server,
    Set<String> localColumns,
  ) {
    final back = {for (final e in renames.entries) e.value: e.key};
    final out = <String, Object?>{};
    for (final e in server.entries) {
      final column = back[e.key] ?? e.key;
      if (!localColumns.contains(column) || localOnly.contains(column)) {
        continue;
      }
      out[column] = _toLocalValue(kinds[column], e.value);
    }
    return out;
  }
}

const _times = {
  'created_at': SyncKind.timestamp,
  'updated_at': SyncKind.timestamp,
  'deleted_at': SyncKind.timestamp,
};

/// Tabulky v pořadí cizích klíčů (rodiče dřív).
const syncTables = <SyncTable>[
  SyncTable(
    'gardens',
    gardenColumn: 'id',
    kinds: {..._times, 'bounds': SyncKind.json},
  ),
  SyncTable(
    'zones',
    kinds: {
      ..._times,
      'archived': SyncKind.boolean,
      'covered': SyncKind.boolean,
      'polygon': SyncKind.json,
    },
  ),
  SyncTable('incidents', kinds: {..._times, 'candidates': SyncKind.json}),
  SyncTable(
    'builds',
    kinds: {..._times, 'params': SyncKind.jsonObject, 'prices': SyncKind.json},
  ),
  SyncTable(
    'inventory_items',
    kinds: {..._times, 'details': SyncKind.jsonObject},
  ),
  SyncTable(
    'tasks',
    kinds: {
      ..._times,
      'completed_at': SyncKind.timestamp,
      'tools': SyncKind.textList,
    },
  ),
  SyncTable(
    'activities',
    kinds: {..._times, 'occurred_at': SyncKind.timestamp},
  ),
  SyncTable('photos', kinds: _times, localOnly: {'local_path'}),
  SyncTable(
    'inventory_movements',
    kinds: {..._times, 'at': SyncKind.timestamp},
  ),
  SyncTable('task_materials', pk: ['task_id', 'item_id'], kinds: _times),
  SyncTable(
    'activity_materials',
    pk: ['activity_id', 'item_id'],
    kinds: _times,
  ),
  SyncTable('shopping_items', kinds: {..._times, 'done': SyncKind.boolean}),
  SyncTable('assistant_threads', gardenColumn: null, kinds: _times),
  SyncTable(
    'assistant_messages',
    gardenColumn: null,
    kinds: {..._times, 'context_summary': SyncKind.json},
    localOnly: {'status'},
    renames: {'body': 'text'},
  ),
];

SyncTable syncTable(String name) =>
    syncTables.firstWhere((t) => t.name == name);

Object? _decode(Object? value) {
  if (value is! String) return value;
  try {
    return jsonDecode(value);
  } on FormatException {
    return null;
  }
}

Object? _toServerValue(SyncKind? kind, Object? value) => switch (kind) {
  SyncKind.boolean => value == null ? null : value == 1 || value == true,
  SyncKind.json => _decode(value),
  SyncKind.jsonObject => switch (_decode(value)) {
    final Map<String, Object?> map => map,
    _ => const <String, Object?>{},
  },
  SyncKind.textList => switch (_decode(value)) {
    final List<Object?> list => [
      for (final v in list)
        if (v is String) v,
    ],
    _ => null,
  },
  SyncKind.timestamp => value is String ? normalizeTimestamp(value) : value,
  null => value,
};

Object? _toLocalValue(SyncKind? kind, Object? value) => switch (kind) {
  SyncKind.boolean => value == null ? null : (value == true ? 1 : 0),
  SyncKind.json ||
  SyncKind.jsonObject ||
  SyncKind.textList => value == null ? null : jsonEncode(value),
  SyncKind.timestamp => value is String ? normalizeTimestamp(value) : value,
  null => value is bool ? (value ? 1 : 0) : value,
};

/// Čas ve tvaru, jak ho ukládá Drift (`2026-10-01T10:00:00.000Z`).
String normalizeTimestamp(String value) {
  final parsed = DateTime.tryParse(value);
  return parsed == null ? value : parsed.toUtc().toIso8601String();
}
