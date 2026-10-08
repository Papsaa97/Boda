import 'package:equatable/equatable.dart';

import 'activity_type.dart';

/// Nejvýš tolik fotek může mít jeden záznam (FR-D8).
const maxPhotosPerActivity = 5;

/// Fotka u záznamu: id (UUID, v exportu `photoId`) a cesta k souboru
/// relativní ke složce dokumentů aplikace (`activity_photos/…`).
class PhotoRef extends Equatable {
  const PhotoRef({required this.id, required this.path});

  final String id;
  final String path;

  @override
  List<Object?> get props => [id, path];
}

/// Jeden záznam v deníku: co se kdy na zahradě dělalo a kde.
class ActivityEntity extends Equatable {
  /// UUID v4 vygenerované na zařízení.
  final String id;
  final ActivityType type;
  final String title;

  /// Kdy se činnost stala (místní čas zařízení).
  final DateTime date;

  /// Id zóny ze seznamu zón.
  final String zoneId;
  final String? notes;

  /// Fotky v pořadí, v jakém je uživatel přidal.
  final List<PhotoRef> photos;

  /// Sklizené množství (FR-D9) v jednotce [harvestUnit] (`kg`, `g`, `ks`).
  final double? harvestQty;
  final String? harvestUnit;

  /// Náklady v Kč (FR-D9).
  final double? costCzk;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ActivityEntity({
    required this.id,
    required this.title,
    required this.date,
    required this.zoneId,
    this.type = ActivityType.other,
    this.notes,
    this.photos = const [],
    this.harvestQty,
    this.harvestUnit,
    this.costCzk,
    this.createdAt,
    this.updatedAt,
  });

  /// První fotka pro náhled v seznamu.
  PhotoRef? get coverPhoto => photos.isEmpty ? null : photos.first;

  /// Kopie se změněnými poli. Poznámku jde vymazat přes [clearNotes]
  /// (samotné `null` znamená „beze změny“); sklizeň a náklady přes
  /// funkci vracející null.
  ActivityEntity copyWith({
    String? id,
    ActivityType? type,
    String? title,
    DateTime? date,
    String? zoneId,
    String? notes,
    bool clearNotes = false,
    List<PhotoRef>? photos,
    double? Function()? harvestQty,
    String? Function()? harvestUnit,
    double? Function()? costCzk,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ActivityEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      date: date ?? this.date,
      zoneId: zoneId ?? this.zoneId,
      notes: clearNotes ? null : (notes ?? this.notes),
      photos: photos ?? this.photos,
      harvestQty: harvestQty == null ? this.harvestQty : harvestQty(),
      harvestUnit: harvestUnit == null ? this.harvestUnit : harvestUnit(),
      costCzk: costCzk == null ? this.costCzk : costCzk(),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    type,
    title,
    date,
    zoneId,
    notes,
    photos,
    harvestQty,
    harvestUnit,
    costCzk,
    createdAt,
    updatedAt,
  ];
}
