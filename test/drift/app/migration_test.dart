// dart format width=80
import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zahradnik_boda/core/database/app_database.dart';

import 'generated/schema.dart';
import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;

/// Migrace schématu lokální databáze (NFR-2, spec 8.2): každá verze ze
/// snímku v `drift_schemas/` se musí převést na každou novější a data
/// z předchozí verze se zachovají.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('schema migrates', () {
    const versions = GeneratedHelper.versions;
    for (final (i, fromVersion) in versions.indexed) {
      for (final toVersion in versions.skip(i + 1)) {
        test('from $fromVersion to $toVersion', () async {
          final schema = await verifier.schemaAt(fromVersion);
          final db = AppDatabase(schema.newConnection());
          await verifier.migrateAndValidate(db, toVersion);
          await db.close();
        });
      }
    }
  });

  test('v1 data survive the upgrade to v2', () async {
    const t = '2026-10-07T08:00:00.000Z';
    const garden = v1.GardensData(
      id: 'g',
      name: 'Moje zahrada',
      createdAt: t,
      updatedAt: t,
    );
    const zone = v1.ZonesData(
      id: 'z',
      gardenId: 'g',
      name: 'Zelenina',
      type: 'vegetable',
      archived: 0,
      sortOrder: 1,
      createdAt: t,
      updatedAt: t,
    );
    const task = v1.TasksData(
      id: 't',
      gardenId: 'g',
      title: 'Zazimovat hadice',
      zoneId: 'z',
      due: '2026-10-25',
      remindAt: 600,
      rrule: 'FREQ=YEARLY',
      status: 'open',
      source: 'user',
      createdAt: t,
      updatedAt: t,
    );

    await verifier.testWithDataIntegrity(
      oldVersion: 1,
      newVersion: 2,
      createOld: v1.DatabaseAtV1.new,
      createNew: v2.DatabaseAtV2.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch.insert(oldDb.gardens, garden);
        batch.insert(oldDb.zones, zone);
        batch.insert(oldDb.tasks, task);
      },
      validateItems: (newDb) async {
        expect(await newDb.select(newDb.zones).get(), [
          const v2.ZonesData(
            id: 'z',
            gardenId: 'g',
            name: 'Zelenina',
            type: 'vegetable',
            archived: 0,
            sortOrder: 1,
            covered: 0,
            createdAt: t,
            updatedAt: t,
          ),
        ]);
        expect(await newDb.select(newDb.tasks).get(), [
          const v2.TasksData(
            id: 't',
            gardenId: 'g',
            title: 'Zazimovat hadice',
            zoneId: 'z',
            due: '2026-10-25',
            remindAt: 600,
            rrule: 'FREQ=YEARLY',
            status: 'open',
            source: 'user',
            createdAt: t,
            updatedAt: t,
          ),
        ]);
        expect(await newDb.select(newDb.inventoryItems).get(), isEmpty);
      },
    );
  });
}
