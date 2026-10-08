import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/text/numbers.dart';
import '../../../l10n/app_localizations.dart';
import '../../activity/presentation/activity_type_ui.dart';
import '../../activity/presentation/controllers/activity_controller.dart';
import '../../activity/presentation/widgets/activity_photo.dart';
import '../../zones/presentation/zones_controller.dart';
import '../domain/season_summary.dart';

/// „Tvoje sezóna 2027“ (FR-D11).
class SeasonScreen extends ConsumerWidget {
  const SeasonScreen({super.key, required this.year});

  final int year;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final activities = ref.watch(activityControllerProvider).value ?? const [];
    final season = buildSeasonSummary(activities, year);
    final theme = Theme.of(context);

    Widget number(String value, String label) => Expanded(
      child: Column(
        children: [
          Text(value, style: theme.textTheme.headlineMedium),
          Text(
            label,
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );

    Widget heading(String text) => Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(text, style: theme.textTheme.titleMedium),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l.seasonTitle(year))),
      body: season.isEmpty
          ? Center(child: Text(l.seasonEmpty))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    number('${season.activityCount}', l.seasonActivities),
                    number('${season.activeDays}', l.seasonActiveDays),
                  ],
                ),
                heading(l.seasonHarvestTitle),
                if (season.harvest.isEmpty)
                  Text(l.seasonHarvestNone)
                else
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final e in season.harvest.entries)
                        Chip(
                          avatar: const Icon(
                            Icons.shopping_basket_outlined,
                            size: 18,
                          ),
                          label: Text(
                            '${formatDecimal(e.value)} '
                            '${harvestUnitLabel(l, e.key)}',
                          ),
                        ),
                    ],
                  ),
                if (season.costCzk > 0) ...[
                  heading(l.seasonCostTitle),
                  Text(l.activityCostValue(formatDecimal(season.costCzk))),
                ],
                heading(l.seasonTopZones),
                for (final e in season.topZones)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      ref.watch(zoneNameProvider(e.key)) ?? l.commonUnknownZone,
                    ),
                    trailing: Text('${e.value}'),
                  ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final e in season.typeCounts)
                      Chip(
                        avatar: Icon(activityTypeIcon(e.key), size: 18),
                        label: Text(
                          '${activityTypeLabel(l, e.key)} ${e.value}',
                        ),
                      ),
                  ],
                ),
                if (season.photos.isNotEmpty) ...[
                  heading(l.seasonPhotos),
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    children: [
                      for (final p in season.photos)
                        ActivityPhoto(path: p.path),
                    ],
                  ),
                ],
              ],
            ),
    );
  }
}
