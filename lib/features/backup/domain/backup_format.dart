import 'package:path/path.dart' as p;

import '../../../core/time/calendar.dart';
import '../../../core/time/time_zone.dart';
import '../../activity/domain/activity_entity.dart';
import '../../activity/domain/activity_type.dart';
import '../../inventory/domain/inventory_item.dart';
import '../../inventory/domain/shopping_item.dart';
import '../../inventory/domain/units.dart';
import '../../tasks/domain/task_entity.dart';
import '../../zones/domain/zone_entity.dart';

/// Verze formátu `data.json` v záloze (docs/FORMAT_EXPORTU.md).
///
/// Při změně formátu verzi zvýšit, starší verze dál umět načíst
/// v [decodeBackup] (FR-E2) a doplnit test.
const backupFormatVersion = 2;

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

/// Materiál spotřebovaný u záznamu (tabulka `activity_materials`).
class ActivityMaterialRecord {
  const ActivityMaterialRecord({
    required this.activityId,
    required this.itemId,
    required this.qty,
    required this.unit,
  });

  final String activityId;
  final String itemId;
  final double qty;
  final String unit;
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
    this.inventory = const [],
    this.shopping = const [],
    this.activityMaterials = const [],
  });

  final int formatVersion;
  final DateTime exportedAt;
  final String appVersion;
  final List<ZoneEntity> zones;
  final List<ActivityEntity> activities;
  final List<TaskEntity> tasks;

  /// Od verze 2 formátu (MVP 1.0).
  final List<InventoryItem> inventory;
  final List<ShoppingItem> shopping;
  final List<ActivityMaterialRecord> activityMaterials;

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
          'areaM2': z.areaM2,
          'soilTexture': z.soilTexture?.name,
          'ph': z.ph,
          'phMeasuredAt': z.phMeasuredAt == null
              ? null
              : _date(z.phMeasuredAt!),
          'sunExposure': z.sunExposure?.name,
          'irrigation': z.irrigation?.name,
          'covered': z.covered,
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
          'harvestQty': a.harvestQty,
          'harvestUnit': a.harvestUnit,
          'costCzk': a.costCzk,
          'materials': [
            for (final m in data.activityMaterials)
              if (m.activityId == a.id)
                {'itemId': m.itemId, 'qty': m.qty, 'unit': m.unit},
          ],
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
          'durationEstMin': t.durationEstMin,
          'tools': t.tools,
          'materials': [
            for (final m in t.materials)
              {'itemId': m.itemId, 'qty': m.qty, 'unit': m.unit},
          ],
          'createdAt': t.createdAt == null ? null : _instant(t.createdAt!),
          'updatedAt': t.updatedAt == null ? null : _instant(t.updatedAt!),
        },
    ],
    'inventory': [
      for (final i in data.inventory)
        {
          'id': i.id,
          'category': i.category.name,
          'name': i.name,
          'unit': i.unit.name,
          'stockQty': i.stockQty,
          'lowStockThreshold': i.lowStockThreshold,
          'details': i.details?.toJson(),
        },
    ],
    'shopping': [
      for (final s in data.shopping)
        {
          'id': s.id,
          'name': s.name,
          'qty': s.qty,
          'unit': s.unit?.name,
          'itemId': s.itemId,
          'done': s.done,
          'source': s.source.name,
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
  // Verze 2 jen přidala nepovinná pole (vlastnosti zón, sklad, nákupní
  // seznam, sklizeň, materiál), takže jeden dekodér čte obě verze.
  try {
    return _decode(json);
  } on BackupException {
    rethrow;
  } catch (e) {
    throw BackupException(BackupError.corrupted, '$e');
  }
}

BackupData _decode(Map<String, Object?> json) {
  List<Map<String, Object?>> list(String key) => [
    for (final item in (json[key] as List?) ?? const [])
      (item as Map).cast<String, Object?>(),
  ];

  DateTime instant(Object? v) => DateTime.parse(v as String).toLocal();
  DateTime? optInstant(Object? v) => v == null ? null : instant(v);
  DateTime date(Object? v) =>
      parseDateKey(v as String) ?? (throw FormatException('date $v'));

  DateTime? optDate(Object? v) => v == null ? null : date(v);
  double? optNum(Object? v) => (v as num?)?.toDouble();
  List<Map<String, Object?>> nested(Object? v) => [
    for (final item in (v as List?) ?? const [])
      (item as Map).cast<String, Object?>(),
  ];
  List<TaskMaterial> materials(Object? v) => [
    for (final m in nested(v))
      TaskMaterial(
        itemId: m['itemId'] as String,
        qty: (m['qty'] as num).toDouble(),
        unit: m['unit'] as String,
      ),
  ];
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
          areaM2: optNum(z['areaM2']),
          soilTexture: SoilTexture.fromKey(z['soilTexture'] as String?),
          ph: optNum(z['ph']),
          phMeasuredAt: optDate(z['phMeasuredAt']),
          sunExposure: SunExposure.fromKey(z['sunExposure'] as String?),
          irrigation: Irrigation.fromKey(z['irrigation'] as String?),
          covered: z['covered'] as bool? ?? false,
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
          harvestQty: optNum(a['harvestQty']),
          harvestUnit: a['harvestQty'] == null
              ? null
              : a['harvestUnit'] as String?,
          costCzk: optNum(a['costCzk']),
          createdAt: optInstant(a['createdAt']),
          updatedAt: optInstant(a['updatedAt']),
        ),
    ],
    activityMaterials: [
      for (final a in list('activities'))
        for (final m in materials(a['materials']))
          ActivityMaterialRecord(
            activityId: a['id'] as String,
            itemId: m.itemId,
            qty: m.qty,
            unit: m.unit,
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
          durationEstMin: (t['durationEstMin'] as num?)?.round(),
          tools: [
            for (final tool in (t['tools'] as List?) ?? const [])
              tool as String,
          ],
          materials: materials(t['materials']),
          createdAt: optInstant(t['createdAt']),
          updatedAt: optInstant(t['updatedAt']),
        ),
    ],
    inventory: [for (final i in list('inventory')) _inventoryItem(i)],
    shopping: [
      for (final s in list('shopping'))
        ShoppingItem(
          id: s['id'] as String,
          name: s['name'] as String,
          qty: optNum(s['qty']),
          unit: InventoryUnit.fromKey(s['unit'] as String?),
          itemId: s['itemId'] as String?,
          done: s['done'] as bool? ?? false,
          source: ShoppingSource.fromKey(s['source'] as String?),
        ),
    ],
  );
}

InventoryItem _inventoryItem(Map<String, Object?> i) {
  final category = InventoryCategory.fromKey(i['category'] as String?);
  return InventoryItem(
    id: i['id'] as String,
    category: category,
    name: i['name'] as String,
    unit: InventoryUnit.fromKey(i['unit'] as String?) ?? InventoryUnit.ks,
    stockQty: (i['stockQty'] as num?)?.toDouble() ?? 0,
    lowStockThreshold: (i['lowStockThreshold'] as num?)?.toDouble(),
    details: ItemDetails.fromJson(category, i['details']),
  );
}
