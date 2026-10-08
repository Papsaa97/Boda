import 'package:equatable/equatable.dart';

import '../../tasks/domain/task_entity.dart';
import 'inventory_item.dart';
import 'units.dart';

/// Důvod pohybu na skladě (spec 8.1 `inventory_movements.reason`).
enum MovementReason {
  purchase,
  task,
  manual,
  reversal;

  static MovementReason fromKey(String? key) => values.firstWhere(
    (r) => r.name == key,
    orElse: () => MovementReason.manual,
  );
}

/// Pohyb na skladě v jednotce položky (FR-S4). Pohyby jen přibývají.
class StockMovement extends Equatable {
  const StockMovement({
    required this.id,
    required this.itemId,
    required this.qtyDelta,
    required this.reason,
    required this.at,
    this.taskId,
  });

  final String id;
  final String itemId;

  /// Kladná = přibylo, záporná = odepsáno.
  final double qtyDelta;
  final MovementReason reason;
  final String? taskId;
  final DateTime at;

  @override
  List<Object?> get props => [id, itemId, qtyDelta, reason, taskId, at];
}

/// Množství materiálu v jednotce položky (odepsané, nebo chybějící).
class StockLine extends Equatable {
  const StockLine({
    required this.itemName,
    required this.qty,
    required this.unit,
  });

  final String itemName;
  final double qty;
  final InventoryUnit unit;

  @override
  List<Object?> get props => [itemName, qty, unit];
}

/// Co se při dokončení úkolu odepíše (FR-S4).
class Consumption extends Equatable {
  const Consumption({
    this.movements = const [],
    this.consumed = const [],
    this.shortages = const [],
    this.skipped = const [],
  });

  final List<StockMovement> movements;

  /// Co se odepsalo (pro hlášku po dokončení úkolu).
  final List<StockLine> consumed;

  /// Stav by šel pod nulu: odepíše se jen to, co je, a upozorní se
  /// (kolik chybí).
  final List<StockLine> shortages;

  /// Názvy materiálů, které nejdou odepsat (položka smazaná nebo
  /// jednotka jiné veličiny, např. kg proti litrům).
  final List<String> skipped;

  bool get isEmpty => movements.isEmpty && shortages.isEmpty && skipped.isEmpty;

  @override
  List<Object?> get props => [movements, consumed, shortages, skipped];
}

double _round(double v) => (v * 1000).roundToDouble() / 1000;

/// Součet pohybů úkolu po položkách (odpis a jeho storna).
Map<String, double> netTaskMovements(
  Iterable<StockMovement> movements,
  String taskId,
) {
  final net = <String, double>{};
  for (final m in movements) {
    if (m.taskId != taskId) continue;
    if (m.reason != MovementReason.task &&
        m.reason != MovementReason.reversal) {
      continue;
    }
    net[m.itemId] = _round((net[m.itemId] ?? 0) + m.qtyDelta);
  }
  return {
    for (final e in net.entries)
      if (e.value != 0) e.key: e.value,
  };
}

/// Odpis materiálu hotového úkolu. Úkol, který už odepsaný je (a nebyl
/// vrácen), se neodepisuje znovu. Stav nikdy nejde pod nulu.
Consumption planTaskConsumption({
  required TaskEntity task,
  required List<InventoryItem> items,
  required Iterable<StockMovement> existing,
  required DateTime now,
  required String Function() newId,
}) {
  if (task.materials.isEmpty) return const Consumption();
  if (netTaskMovements(existing, task.id).isNotEmpty) {
    return const Consumption();
  }
  final byId = {for (final i in items) i.id: i};
  final movements = <StockMovement>[];
  final consumed = <StockLine>[];
  final shortages = <StockLine>[];
  final skipped = <String>[];
  for (final m in task.materials) {
    final item = byId[m.itemId];
    final unit = InventoryUnit.fromKey(m.unit);
    final needed = item == null || unit == null
        ? null
        : unit.convert(m.qty, item.unit);
    if (item == null || needed == null) {
      skipped.add(item?.name ?? m.itemId);
      continue;
    }
    final take = _round(needed > item.stockQty ? item.stockQty : needed);
    if (needed > item.stockQty + 1e-9) {
      shortages.add(
        StockLine(
          itemName: item.name,
          qty: _round(needed - item.stockQty),
          unit: item.unit,
        ),
      );
    }
    if (take > 0) {
      movements.add(
        StockMovement(
          id: newId(),
          itemId: item.id,
          qtyDelta: -take,
          reason: MovementReason.task,
          taskId: task.id,
          at: now,
        ),
      );
      consumed.add(StockLine(itemName: item.name, qty: take, unit: item.unit));
    }
  }
  return Consumption(
    movements: movements,
    consumed: consumed,
    shortages: shortages,
    skipped: skipped,
  );
}

/// Storno odpisu úkolu vráceného mezi otevřené (FR-S4).
List<StockMovement> planTaskReversal({
  required String taskId,
  required Iterable<StockMovement> existing,
  required DateTime now,
  required String Function() newId,
}) => [
  for (final e in netTaskMovements(existing, taskId).entries)
    StockMovement(
      id: newId(),
      itemId: e.key,
      qtyDelta: -e.value,
      reason: MovementReason.reversal,
      taskId: taskId,
      at: now,
    ),
];
