import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/time/today.dart';
import '../../../core/formatting/dates.dart';
import '../../activity/presentation/controllers/activity_controller.dart';
import '../../activity/presentation/screens/activity_form_screen.dart';
import '../../activity/presentation/widgets/activity_tile.dart';
import '../../zones/domain/zone_entity.dart';
import '../../zones/presentation/zones_controller.dart';
import '../domain/boda_tips.dart';
import '../domain/today_summary.dart';
import '../../zones/presentation/zone_icons.dart';

/// Souhrn „Co dnes?“ přepočítaný při každé změně deníku nebo zón.
final todaySummaryProvider = Provider<AsyncValue<TodaySummary>>((ref) {
  final activities = ref.watch(activityControllerProvider);
  final zones = ref.watch(zonesControllerProvider);
  final now = ref.watch(todayProvider);

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
    buildTodaySummary(
      activities: activities.value!,
      zones: zones.value!,
      now: now,
    ),
  );
});

/// Dashboard „Co dnes?“ v podobě bento mřížky.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(todaySummaryProvider);
    final now = ref.watch(todayProvider);
    final dateLabel = DateFormat('EEEE d. MMMM', appLocale).format(now);

    return Scaffold(
      appBar: AppBar(title: const Text('Co dnes?')),
      body: summaryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Chyba: $error')),
        data: (summary) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
          children: [
            Text(
              _capitalize(dateLabel),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _HeroCard(summary: summary),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.event_available,
                    value: '${summary.lastWeekCount}',
                    label: 'záznamů za 7 dní',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.history,
                    value: summary.lastActivity == null
                        ? '–'
                        : formatDaysAgo(
                            calendarDaysBetween(
                              summary.lastActivity!.date,
                              now,
                            ),
                          ),
                    label: 'poslední záznam',
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

  static String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

/// Hero karta: co je dnes zapsané, nebo co by stálo za to udělat.
class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.summary});

  final TodaySummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final ZoneStatus? suggestion = summary.needsAttention.isEmpty
        ? null
        : summary.needsAttention.first;

    final String headline;
    final String body;
    if (summary.today.isNotEmpty) {
      headline = summary.today.length == 1
          ? 'Dnes máš zapsaný 1 záznam'
          : 'Dnes máš zapsané záznamy: ${summary.today.length}';
      body = 'Dobrá práce. Zahrada ti to vrátí.';
    } else if (suggestion != null) {
      headline = 'Dnes zatím nic';
      body = suggestion.daysSince == null
          ? 'V zóně ${suggestion.zone.name} ještě nemáš žádný záznam. Co se tam teď děje?'
          : 'Poslední záznam v zóně ${suggestion.zone.name} je ${formatDaysAgo(suggestion.daysSince!)}. Mrkni, jak se jí daří.';
    } else {
      headline = 'Dnes zatím nic';
      body = 'Všechny zóny máš za poslední týden zapsané. Co dnes uděláš?';
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
              label: const Text('Zapsat aktivitu'),
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
                  Text('Tip od Bódi', style: theme.textTheme.titleMedium),
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
                'Zaslouží pozornost',
                style: theme.textTheme.titleMedium,
              ),
            ),
            for (final s in statuses)
              ListTile(
                dense: true,
                leading: Icon(zoneIcon(s.zone.id)),
                title: Text(s.zone.name),
                subtitle: Text(
                  s.daysSince == null
                      ? 'zatím bez záznamu'
                      : 'naposledy ${formatDaysAgo(s.daysSince!)}',
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
