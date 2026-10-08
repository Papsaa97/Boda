import 'package:equatable/equatable.dart';

/// Jeden záznam v deníku: co se kdy na zahradě dělalo a kde.
class ActivityEntity extends Equatable {
  /// UUID v4 vygenerované na zařízení.
  final String id;
  final String title;

  /// Kdy se činnost stala (místní čas zařízení).
  final DateTime date;

  /// Id zóny ze seznamu zón.
  final String zoneId;
  final String? notes;

  /// Fotka jako cesta relativní ke složce aplikace (`activity_photos/…`).
  /// Starší záznamy mohou mít absolutní cestu, viz `PhotoStorage.resolve`.
  final String? imagePath;

  const ActivityEntity({
    required this.id,
    required this.title,
    required this.date,
    required this.zoneId,
    this.notes,
    this.imagePath,
  });

  /// Kopie se změněnými poli. Volitelná pole jde vymazat přes
  /// [clearNotes] a [clearImagePath] (samotné `null` znamená „beze změny“).
  ActivityEntity copyWith({
    String? id,
    String? title,
    DateTime? date,
    String? zoneId,
    String? notes,
    String? imagePath,
    bool clearNotes = false,
    bool clearImagePath = false,
  }) {
    return ActivityEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      zoneId: zoneId ?? this.zoneId,
      notes: clearNotes ? null : (notes ?? this.notes),
      imagePath: clearImagePath ? null : (imagePath ?? this.imagePath),
    );
  }

  @override
  List<Object?> get props => [id, title, date, zoneId, notes, imagePath];
}
