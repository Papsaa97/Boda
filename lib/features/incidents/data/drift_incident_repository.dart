import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../activity/domain/activity_entity.dart';
import '../domain/incident.dart';

/// Incidenty v lokální databázi; fotky jsou řádky `photos`
/// s `incident_id`. Mazání je měkké.
class DriftIncidentRepository implements IncidentRepository {
  DriftIncidentRepository(this._db, this._gardenId, this._clock);

  final AppDatabase _db;
  final String _gardenId;
  final DateTime Function() _clock;

  @override
  Future<List<Incident>> getAll() async {
    final rows =
        await (_db.select(_db.incidents)
              ..where((i) => i.deletedAt.isNull())
              ..orderBy([
                (i) => OrderingTerm(
                  expression: i.createdAt,
                  mode: OrderingMode.desc,
                ),
              ]))
            .get();
    final photoRows =
        await (_db.select(_db.photos)
              ..where((p) => p.deletedAt.isNull() & p.incidentId.isNotNull())
              ..orderBy([(p) => OrderingTerm(expression: p.position)]))
            .get();
    final photos = <String, List<PhotoRef>>{};
    for (final p in photoRows) {
      (photos[p.incidentId!] ??= []).add(PhotoRef(id: p.id, path: p.localPath));
    }
    return [for (final r in rows) incidentFromRow(r, photos[r.id] ?? const [])];
  }

  @override
  Future<void> save(Incident incident) async {
    final now = _clock().toUtc();
    await _db.transaction(() async {
      final companion = IncidentsCompanion(
        zoneId: Value(incident.zoneId),
        label: Value(incident.label),
        source: Value(incident.source.name),
        candidates: Value(
          incident.candidates.isEmpty
              ? null
              : jsonEncode([for (final c in incident.candidates) c.toJson()]),
        ),
        planBio: Value(incident.planBio),
        planChem: Value(incident.planChem),
        status: Value(incident.status.name),
        updatedAt: Value(now),
        deletedAt: const Value(null),
      );
      await _db
          .into(_db.incidents)
          .insert(
            companion.copyWith(
              id: Value(incident.id),
              gardenId: Value(_gardenId),
              createdAt: Value(incident.createdAt?.toUtc() ?? now),
            ),
            onConflict: DoUpdate((_) => companion),
          );

      final keep = [for (final p in incident.photos) p.id];
      await (_db.update(_db.photos)..where(
            (p) =>
                p.incidentId.equals(incident.id) &
                p.deletedAt.isNull() &
                p.id.isNotIn(keep),
          ))
          .write(PhotosCompanion(deletedAt: Value(now), updatedAt: Value(now)));
      for (var i = 0; i < incident.photos.length; i++) {
        final photo = incident.photos[i];
        await _db
            .into(_db.photos)
            .insert(
              PhotosCompanion.insert(
                id: photo.id,
                gardenId: _gardenId,
                incidentId: Value(incident.id),
                localPath: photo.path,
                position: Value(i),
                createdAt: now,
                updatedAt: Value(now),
              ),
              onConflict: DoUpdate(
                (_) => PhotosCompanion(
                  localPath: Value(photo.path),
                  position: Value(i),
                  updatedAt: Value(now),
                  deletedAt: const Value(null),
                ),
              ),
            );
      }
    });
  }

  @override
  Future<void> delete(String id) async {
    final now = _clock().toUtc();
    await _db.transaction(() async {
      await (_db.update(_db.incidents)..where((i) => i.id.equals(id))).write(
        IncidentsCompanion(deletedAt: Value(now), updatedAt: Value(now)),
      );
      await (_db.update(_db.photos)
            ..where((p) => p.incidentId.equals(id) & p.deletedAt.isNull()))
          .write(PhotosCompanion(deletedAt: Value(now), updatedAt: Value(now)));
    });
  }
}

Incident incidentFromRow(IncidentRow r, List<PhotoRef> photos) {
  var candidates = const <IncidentCandidate>[];
  if (r.candidates case final json?) {
    try {
      final list = jsonDecode(json);
      if (list is List) {
        candidates = [for (final c in list) ?IncidentCandidate.fromJson(c)];
      }
    } on FormatException {
      candidates = const [];
    }
  }
  return Incident(
    id: r.id,
    zoneId: r.zoneId,
    label: r.label,
    source: IncidentSource.fromKey(r.source),
    candidates: candidates,
    planBio: r.planBio,
    planChem: r.planChem,
    status: IncidentStatus.fromKey(r.status),
    photos: photos,
    createdAt: r.createdAt.toLocal(),
    updatedAt: r.updatedAt.toLocal(),
  );
}
