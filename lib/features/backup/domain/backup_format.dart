import 'package:path/path.dart' as p;

import '../../../core/time/calendar.dart';
import '../../../core/time/time_zone.dart';
import '../../activity/domain/activity_entity.dart';
import '../../activity/domain/activity_type.dart';
import '../../tasks/domain/task_entity.dart';
import '../../zones/domain/zone_entity.dart';

/// Verze formátu `data.json` v záloze (docs/FORMAT_EXPORTU.md).
///
/// Při změně formátu verzi zvýšit, starší verze dál umět načíst
/// v [decodeBackup] (FR-E2) a doplnit test.
const backupFormatVersion = 1;

/// Složka s fotkami uvnitř ZIP souboru.
const backupPhotoFolder = 'photos';

/// Chyby čtení zálohy, které se dají uživateli srozumitelně vysvětlit.
enum BackupError {
  /// Soubor není ZIP, nebo v něm chybí `data.json`.
  notABackup,

  /// `data.json` nejde přečíst (poškozený soubor, chybí povinná pole).
  corrupted,

  /// Záloha z novější verze aplikace, kterou tahle verze neumí.
  tooNew,
}

class BackupException implements Exception {
  const BackupException(this.error, [this.detail]);

  final BackupError error;
  final String? detail;

  @override
  String toString() =>
      'BackupException($error${detail == null ? '' : ': $detail'})';
}

/// Obsah zálohy: všechna data deníku jedné zahrady.
class BackupData {
  const BackupData({
    required this.formatVersion,
    required this.exportedAt,
    required this.appVersion,
    required this.zones,
    required this.activities,
    required this.tasks,
  });

  final int formatVersion;
  final DateTime exportedAt;
  final String appVersion;
  final List<ZoneEntity> zones;
  final List<ActivityEntity> activities;
  final List<TaskEntity> tasks;

  /// Všechny fotky, na které záznamy odkazují.
  List<PhotoRef> get photos => [for (final a in activities) ...a.photos];
}

/// Cesta fotky uvnitř ZIP: `photos/<photoId><přípona>`.
String backupPhotoPath(PhotoRef photo) {
  final ext = p.extension(photo.path);
  return '$backupPhotoFolder/${photo.id}${ext.isEmpty ? '.jpg' : ext}';
}

String _instant(DateTime d) => d.toUtc().toIso8601String();

String _date(DateTime d) => formatDateKey(d);

String _minuteOfDay(int m) =>
    '${(m ~/ 60).toString().padLeft(2, '0')}:${(m % 60).toString().padLeft(2, '0')}';

/// Převede data na JSON mapu formátu [backupFormatVersion].
Map<String, Object?> encodeBackup(BackupData data) {
  final photos = data.photos;
  return {
    'formatVersion': backupFormatVersion,
    'app': 'zahradnik_boda',
    'appVersion': data.appVersion,
    'exportedAt': _instant(data.exportedAt),
    'zones': [
      for (final z in data.zones)
        {
          'id': z.id,
          'name': z.name,
          'type': z.type.name,
          'archived': z.archived,
        },
    ],
    'activities': [
      for (final a in data.activities)
        {
          'id': a.id,
          'type': a.type.key,
          'title': a.title,
          'occurredAt': _instant(a.date),
          'occurredTz': formatUtcOffset(a.date.timeZoneOffset),
          'zoneId': a.zoneId,
          'notes': a.notes,
          'photoIds': [for (final photo in a.photos) photo.id],
          'createdAt': a.createdAt == null ? null : _instant(a.createdAt!),
          'updatedAt': a.updatedAt == null ? null : _instant(a.updatedAt!),
        },
    ],
    'tasks': [
      for (final t in data.tasks)
        {
          'id': t.id,
          'title': t.title,
          'zoneId': t.zoneId,
          'due': _date(t.due),
          'remindAt': t.remindAt == null ? null : _minuteOfDay(t.remindAt!),
          'rrule': t.rrule,
          'snoozedUntil': t.snoozedUntil == null
              ? null
              : _date(t.snoozedUntil!),
          'status': t.status.name,
          'notes': t.notes,
          'completedAt': t.completedAt == null
              ? null
              : _instant(t.completedAt!),
          'completedActivityId': t.completedActivityId,
          'createdAt': t.createdAt == null ? null : _instant(t.createdAt!),
          'updatedAt': t.updatedAt == null ? null : _instant(t.updatedAt!),
        },
    ],
    'photos': [
      for (final photo in photos)
        {'id': photo.id, 'file': backupPhotoPath(photo)},
    ],
  };
}

/// Načte JSON mapu zálohy libovolné podporované verze formátu.
BackupData decodeBackup(Map<String, Object?> json) {
  final version = json['formatVersion'];
  if (version is! int || version < 1) {
    throw const BackupException(BackupError.corrupted, 'formatVersion');
  }
  if (version > backupFormatVersion) {
    throw BackupException(BackupError.tooNew, 'formatVersion $version');
  }
  // Až vznikne verze 2: zde převést mapu verze 1 na 2 a pokračovat.
  try {
    return _decodeV1(json);
  } on BackupException {
    rethrow;
  } catch (e) {
    throw BackupException(BackupError.corrupted, '$e');
  }
}

BackupData _decodeV1(Map<String, Object?> json) {
  List<Map<String, Object?>> list(String key) => [
    for (final item in (json[key] as List?) ?? const [])
      (item as Map).cast<String, Object?>(),
  ];

  DateTime instant(Object? v) => DateTime.parse(v as String).toLocal();
  DateTime? optInstant(Object? v) => v == null ? null : instant(v);
  DateTime date(Object? v) =>
      parseDateKey(v as String) ?? (throw FormatException('date $v'));

  DateTime? optDate(Object? v) => v == null ? null : date(v);
  int? minuteOfDay(Object? v) {
    if (v == null) return null;
    final parts = (v as String).split(':').map(int.parse).toList();
    return parts[0] * 60 + parts[1];
  }

  // photoId -> cesta souboru uvnitř ZIP
  final photoFiles = <String, String>{
    for (final photo in list('photos'))
      photo['id'] as String: photo['file'] as String,
  };

  return BackupData(
    formatVersion: json['formatVersion'] as int,
    exportedAt: instant(json['exportedAt']),
    appVersion: json['appVersion'] as String? ?? '?',
    zones: [
      for (final z in list('zones'))
        ZoneEntity(
          id: z['id'] as String,
          name: z['name'] as String,
          type: ZoneType.fromKey(z['type'] as String?),
          archived: z['archived'] as bool? ?? false,
        ),
    ],
    activities: [
      for (final a in list('activities'))
        ActivityEntity(
          id: a['id'] as String,
          type: ActivityType.fromKey(a['type'] as String?),
          title: a['title'] as String,
          date: instant(a['occurredAt']),
          zoneId: a['zoneId'] as String,
          notes: a['notes'] as String?,
          photos: [
            for (final id in (a['photoIds'] as List?) ?? const [])
              PhotoRef(
                id: id as String,
                path: photoFiles[id] ?? '$backupPhotoFolder/$id.jpg',
              ),
          ],
          createdAt: optInstant(a['createdAt']),
          updatedAt: optInstant(a['updatedAt']),
        ),
    ],
    tasks: [
      for (final t in list('tasks'))
        TaskEntity(
          id: t['id'] as String,
          title: t['title'] as String,
          zoneId: t['zoneId'] as String?,
          due: date(t['due']),
          remindAt: minuteOfDay(t['remindAt']),
          rrule: t['rrule'] as String?,
          snoozedUntil: optDate(t['snoozedUntil']),
          status: TaskStatus.fromKey(t['status'] as String?),
          notes: t['notes'] as String?,
          completedAt: optInstant(t['completedAt']),
          completedActivityId: t['completedActivityId'] as String?,
          createdAt: optInstant(t['createdAt']),
          updatedAt: optInstant(t['updatedAt']),
        ),
    ],
  );
}
