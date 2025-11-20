import 'package:equatable/equatable.dart';

class ActivityEntity extends Equatable {
  final String id;
  final String title;
  final DateTime date;
  final String zoneId;
  final String? notes;
  final String? imagePath;

  const ActivityEntity({
    required this.id,
    required this.title,
    required this.date,
    required this.zoneId,
    this.notes,
    this.imagePath,
  });

  ActivityEntity copyWith({
    String? id,
    String? title,
    DateTime? date,
    String? zoneId,
    String? notes,
    String? imagePath,
  }) {
    return ActivityEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      zoneId: zoneId ?? this.zoneId,
      notes: notes ?? this.notes,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        date,
        zoneId,
        notes,
        imagePath,
      ];
}
