import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
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
            createdAt: now,
            updatedAt: now,
          ),
          onConflict: DoUpdate(
            (_) => ZonesCompanion(
              name: Value(zone.name),
              type: Value(zone.type.name),
              archived: Value(zone.archived),
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

ZoneEntity zoneFromRow(ZoneRow r) => ZoneEntity(
  id: r.id,
  name: r.name,
  type: ZoneType.fromKey(r.type),
  archived: r.archived,
);
