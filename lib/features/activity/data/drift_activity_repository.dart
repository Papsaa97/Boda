import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/time/time_zone.dart';
import '../domain/activity_entity.dart';
import '../domain/activity_repository.dart';
import '../domain/activity_type.dart';

/// Záznamy deníku a jejich fotky v lokální databázi.
///
/// Čas činnosti se ukládá v UTC a k němu posun časové zóny zařízení
/// (spec 7.3); entita nese místní čas. Smazání je měkké.
class DriftActivityRepository implements ActivityRepository {
  DriftActivityRepository(this._db, this._gardenId, this._clock);

  final AppDatabase _db;
  final String _gardenId;
  final DateTime Function() _clock;

  @override
  Future<List<ActivityEntity>> getAllActivities() async {
    final rows =
        await (_db.select(_db.activities)
              ..where((a) => a.deletedAt.isNull())
              ..orderBy([
                (a) => OrderingTerm(
                  expression: a.occurredAt,
                  mode: OrderingMode.desc,
                ),
              ]))
            .get();
    final photos = await _photosByActivity();
    return [for (final r in rows) activityFromRow(r, photos[r.id] ?? const [])];
  }

  @override
  Future<ActivityEntity?> getActivityById(String id) async {
    final row = await (_db.select(
      _db.activities,
    )..where((a) => a.id.equals(id) & a.deletedAt.isNull())).getSingleOrNull();
    if (row == null) return null;
    final photos = await _photosByActivity(activityId: id);
    return activityFromRow(row, photos[id] ?? const []);
  }

  @override
  Future<void> addActivity(ActivityEntity activity) => _upsert(activity);

  @override
  Future<void> updateActivity(ActivityEntity activity) => _upsert(activity);

  @override
  Future<void> deleteActivity(String id) async {
    final now = _clock().toUtc();
    await _db.transaction(() async {
      await (_db.update(_db.activities)..where((a) => a.id.equals(id))).write(
        ActivitiesCompanion(deletedAt: Value(now), updatedAt: Value(now)),
      );
      await (_db.update(_db.photos)
            ..where((p) => p.activityId.equals(id) & p.deletedAt.isNull()))
          .write(PhotosCompanion(deletedAt: Value(now)));
    });
  }

  Future<void> _upsert(ActivityEntity a) async {
    final now = _clock().toUtc();
    await _db.transaction(() async {
      await _db
          .into(_db.activities)
          .insert(
            ActivitiesCompanion.insert(
              id: a.id,
              gardenId: _gardenId,
              zoneId: a.zoneId,
              type: a.type.key,
              title: a.title,
              occurredAt: a.date.toUtc(),
              occurredTz: formatUtcOffset(a.date.timeZoneOffset),
              notes: Value(a.notes),
              createdAt: (a.createdAt ?? now).toUtc(),
              updatedAt: now,
            ),
            onConflict: DoUpdate(
              (_) => ActivitiesCompanion(
                zoneId: Value(a.zoneId),
                type: Value(a.type.key),
                title: Value(a.title),
                occurredAt: Value(a.date.toUtc()),
                occurredTz: Value(formatUtcOffset(a.date.timeZoneOffset)),
                notes: Value(a.notes),
                updatedAt: Value(now),
                deletedAt: const Value(null),
              ),
            ),
          );

      // Fotky, které v záznamu už nejsou, se označí jako smazané.
      final keep = a.photos.map((p) => p.id).toList();
      await (_db.update(_db.photos)..where(
            (p) =>
                p.activityId.equals(a.id) &
                p.deletedAt.isNull() &
                p.id.isNotIn(keep),
          ))
          .write(PhotosCompanion(deletedAt: Value(now)));
      for (var i = 0; i < a.photos.length; i++) {
        final photo = a.photos[i];
        await _db
            .into(_db.photos)
            .insert(
              PhotosCompanion.insert(
                id: photo.id,
                gardenId: _gardenId,
                activityId: Value(a.id),
                localPath: photo.path,
                position: Value(i),
                createdAt: now,
              ),
              onConflict: DoUpdate(
                (_) => PhotosCompanion(
                  localPath: Value(photo.path),
                  position: Value(i),
                  deletedAt: const Value(null),
                ),
              ),
            );
      }
    });
  }

  Future<Map<String, List<PhotoRef>>> _photosByActivity({
    String? activityId,
  }) async {
    final query = _db.select(_db.photos)
      ..where(
        (p) =>
            p.deletedAt.isNull() &
            (activityId == null
                ? p.activityId.isNotNull()
                : p.activityId.equals(activityId)),
      )
      ..orderBy([(p) => OrderingTerm(expression: p.position)]);
    final result = <String, List<PhotoRef>>{};
    for (final row in await query.get()) {
      (result[row.activityId!] ??= []).add(
        PhotoRef(id: row.id, path: row.localPath),
      );
    }
    return result;
  }
}

ActivityEntity activityFromRow(ActivityRow r, List<PhotoRef> photos) =>
    ActivityEntity(
      id: r.id,
      type: ActivityType.fromKey(r.type),
      title: r.title,
      date: r.occurredAt.toLocal(),
      zoneId: r.zoneId,
      notes: r.notes,
      photos: photos,
      createdAt: r.createdAt.toLocal(),
      updatedAt: r.updatedAt.toLocal(),
    );
