import 'package:flutter_test/flutter_test.dart';
import 'package:zahradnik_boda/core/database/app_database.dart';
import 'package:zahradnik_boda/features/inventory/data/drift_inventory_repository.dart';
import 'package:zahradnik_boda/features/inventory/domain/inventory_item.dart';
import 'package:zahradnik_boda/features/inventory/domain/shopping_item.dart';
import 'package:zahradnik_boda/features/inventory/domain/units.dart';
import 'package:zahradnik_boda/features/tasks/data/drift_task_repository.dart';
import 'package:zahradnik_boda/features/tasks/domain/task_entity.dart';
import 'package:zahradnik_boda/features/zones/data/drift_zone_repository.dart';
import 'package:zahradnik_boda/features/zones/domain/zone_entity.dart';

import '../../helpers/database.dart';
import '../../helpers/fakes.dart';

void main() {
  late AppDatabase db;
  late DriftInventoryRepository inventory;
  late DriftShoppingRepository shopping;
  late DriftTaskRepository tasks;
  late DriftZoneRepository zones;

  const seeds = InventoryItem(
    id: 'i1',
    category: InventoryCategory.seed,
    name: 'Mrkev Nantes',
    unit: InventoryUnit.pack,
    stockQty: 2,
  );
  const fertilizer = InventoryItem(
    id: 'i2',
    category: InventoryCategory.fertilizer,
    name: 'Cererit',
    unit: InventoryUnit.kg,
    stockQty: 2.5,
    lowStockThreshold: 1,
    details: FertilizerDetails(dose: LabelDose(60, InventoryUnit.g)),
  );

  setUp(() async {
    db = memoryDatabase();
    final gardenId = await db.ensureDefaultGarden(
      newId: () => 'g',
      now: testNow,
    );
    inventory = DriftInventoryRepository(db, gardenId, () => testNow);
    shopping = DriftShoppingRepository(db, gardenId, () => testNow);
    tasks = DriftTaskRepository(db, gardenId, () => testNow);
    zones = DriftZoneRepository(db, gardenId, () => testNow);
  });

  tearDown(() => db.close());

  test('inventory: save, update, soft delete', () async {
    await inventory.save(seeds);
    await inventory.save(fertilizer);
    await inventory.save(fertilizer.copyWith(stockQty: 1.5));
    expect(await inventory.getAll(), [
      fertilizer.copyWith(stockQty: 1.5),
      seeds,
    ]);

    await inventory.delete('i1');
    expect((await inventory.getAll()).map((i) => i.id), ['i2']);
    final row = await (db.select(
      db.inventoryItems,
    )..where((i) => i.id.equals('i1'))).getSingle();
    expect(row.deletedAt, isNotNull);
  });

  test('shopping list: save, tick, clear bought', () async {
    await inventory.save(fertilizer);
    const item = ShoppingItem(
      id: 's1',
      name: 'Cererit',
      qty: 5,
      unit: InventoryUnit.kg,
      itemId: 'i2',
    );
    await shopping.save(item);
    await shopping.save(const ShoppingItem(id: 's2', name: 'Provázek'));
    await shopping.save(item.copyWith(done: true));
    await shopping.clearDone();
    expect((await shopping.getAll()).map((s) => s.id), ['s2']);
  });

  test('task materials and tools round trip; removed material goes', () async {
    await inventory.save(seeds);
    await inventory.save(fertilizer);
    await zones.saveZone(const ZoneEntity(id: 'z', name: 'Zelenina'));
    final task = TaskEntity(
      id: 't',
      title: 'Vysít mrkev',
      zoneId: 'z',
      due: DateTime(2027, 4, 10),
      durationEstMin: 45,
      tools: const ['Motyčka', 'Provázek'],
      materials: const [
        TaskMaterial(itemId: 'i1', qty: 1, unit: 'pack'),
        TaskMaterial(itemId: 'i2', qty: 1.2, unit: 'kg'),
      ],
    );
    await tasks.saveTask(task);
    var loaded = (await tasks.getAllTasks()).single;
    expect(loaded.tools, ['Motyčka', 'Provázek']);
    expect(loaded.durationEstMin, 45);
    expect(loaded.materials, task.materials);

    await tasks.saveTask(task.copyWith(materials: [task.materials.last]));
    loaded = (await tasks.getAllTasks()).single;
    expect(loaded.materials, [task.materials.last]);

    // Materiál se vrátí i po předchozím odebrání.
    await tasks.saveTask(task);
    expect((await tasks.getAllTasks()).single.materials, hasLength(2));
  });

  test('used materials are recorded for the diary entry', () async {
    await inventory.save(fertilizer);
    final task = TaskEntity(
      id: 't',
      title: 'Přihnojit',
      due: DateTime(2027, 5, 1),
      materials: const [TaskMaterial(itemId: 'i2', qty: 600, unit: 'g')],
    );
    await zones.saveZone(const ZoneEntity(id: 'z', name: 'Zelenina'));
    await db
        .into(db.activities)
        .insert(
          ActivitiesCompanion.insert(
            id: 'a',
            gardenId: 'g',
            zoneId: 'z',
            type: 'fertilizing',
            title: 'Přihnojit',
            occurredAt: testNow.toUtc(),
            occurredTz: '+02:00',
            createdAt: testNow,
            updatedAt: testNow,
          ),
        );
    await tasks.recordMaterialsUsed(task, 'a');
    final rows = await db.select(db.activityMaterials).get();
    expect(rows.single.itemId, 'i2');
    expect(rows.single.qty, 600);
    expect(rows.single.unit, 'g');
  });
}
