import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/time/today.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../zones/presentation/zones_controller.dart';
import '../../domain/task_actions.dart';
import '../../domain/task_entity.dart';
import '../screens/task_form_screen.dart';
import '../task_ui.dart';
import '../tasks_controller.dart';

enum _TaskMenu { snoozeDay, snoozeWeekend, snoozeWeek, skip, reopen, delete }

/// Řádek úkolu: zaškrtnutím se dokončí, v menu odložení a přeskočení.
class TaskTile extends ConsumerWidget {
  const TaskTile({super.key, required this.task});

  final TaskEntity task;

  Future<void> _onMenu(
    BuildContext context,
    WidgetRef ref,
    _TaskMenu action,
  ) async {
    final l = AppLocalizations.of(context);
    final controller = ref.read(tasksControllerProvider.notifier);
    switch (action) {
      case _TaskMenu.snoozeDay:
        await controller.snooze(task.id, SnoozeOption.oneDay);
      case _TaskMenu.snoozeWeekend:
        await controller.snooze(task.id, SnoozeOption.weekend);
      case _TaskMenu.snoozeWeek:
        await controller.snooze(task.id, SnoozeOption.oneWeek);
      case _TaskMenu.skip:
        await controller.close(task.id, TaskStatus.skipped);
      case _TaskMenu.reopen:
        await controller.reopen(task.id);
      case _TaskMenu.delete:
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l.taskDeleteTitle),
            content: Text(task.title),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l.commonCancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(l.commonDelete),
              ),
            ],
          ),
        );
        if (confirmed == true) await controller.delete(task.id);
    }
    if (context.mounted && ref.read(tasksControllerProvider).hasError) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.taskSaveFailed)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final now = ref.watch(todayProvider);
    final zoneName = task.zoneId == null
        ? null
        : ref.watch(zoneNameProvider(task.zoneId!));
    final scheme = Theme.of(context).colorScheme;
    final overdue = isOverdue(task, now);
    final recurrence = task.recurrence;

    final details = [
      if (task.isOpen) taskWhenLabel(l, task, now),
      if (task.status == TaskStatus.done) l.taskStatusDone,
      if (task.status == TaskStatus.skipped) l.taskStatusSkipped,
      ?zoneName,
      if (recurrence != null) recurrenceLabel(l, recurrence),
    ].join(' · ');

    return ListTile(
      leading: Checkbox(
        value: !task.isOpen,
        semanticLabel: l.taskMarkDone,
        onChanged: task.isOpen ? (_) => completeTask(context, ref, task) : null,
      ),
      title: Text(
        task.title,
        style: task.isOpen
            ? null
            : const TextStyle(decoration: TextDecoration.lineThrough),
      ),
      subtitle: Text(
        details,
        style: overdue ? TextStyle(color: scheme.error) : null,
      ),
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => TaskFormScreen(initial: task))),
      trailing: PopupMenuButton<_TaskMenu>(
        tooltip: l.taskMoreActions,
        onSelected: (action) => _onMenu(context, ref, action),
        itemBuilder: (context) => [
          if (task.isOpen) ...[
            PopupMenuItem(
              value: _TaskMenu.snoozeDay,
              child: Text(snoozeLabel(l, SnoozeOption.oneDay)),
            ),
            PopupMenuItem(
              value: _TaskMenu.snoozeWeekend,
              child: Text(snoozeLabel(l, SnoozeOption.weekend)),
            ),
            PopupMenuItem(
              value: _TaskMenu.snoozeWeek,
              child: Text(snoozeLabel(l, SnoozeOption.oneWeek)),
            ),
            PopupMenuItem(value: _TaskMenu.skip, child: Text(l.taskSkip)),
          ] else
            PopupMenuItem(value: _TaskMenu.reopen, child: Text(l.taskReopen)),
          PopupMenuItem(value: _TaskMenu.delete, child: Text(l.commonDelete)),
        ],
      ),
    );
  }
}
