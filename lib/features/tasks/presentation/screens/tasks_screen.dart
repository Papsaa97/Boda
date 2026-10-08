import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/time/today.dart';
import '../../../../core/formatting/dates.dart';
import '../../../../core/time/calendar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/task_entity.dart';
import '../tasks_controller.dart';
import '../widgets/task_tile.dart';

/// Úkoly: týdenní pruh s počty a seznam po skupinách (po termínu, dnes,
/// tento týden, později, hotové).
class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  /// Posun zobrazeného týdne od aktuálního.
  int _weekOffset = 0;

  /// Vybraný den v týdenním pruhu; null = všechny úkoly.
  DateTime? _selectedDay;

  bool _showClosed = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final tasksAsync = ref.watch(tasksControllerProvider);
    final now = ref.watch(todayProvider);
    final today = dayOnly(now);

    return Scaffold(
      appBar: AppBar(title: Text(l.navTasks)),
      body: tasksAsync.when(
        skipError: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text(l.commonErrorWithDetail('$error'))),
        data: (tasks) {
          final open = tasks.where((t) => t.isOpen).toList();
          final closed = tasks.where((t) => !t.isOpen).toList()
            ..sort(
              (a, b) =>
                  (b.completedAt ?? b.due).compareTo(a.completedAt ?? a.due),
            );

          final monday = startOfWeek(today);
          final weekStart = DateTime(
            monday.year,
            monday.month,
            monday.day + 7 * _weekOffset,
          );

          final children = <Widget>[
            _WeekStrip(
              weekStart: weekStart,
              today: today,
              selected: _selectedDay,
              counts: {
                for (var i = 0; i < 7; i++)
                  i: open.where((t) {
                    final d = DateTime(
                      weekStart.year,
                      weekStart.month,
                      weekStart.day + i,
                    );
                    return dayOnly(t.effectiveDate) == d;
                  }).length,
              },
              onSelect: (day) => setState(
                () => _selectedDay = _selectedDay == day ? null : day,
              ),
              onPrev: () => setState(() {
                _weekOffset--;
                _selectedDay = null;
              }),
              onNext: () => setState(() {
                _weekOffset++;
                _selectedDay = null;
              }),
            ),
          ];

          final selected = _selectedDay;
          if (selected != null) {
            final dayTasks = tasks
                .where((t) => dayOnly(t.effectiveDate) == selected)
                .toList();
            children.add(
              _Section(
                title: capitalize(formatDayHeader(l, selected, now)),
                tasks: dayTasks,
                empty: l.tasksNoneThatDay,
              ),
            );
          } else if (open.isEmpty) {
            children.add(
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.checklist,
                      size: 56,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(l.tasksEmptyTitle, textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Text(
                      l.tasksEmptyBody,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            );
          } else {
            final weekEnd = DateTime(today.year, today.month, today.day + 7);
            final overdue = open
                .where((t) => t.effectiveDate.isBefore(today))
                .toList();
            final todays = open
                .where((t) => dayOnly(t.effectiveDate) == today)
                .toList();
            final soon = open
                .where(
                  (t) =>
                      t.effectiveDate.isAfter(today) &&
                      t.effectiveDate.isBefore(weekEnd),
                )
                .toList();
            final later = open
                .where((t) => !t.effectiveDate.isBefore(weekEnd))
                .toList();
            if (overdue.isNotEmpty) {
              children.add(_Section(title: l.tasksOverdue, tasks: overdue));
            }
            if (todays.isNotEmpty) {
              children.add(_Section(title: l.dayHeaderToday, tasks: todays));
            }
            if (soon.isNotEmpty) {
              children.add(_Section(title: l.tasksNext7Days, tasks: soon));
            }
            if (later.isNotEmpty) {
              children.add(_Section(title: l.tasksLater, tasks: later));
            }
          }

          if (selected == null && closed.isNotEmpty) {
            children.add(
              ListTile(
                title: Text(l.tasksClosedSection(closed.length)),
                trailing: Icon(
                  _showClosed ? Icons.expand_less : Icons.expand_more,
                ),
                onTap: () => setState(() => _showClosed = !_showClosed),
              ),
            );
            if (_showClosed) {
              children.addAll(closed.take(30).map((t) => TaskTile(task: t)));
            }
          }

          return ListView(
            padding: const EdgeInsets.only(bottom: 96),
            children: children,
          );
        },
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.tasks, this.empty});

  final String title;
  final List<TaskEntity> tasks;
  final String? empty;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        if (tasks.isEmpty && empty != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(empty!),
          ),
        for (final task in tasks) TaskTile(task: task),
      ],
    );
  }
}

/// Kalendářní pohled týdne: dny s počtem otevřených úkolů.
class _WeekStrip extends StatelessWidget {
  const _WeekStrip({
    required this.weekStart,
    required this.today,
    required this.selected,
    required this.counts,
    required this.onSelect,
    required this.onPrev,
    required this.onNext,
  });

  final DateTime weekStart;
  final DateTime today;
  final DateTime? selected;
  final Map<int, int> counts;
  final ValueChanged<DateTime> onSelect;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          IconButton(
            tooltip: l.tasksPrevWeek,
            onPressed: onPrev,
            icon: const Icon(Icons.chevron_left),
          ),
          for (var i = 0; i < 7; i++)
            Expanded(
              child: Builder(
                builder: (context) {
                  final day = DateTime(
                    weekStart.year,
                    weekStart.month,
                    weekStart.day + i,
                  );
                  final isSelected = selected == day;
                  final isToday = day == today;
                  final count = counts[i] ?? 0;
                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => onSelect(day),
                    child: Semantics(
                      selected: isSelected,
                      label: l.tasksDaySemantics(formatDate(day), count),
                      excludeSemantics: true,
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 64),
                        decoration: BoxDecoration(
                          color: isSelected ? scheme.primaryContainer : null,
                          border: isToday
                              ? Border.all(color: scheme.primary)
                              : null,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              DateFormat.E(appLocale).format(day),
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                            Text(
                              '${day.day}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              count == 0 ? ' ' : '$count',
                              style: TextStyle(
                                color: scheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          IconButton(
            tooltip: l.tasksNextWeek,
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
