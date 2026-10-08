// lib/features/activity/presentation/screens/timeline_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/time/today.dart';
import '../../../../core/formatting/dates.dart';
import '../../../zones/domain/zone_entity.dart';
import '../../../zones/presentation/zones_controller.dart';
import '../../domain/activity_entity.dart';
import '../controllers/activity_controller.dart';
import '../widgets/activity_tile.dart';

/// Časová osa: všechny záznamy od nejnovějšího, seskupené po dnech,
/// s volitelným filtrem podle zóny.
class TimelineScreen extends ConsumerStatefulWidget {
  const TimelineScreen({super.key});

  @override
  ConsumerState<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends ConsumerState<TimelineScreen> {
  /// Id vybrané zóny, nebo null pro všechny záznamy.
  String? _zoneFilter;

  @override
  Widget build(BuildContext context) {
    final activitiesAsync = ref.watch(activityControllerProvider);
    final zones =
        ref.watch(zonesControllerProvider).value ?? const <ZoneEntity>[];
    final now = ref.watch(todayProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Deník')),
      body: activitiesAsync.when(
        skipError: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Chyba při načítání deníku: $error')),
        data: (activities) {
          if (activities.isEmpty) {
            return const _EmptyTimeline();
          }

          // Filtr nabízí jen zóny, ve kterých něco je.
          final usedZoneIds = activities.map((a) => a.zoneId).toSet();
          final filterZones = zones
              .where((z) => usedZoneIds.contains(z.id))
              .toList();
          final filter = usedZoneIds.contains(_zoneFilter) ? _zoneFilter : null;
          final visible = filter == null
              ? activities
              : activities.where((a) => a.zoneId == filter).toList();
          final groups = _groupByDay(visible);

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 96),
            itemCount: groups.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                if (filterZones.length < 2) return const SizedBox.shrink();
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      ChoiceChip(
                        label: const Text('Vše'),
                        selected: filter == null,
                        onSelected: (_) => setState(() => _zoneFilter = null),
                      ),
                      for (final zone in filterZones) ...[
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: Text(zone.name),
                          selected: filter == zone.id,
                          onSelected: (_) =>
                              setState(() => _zoneFilter = zone.id),
                        ),
                      ],
                    ],
                  ),
                );
              }
              final group = groups[index - 1];
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
                  for (final activity in group)
                    ActivityTile(activity: activity),
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
            Icon(
              Icons.menu_book_outlined,
              size: 56,
              color: Theme.of(context).colorScheme.primary,
            ),
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
