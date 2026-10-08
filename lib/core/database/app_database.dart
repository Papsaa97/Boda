import 'package:drift/drift.dart';

import 'app_database.steps.dart';

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

  // Vlastnosti zóny (1.0, schéma v2), číselníky podle kap. 8.3.
  RealColumn get areaM2 => real().nullable()();
  TextColumn get soilTexture => text().nullable()();
  RealColumn get ph => real().nullable()();

  /// Den měření pH `YYYY-MM-DD`.
  TextColumn get phMeasuredAt => text().nullable()();
  TextColumn get sunExposure => text().nullable()();
  TextColumn get irrigation => text().nullable()();
  BoolColumn get covered => boolean().withDefault(const Constant(false))();
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

  /// Od schématu 4 (synchronizace „poslední zápis vyhrává“); starší
  /// fotky ho dostaly podle `created_at`.
  DateTimeColumn get updatedAt => dateTime().nullable()();
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

  /// Odhad doby v minutách (FR-U7, schéma v2).
  IntColumn get durationEstMin => integer().nullable()();

  /// Nářadí jako JSON pole textů (v PostgreSQL `text[]`).
  TextColumn get tools => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Položka skladu (FR-S1, schéma v2).
@DataClassName('InventoryItemRow')
class InventoryItems extends Table {
  TextColumn get id => text()();
  TextColumn get gardenId => text().references(Gardens, #id)();

  /// `seed`, `fertilizer`, `plantProtection`, `tool`, `other`.
  TextColumn get category => text()();
  TextColumn get name => text()();

  /// `g`, `kg`, `ml`, `l`, `ks`, `pack`.
  TextColumn get unit => text()();
  RealColumn get stockQty => real().withDefault(const Constant(0))();
  RealColumn get lowStockThreshold => real().nullable()();

  /// Údaje podle kategorie jako JSON (v PostgreSQL `jsonb`).
  TextColumn get details => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Materiál potřebný k úkolu (FR-U7).
@DataClassName('TaskMaterialRow')
class TaskMaterials extends Table {
  TextColumn get taskId => text().references(Tasks, #id)();
  TextColumn get itemId => text().references(InventoryItems, #id)();
  TextColumn get gardenId => text().references(Gardens, #id)();
  RealColumn get qty => real()();
  TextColumn get unit => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {taskId, itemId};
}

/// Materiál spotřebovaný při činnosti (zapisuje se při dokončení úkolu;
/// automatický odpis ze skladu je až ve V2, FR-S4).
@DataClassName('ActivityMaterialRow')
class ActivityMaterials extends Table {
  TextColumn get activityId => text().references(Activities, #id)();
  TextColumn get itemId => text().references(InventoryItems, #id)();
  TextColumn get gardenId => text().references(Gardens, #id)();
  RealColumn get qty => real()();
  TextColumn get unit => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {activityId, itemId};
}

/// Nákupní seznam (z rad Bódi a z hlídače zásob).
@DataClassName('ShoppingItemRow')
class ShoppingItems extends Table {
  TextColumn get id => text()();
  TextColumn get gardenId => text().references(Gardens, #id)();
  TextColumn get name => text()();
  RealColumn get qty => real().nullable()();
  TextColumn get unit => text().nullable()();
  TextColumn get itemId => text().nullable().references(InventoryItems, #id)();
  BoolColumn get done => boolean().withDefault(const Constant(false))();

  /// `user`, `boda`, `lowStock`.
  TextColumn get source => text().withDefault(const Constant('user'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Rozhovor s Bóďou (spec 8.1 `assistant_threads`, ve výchozím stavu jen
/// v telefonu).
@DataClassName('AssistantThreadRow')
class AssistantThreads extends Table {
  TextColumn get id => text()();
  TextColumn get gardenId => text().nullable().references(Gardens, #id)();
  TextColumn get title => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Zpráva v rozhovoru s Bóďou.
@DataClassName('AssistantMessageRow')
class AssistantMessages extends Table {
  TextColumn get id => text()();
  TextColumn get threadId => text().references(AssistantThreads, #id)();

  /// `user` nebo `assistant`.
  TextColumn get role => text()();

  /// Na serveru sloupec `text` (synchronizace ho přejmenuje); `text` by se
  /// v generovaném kódu Driftu tloukl s metodou `Table.text()`.
  TextColumn get body => text()();

  /// Z čeho Bóďa vycházel, akce, upozornění a čerpání limitu (JSON).
  TextColumn get contextSummary => text().nullable()();

  /// Dotaz bez připojení čeká na odeslání (FR-B7): `pending`, `sent`,
  /// `failed`. Jen v telefonu.
  TextColumn get status => text().withDefault(const Constant('sent'))();

  /// `up` / `down` (FR-B6).
  TextColumn get feedback => text().nullable()();
  TextColumn get feedbackComment => text().nullable()();
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
  tables: [
    Gardens,
    Zones,
    Activities,
    Photos,
    Tasks,
    InventoryItems,
    TaskMaterials,
    ActivityMaterials,
    ShoppingItems,
    AssistantThreads,
    AssistantMessages,
    SettingEntries,
  ],
  include: {'sync.drift'},
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: stepByStep(
      // 1.0: vlastnosti zón, odhad doby a nářadí u úkolů, sklad,
      // materiály a nákupní seznam.
      from1To2: (m, schema) async {
        await m.addColumn(schema.zones, schema.zones.areaM2);
        await m.addColumn(schema.zones, schema.zones.soilTexture);
        await m.addColumn(schema.zones, schema.zones.ph);
        await m.addColumn(schema.zones, schema.zones.phMeasuredAt);
        await m.addColumn(schema.zones, schema.zones.sunExposure);
        await m.addColumn(schema.zones, schema.zones.irrigation);
        await m.addColumn(schema.zones, schema.zones.covered);
        await m.addColumn(schema.tasks, schema.tasks.durationEstMin);
        await m.addColumn(schema.tasks, schema.tasks.tools);
        await m.createTable(schema.inventoryItems);
        await m.createTable(schema.taskMaterials);
        await m.createTable(schema.activityMaterials);
        await m.createTable(schema.shoppingItems);
      },
      // 1.0: rozhovory s Bóďou.
      from2To3: (m, schema) async {
        await m.createTable(schema.assistantThreads);
        await m.createTable(schema.assistantMessages);
      },
      // 1.0: synchronizace – fronta změn, stav, čas změny fotek.
      from3To4: (m, schema) async {
        await m.addColumn(schema.photos, schema.photos.updatedAt);
        await m.database.customStatement(
          'UPDATE photos SET updated_at = created_at',
        );
        await m.createTable(schema.syncOutbox);
        await m.createTable(schema.syncState);
        for (final trigger in [
          schema.gardensOutboxInsert,
          schema.gardensOutboxUpdate,
          schema.gardensOutboxDelete,
          schema.zonesOutboxInsert,
          schema.zonesOutboxUpdate,
          schema.zonesOutboxDelete,
          schema.inventoryItemsOutboxInsert,
          schema.inventoryItemsOutboxUpdate,
          schema.inventoryItemsOutboxDelete,
          schema.tasksOutboxInsert,
          schema.tasksOutboxUpdate,
          schema.tasksOutboxDelete,
          schema.activitiesOutboxInsert,
          schema.activitiesOutboxUpdate,
          schema.activitiesOutboxDelete,
          schema.photosOutboxInsert,
          schema.photosOutboxUpdate,
          schema.photosOutboxDelete,
          schema.taskMaterialsOutboxInsert,
          schema.taskMaterialsOutboxUpdate,
          schema.taskMaterialsOutboxDelete,
          schema.activityMaterialsOutboxInsert,
          schema.activityMaterialsOutboxUpdate,
          schema.activityMaterialsOutboxDelete,
          schema.shoppingItemsOutboxInsert,
          schema.shoppingItemsOutboxUpdate,
          schema.shoppingItemsOutboxDelete,
          schema.assistantThreadsOutboxInsert,
          schema.assistantThreadsOutboxUpdate,
          schema.assistantThreadsOutboxDelete,
          schema.assistantMessagesOutboxInsert,
          schema.assistantMessagesOutboxUpdate,
          schema.assistantMessagesOutboxDelete,
        ]) {
          await m.create(trigger);
        }
      },
    ),
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
