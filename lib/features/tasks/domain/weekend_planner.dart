import 'package:equatable/equatable.dart';

import '../../../core/time/calendar.dart';
import 'task_entity.dart';

/// Odhad pro úkol bez zadané doby.
const defaultTaskMinutes = 30;

class PlannedTask extends Equatable {
  const PlannedTask(this.task, this.minutes, {required this.estimated});

  final TaskEntity task;
  final int minutes;

  /// Doba není zadaná, počítá se s [defaultTaskMinutes].
  final bool estimated;

  @override
  List<Object?> get props => [task, minutes, estimated];
}

/// Výsledek režimu „víkend na chalupě“ (FR-U8).
class WeekendPlan extends Equatable {
  const WeekendPlan({
    required this.planned,
    required this.leftOver,
    required this.availableMinutes,
  });

  /// Úkoly, které se vejdou, v pořadí, jak je dělat.
  final List<PlannedTask> planned;

  /// Úkoly na řadě, na které už čas nezbyl.
  final List<PlannedTask> leftOver;
  final int availableMinutes;

  int get plannedMinutes => planned.fold(0, (sum, p) => sum + p.minutes);

  /// Nářadí pro naplánované úkoly bez opakování (podle prvního výskytu).
  List<String> get tools {
    final seen = <String>{};
    return [
      for (final p in planned)
        for (final tool in p.task.tools)
          if (seen.add(tool.trim().toLowerCase())) tool.trim(),
    ];
  }

  @override
  List<Object?> get props => [planned, leftOver, availableMinutes];
}

/// Vybere otevřené úkoly na řadě do [horizonDays] dní, aby se vešly do
/// [availableMinutes]. Priorita: nejdřív zpožděné (nejstarší první), pak
/// podle termínu, při shodě kratší. Úkol, který se nevejde, se přeskočí
/// a zkusí se další (kratší se ještě může vejít).
WeekendPlan planWeekend(
  List<TaskEntity> tasks, {
  required DateTime today,
  required int availableMinutes,
  int horizonDays = 7,
}) {
  final day = dayOnly(today);
  final horizon = DateTime(day.year, day.month, day.day + horizonDays);
  final candidates = [
    for (final t in tasks)
      if (t.isOpen && t.effectiveDate.isBefore(horizon))
        PlannedTask(
          t,
          t.durationEstMin ?? defaultTaskMinutes,
          estimated: t.durationEstMin == null,
        ),
  ];
  candidates.sort((a, b) {
    final byDate = a.task.effectiveDate.compareTo(b.task.effectiveDate);
    if (byDate != 0) return byDate;
    return a.minutes.compareTo(b.minutes);
  });

  final planned = <PlannedTask>[];
  final leftOver = <PlannedTask>[];
  var remaining = availableMinutes;
  for (final c in candidates) {
    if (c.minutes <= remaining) {
      planned.add(c);
      remaining -= c.minutes;
    } else {
      leftOver.add(c);
    }
  }
  return WeekendPlan(
    planned: planned,
    leftOver: leftOver,
    availableMinutes: availableMinutes,
  );
}
