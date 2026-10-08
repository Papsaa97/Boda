import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/time/today.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../inventory/presentation/inventory_controller.dart';
import '../../../inventory/presentation/inventory_ui.dart';
import '../../../inventory/domain/units.dart';
import '../../domain/weekend_planner.dart';
import '../task_ui.dart';
import '../tasks_controller.dart';
import '../widgets/task_tile.dart';

/// Režim „víkend na chalupě“ (FR-U8): úkoly na řadě, které se vejdou do
/// zadaného času, a co si vzít s sebou.
class WeekendScreen extends ConsumerStatefulWidget {
  const WeekendScreen({super.key});

  @override
  ConsumerState<WeekendScreen> createState() => _WeekendScreenState();
}

class _WeekendScreenState extends ConsumerState<WeekendScreen> {
  int _hours = 4;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final tasks = ref.watch(tasksControllerProvider).value ?? const [];
    final plan = planWeekend(
      tasks,
      today: ref.watch(todayProvider),
      availableMinutes: _hours * 60,
    );
    final textTheme = Theme.of(context).textTheme;
    final takeAlong = _takeAlong(l, plan);

    return Scaffold(
      appBar: AppBar(title: Text(l.weekendTitle)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text(l.weekendAvailable(_hours)),
          ),
          Slider(
            value: _hours.toDouble(),
            min: 1,
            max: 16,
            divisions: 15,
            label: l.durationHours(_hours),
            onChanged: (v) => setState(() => _hours = v.round()),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(l.weekendHint, style: textTheme.bodySmall),
          ),
          if (plan.planned.isEmpty && plan.leftOver.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Text(l.weekendNothing, textAlign: TextAlign.center),
            )
          else ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
              child: Text(
                l.weekendSummary(
                  plan.planned.length,
                  formatDuration(l, plan.plannedMinutes),
                ),
                style: textTheme.titleMedium,
              ),
            ),
            for (final p in plan.planned) _tile(l, p),
            if (takeAlong.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
                child: Text(l.weekendTakeAlong, style: textTheme.titleSmall),
              ),
              for (final line in takeAlong)
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.check_box_outline_blank),
                  title: Text(line),
                ),
            ],
            if (plan.leftOver.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
                child: Text(l.weekendLeftOver, style: textTheme.titleSmall),
              ),
              for (final p in plan.leftOver) _tile(l, p),
            ],
          ],
        ],
      ),
    );
  }

  Widget _tile(AppLocalizations l, PlannedTask p) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      TaskTile(task: p.task),
      if (p.estimated)
        Padding(
          padding: const EdgeInsets.only(left: 72, bottom: 4),
          child: Text(
            '${formatDuration(l, p.minutes)} (${l.weekendEstimated})',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
    ],
  );

  /// Nářadí a materiál pro naplánované úkoly; stejné položky se sečtou.
  List<String> _takeAlong(AppLocalizations l, WeekendPlan plan) {
    final lines = <String>[...plan.tools];
    final totals = <String, (double, InventoryUnit)>{};
    for (final p in plan.planned) {
      for (final m in p.task.materials) {
        final unit = InventoryUnit.fromKey(m.unit);
        if (unit == null) continue;
        final current = totals[m.itemId];
        if (current == null) {
          totals[m.itemId] = (m.qty, unit);
        } else {
          final converted = unit.convert(m.qty, current.$2);
          if (converted != null) {
            totals[m.itemId] = (current.$1 + converted, current.$2);
          }
        }
      }
    }
    for (final entry in totals.entries) {
      final item = ref.watch(inventoryItemProvider(entry.key));
      lines.add(
        l.taskMaterialQty(
          item?.name ?? l.taskMaterialMissing,
          formatQty(l, entry.value.$1, entry.value.$2),
        ),
      );
    }
    return lines;
  }
}
