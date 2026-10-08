// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ActivityHiveModelAdapter extends TypeAdapter<ActivityHiveModel> {
  @override
  final typeId = 0;

  @override
  ActivityHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ActivityHiveModel(
      id: fields[0] as String,
      title: fields[1] as String,
      date: fields[2] as DateTime,
      zoneId: fields[3] as String,
      notes: fields[4] as String?,
      imagePath: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ActivityHiveModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.zoneId)
      ..writeByte(4)
      ..write(obj.notes)
      ..writeByte(5)
      ..write(obj.imagePath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
