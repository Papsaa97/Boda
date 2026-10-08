import 'inventory_item.dart';
import 'shopping_item.dart';
import 'stock_movement.dart';

abstract interface class InventoryRepository {
  Future<List<InventoryItem>> getAll();
  Future<void> save(InventoryItem item);
  Future<void> delete(String id);

  /// Pohyby na skladě, volitelně jen jedné položky nebo jednoho úkolu,
  /// od nejnovějšího.
  Future<List<StockMovement>> movements({String? itemId, String? taskId});

  /// Zapíše pohyby a v jedné transakci podle nich upraví stav položek
  /// (nikdy pod nulu). S [adjustStock] = false jen zapíše pohyby (stav
  /// už uložil formulář).
  Future<void> applyMovements(
    List<StockMovement> movements, {
    bool adjustStock = true,
  });
}

abstract interface class ShoppingRepository {
  Future<List<ShoppingItem>> getAll();
  Future<void> save(ShoppingItem item);
  Future<void> delete(String id);

  /// Smaže všechny odškrtnuté položky.
  Future<void> clearDone();
}
