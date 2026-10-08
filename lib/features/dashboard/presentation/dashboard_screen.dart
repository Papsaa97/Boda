import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../weather/presentation/weather_screen.dart';
import '../../../core/formatting/dates.dart';
import '../../../core/time/calendar.dart';
import '../../../core/time/today.dart';
import '../../../l10n/app_localizations.dart';
import '../../activity/presentation/controllers/activity_controller.dart';
import '../../activity/presentation/screens/activity_form_screen.dart';
import '../../activity/presentation/widgets/activity_tile.dart';
import '../../backup/presentation/backup_actions.dart';
import '../../inventory/presentation/inventory_controller.dart';
import '../../inventory/presentation/inventory_screen.dart';
import '../../settings/presentation/settings_controller.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../stats/domain/season_summary.dart';
import '../../stats/presentation/season_screen.dart';
import '../../tasks/domain/task_entity.dart';
import '../../tasks/presentation/screens/tasks_screen.dart';
import '../../tasks/presentation/tasks_controller.dart';
import '../../tasks/presentation/widgets/task_tile.dart';
import '../../zones/domain/zone_entity.dart';
import '../../zones/presentation/zone_icons.dart';
import '../../zones/presentation/zones_controller.dart';
import '../domain/boda_tips.dart';
import '../domain/today_summary.dart';

/// Souhrn „Co dnes?“ přepočítaný při každé změně deníku nebo zón.
final todaySummaryProvider = Provider<AsyncValue<TodaySummary>>((ref) {
  final activities = ref.watch(activityControllerProvider);
  final zones = ref.watch(zonesControllerProvider);
  final now = ref.watch(todayProvider);
  // Archivované zóny se do „zaslouží pozornost“ nepočítají.
  final active = ref.watch(activeZonesProvider);

  // Po chybě zápisu nesou stavy chybu i poslední seznam; počítáme z něj.
  if (!activities.hasValue) {
    return activities.hasError
        ? AsyncError(activities.error!, activities.stackTrace!)
        : const AsyncLoading();
  }
  if (!zones.hasValue) {
    return zones.hasError
        ? AsyncError(zones.error!, zones.stackTrace!)
        : const AsyncLoading();
  }

  return AsyncData(
    buildTodaySummary(activities: activities.value!, zones: active, now: now),
  );
});

/// Dashboard „Co dnes?“ v podobě bento mřížky.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final summaryAsync = ref.watch(todaySummaryProvider);
    final now = ref.watch(todayProvider);
    final dateLabel = DateFormat('EEEE d. MMMM', appLocale).format(now);
    final todayTasks = _tasksForToday(ref.watch(tasksControllerProvider), now);
    final settings = ref.watch(settingsControllerProvider);
    final inventoryAlertCount = ref.watch(inventoryAlertsProvider).length;
    final activities = ref.watch(activityControllerProvider).value ?? const [];

    return Scaffold(
      appBar: AppBar(
        title: Text(l.dashboardTitle),
        actions: [
          IconButton(
            tooltip: l.settingsTooltip,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: summaryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text(l.commonErrorWithDetail('$error'))),
        data: (summary) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
          children: [
            Text(
              capitalize(dateLabel),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _HeroCard(summary: summary),
            if (todayTasks.isNotEmpty) ...[
              const SizedBox(height: 12),
              _TasksCard(tasks: todayTasks),
            ],
            const WeatherCard(),
            if (!kIsWeb &&
                backupReminderDue(
                  lastExportAt: settings.lastExportAt,
                  activityCount: summary.totalCount,
                  now: now,
                )) ...[
              const SizedBox(height: 12),
              const _BackupCard(),
            ],
            if (inventoryAlertCount > 0) ...[
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: Icon(
                    Icons.notifications_active,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                  title: Text(l.dashboardInventoryAlerts(inventoryAlertCount)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const InventoryScreen()),
                  ),
                ),
              ),
            ],
            if (isWinter(now) &&
                activities.any((a) => a.date.year == seasonYearFor(now))) ...[
              const SizedBox(height: 12),
              _SeasonCard(year: seasonYearFor(now)),
            ],
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.event_available,
                    value: '${summary.lastWeekCount}',
                    label: l.dashboardLastWeek(summary.lastWeekCount),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.history,
                    value: summary.lastActivity == null
                        ? '–'
                        : formatDaysAgo(
                            l,
                            calendarDaysBetween(
                              summary.lastActivity!.date,
                              now,
                            ),
                          ),
                    label: l.dashboardLastEntry,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _TipCard(tip: BodaTips.forDate(now)),
            if (summary.needsAttention.isNotEmpty) ...[
              const SizedBox(height: 12),
              _AttentionCard(statuses: summary.needsAttention),
            ],
          ],
        ),
      ),
    );
  }

  /// Otevřené úkoly na dnešek a po termínu (spec 10.3: „+ dnešní úkoly“).
  static List<TaskEntity> _tasksForToday(
    AsyncValue<List<TaskEntity>> tasks,
    DateTime now,
  ) {
    final today = dayOnly(now);
    return [
      for (final t in tasks.value ?? const <TaskEntity>[])
        if (t.isOpen && !dayOnly(t.effectiveDate).isAfter(today)) t,
    ];
  }
}

/// Úkoly na dnešek (a po termínu).
class _TasksCard extends StatelessWidget {
  const _TasksCard({required this.tasks});

  final List<TaskEntity> tasks;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                l.dashboardTodayTasks(tasks.length),
                style: theme.textTheme.titleMedium,
              ),
            ),
            for (final task in tasks.take(5)) TaskTile(task: task),
            if (tasks.length > 5)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const TasksScreen()),
                  ),
                  child: Text(l.dashboardAllTasks),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// V zimě pozvánka do přehledu sezóny (FR-D11).
class _SeasonCard extends StatelessWidget {
  const _SeasonCard({required this.year});

  final int year;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l.seasonTitle(year),
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(l.seasonCardBody),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.tonal(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => SeasonScreen(year: year)),
                ),
                child: Text(l.seasonCardAction),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Připomínka zálohy jednou za měsíc (FR-E3).
class _BackupCard extends ConsumerWidget {
  const _BackupCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.backup_outlined, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l.backupReminderTitle,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(l.backupReminderBody),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.tonalIcon(
                onPressed: () => exportBackup(context, ref),
                icon: const Icon(Icons.upload_file),
                label: Text(l.backupReminderAction),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Hero karta: co je dnes zapsané, nebo co by stálo za to udělat.
class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.summary});

  final TodaySummary summary;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final ZoneStatus? suggestion = summary.needsAttention.isEmpty
        ? null
        : summary.needsAttention.first;

    final String headline;
    final String body;
    if (summary.today.isNotEmpty) {
      headline = l.dashboardHeroToday(summary.today.length);
      body = l.dashboardHeroTodayBody;
    } else if (suggestion != null) {
      headline = l.dashboardHeroNothing;
      body = suggestion.daysSince == null
          ? l.dashboardHeroZoneEmpty(suggestion.zone.name)
          : l.dashboardHeroZoneStale(
              suggestion.zone.name,
              formatDaysAgo(l, suggestion.daysSince!),
            );
    } else {
      headline = l.dashboardHeroNothing;
      body = l.dashboardHeroAllFresh;
    }

    return Card(
      color: scheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              headline,
              style: theme.textTheme.titleLarge?.copyWith(
                color: scheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onPrimaryContainer,
              ),
            ),
            if (summary.today.isNotEmpty) ...[
              const SizedBox(height: 8),
              for (final a in summary.today.take(3)) ActivityTile(activity: a),
            ],
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ActivityFormScreen(
                    initialZoneId: summary.today.isEmpty
                        ? suggestion?.zone.id
                        : null,
                  ),
                ),
              ),
              icon: const Icon(Icons.edit_note),
              label: Text(l.dashboardLogActivity),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(height: 8),
            Text(value, style: theme.textTheme.headlineSmall),
            Text(label, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

/// Statický tip od Bódi podle ročního období.
class _TipCard extends StatelessWidget {
  const _TipCard({required this.tip});

  final String tip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.lightbulb_outline,
              size: 32,
              color: theme.colorScheme.tertiary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).dashboardTip,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(tip),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Zóny, kam se dlouho nikdo nepodíval.
class _AttentionCard extends StatelessWidget {
  const _AttentionCard({required this.statuses});

  final List<ZoneStatus> statuses;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                l.dashboardAttention,
                style: theme.textTheme.titleMedium,
              ),
            ),
            for (final s in statuses)
              ListTile(
                dense: true,
                leading: Icon(zoneIcon(s.zone.type)),
                title: Text(s.zone.name),
                subtitle: Text(
                  s.daysSince == null
                      ? l.dashboardZoneNoEntry
                      : l.dashboardZoneLast(formatDaysAgo(l, s.daysSince!)),
                ),
                trailing: const Icon(Icons.add),
                onTap: () => _addForZone(context, s.zone),
              ),
          ],
        ),
      ),
    );
  }

  void _addForZone(BuildContext context, ZoneEntity zone) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ActivityFormScreen(initialZoneId: zone.id),
      ),
    );
  }
}
