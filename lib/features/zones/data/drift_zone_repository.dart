import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/time/calendar.dart';
import '../../canvas/domain/geometry.dart';
import '../domain/zone_entity.dart';
import '../domain/zone_repository.dart';

/// Zóny v lokální databázi. Smazání je měkké (`deleted_at`).
class DriftZoneRepository implements ZoneRepository {
  DriftZoneRepository(this._db, this._gardenId, this._clock);

  final AppDatabase _db;
  final String _gardenId;
  final DateTime Function() _clock;

  @override
  Future<List<ZoneEntity>> getAllZones() async {
    final rows =
        await (_db.select(_db.zones)
              ..where((z) => z.deletedAt.isNull())
              ..orderBy([
                (z) => OrderingTerm(
                  expression: z.sortOrder,
                  nulls: NullsOrder.last,
                ),
                (z) => OrderingTerm(expression: z.createdAt),
              ]))
            .get();
    return [for (final r in rows) zoneFromRow(r)];
  }

  @override
  Future<void> saveZone(ZoneEntity zone) async {
    final now = _clock().toUtc();
    await _db
        .into(_db.zones)
        .insert(
          ZonesCompanion.insert(
            id: zone.id,
            gardenId: _gardenId,
            name: zone.name,
            type: Value(zone.type.name),
            archived: Value(zone.archived),
            areaM2: Value(zone.areaM2),
            soilTexture: Value(zone.soilTexture?.name),
            ph: Value(zone.ph),
            phMeasuredAt: Value(_dateKey(zone.phMeasuredAt)),
            sunExposure: Value(zone.sunExposure?.name),
            irrigation: Value(zone.irrigation?.name),
            covered: Value(zone.covered),
            polygon: Value(_polygon(zone)),
            layer: Value(zone.layer.name),
            createdAt: now,
            updatedAt: now,
          ),
          onConflict: DoUpdate(
            (_) => ZonesCompanion(
              name: Value(zone.name),
              type: Value(zone.type.name),
              archived: Value(zone.archived),
              areaM2: Value(zone.areaM2),
              soilTexture: Value(zone.soilTexture?.name),
              ph: Value(zone.ph),
              phMeasuredAt: Value(_dateKey(zone.phMeasuredAt)),
              sunExposure: Value(zone.sunExposure?.name),
              irrigation: Value(zone.irrigation?.name),
              covered: Value(zone.covered),
              polygon: Value(_polygon(zone)),
              layer: Value(zone.layer.name),
              updatedAt: Value(now),
              deletedAt: const Value(null),
            ),
          ),
        );
  }

  @override
  Future<void> deleteZone(String id) async {
    final now = _clock().toUtc();
    await (_db.update(_db.zones)..where((z) => z.id.equals(id))).write(
      ZonesCompanion(deletedAt: Value(now), updatedAt: Value(now)),
    );
  }
}

String? _polygon(ZoneEntity zone) {
  final polygon = zone.polygon;
  return polygon == null ? null : jsonEncode(polygonToJson(polygon));
}

String? _dateKey(DateTime? d) => d == null ? null : formatDateKey(d);

ZoneEntity zoneFromRow(ZoneRow r) => ZoneEntity(
  id: r.id,
  name: r.name,
  type: ZoneType.fromKey(r.type),
  archived: r.archived,
  areaM2: r.areaM2,
  soilTexture: SoilTexture.fromKey(r.soilTexture),
  ph: r.ph,
  phMeasuredAt: parseDateKey(r.phMeasuredAt),
  sunExposure: SunExposure.fromKey(r.sunExposure),
  irrigation: Irrigation.fromKey(r.irrigation),
  covered: r.covered,
  polygon: r.polygon == null ? null : _decodePolygon(r.polygon!),
  layer: ZoneLayer.fromKey(r.layer),
);

List<Pt>? _decodePolygon(String json) {
  try {
    return polygonFromJson(jsonDecode(json));
  } on FormatException {
    return null;
  }
}
