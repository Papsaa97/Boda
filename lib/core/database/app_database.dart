import 'package:drift/drift.dart';

part 'app_database.g.dart';

/// Lokální databáze (Drift nad SQLite), spec kap. 8.2.
///
/// Tabulky a sloupce odpovídají serverovému schématu v Supabase (kap. 8.1,
/// snake_case), aby synchronizace v 1.0 byla 1 : 1. V 0.x je jedna
/// implicitní zahrada. Mazání je měkké (`deleted_at`), aby se v 1.0 dalo
/// propsat na ostatní zařízení.
///
/// Každá změna schématu = vyšší [AppDatabase.schemaVersion], krok
/// v [AppDatabase.migration], snímek v `drift_schemas/` a test.

@DataClassName('GardenRow')
class Gardens extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ZoneRow')
class Zones extends Table {
  TextColumn get id => text()();
  TextColumn get gardenId => text().references(Gardens, #id)();
  TextColumn get name => text()();

  /// Číselník `zone.type` (kap. 8.3).
  TextColumn get type => text().withDefault(const Constant('other'))();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();

  /// Pořadí v nabídce (menší první); null = podle názvu.
  IntColumn get sortOrder => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ActivityRow')
class Activities extends Table {
  TextColumn get id => text()();
  TextColumn get gardenId => text().references(Gardens, #id)();
  TextColumn get zoneId => text().references(Zones, #id)();

  /// Číselník `activity.type` (kap. 8.3).
  TextColumn get type => text()();
  TextColumn get title => text()();
  DateTimeColumn get occurredAt => dateTime()();

  /// Posun časové zóny v době činnosti, např. `+02:00` (kap. 7.3).
  TextColumn get occurredTz => text()();
  TextColumn get notes => text().nullable()();
  RealColumn get harvestQty => real().nullable()();
  TextColumn get harvestUnit => text().nullable()();
  RealColumn get costCzk => real().nullable()();
  TextColumn get taskId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('PhotoRow')
class Photos extends Table {
  TextColumn get id => text()();
  TextColumn get gardenId => text().references(Gardens, #id)();
  TextColumn get activityId => text().nullable().references(Activities, #id)();

  /// Cesta k souboru relativní ke složce dokumentů aplikace. Na server
  /// se neposílá (tam je `storage_path`).
  TextColumn get localPath => text()();

  /// Pořadí fotky v záznamu.
  IntColumn get position => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('TaskRow')
class Tasks extends Table {
  TextColumn get id => text()();
  TextColumn get gardenId => text().references(Gardens, #id)();
  TextColumn get title => text()();
  TextColumn get zoneId => text().nullable().references(Zones, #id)();

  /// Den termínu `YYYY-MM-DD` (v PostgreSQL typ `date`).
  TextColumn get due => text()();

  /// Čas připomínky v den termínu v minutách od půlnoci.
  IntColumn get remindAt => integer().nullable()();
  TextColumn get rrule => text().nullable()();
  TextColumn get snoozedUntil => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('open'))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  TextColumn get completedActivityId => text().nullable()();
  TextColumn get source => text().withDefault(const Constant('user'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Nastavení a příznaky aplikace (klíč → hodnota). V 1.0 se nastavení
/// synchronizuje jako `profiles.settings`.
@DataClassName('SettingRow')
class SettingEntries extends Table {
  @override
  String get tableName => 'app_settings';

  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(
  tables: [Gardens, Zones, Activities, Photos, Tasks, SettingEntries],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  Future<String?> readSetting(String key) async {
    final row = await (select(
      settingEntries,
    )..where((s) => s.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> writeSetting(String key, String? value) async {
    if (value == null) {
      await (delete(settingEntries)..where((s) => s.key.equals(key))).go();
    } else {
      await into(settingEntries).insertOnConflictUpdate(
        SettingEntriesCompanion.insert(key: key, value: value),
      );
    }
  }

  Future<Map<String, String>> readAllSettings() async {
    final rows = await select(settingEntries).get();
    return {for (final r in rows) r.key: r.value};
  }

  /// Id implicitní zahrady (v 0.x je jen jedna). Při prvním volání ji
  /// založí s novým UUID.
  Future<String> ensureDefaultGarden({
    required String Function() newId,
    required DateTime now,
    String name = 'Moje zahrada',
  }) async {
    final existing = await (select(gardens)..limit(1)).getSingleOrNull();
    if (existing != null) return existing.id;
    final id = newId();
    await into(gardens).insert(
      GardensCompanion.insert(
        id: id,
        name: name,
        createdAt: now,
        updatedAt: now,
      ),
    );
    return id;
  }
}
