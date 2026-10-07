// lib/features/activity/presentation/screens/timeline_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/formatting/dates.dart';
import '../../domain/activity_entity.dart';
import '../controllers/activity_controller.dart';
import '../widgets/activity_tile.dart';

/// Časová osa: všechny záznamy od nejnovějšího, seskupené po dnech.
class TimelineScreen extends ConsumerWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(activityControllerProvider);
    final now = ref.watch(clockProvider)();

    return Scaffold(
      appBar: AppBar(title: const Text('Deník')),
      body: activitiesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text('Chyba při načítání deníku: $error'),
        ),
        data: (activities) {
          if (activities.isEmpty) {
            return const _EmptyTimeline();
          }
          final groups = _groupByDay(activities);
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 96),
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
                    child: Text(
                      formatDayHeader(group.first.date, now),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ),
                  for (final activity in group) ActivityTile(activity: activity),
                ],
              );
            },
          );
        },
      ),
    );
  }

  /// Rozdělí seřazený seznam (nejnovější první) na skupiny po dnech.
  static List<List<ActivityEntity>> _groupByDay(List<ActivityEntity> sorted) {
    final groups = <List<ActivityEntity>>[];
    for (final activity in sorted) {
      final d = activity.date;
      if (groups.isNotEmpty) {
        final last = groups.last.first.date;
        if (last.year == d.year && last.month == d.month && last.day == d.day) {
          groups.last.add(activity);
          continue;
        }
      }
      groups.add([activity]);
    }
    return groups;
  }
}

class _EmptyTimeline extends StatelessWidget {
  const _EmptyTimeline();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.menu_book_outlined,
                size: 56, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            const Text('Zatím žádné záznamy', textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              'Zapiš první práci na zahradě tlačítkem dole.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
