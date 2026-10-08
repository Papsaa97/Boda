import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/time/today.dart';
import '../domain/inventory_alerts.dart';
import '../domain/inventory_item.dart';
import '../domain/shopping_item.dart';
import '../domain/units.dart';

/// Položky skladu seřazené podle názvu.
class InventoryController extends AsyncNotifier<List<InventoryItem>> {
  @override
  Future<List<InventoryItem>> build() async =>
      _sorted(await ref.watch(inventoryRepositoryProvider).getAll());

  /// Uloží položku; prázdné id = nová položka. Vrací uloženou položku,
  /// nebo null při chybě úložiště.
  Future<InventoryItem?> save(InventoryItem item) async {
    final stored = item.id.isEmpty
        ? InventoryItem(
            id: ref.read(newIdProvider)(),
            category: item.category,
            name: item.name.trim(),
            unit: item.unit,
            stockQty: item.stockQty,
            lowStockThreshold: item.lowStockThreshold,
            details: item.details,
          )
        : item.copyWith(name: item.name.trim());
    await _mutate((list) async {
      await ref.read(inventoryRepositoryProvider).save(stored);
      return [...list.where((i) => i.id != stored.id), stored];
    });
    return state.hasError ? null : stored;
  }

  /// Přidá k zásobě [qty] v jednotce [unit] (převede na jednotku položky).
  /// Vrací false, když jednotky nejdou převést.
  Future<bool> addStock(String id, double qty, InventoryUnit unit) async {
    final item = _find(id);
    if (item == null) return false;
    final converted = unit.convert(qty, item.unit);
    if (converted == null) return false;
    final stock = item.stockQty + converted;
    await save(item.copyWith(stockQty: stock < 0 ? 0 : stock));
    return !state.hasError;
  }

  Future<void> delete(String id) async {
    await _mutate((list) async {
      await ref.read(inventoryRepositoryProvider).delete(id);
      return list.where((i) => i.id != id).toList();
    });
  }

  InventoryItem? _find(String id) => (state.value ?? const <InventoryItem>[])
      .where((i) => i.id == id)
      .firstOrNull;

  Future<void> _mutate(
    Future<List<InventoryItem>> Function(List<InventoryItem> current) op,
  ) async {
    final current = state.value ?? const <InventoryItem>[];
    state = await AsyncValue.guard(() async => _sorted(await op(current)));
  }

  static List<InventoryItem> _sorted(List<InventoryItem> items) =>
      [...items]
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
}

final inventoryControllerProvider =
    AsyncNotifierProvider<InventoryController, List<InventoryItem>>(
      InventoryController.new,
    );

/// Položka skladu podle id.
final inventoryItemProvider = Provider.family<InventoryItem?, String>((
  ref,
  id,
) {
  final items = ref.watch(inventoryControllerProvider).value ?? const [];
  return items.where((i) => i.id == id).firstOrNull;
});

/// Upozornění hlídače zásob pro dnešek (FR-S3).
final inventoryAlertsProvider = Provider<List<InventoryAlert>>((ref) {
  final items = ref.watch(inventoryControllerProvider).value ?? const [];
  return inventoryAlerts(items, ref.watch(todayProvider));
});

/// Nákupní seznam: nejdřív nekoupené, pak koupené.
class ShoppingController extends AsyncNotifier<List<ShoppingItem>> {
  @override
  Future<List<ShoppingItem>> build() async =>
      _sorted(await ref.watch(shoppingRepositoryProvider).getAll());

  /// Přidá položku. Pro položku skladu, která už na seznamu nekoupená je,
  /// nepřidá nic (hlídač ani Bóďa nevytvoří duplicitu).
  Future<void> add({
    required String name,
    double? qty,
    InventoryUnit? unit,
    String? itemId,
    ShoppingSource source = ShoppingSource.user,
  }) async {
    final current = state.value ?? const <ShoppingItem>[];
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    final duplicate = current.any(
      (s) =>
          !s.done &&
          (itemId != null
              ? s.itemId == itemId
              : s.name.toLowerCase() == trimmed.toLowerCase()),
    );
    if (duplicate) return;
    final item = ShoppingItem(
      id: ref.read(newIdProvider)(),
      name: trimmed,
      qty: qty,
      unit: unit,
      itemId: itemId,
      source: source,
    );
    await _mutate((list) async {
      await ref.read(shoppingRepositoryProvider).save(item);
      return [...list, item];
    });
  }

  /// Odškrtne položku. S [restock] přidá koupené množství do skladu
  /// (jen když je položka propojená a jednotky jdou převést).
  Future<void> setDone(String id, bool done, {bool restock = false}) async {
    final item = (state.value ?? const <ShoppingItem>[])
        .where((s) => s.id == id)
        .firstOrNull;
    if (item == null || item.done == done) return;
    final updated = item.copyWith(done: done);
    await _mutate((list) async {
      await ref.read(shoppingRepositoryProvider).save(updated);
      return [...list.where((s) => s.id != id), updated];
    });
    final itemId = item.itemId;
    final qty = item.qty;
    final unit = item.unit;
    if (restock && done && !state.hasError) {
      if (itemId != null && qty != null && unit != null) {
        await ref
            .read(inventoryControllerProvider.notifier)
            .addStock(itemId, qty, unit);
      }
    }
  }

  Future<void> delete(String id) async {
    await _mutate((list) async {
      await ref.read(shoppingRepositoryProvider).delete(id);
      return list.where((s) => s.id != id).toList();
    });
  }

  Future<void> clearDone() async {
    await _mutate((list) async {
      await ref.read(shoppingRepositoryProvider).clearDone();
      return list.where((s) => !s.done).toList();
    });
  }

  Future<void> _mutate(
    Future<List<ShoppingItem>> Function(List<ShoppingItem> current) op,
  ) async {
    final current = state.value ?? const <ShoppingItem>[];
    state = await AsyncValue.guard(() async => _sorted(await op(current)));
  }

  static List<ShoppingItem> _sorted(List<ShoppingItem> items) {
    final open = [
      for (final s in items)
        if (!s.done) s,
    ];
    final done = [
      for (final s in items)
        if (s.done) s,
    ];
    return [...open, ...done];
  }
}

final shoppingControllerProvider =
    AsyncNotifierProvider<ShoppingController, List<ShoppingItem>>(
      ShoppingController.new,
    );
