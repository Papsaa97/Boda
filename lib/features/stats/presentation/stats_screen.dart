import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/formatting/dates.dart';
import '../../../core/time/today.dart';
import '../../../l10n/app_localizations.dart';
import '../../activity/presentation/activity_type_ui.dart';
import '../../activity/presentation/controllers/activity_controller.dart';
import '../../zones/presentation/zones_controller.dart';
import '../domain/diary_stats.dart';

/// Statistika pro testery: záznamy po týdnech, nejaktivnější zóny a práce.
///
/// Aplikace nic neodesílá; tester čísla odsud opíše nebo pošle export
/// (spec 3, „Jak měřit“).
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final activities = ref.watch(activityControllerProvider).value ?? const [];
    final now = ref.watch(todayProvider);
    final stats = buildDiaryStats(activities: activities, now: now);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l.statsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: _Number(value: stats.total, label: l.statsTotal),
              ),
              Expanded(
                child: _Number(value: stats.thisWeek, label: l.statsThisWeek),
              ),
              Expanded(
                child: _Number(
                  value: stats.activeWeeks,
                  label: l.statsActiveWeeks(stats.weeks.length),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(l.statsPerWeek, style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          _WeekBars(weeks: stats.weeks),
          const SizedBox(height: 24),
          Text(l.statsTopZones, style: theme.textTheme.titleMedium),
          if (stats.zoneCounts.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(l.statsEmpty),
            ),
          for (final entry in stats.zoneCounts.take(5))
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                ref.watch(zoneNameProvider(entry.key)) ?? l.commonUnknownZone,
              ),
              trailing: Text('${entry.value}'),
            ),
          const SizedBox(height: 16),
          Text(l.statsTopTypes, style: theme.textTheme.titleMedium),
          for (final entry in stats.typeCounts.take(5))
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(activityTypeIcon(entry.key)),
              title: Text(activityTypeLabel(l, entry.key)),
              trailing: Text('${entry.value}'),
            ),
        ],
      ),
    );
  }
}

class _Number extends StatelessWidget {
  const _Number({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text('$value', style: theme.textTheme.headlineMedium),
        Text(
          label,
          style: theme.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Jednoduchý sloupcový graf po týdnech.
class _WeekBars extends StatelessWidget {
  const _WeekBars({required this.weeks});

  final List<WeekCount> weeks;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final max = weeks.fold<int>(1, (m, w) => w.count > m ? w.count : m);
    const height = 120.0;
    return SizedBox(
      height: height + 40,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final w in weeks)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('${w.count}', style: textTheme.labelSmall),
                    const SizedBox(height: 4),
                    Container(
                      height: w.count == 0 ? 2 : height * w.count / max,
                      decoration: BoxDecoration(
                        color: w.count >= 2
                            ? scheme.primary
                            : scheme.primary.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('d. M.', appLocale).format(w.weekStart),
                      style: textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
