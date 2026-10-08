import 'package:flutter_test/flutter_test.dart';
import 'package:zahradnik_boda/features/inventory/data/drift_inventory_repository.dart';
import 'package:zahradnik_boda/features/inventory/domain/inventory_item.dart';
import 'package:zahradnik_boda/features/inventory/domain/stock_movement.dart';
import 'package:zahradnik_boda/features/inventory/domain/units.dart';
import 'package:zahradnik_boda/features/inventory/presentation/inventory_controller.dart';
import 'package:zahradnik_boda/features/inventory/presentation/inventory_ui.dart';
import 'package:zahradnik_boda/features/tasks/domain/task_entity.dart';
import 'package:zahradnik_boda/features/tasks/presentation/tasks_controller.dart';
import 'package:zahradnik_boda/l10n/app_localizations_cs.dart';

import '../../helpers/database.dart';
import '../../helpers/fakes.dart';

const _cererit = InventoryItem(
  id: 'i1',
  category: InventoryCategory.fertilizer,
  name: 'Cererit',
  unit: InventoryUnit.kg,
  stockQty: 2,
);
const _postrik = InventoryItem(
  id: 'i2',
  category: InventoryCategory.other,
  name: 'Postřik',
  unit: InventoryUnit.l,
  stockQty: 0.5,
);

TaskEntity _task({List<TaskMaterial> materials = const []}) => TaskEntity(
  id: 't1',
  title: 'Pohnojit',
  due: DateTime(2026, 10, 7),
  materials: materials,
);

void main() {
  group('planTaskConsumption', () {
    test('converts units and deducts', () {
      final c = planTaskConsumption(
        task: _task(
          materials: const [TaskMaterial(itemId: 'i1', qty: 600, unit: 'g')],
        ),
        items: const [_cererit],
        existing: const [],
        now: testNow,
        newId: sequentialIds(),
      );
      expect(c.movements.single.qtyDelta, -0.6);
      expect(c.movements.single.reason, MovementReason.task);
      expect(c.movements.single.taskId, 't1');
      expect(
        c.consumed.single,
        const StockLine(itemName: 'Cererit', qty: 0.6, unit: InventoryUnit.kg),
      );
      expect(c.shortages, isEmpty);
    });

    test('never goes below zero, reports the shortage', () {
      final c = planTaskConsumption(
        task: _task(
          materials: const [TaskMaterial(itemId: 'i2', qty: 800, unit: 'ml')],
        ),
        items: const [_postrik],
        existing: const [],
        now: testNow,
        newId: sequentialIds(),
      );
      expect(c.movements.single.qtyDelta, -0.5);
      expect(
        c.shortages.single,
        const StockLine(itemName: 'Postřik', qty: 0.3, unit: InventoryUnit.l),
      );
    });

    test('skips other quantities and missing items', () {
      final c = planTaskConsumption(
        task: _task(
          materials: const [
            TaskMaterial(itemId: 'i1', qty: 1, unit: 'l'),
            TaskMaterial(itemId: 'gone', qty: 1, unit: 'kg'),
          ],
        ),
        items: const [_cererit],
        existing: const [],
        now: testNow,
        newId: sequentialIds(),
      );
      expect(c.movements, isEmpty);
      expect(c.skipped, ['Cererit', 'gone']);
    });

    test('a deducted task is not deducted twice; reversal undoes it', () {
      final first = planTaskConsumption(
        task: _task(
          materials: const [TaskMaterial(itemId: 'i1', qty: 1, unit: 'kg')],
        ),
        items: const [_cererit],
        existing: const [],
        now: testNow,
        newId: sequentialIds(),
      );
      final again = planTaskConsumption(
        task: _task(
          materials: const [TaskMaterial(itemId: 'i1', qty: 1, unit: 'kg')],
        ),
        items: const [_cererit],
        existing: first.movements,
        now: testNow,
        newId: sequentialIds(),
      );
      expect(again.isEmpty, isTrue);

      final reversal = planTaskReversal(
        taskId: 't1',
        existing: first.movements,
        now: testNow,
        newId: () => 'r1',
      );
      expect(reversal.single.qtyDelta, 1);
      expect(reversal.single.reason, MovementReason.reversal);
      expect(
        netTaskMovements([...first.movements, ...reversal], 't1'),
        isEmpty,
      );
      expect(
        planTaskReversal(
          taskId: 't1',
          existing: [...first.movements, ...reversal],
          now: testNow,
          newId: () => 'r2',
        ),
        isEmpty,
      );
    });
  });

  test('consumption text lists what was deducted and what is missing', () {
    final l = AppLocalizationsCs();
    final text = consumptionText(
      l,
      const Consumption(
        consumed: [
          StockLine(itemName: 'Cererit', qty: 1.2, unit: InventoryUnit.kg),
        ],
        shortages: [
          StockLine(itemName: 'Postřik', qty: 0.3, unit: InventoryUnit.l),
        ],
      ),
    );
    expect(text, contains('Cererit 1,2'));
    expect(text, contains('Postřik 0,3'));
    expect(consumptionText(l, const Consumption()), isNull);
  });

  test('Drift applies movements in one transaction, clamped at zero', () async {
    final db = memoryDatabase();
    addTearDown(db.close);
    final gardenId = await db.ensureDefaultGarden(
      newId: sequentialIds(),
      now: testNow,
    );
    final repo = DriftInventoryRepository(db, gardenId, () => testNow);
    await repo.save(_cererit);
    await repo.applyMovements([
      StockMovement(
        id: 'm1',
        itemId: 'i1',
        qtyDelta: -0.5,
        reason: MovementReason.manual,
        at: testNow,
      ),
      StockMovement(
        id: 'm2',
        itemId: 'i1',
        qtyDelta: -5,
        reason: MovementReason.manual,
        at: testNow.add(const Duration(minutes: 1)),
      ),
    ]);
    expect((await repo.getAll()).single.stockQty, 0);
    final movements = await repo.movements(itemId: 'i1');
    expect(movements.map((m) => m.id), ['m2', 'm1']);
    await repo.applyMovements([
      StockMovement(
        id: 'm3',
        itemId: 'i1',
        qtyDelta: 3,
        reason: MovementReason.purchase,
        at: testNow,
      ),
    ], adjustStock: false);
    expect((await repo.getAll()).single.stockQty, 0);
    expect(await repo.movements(taskId: 'x'), isEmpty);
    final outbox = await db.select(db.syncOutbox).get();
    expect(
      outbox.where((o) => o.entity == 'inventory_movements'),
      hasLength(3),
    );
  });

  group('controllers', () {
    late InMemoryInventoryRepository inventory;
    late InMemoryTaskRepository tasks;

    setUp(() {
      inventory = InMemoryInventoryRepository([_cererit]);
      tasks = InMemoryTaskRepository([
        _task(
          materials: const [TaskMaterial(itemId: 'i1', qty: 500, unit: 'g')],
        ),
      ]);
    });

    test('completing a task deducts, reopening reverses (FR-S4)', () async {
      final c = makeContainer(inventory: inventory, tasks: tasks);
      addTearDown(c.dispose);
      await c.read(tasksControllerProvider.future);
      await c.read(inventoryControllerProvider.future);
      final closure = await c
          .read(tasksControllerProvider.notifier)
          .close('t1', TaskStatus.done);
      expect(closure!.consumption.consumed.single.qty, 0.5);
      expect(inventory.items['i1']!.stockQty, 1.5);
      expect(
        (await c.read(inventoryControllerProvider.future)).single.stockQty,
        1.5,
      );

      await c.read(tasksControllerProvider.notifier).reopen('t1');
      expect(inventory.items['i1']!.stockQty, 2);
      expect(inventory.movementLog.map((m) => m.reason), [
        MovementReason.task,
        MovementReason.reversal,
      ]);
    });

    test('skipping a task deducts nothing', () async {
      final c = makeContainer(inventory: inventory, tasks: tasks);
      addTearDown(c.dispose);
      await c.read(tasksControllerProvider.future);
      final closure = await c
          .read(tasksControllerProvider.notifier)
          .close('t1', TaskStatus.skipped);
      expect(closure!.consumption.isEmpty, isTrue);
      expect(inventory.items['i1']!.stockQty, 2);
    });

    test('purchases and manual edits are recorded', () async {
      final c = makeContainer(inventory: inventory);
      addTearDown(c.dispose);
      await c.read(inventoryControllerProvider.future);
      final ctrl = c.read(inventoryControllerProvider.notifier);
      expect(await ctrl.addStock('i1', 500, InventoryUnit.g), isTrue);
      expect(inventory.items['i1']!.stockQty, 2.5);
      await ctrl.save(inventory.items['i1']!.copyWith(stockQty: 1));
      expect(inventory.items['i1']!.stockQty, 1);
      final history = await c.read(stockMovementsProvider('i1').future);
      expect(history.map((m) => (m.reason, m.qtyDelta)), [
        (MovementReason.manual, -1.5),
        (MovementReason.purchase, 0.5),
      ]);
    });
  });
}
