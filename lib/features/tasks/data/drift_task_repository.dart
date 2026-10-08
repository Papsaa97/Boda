import 'dart:convert';

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
    final materialRows = await (_db.select(
      _db.taskMaterials,
    )..where((m) => m.deletedAt.isNull())).get();
    final materials = <String, List<TaskMaterial>>{};
    for (final m in materialRows) {
      (materials[m.taskId] ??= []).add(
        TaskMaterial(itemId: m.itemId, qty: m.qty, unit: m.unit),
      );
    }
    return [for (final r in rows) taskFromRow(r, materials[r.id] ?? const [])];
  }

  @override
  Future<void> saveTask(TaskEntity task) async {
    final now = _clock().toUtc();
    final row = taskToCompanion(task, gardenId: _gardenId, now: now);
    await _db.transaction(() async {
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
      await _saveMaterials(task, now);
    });
  }

  /// Materiál úkolu: odebraný se měkce smaže, ostatní se uloží.
  Future<void> _saveMaterials(TaskEntity task, DateTime now) async {
    final keep = {for (final m in task.materials) m.itemId};
    await (_db.update(_db.taskMaterials)..where(
          (m) =>
              m.taskId.equals(task.id) &
              m.deletedAt.isNull() &
              m.itemId.isNotIn(keep),
        ))
        .write(
          TaskMaterialsCompanion(deletedAt: Value(now), updatedAt: Value(now)),
        );
    for (final m in task.materials) {
      final companion = TaskMaterialsCompanion(
        qty: Value(m.qty),
        unit: Value(m.unit),
        updatedAt: Value(now),
        deletedAt: const Value(null),
      );
      await _db
          .into(_db.taskMaterials)
          .insert(
            companion.copyWith(
              taskId: Value(task.id),
              itemId: Value(m.itemId),
              gardenId: Value(_gardenId),
              createdAt: Value(now),
            ),
            onConflict: DoUpdate((_) => companion),
          );
    }
  }

  @override
  Future<void> recordMaterialsUsed(TaskEntity task, String activityId) async {
    final now = _clock().toUtc();
    await _db.transaction(() async {
      for (final m in task.materials) {
        final companion = ActivityMaterialsCompanion(
          qty: Value(m.qty),
          unit: Value(m.unit),
          updatedAt: Value(now),
          deletedAt: const Value(null),
        );
        await _db
            .into(_db.activityMaterials)
            .insert(
              companion.copyWith(
                activityId: Value(activityId),
                itemId: Value(m.itemId),
                gardenId: Value(_gardenId),
                createdAt: Value(now),
              ),
              onConflict: DoUpdate((_) => companion),
            );
      }
    });
  }

  @override
  Future<void> deleteTask(String id) async {
    final now = _clock().toUtc();
    await (_db.update(_db.tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(deletedAt: Value(now), updatedAt: Value(now)),
    );
  }
}

TaskEntity taskFromRow(TaskRow r, [List<TaskMaterial> materials = const []]) =>
    TaskEntity(
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
      durationEstMin: r.durationEstMin,
      incidentId: r.incidentId,
      tools: decodeTools(r.tools),
      materials: materials,
      source: TaskSource.fromKey(r.source),
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
  durationEstMin: Value(t.durationEstMin),
  incidentId: Value(t.incidentId),
  tools: Value(t.tools.isEmpty ? null : jsonEncode(t.tools)),
  source: Value(t.source.name),
  createdAt: (t.createdAt ?? now).toUtc(),
  updatedAt: now,
);

/// Nářadí uložené jako JSON pole; poškozený text = žádné nářadí.
List<String> decodeTools(String? json) {
  if (json == null) return const [];
  try {
    final decoded = jsonDecode(json);
    if (decoded is List) {
      return [
        for (final t in decoded)
          if (t is String) t,
      ];
    }
  } on FormatException {
    // Poškozená hodnota se ignoruje.
  }
  return const [];
}
