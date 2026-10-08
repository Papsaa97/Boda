import 'package:flutter_test/flutter_test.dart';
import 'package:zahradnik_boda/features/inventory/domain/inventory_item.dart';
import 'package:zahradnik_boda/features/inventory/domain/shopping_item.dart';
import 'package:zahradnik_boda/features/inventory/domain/units.dart';
import 'package:zahradnik_boda/features/inventory/presentation/inventory_controller.dart';

import '../../helpers/fakes.dart';

void main() {
  const fertilizer = InventoryItem(
    id: 'i1',
    category: InventoryCategory.fertilizer,
    name: 'Cererit',
    unit: InventoryUnit.kg,
    stockQty: 0.5,
    lowStockThreshold: 1,
  );

  test('a low stock item goes on the shopping list once', () async {
    final shopping = InMemoryShoppingRepository();
    final c = makeContainer(
      inventory: InMemoryInventoryRepository([fertilizer]),
      shopping: shopping,
    );
    addTearDown(c.dispose);
    await c.read(inventoryControllerProvider.future);
    await c.read(shoppingControllerProvider.future);
    expect(c.read(inventoryAlertsProvider), hasLength(1));

    final controller = c.read(shoppingControllerProvider.notifier);
    for (var i = 0; i < 2; i++) {
      await controller.add(
        name: 'Cererit',
        itemId: 'i1',
        source: ShoppingSource.lowStock,
      );
    }
    expect(shopping.items.values.single.source, ShoppingSource.lowStock);
  });

  test('buying a linked item adds it to the stock', () async {
    final inventory = InMemoryInventoryRepository([fertilizer]);
    final c = makeContainer(
      inventory: inventory,
      shopping: InMemoryShoppingRepository(),
    );
    addTearDown(c.dispose);
    await c.read(inventoryControllerProvider.future);
    await c.read(shoppingControllerProvider.future);
    final shopping = c.read(shoppingControllerProvider.notifier);
    await shopping.add(
      name: 'Cererit',
      qty: 500,
      unit: InventoryUnit.g,
      itemId: 'i1',
    );
    final id = c.read(shoppingControllerProvider).value!.single.id;

    await shopping.setDone(id, true, restock: true);

    expect(inventory.items['i1']!.stockQty, 1.0);
    expect(c.read(inventoryAlertsProvider).single.item.stockQty, 1.0);
    expect(c.read(shoppingControllerProvider).value!.single.done, isTrue);
  });

  test('stock in incompatible units is not changed', () async {
    final inventory = InMemoryInventoryRepository([fertilizer]);
    final c = makeContainer(inventory: inventory);
    addTearDown(c.dispose);
    await c.read(inventoryControllerProvider.future);
    final ok = await c
        .read(inventoryControllerProvider.notifier)
        .addStock('i1', 1, InventoryUnit.l);
    expect(ok, isFalse);
    expect(inventory.items['i1']!.stockQty, 0.5);
  });

  test('a new item gets an id', () async {
    final inventory = InMemoryInventoryRepository();
    final c = makeContainer(inventory: inventory);
    addTearDown(c.dispose);
    await c.read(inventoryControllerProvider.future);
    final saved = await c
        .read(inventoryControllerProvider.notifier)
        .save(
          const InventoryItem(
            id: '',
            category: InventoryCategory.tool,
            name: '  Rýč ',
            unit: InventoryUnit.ks,
          ),
        );
    expect(saved!.id, 'id-1');
    expect(inventory.items['id-1']!.name, 'Rýč');
  });
}
