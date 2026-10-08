import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../domain/activity_type.dart';

/// Český popisek typu činnosti.
String activityTypeLabel(AppLocalizations l, ActivityType type) {
  return switch (type) {
    ActivityType.sowing => l.activityTypeSowing,
    ActivityType.planting => l.activityTypePlanting,
    ActivityType.watering => l.activityTypeWatering,
    ActivityType.fertilizing => l.activityTypeFertilizing,
    ActivityType.spraying => l.activityTypeSpraying,
    ActivityType.pruning => l.activityTypePruning,
    ActivityType.harvest => l.activityTypeHarvest,
    ActivityType.weeding => l.activityTypeWeeding,
    ActivityType.mowing => l.activityTypeMowing,
    ActivityType.other => l.activityTypeOther,
  };
}

IconData activityTypeIcon(ActivityType type) {
  return switch (type) {
    ActivityType.sowing => Icons.grain,
    ActivityType.planting => Icons.yard_outlined,
    ActivityType.watering => Icons.water_drop_outlined,
    ActivityType.fertilizing => Icons.compost,
    ActivityType.spraying => Icons.sanitizer_outlined,
    ActivityType.pruning => Icons.content_cut,
    ActivityType.harvest => Icons.shopping_basket_outlined,
    ActivityType.weeding => Icons.grass,
    ActivityType.mowing => Icons.agriculture_outlined,
    ActivityType.other => Icons.more_horiz,
  };
}

/// Pořadí typů v rychlém výběru: nejčastější práce první.
const quickPickTypes = [
  ActivityType.watering,
  ActivityType.weeding,
  ActivityType.harvest,
  ActivityType.sowing,
  ActivityType.planting,
  ActivityType.fertilizing,
  ActivityType.pruning,
  ActivityType.mowing,
  ActivityType.spraying,
  ActivityType.other,
];

/// Jednotky sklizně (FR-D9).
const harvestUnits = ['kg', 'g', 'ks'];

String harvestUnitLabel(AppLocalizations l, String unit) => switch (unit) {
  'g' => l.inventoryUnitG,
  'ks' => l.inventoryUnitKs,
  _ => l.inventoryUnitKg,
};
