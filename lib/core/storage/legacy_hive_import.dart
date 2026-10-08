import 'package:drift/drift.dart';
import 'package:hive_ce/hive.dart';

import '../../features/activity/domain/activity_type.dart';
import '../../features/zones/domain/zone_entity.dart';
import '../database/app_database.dart';
import '../photos/photo_storage.dart';
import '../time/time_zone.dart';

/// Klíč v `app_settings`: kdy proběhl převod dat z verze 0.1.
const legacyImportSettingKey = 'legacy_hive_import_at';

/// Záznam deníku tak, jak ho verze 0.1 ukládala do Hive.
class LegacyActivity {
  LegacyActivity({
    required this.id,
    required this.title,
    required this.date,
    required this.zoneId,
    this.notes,
    this.imagePath,
  });

  final String id;
  final String title;
  final DateTime date;
  final String zoneId;
  final String? notes;
  final String? imagePath;
}

/// Adaptér pro záznamy z verze 0.1 (typeId 0, pole 0–5).
///
/// Psaný ručně: generátor Hive už projekt nepoužívá (DECLOG D26) a formát
/// se nikdy nezmění, slouží jen ke čtení starých dat.
class LegacyActivityAdapter extends TypeAdapter<LegacyActivity> {
  @override
  final typeId = 0;

  @override
  LegacyActivity read(BinaryReader reader) {
    final count = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < count; i++) reader.readByte(): reader.read(),
    };
    return LegacyActivity(
      id: fields[0] as String,
      title: fields[1] as String,
      date: fields[2] as DateTime,
      zoneId: fields[3] as String,
      notes: fields[4] as String?,
      imagePath: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, LegacyActivity obj) {
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
}

/// Názvy zón z verze 0.1 podle pevných id (pro zóny, které v boxu nejsou).
const _legacyZoneNames = <String, String>{
  'Z1': 'Zelenina',
  'Z2': 'Okrasná zahrada',
  'Z3': 'Ovocný sad',
  'Z4': 'Trávník',
  'Z5': 'Skleník',
  'Z6': 'Bylinky',
  'Z7': 'Jezírko',
};

/// Výsledek převodu (pro test a log).
class LegacyImportResult {
  const LegacyImportResult({
    required this.zones,
    required this.activities,
    required this.photos,
  });

  final int zones;
  final int activities;
  final int photos;

  static const none = LegacyImportResult(zones: 0, activities: 0, photos: 0);
}

/// Jednorázově převede data verze 0.1 z Hive do Driftu (spec 8.2, D26).
///
/// Hive musí být inicializovaný (`Hive.initFlutter()`, v testech
/// `Hive.init`). Převod proběhne v jedné transakci; příznak v
/// `app_settings` zajistí, že se nespustí podruhé. Soubory Hive zůstávají
/// na disku jako pojistka.
///
/// Zóny dostanou UUID a typ podle pevného id (Z1 → zelenina …), záznamy
/// typ odhadnutý z názvu. Fotky mimo složku aplikace se do ní zkopírují.
Future<LegacyImportResult> importLegacyHiveData({
  required AppDatabase db,
  required String Function() newId,
  required DateTime now,
  PhotoStorage? photos,
}) async {
  if (await db.readSetting(legacyImportSettingKey) != null) {
    return LegacyImportResult.none;
  }
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(LegacyActivityAdapter());
  }

  final activityBox = await Hive.openBox<LegacyActivity>('activities');
  final zoneBox = await Hive.openBox<String>('zones');
  final activities = activityBox.values.toList();
  final zoneNames = <String, String>{
    for (final key in zoneBox.keys) '$key': zoneBox.get(key)!,
  };
  await activityBox.close();
  await zoneBox.close();

  // Verze bez seznamu zón měla zóny Z1–Z5 napevno.
  if (zoneNames.isEmpty && activities.isNotEmpty) {
    for (final id in ['Z1', 'Z2', 'Z3', 'Z4', 'Z5']) {
      zoneNames[id] = _legacyZoneNames[id]!;
    }
  }
  for (final a in activities) {
    zoneNames.putIfAbsent(a.zoneId, () => _legacyZoneNames[a.zoneId] ?? 'Zóna');
  }

  // Fotky se kopírují mimo transakci (souborový systém), cesty se pak
  // uloží v ní.
  final photoPaths = <String, String>{};
  for (final a in activities) {
    final stored = a.imagePath;
    if (stored == null || stored.isEmpty) continue;
    photoPaths[a.id] = await photos?.adopt(stored) ?? stored;
  }

  final zoneIds = {for (final id in zoneNames.keys) id: newId()};

  await db.transaction(() async {
    final gardenId = await db.ensureDefaultGarden(newId: newId, now: now);
    var order = 0;
    for (final entry in zoneNames.entries) {
      await db
          .into(db.zones)
          .insert(
            ZonesCompanion.insert(
              id: zoneIds[entry.key]!,
              gardenId: gardenId,
              name: entry.value,
              type: Value((legacyZoneTypes[entry.key] ?? ZoneType.other).name),
              sortOrder: Value(order++),
              createdAt: now,
              updatedAt: now,
            ),
          );
    }
    for (final a in activities) {
      await db
          .into(db.activities)
          .insert(
            ActivitiesCompanion.insert(
              id: a.id,
              gardenId: gardenId,
              zoneId: zoneIds[a.zoneId]!,
              type: ActivityType.guessFromTitle(a.title).key,
              title: a.title,
              occurredAt: a.date.toUtc(),
              occurredTz: formatUtcOffset(a.date.timeZoneOffset),
              notes: Value(a.notes),
              createdAt: now,
              updatedAt: now,
            ),
          );
      final path = photoPaths[a.id];
      if (path != null) {
        await db
            .into(db.photos)
            .insert(
              PhotosCompanion.insert(
                id: newId(),
                gardenId: gardenId,
                activityId: Value(a.id),
                localPath: path,
                createdAt: now,
              ),
            );
      }
    }
    await db.writeSetting(
      legacyImportSettingKey,
      now.toUtc().toIso8601String(),
    );
  });

  return LegacyImportResult(
    zones: zoneIds.length,
    activities: activities.length,
    photos: photoPaths.length,
  );
}
