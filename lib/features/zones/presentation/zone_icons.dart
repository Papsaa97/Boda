import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../domain/zone_entity.dart';

/// Ikona zóny podle jejího druhu.
IconData zoneIcon(ZoneType type) => switch (type) {
  ZoneType.vegetable => Icons.eco,
  ZoneType.herbs => Icons.spa,
  ZoneType.fruit => Icons.park,
  ZoneType.ornamental => Icons.local_florist,
  ZoneType.lawn => Icons.grass,
  ZoneType.greenhouse => Icons.house_siding,
  ZoneType.pond => Icons.water,
  ZoneType.structure => Icons.cottage,
  ZoneType.other => Icons.yard,
};

/// Český popisek druhu zóny (a výchozí název zóny z onboardingu).
String zoneTypeLabel(AppLocalizations l, ZoneType type) => switch (type) {
  ZoneType.vegetable => l.zoneTypeVegetable,
  ZoneType.herbs => l.zoneTypeHerbs,
  ZoneType.fruit => l.zoneTypeFruit,
  ZoneType.ornamental => l.zoneTypeOrnamental,
  ZoneType.lawn => l.zoneTypeLawn,
  ZoneType.greenhouse => l.zoneTypeGreenhouse,
  ZoneType.pond => l.zoneTypePond,
  ZoneType.structure => l.zoneTypeStructure,
  ZoneType.other => l.zoneTypeOther,
};

String soilTextureLabel(AppLocalizations l, SoilTexture v) => switch (v) {
  SoilTexture.sandy => l.zoneSoilSandy,
  SoilTexture.loamy => l.zoneSoilLoamy,
  SoilTexture.clay => l.zoneSoilClay,
  SoilTexture.unknown => l.zoneSoilUnknown,
};

String sunExposureLabel(AppLocalizations l, SunExposure v) => switch (v) {
  SunExposure.fullSun => l.zoneSunFull,
  SunExposure.partShade => l.zoneSunPartShade,
  SunExposure.shade => l.zoneSunShade,
};

String irrigationLabel(AppLocalizations l, Irrigation v) => switch (v) {
  Irrigation.none => l.zoneIrrigationNone,
  Irrigation.manual => l.zoneIrrigationManual,
  Irrigation.drip => l.zoneIrrigationDrip,
  Irrigation.sprinkler => l.zoneIrrigationSprinkler,
};
