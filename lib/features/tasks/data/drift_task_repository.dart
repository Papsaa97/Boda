import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/time/calendar.dart';
import '../domain/task_entity.dart';
import '../domain/task_repository.dart';

/// Úkoly v lokální databázi. Termín a odložení jsou dny (`YYYY-MM-DD`),
/// smazání je měkké.
class DriftTaskRepository implements TaskRepository {
  DriftTaskRepository(this._db, this._gardenId, this._clock);

  final AppDatabase _db;
  final String _gardenId;
  final DateTime Function() _clock;

  @override
  Future<List<TaskEntity>> getAllTasks() async {
    final rows =
        await (_db.select(_db.tasks)
              ..where((t) => t.deletedAt.isNull())
              ..orderBy([(t) => OrderingTerm(expression: t.due)]))
            .get();
    return [for (final r in rows) taskFromRow(r)];
  }

  @override
  Future<void> saveTask(TaskEntity task) async {
    final now = _clock().toUtc();
    final row = taskToCompanion(task, gardenId: _gardenId, now: now);
    await _db
        .into(_db.tasks)
        .insert(
          row,
          onConflict: DoUpdate(
            (_) => row.copyWith(
              createdAt: const Value.absent(),
              deletedAt: const Value(null),
            ),
          ),
        );
  }

  @override
  Future<void> deleteTask(String id) async {
    final now = _clock().toUtc();
    await (_db.update(_db.tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(deletedAt: Value(now), updatedAt: Value(now)),
    );
  }
}

TaskEntity taskFromRow(TaskRow r) => TaskEntity(
  id: r.id,
  title: r.title,
  zoneId: r.zoneId,
  due: parseDateKey(r.due) ?? dayOnly(r.createdAt.toLocal()),
  remindAt: r.remindAt,
  rrule: r.rrule,
  snoozedUntil: parseDateKey(r.snoozedUntil),
  status: TaskStatus.fromKey(r.status),
  notes: r.notes,
  completedAt: r.completedAt?.toLocal(),
  completedActivityId: r.completedActivityId,
  createdAt: r.createdAt.toLocal(),
  updatedAt: r.updatedAt.toLocal(),
);

TasksCompanion taskToCompanion(
  TaskEntity t, {
  required String gardenId,
  required DateTime now,
}) => TasksCompanion.insert(
  id: t.id,
  gardenId: gardenId,
  title: t.title,
  zoneId: Value(t.zoneId),
  due: formatDateKey(t.due),
  remindAt: Value(t.remindAt),
  rrule: Value(t.rrule),
  snoozedUntil: Value(
    t.snoozedUntil == null ? null : formatDateKey(t.snoozedUntil!),
  ),
  status: Value(t.status.name),
  notes: Value(t.notes),
  completedAt: Value(t.completedAt?.toUtc()),
  completedActivityId: Value(t.completedActivityId),
  createdAt: (t.createdAt ?? now).toUtc(),
  updatedAt: now,
);
