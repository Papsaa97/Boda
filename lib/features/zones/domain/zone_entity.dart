import 'package:equatable/equatable.dart';

import '../../canvas/domain/geometry.dart';

/// Druh zóny (číselník `zone.type`, spec kap. 8.3). Podle něj se volí
/// ikona; v 1.0 i výchozí rady Bódi.
enum ZoneType {
  vegetable,
  herbs,
  fruit,
  ornamental,
  lawn,
  greenhouse,
  pond,
  structure,
  other;

  static ZoneType fromKey(String? key) =>
      values.firstWhere((t) => t.name == key, orElse: () => other);
}

/// Textura půdy (číselník `zone.soilTexture`, spec 8.3).
enum SoilTexture {
  sandy,
  loamy,
  clay,
  unknown;

  static SoilTexture? fromKey(String? key) => _byName(values, key);
}

/// Oslunění (číselník `zone.sunExposure`).
enum SunExposure {
  fullSun,
  partShade,
  shade;

  static SunExposure? fromKey(String? key) => _byName(values, key);
}

/// Způsob závlahy (číselník `zone.irrigation`).
enum Irrigation {
  none,
  manual,
  drip,
  sprinkler;

  static Irrigation? fromKey(String? key) => _byName(values, key);
}

/// Vrstva plánu zahrady (FR-P5): co v zahradě je, nebo co se teprve
/// plánuje. Zóna v návrhu se nenabízí pro záznamy a úkoly.
enum ZoneLayer {
  reality,
  plan;

  static ZoneLayer fromKey(String? key) => key == plan.name ? plan : reality;
}

T? _byName<T extends Enum>(List<T> values, String? key) {
  for (final v in values) {
    if (v.name == key) return v;
  }
  return null;
}

/// Zóna zahrady, ke které se váže záznam v deníku.
///
/// Od 1.0 nese vlastnosti zadané formulářem (výměra, půda, oslunění,
/// závlaha); z nich Bóďa a kalkulátor počítají dávky. Od 1.1 může mít
/// tvar na plánu zahrady a patřit do vrstvy Návrh.
class ZoneEntity extends Equatable {
  /// UUID v4 (zóny z verze 0.1 měly id Z1–Z7, při převodu do databáze
  /// dostaly UUID).
  final String id;
  final String name;
  final ZoneType type;

  /// Archivovaná zóna se nenabízí pro nové záznamy, ale její záznamy
  /// zůstávají v deníku (FR-D3).
  final bool archived;

  /// Výměra v m² zadaná číslem (změřená pásmem).
  final double? areaM2;
  final SoilTexture? soilTexture;
  final double? ph;

  /// Den měření pH.
  final DateTime? phMeasuredAt;
  final SunExposure? sunExposure;
  final Irrigation? irrigation;

  /// Krytá zóna (skleník, fóliovník).
  final bool covered;

  /// Tvar na plánu zahrady v metrech (1.1); null = zóna na plánu není.
  final List<Pt>? polygon;
  final ZoneLayer layer;

  const ZoneEntity({
    required this.id,
    required this.name,
    this.type = ZoneType.other,
    this.archived = false,
    this.areaM2,
    this.soilTexture,
    this.ph,
    this.phMeasuredAt,
    this.sunExposure,
    this.irrigation,
    this.covered = false,
    this.polygon,
    this.layer = ZoneLayer.reality,
  });

  /// Zóna jen v návrhu (FR-P5).
  bool get isPlanned => layer == ZoneLayer.plan;

  /// Nabízí se pro nové záznamy a úkoly: není archivovaná ani v návrhu.
  bool get isActive => !archived && !isPlanned;

  /// Má zóna vyplněnou aspoň jednu vlastnost?
  bool get hasProperties =>
      areaM2 != null ||
      soilTexture != null ||
      ph != null ||
      sunExposure != null ||
      irrigation != null ||
      covered;

  ZoneEntity copyWith({
    String? name,
    ZoneType? type,
    bool? archived,
    double? Function()? areaM2,
    SoilTexture? Function()? soilTexture,
    double? Function()? ph,
    DateTime? Function()? phMeasuredAt,
    SunExposure? Function()? sunExposure,
    Irrigation? Function()? irrigation,
    bool? covered,
    List<Pt>? Function()? polygon,
    ZoneLayer? layer,
  }) => ZoneEntity(
    id: id,
    name: name ?? this.name,
    type: type ?? this.type,
    archived: archived ?? this.archived,
    areaM2: areaM2 == null ? this.areaM2 : areaM2(),
    soilTexture: soilTexture == null ? this.soilTexture : soilTexture(),
    ph: ph == null ? this.ph : ph(),
    phMeasuredAt: phMeasuredAt == null ? this.phMeasuredAt : phMeasuredAt(),
    sunExposure: sunExposure == null ? this.sunExposure : sunExposure(),
    irrigation: irrigation == null ? this.irrigation : irrigation(),
    covered: covered ?? this.covered,
    polygon: polygon == null ? this.polygon : polygon(),
    layer: layer ?? this.layer,
  );

  @override
  List<Object?> get props => [
    id,
    name,
    type,
    archived,
    areaM2,
    soilTexture,
    ph,
    phMeasuredAt,
    sunExposure,
    irrigation,
    covered,
    polygon,
    layer,
  ];
}

/// Nabídka zón pro onboarding (pořadí karet). Názvy dodá lokalizace.
const zoneCatalog = <ZoneType>[
  ZoneType.vegetable,
  ZoneType.ornamental,
  ZoneType.fruit,
  ZoneType.lawn,
  ZoneType.greenhouse,
  ZoneType.herbs,
  ZoneType.pond,
];

/// Výchozí zóny pro „Přeskočit“ v onboardingu.
const defaultZoneTypes = <ZoneType>[
  ZoneType.vegetable,
  ZoneType.ornamental,
  ZoneType.fruit,
  ZoneType.lawn,
  ZoneType.greenhouse,
];

/// Zóny verze 0.1 podle pevných id (převod z Hive).
const legacyZoneTypes = <String, ZoneType>{
  'Z1': ZoneType.vegetable,
  'Z2': ZoneType.ornamental,
  'Z3': ZoneType.fruit,
  'Z4': ZoneType.lawn,
  'Z5': ZoneType.greenhouse,
  'Z6': ZoneType.herbs,
  'Z7': ZoneType.pond,
};
