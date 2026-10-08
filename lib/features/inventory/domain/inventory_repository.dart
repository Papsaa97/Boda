import 'inventory_item.dart';
import 'shopping_item.dart';

abstract interface class InventoryRepository {
  Future<List<InventoryItem>> getAll();
  Future<void> save(InventoryItem item);
  Future<void> delete(String id);
}

abstract interface class ShoppingRepository {
  Future<List<ShoppingItem>> getAll();
  Future<void> save(ShoppingItem item);
  Future<void> delete(String id);

  /// Smaže všechny odškrtnuté položky.
  Future<void> clearDone();
}
