import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/notifications/notification_scheduler.dart';
import '../../../core/time/today.dart';
import '../../../l10n/app_localizations.dart';
import '../../settings/presentation/settings_controller.dart';
import '../domain/reminder_planner.dart';
import 'tasks_controller.dart';

/// Plán notifikací z aktuálních úkolů a nastavení.
final plannedNotificationsProvider = Provider<List<PlannedNotification>>((ref) {
  final tasks = ref.watch(tasksControllerProvider).value;
  if (tasks == null) return const [];
  return const ReminderPlanner().plan(
    tasks: tasks,
    settings: ref.watch(settingsControllerProvider),
    now: ref.watch(todayProvider),
  );
});

/// Texty notifikací v jazyce aplikace.
ScheduledMessage messageFor(AppLocalizations l, PlannedNotification n) {
  switch (n.kind) {
    case PlannedKind.task:
      final task = n.tasks.single;
      return ScheduledMessage(
        at: n.at,
        title: task.title,
        body: task.notes ?? l.notificationTaskBody,
      );
    case PlannedKind.digest:
      final titles = n.tasks.take(6).map((t) => '• ${t.title}').join('\n');
      final more = n.tasks.length > 6
          ? '\n${l.notificationDigestMore(n.tasks.length - 6)}'
          : '';
      return ScheduledMessage(
        at: n.at,
        title: n.weekly
            ? l.notificationDigestWeeklyTitle(n.tasks.length)
            : l.notificationDigestDailyTitle(n.tasks.length),
        body: '$titles$more',
      );
  }
}

/// Při každé změně plánu přeplánuje lokální notifikace.
class ReminderSync extends ConsumerStatefulWidget {
  const ReminderSync({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<ReminderSync> createState() => _ReminderSyncState();
}

class _ReminderSyncState extends ConsumerState<ReminderSync> {
  bool _scheduledOnce = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Hned po startu přeplánovat, i když se plán od minula nezměnil
    // (notifikace mohl zrušit systém, např. po aktualizaci aplikace).
    if (!_scheduledOnce) {
      _scheduledOnce = true;
      _schedule(ref.read(plannedNotificationsProvider));
    }
  }

  void _schedule(List<PlannedNotification> plan) {
    final l = AppLocalizations.of(context);
    // Plán se počítá k „dnes“, které se obnovuje jen o půlnoci a při
    // návratu do aplikace; co už mezitím proběhlo, se neplánuje.
    final now = ref.read(clockProvider)();
    ref
        .read(notificationSchedulerProvider)
        .replaceAll([
          for (final n in plan)
            if (n.at.isAfter(now)) messageFor(l, n),
        ], channel: l.notificationChannelName)
        .catchError((Object e) {
          debugPrint('Notifikace se nepodařilo naplánovat: $e');
        });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<List<PlannedNotification>>(
      plannedNotificationsProvider,
      (_, plan) => _schedule(plan),
    );
    return widget.child;
  }
}
