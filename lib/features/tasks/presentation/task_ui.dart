import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/formatting/dates.dart';
import '../../../core/time/calendar.dart';
import '../../../l10n/app_localizations.dart';
import '../../activity/domain/activity_type.dart';
import '../../activity/presentation/screens/activity_form_screen.dart';
import '../../activity/domain/activity_entity.dart';
import '../domain/recurrence.dart';
import '../domain/task_actions.dart';
import '../domain/task_entity.dart';
import 'tasks_controller.dart';

/// „Každý týden (duben–září)“ apod.
String recurrenceLabel(AppLocalizations l, Recurrence r) {
  final base = switch (r.frequency) {
    RepeatFrequency.weekly => l.repeatWeekly,
    RepeatFrequency.monthly => l.repeatMonthly,
    RepeatFrequency.yearly => l.repeatYearly,
  };
  if (r.months.isEmpty) return base;
  final months = (r.months.toList()..sort())
      .map((m) => DateFormat.MMM(appLocale).format(DateTime(2000, m)))
      .join(', ');
  return l.repeatInMonths(base, months);
}

/// Kdy je úkol na řadě: „Dnes 18:00“, „Zítra“, „čtvrtek 9. října“.
String taskWhenLabel(AppLocalizations l, TaskEntity task, DateTime now) {
  final day = capitalize(formatDayHeader(l, task.effectiveDate, now));
  final minutes = task.remindAt;
  return minutes == null ? day : '$day ${formatMinuteOfDay(minutes)}';
}

bool isOverdue(TaskEntity task, DateTime now) =>
    task.isOpen && task.effectiveDate.isBefore(dayOnly(now));

String snoozeLabel(AppLocalizations l, SnoozeOption option) => switch (option) {
  SnoozeOption.oneDay => l.snoozeOneDay,
  SnoozeOption.weekend => l.snoozeWeekend,
  SnoozeOption.oneWeek => l.snoozeOneWeek,
};

/// Dokončí úkol a nabídne zápis do deníku (FR-U4).
Future<void> completeTask(
  BuildContext context,
  WidgetRef ref,
  TaskEntity task,
) async {
  final l = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);
  // Řádek úkolu po dokončení zmizí, proto si controller vezmeme předem
  // (akce ve snackbaru přijde až potom).
  final controller = ref.read(tasksControllerProvider.notifier);
  final closure = await controller.close(task.id, TaskStatus.done);
  if (closure == null) {
    messenger.showSnackBar(SnackBar(content: Text(l.taskSaveFailed)));
    return;
  }
  messenger.showSnackBar(
    SnackBar(
      content: Text(
        closure.next == null
            ? l.taskDoneSnack(task.title)
            : l.taskDoneRecurringSnack(
                task.title,
                formatDate(closure.next!.due),
              ),
      ),
      duration: const Duration(seconds: 6),
      action: SnackBarAction(
        label: l.taskLogToDiary,
        onPressed: () async {
          final activity = await navigator.push<ActivityEntity>(
            MaterialPageRoute(
              builder: (_) => ActivityFormScreen(
                draft: ActivityDraft(
                  title: task.title,
                  type: ActivityType.guessFromTitle(task.title),
                  zoneId: task.zoneId,
                  notes: task.notes,
                ),
              ),
            ),
          );
          if (activity != null) {
            await controller.linkActivity(task.id, activity.id);
          }
        },
      ),
    ),
  );
}

/// „45 min“, „2 h“, „1 h 30 min“.
String formatDuration(AppLocalizations l, int minutes) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (h == 0) return l.durationMinutes(m);
  if (m == 0) return l.durationHours(h);
  return l.durationHoursMinutes(h, m);
}
