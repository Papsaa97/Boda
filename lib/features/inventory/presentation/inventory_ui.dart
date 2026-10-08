import 'package:flutter/material.dart';

import '../../../core/formatting/dates.dart';
import '../../../core/text/numbers.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/inventory_alerts.dart';
import '../domain/inventory_item.dart';
import '../domain/stock_movement.dart';
import '../domain/units.dart';

IconData inventoryCategoryIcon(InventoryCategory c) => switch (c) {
  InventoryCategory.seed => Icons.grain,
  InventoryCategory.fertilizer => Icons.compost,
  InventoryCategory.plantProtection => Icons.sanitizer_outlined,
  InventoryCategory.tool => Icons.handyman_outlined,
  InventoryCategory.other => Icons.inventory_2_outlined,
};

String inventoryCategoryLabel(AppLocalizations l, InventoryCategory c) =>
    switch (c) {
      InventoryCategory.seed => l.inventoryCategorySeed,
      InventoryCategory.fertilizer => l.inventoryCategoryFertilizer,
      InventoryCategory.plantProtection => l.inventoryCategoryPlantProtection,
      InventoryCategory.tool => l.inventoryCategoryTool,
      InventoryCategory.other => l.inventoryCategoryOther,
    };

String unitLabel(AppLocalizations l, InventoryUnit u) => switch (u) {
  InventoryUnit.g => l.inventoryUnitG,
  InventoryUnit.kg => l.inventoryUnitKg,
  InventoryUnit.ml => l.inventoryUnitMl,
  InventoryUnit.l => l.inventoryUnitL,
  InventoryUnit.ks => l.inventoryUnitKs,
  InventoryUnit.pack => l.inventoryUnitPack,
};

/// „2,5 kg“.
String formatQty(AppLocalizations l, double qty, InventoryUnit unit) =>
    l.inventoryStock(formatDecimal(qty), unitLabel(l, unit));

String fertilizerFormLabel(AppLocalizations l, FertilizerForm f) => switch (f) {
  FertilizerForm.granular => l.inventoryFormGranular,
  FertilizerForm.liquid => l.inventoryFormLiquid,
  FertilizerForm.powder => l.inventoryFormPowder,
  FertilizerForm.organic => l.inventoryFormOrganic,
};

String toolConditionLabel(AppLocalizations l, ToolCondition c) => switch (c) {
  ToolCondition.good => l.inventoryConditionGood,
  ToolCondition.needsService => l.inventoryConditionNeedsService,
  ToolCondition.broken => l.inventoryConditionBroken,
};

String inventoryAlertText(AppLocalizations l, InventoryAlert alert) {
  final item = alert.item;
  return switch (alert.kind) {
    InventoryAlertKind.lowStock => l.inventoryAlertLowStock(
      item.name,
      formatQty(l, item.stockQty, item.unit),
    ),
    InventoryAlertKind.seedExpired => l.inventoryAlertSeedExpired(
      item.name,
      formatDate((item.details as SeedDetails).bestBefore!),
    ),
    InventoryAlertKind.seedExpiringSoon => l.inventoryAlertSeedExpiringSoon(
      item.name,
      formatDate((item.details as SeedDetails).bestBefore!),
    ),
    InventoryAlertKind.toolServiceDue => l.inventoryAlertToolService(item.name),
  };
}

/// Druhý řádek dlaždice: stav a nejdůležitější údaj kategorie.
String inventorySubtitle(AppLocalizations l, InventoryItem item) {
  final parts = <String>[formatQty(l, item.stockQty, item.unit)];
  switch (item.details) {
    case SeedDetails(:final variety, :final bestBefore):
      if (variety != null) parts.add(variety);
      if (bestBefore != null) {
        parts.add(l.inventoryBestBefore(formatDate(bestBefore)));
      }
    case PlantProtectionDetails(:final phiDays?):
      parts.add(l.inventoryPhi(phiDays));
    case ToolDetails(:final condition?):
      parts.add(toolConditionLabel(l, condition));
    default:
      break;
  }
  return parts.join(' · ');
}

String movementReasonLabel(AppLocalizations l, MovementReason r) => switch (r) {
  MovementReason.purchase => l.movementPurchase,
  MovementReason.task => l.movementTask,
  MovementReason.manual => l.movementManual,
  MovementReason.reversal => l.movementReversal,
};

/// „Cererit 1,2 kg, Konev 1 ks“.
String stockLines(AppLocalizations l, List<StockLine> lines) => [
  for (final line in lines)
    '${line.itemName} ${formatQty(l, line.qty, line.unit)}',
].join(', ');

/// Hláška po dokončení úkolu s materiálem (FR-S4); null, když se nic
/// neodepisovalo.
String? consumptionText(AppLocalizations l, Consumption c) {
  final parts = [
    if (c.consumed.isNotEmpty) l.stockConsumed(stockLines(l, c.consumed)),
    if (c.shortages.isNotEmpty) l.stockShortage(stockLines(l, c.shortages)),
    if (c.skipped.isNotEmpty) l.stockSkipped(c.skipped.join(', ')),
  ];
  return parts.isEmpty ? null : parts.join(' ');
}
