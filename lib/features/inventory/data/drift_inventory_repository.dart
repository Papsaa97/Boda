import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/inventory_item.dart';
import '../domain/inventory_repository.dart';
import '../domain/shopping_item.dart';
import '../domain/units.dart';

/// Sklad v lokální databázi. Mazání je měkké (`deleted_at`).
class DriftInventoryRepository implements InventoryRepository {
  DriftInventoryRepository(this._db, this._gardenId, this._clock);

  final AppDatabase _db;
  final String _gardenId;
  final DateTime Function() _clock;

  @override
  Future<List<InventoryItem>> getAll() async {
    final rows =
        await (_db.select(_db.inventoryItems)
              ..where((i) => i.deletedAt.isNull())
              ..orderBy([(i) => OrderingTerm(expression: i.name)]))
            .get();
    return [for (final r in rows) inventoryItemFromRow(r)];
  }

  @override
  Future<void> save(InventoryItem item) async {
    final now = _clock().toUtc();
    final details = item.details;
    final companion = InventoryItemsCompanion(
      category: Value(item.category.name),
      name: Value(item.name),
      unit: Value(item.unit.name),
      stockQty: Value(item.stockQty),
      lowStockThreshold: Value(item.lowStockThreshold),
      details: Value(details == null ? null : jsonEncode(details.toJson())),
      updatedAt: Value(now),
      deletedAt: const Value(null),
    );
    await _db
        .into(_db.inventoryItems)
        .insert(
          companion.copyWith(
            id: Value(item.id),
            gardenId: Value(_gardenId),
            createdAt: Value(now),
          ),
          onConflict: DoUpdate((_) => companion),
        );
  }

  @override
  Future<void> delete(String id) async {
    final now = _clock().toUtc();
    await (_db.update(_db.inventoryItems)..where((i) => i.id.equals(id))).write(
      InventoryItemsCompanion(deletedAt: Value(now), updatedAt: Value(now)),
    );
  }
}

InventoryItem inventoryItemFromRow(InventoryItemRow r) {
  final category = InventoryCategory.fromKey(r.category);
  Object? details;
  if (r.details != null) {
    try {
      details = jsonDecode(r.details!);
    } on FormatException {
      details = null;
    }
  }
  return InventoryItem(
    id: r.id,
    category: category,
    name: r.name,
    unit: InventoryUnit.fromKey(r.unit) ?? InventoryUnit.ks,
    stockQty: r.stockQty,
    lowStockThreshold: r.lowStockThreshold,
    details: r.details == null ? null : ItemDetails.fromJson(category, details),
  );
}

/// Nákupní seznam v lokální databázi.
class DriftShoppingRepository implements ShoppingRepository {
  DriftShoppingRepository(this._db, this._gardenId, this._clock);

  final AppDatabase _db;
  final String _gardenId;
  final DateTime Function() _clock;

  @override
  Future<List<ShoppingItem>> getAll() async {
    final rows =
        await (_db.select(_db.shoppingItems)
              ..where((s) => s.deletedAt.isNull())
              ..orderBy([(s) => OrderingTerm(expression: s.createdAt)]))
            .get();
    return [for (final r in rows) shoppingItemFromRow(r)];
  }

  @override
  Future<void> save(ShoppingItem item) async {
    final now = _clock().toUtc();
    final companion = ShoppingItemsCompanion(
      name: Value(item.name),
      qty: Value(item.qty),
      unit: Value(item.unit?.name),
      itemId: Value(item.itemId),
      done: Value(item.done),
      source: Value(item.source.name),
      updatedAt: Value(now),
      deletedAt: const Value(null),
    );
    await _db
        .into(_db.shoppingItems)
        .insert(
          companion.copyWith(
            id: Value(item.id),
            gardenId: Value(_gardenId),
            createdAt: Value(now),
          ),
          onConflict: DoUpdate((_) => companion),
        );
  }

  @override
  Future<void> delete(String id) async {
    final now = _clock().toUtc();
    await (_db.update(_db.shoppingItems)..where((s) => s.id.equals(id))).write(
      ShoppingItemsCompanion(deletedAt: Value(now), updatedAt: Value(now)),
    );
  }

  @override
  Future<void> clearDone() async {
    final now = _clock().toUtc();
    await (_db.update(
      _db.shoppingItems,
    )..where((s) => s.done.equals(true) & s.deletedAt.isNull())).write(
      ShoppingItemsCompanion(deletedAt: Value(now), updatedAt: Value(now)),
    );
  }
}

ShoppingItem shoppingItemFromRow(ShoppingItemRow r) => ShoppingItem(
  id: r.id,
  name: r.name,
  qty: r.qty,
  unit: InventoryUnit.fromKey(r.unit),
  itemId: r.itemId,
  done: r.done,
  source: ShoppingSource.fromKey(r.source),
);
