import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/formatting/dates.dart';
import '../../../../core/time/today.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../zones/domain/zone_entity.dart';
import '../../../zones/presentation/zones_controller.dart';
import '../../domain/activity_entity.dart';
import '../../domain/activity_filter.dart';
import '../../domain/activity_type.dart';
import '../activity_type_ui.dart';
import '../controllers/activity_controller.dart';
import '../widgets/activity_tile.dart';

/// Časová osa: všechny záznamy od nejnovějšího, seskupené po dnech,
/// s filtrem podle zóny, typu činnosti a fulltextem (FR-D7).
class TimelineScreen extends ConsumerStatefulWidget {
  const TimelineScreen({super.key});

  @override
  ConsumerState<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends ConsumerState<TimelineScreen> {
  String? _zoneFilter;
  ActivityType? _typeFilter;
  bool _searching = false;
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _searching = !_searching;
      if (!_searching) _search.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final activitiesAsync = ref.watch(activityControllerProvider);
    final zones =
        ref.watch(zonesControllerProvider).value ?? const <ZoneEntity>[];
    final now = ref.watch(todayProvider);

    return Scaffold(
      appBar: AppBar(
        title: _searching
            ? TextField(
                controller: _search,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l.timelineSearchHint,
                  border: InputBorder.none,
                ),
                textInputAction: TextInputAction.search,
                onChanged: (_) => setState(() {}),
              )
            : Text(l.navDiary),
        actions: [
          IconButton(
            tooltip: _searching ? l.timelineSearchClose : l.timelineSearch,
            icon: Icon(_searching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
        ],
      ),
      body: activitiesAsync.when(
        skipError: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(l.timelineLoadError('$error'))),
        data: (activities) {
          if (activities.isEmpty) return const _EmptyTimeline();

          // Filtry nabízí jen zóny a typy, které v deníku jsou.
          final usedZoneIds = activities.map((a) => a.zoneId).toSet();
          final filterZones = zones
              .where((z) => usedZoneIds.contains(z.id))
              .toList();
          final usedTypes = activities.map((a) => a.type).toSet();
          final filterTypes = quickPickTypes.where(usedTypes.contains).toList();

          final filter = ActivityFilter(
            zoneId: usedZoneIds.contains(_zoneFilter) ? _zoneFilter : null,
            type: usedTypes.contains(_typeFilter) ? _typeFilter : null,
            query: _search.text,
          );
          final visible = filter.apply(activities);
          final groups = _groupByDay(visible);

          final header = <Widget>[
            if (filterZones.length > 1)
              _ChipRow(
                children: [
                  ChoiceChip(
                    label: Text(l.filterAllZones),
                    selected: filter.zoneId == null,
                    onSelected: (_) => setState(() => _zoneFilter = null),
                  ),
                  for (final zone in filterZones)
                    ChoiceChip(
                      label: Text(zone.name),
                      selected: filter.zoneId == zone.id,
                      onSelected: (_) => setState(() => _zoneFilter = zone.id),
                    ),
                ],
              ),
            if (filterTypes.length > 1)
              _ChipRow(
                children: [
                  ChoiceChip(
                    label: Text(l.filterAllTypes),
                    selected: filter.type == null,
                    onSelected: (_) => setState(() => _typeFilter = null),
                  ),
                  for (final type in filterTypes)
                    ChoiceChip(
                      avatar: Icon(activityTypeIcon(type), size: 18),
                      showCheckmark: false,
                      label: Text(activityTypeLabel(l, type)),
                      selected: filter.type == type,
                      onSelected: (_) => setState(() => _typeFilter = type),
                    ),
                ],
              ),
            if (filter.isActive)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Text(
                  l.filterResultCount(visible.length),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
          ];

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 96),
            itemCount: header.length + (groups.isEmpty ? 1 : groups.length),
            itemBuilder: (context, index) {
              if (index < header.length) return header[index];
              if (groups.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(l.filterNoMatch, textAlign: TextAlign.center),
                );
              }
              final group = groups[index - header.length];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
                    child: Text(
                      capitalize(formatDayHeader(l, group.first.date, now)),
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

class _ChipRow extends StatelessWidget {
  const _ChipRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Row(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _EmptyTimeline extends StatelessWidget {
  const _EmptyTimeline();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
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
            Text(l.timelineEmptyTitle, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              l.timelineEmptyBody,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
