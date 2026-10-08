import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/time/today.dart';
import '../domain/inventory_alerts.dart';
import '../domain/inventory_item.dart';
import '../../tasks/domain/task_entity.dart';
import '../domain/shopping_item.dart';
import '../domain/stock_movement.dart';
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
    final before = _find(stored.id)?.stockQty ?? 0;
    final delta = stored.stockQty - before;
    await _mutate((list) async {
      final repo = ref.read(inventoryRepositoryProvider);
      await repo.save(stored);
      // Ruční změna stavu se zapíše jako pohyb (historie položky).
      if (delta.abs() > 1e-9) {
        await repo.applyMovements([
          _movement(stored.id, delta, MovementReason.manual),
        ], adjustStock: false);
      }
      return [...list.where((i) => i.id != stored.id), stored];
    });
    if (!state.hasError) ref.invalidate(stockMovementsProvider(stored.id));
    return state.hasError ? null : stored;
  }

  StockMovement _movement(
    String itemId,
    double delta,
    MovementReason reason, {
    String? taskId,
  }) => StockMovement(
    id: ref.read(newIdProvider)(),
    itemId: itemId,
    qtyDelta: delta,
    reason: reason,
    taskId: taskId,
    at: ref.read(clockProvider)(),
  );

  /// Odepíše materiál hotového úkolu (FR-S4). Vrací null při chybě
  /// úložiště; úkol zůstane hotový.
  Future<Consumption?> consumeForTask(TaskEntity task) async {
    if (task.materials.isEmpty) return const Consumption();
    final repo = ref.read(inventoryRepositoryProvider);
    try {
      final consumption = planTaskConsumption(
        task: task,
        items: await repo.getAll(),
        existing: await repo.movements(taskId: task.id),
        now: ref.read(clockProvider)(),
        newId: ref.read(newIdProvider),
      );
      await repo.applyMovements(consumption.movements);
      if (consumption.movements.isNotEmpty) _refresh(consumption.movements);
      return consumption;
    } on Exception {
      return null;
    }
  }

  /// Úkol se vrátil mezi otevřené: odpis se stornuje (FR-S4).
  Future<void> reverseTask(String taskId) async {
    final repo = ref.read(inventoryRepositoryProvider);
    final reversal = planTaskReversal(
      taskId: taskId,
      existing: await repo.movements(taskId: taskId),
      now: ref.read(clockProvider)(),
      newId: ref.read(newIdProvider),
    );
    if (reversal.isEmpty) return;
    await repo.applyMovements(reversal);
    _refresh(reversal);
  }

  void _refresh(List<StockMovement> movements) {
    for (final id in {for (final m in movements) m.itemId}) {
      ref.invalidate(stockMovementsProvider(id));
    }
    ref.invalidateSelf();
  }

  /// Přidá k zásobě [qty] v jednotce [unit] (převede na jednotku položky).
  /// Vrací false, když jednotky nejdou převést.
  Future<bool> addStock(String id, double qty, InventoryUnit unit) async {
    final item = _find(id);
    if (item == null) return false;
    final converted = unit.convert(qty, item.unit);
    if (converted == null) return false;
    await _mutate((list) async {
      final repo = ref.read(inventoryRepositoryProvider);
      await repo.applyMovements([
        _movement(id, converted, MovementReason.purchase),
      ]);
      return repo.getAll();
    });
    if (!state.hasError) ref.invalidate(stockMovementsProvider(id));
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

/// Historie pohybů položky skladu, od nejnovějšího.
final stockMovementsProvider =
    FutureProvider.family<List<StockMovement>, String>(
      (ref, itemId) =>
          ref.watch(inventoryRepositoryProvider).movements(itemId: itemId),
    );
