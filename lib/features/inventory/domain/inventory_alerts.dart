import 'package:equatable/equatable.dart';

import '../../../core/time/calendar.dart';
import 'inventory_item.dart';

/// Na co hlídač zásob upozorňuje (FR-S3).
enum InventoryAlertKind {
  /// Stav klesl na práh nebo pod něj.
  lowStock,

  /// Osivu prošlo datum spotřeby / klíčivosti.
  seedExpired,

  /// Osivu projde datum do [seedExpiryWarningDays] dní.
  seedExpiringSoon,

  /// Nářadí je na řadě se servisem.
  toolServiceDue,
}

class InventoryAlert extends Equatable {
  const InventoryAlert(this.item, this.kind);

  final InventoryItem item;
  final InventoryAlertKind kind;

  @override
  List<Object?> get props => [item, kind];
}

/// Jak dlouho dopředu upozornit na končící osivo (zimní inventura osiv,
/// spec 11.4).
const seedExpiryWarningDays = 60;

/// Upozornění pro dnešek, seřazená: nejdřív docházející zásoby, pak osiva,
/// pak nářadí; uvnitř podle názvu.
List<InventoryAlert> inventoryAlerts(
  List<InventoryItem> items,
  DateTime today,
) {
  final day = dayOnly(today);
  final alerts = <InventoryAlert>[];
  for (final item in items) {
    final threshold = item.lowStockThreshold;
    if (threshold != null && item.stockQty <= threshold) {
      alerts.add(InventoryAlert(item, InventoryAlertKind.lowStock));
    }
    switch (item.details) {
      case SeedDetails(:final bestBefore?):
        final days = calendarDaysBetween(day, bestBefore);
        if (days < 0) {
          alerts.add(InventoryAlert(item, InventoryAlertKind.seedExpired));
        } else if (days <= seedExpiryWarningDays) {
          alerts.add(InventoryAlert(item, InventoryAlertKind.seedExpiringSoon));
        }
      case final ToolDetails tool:
        final next = tool.nextServiceAt;
        if (next != null && !next.isAfter(day)) {
          alerts.add(InventoryAlert(item, InventoryAlertKind.toolServiceDue));
        }
      default:
        break;
    }
  }
  alerts.sort((a, b) {
    final byKind = a.kind.index.compareTo(b.kind.index);
    if (byKind != 0) return byKind;
    return a.item.name.toLowerCase().compareTo(b.item.name.toLowerCase());
  });
  return alerts;
}
