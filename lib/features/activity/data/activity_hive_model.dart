import 'package:hive/hive.dart';

import '../domain/activity_entity.dart';

part 'activity_hive_model.g.dart';

@HiveType(typeId: 0)
class ActivityHiveModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  String zoneId;

  @HiveField(4)
  String? notes;

  @HiveField(5)
  String? imagePath;

  ActivityHiveModel({
    required this.id,
    required this.title,
    required this.date,
    required this.zoneId,
    this.notes,
    this.imagePath,
  });

  factory ActivityHiveModel.fromEntity(ActivityEntity entity) {
    return ActivityHiveModel(
      id: entity.id,
      title: entity.title,
      date: entity.date,
      zoneId: entity.zoneId,
      notes: entity.notes,
      imagePath: entity.imagePath,
    );
  }

  ActivityEntity toEntity() {
    return ActivityEntity(
      id: id,
      title: title,
      date: date,
      zoneId: zoneId,
      notes: notes,
      imagePath: imagePath,
    );
  }
}
