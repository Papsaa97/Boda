import 'package:equatable/equatable.dart';

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

/// Zóna zahrady, ke které se váže záznam v deníku.
///
/// V MVP 0.x je zóna pojmenovaná položka seznamu. Vlastnosti (výměra,
/// půda, oslunění) přijdou v MVP 1.0, polygon na plátně v 1.1.
class ZoneEntity extends Equatable {
  /// UUID v4 (zóny z verze 0.1 měly id Z1–Z7, při převodu do databáze
  /// dostaly UUID).
  final String id;
  final String name;
  final ZoneType type;

  /// Archivovaná zóna se nenabízí pro nové záznamy, ale její záznamy
  /// zůstávají v deníku (FR-D3).
  final bool archived;

  const ZoneEntity({
    required this.id,
    required this.name,
    this.type = ZoneType.other,
    this.archived = false,
  });

  ZoneEntity copyWith({String? name, ZoneType? type, bool? archived}) =>
      ZoneEntity(
        id: id,
        name: name ?? this.name,
        type: type ?? this.type,
        archived: archived ?? this.archived,
      );

  @override
  List<Object?> get props => [id, name, type, archived];
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
