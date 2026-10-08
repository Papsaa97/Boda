import 'package:equatable/equatable.dart';

import 'units.dart';

/// Odkud položka nákupního seznamu přišla.
enum ShoppingSource {
  user,
  boda,
  lowStock;

  static ShoppingSource fromKey(String? key) =>
      values.firstWhere((s) => s.name == key, orElse: () => user);
}

/// Položka nákupního seznamu (FR-B5, FR-S3).
class ShoppingItem extends Equatable {
  const ShoppingItem({
    required this.id,
    required this.name,
    this.qty,
    this.unit,
    this.itemId,
    this.done = false,
    this.source = ShoppingSource.user,
  });

  final String id;
  final String name;
  final double? qty;
  final InventoryUnit? unit;

  /// Položka skladu, kterou nákup doplní.
  final String? itemId;
  final bool done;
  final ShoppingSource source;

  ShoppingItem copyWith({bool? done}) => ShoppingItem(
    id: id,
    name: name,
    qty: qty,
    unit: unit,
    itemId: itemId,
    done: done ?? this.done,
    source: source,
  );

  @override
  List<Object?> get props => [id, name, qty, unit, itemId, done, source];
}
