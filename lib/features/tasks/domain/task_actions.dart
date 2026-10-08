import '../../../core/time/calendar.dart';
import '../../inventory/domain/stock_movement.dart';
import 'task_entity.dart';

/// Možnosti odložení úkolu (FR-U3).
enum SnoozeOption { oneDay, weekend, oneWeek }

/// Den, do kdy se úkol odloží, počítáno od dneška.
///
/// „Do víkendu“ je nejbližší sobota; o víkendu sobota příští.
DateTime snoozeTarget(SnoozeOption option, DateTime now) {
  final today = dayOnly(now);
  return switch (option) {
    SnoozeOption.oneDay => DateTime(today.year, today.month, today.day + 1),
    SnoozeOption.oneWeek => DateTime(today.year, today.month, today.day + 7),
    SnoozeOption.weekend => DateTime(
      today.year,
      today.month,
      today.day + _daysUntilSaturday(today.weekday),
    ),
  };
}

int _daysUntilSaturday(int weekday) {
  final diff = DateTime.saturday - weekday;
  return diff > 0 ? diff : diff + 7;
}

/// Výsledek uzavření úkolu: uzavřený úkol a případně další výskyt.
class TaskClosure {
  const TaskClosure(
    this.closed,
    this.next, {
    this.consumption = const Consumption(),
  });

  final TaskEntity closed;
  final TaskEntity? next;

  /// Odpis materiálu ze skladu (FR-S4); prázdný u úkolu bez materiálu
  /// nebo u přeskočeného úkolu.
  final Consumption consumption;
}

/// Uzavře úkol jako hotový nebo přeskočený. U opakovaného úkolu vznikne
/// nový otevřený úkol s nejbližším termínem po dnešku, takže uzavřený
/// zůstane v historii.
TaskClosure closeTask(
  TaskEntity task, {
  required TaskStatus status,
  required DateTime now,
  required String nextId,
}) {
  assert(status != TaskStatus.open);
  final closed = task.copyWith(
    status: status,
    completedAt: () => now,
    updatedAt: now,
  );

  final recurrence = task.recurrence;
  if (recurrence == null) return TaskClosure(closed, null);

  // Další termín je vždy až po dnešku: zpožděný opakovaný úkol nevyrobí
  // řadu termínů v minulosti a dnešní práce je tímto uzavřením hotová.
  final today = dayOnly(now);
  var nextDue = recurrence.nextAfter(task.due);
  while (!nextDue.isAfter(today)) {
    nextDue = recurrence.nextAfter(nextDue);
  }

  final next = TaskEntity(
    id: nextId,
    title: task.title,
    zoneId: task.zoneId,
    due: nextDue,
    remindAt: task.remindAt,
    rrule: task.rrule,
    notes: task.notes,
    durationEstMin: task.durationEstMin,
    tools: task.tools,
    materials: task.materials,
    source: task.source,
    createdAt: now,
    updatedAt: now,
  );
  return TaskClosure(closed, next);
}
