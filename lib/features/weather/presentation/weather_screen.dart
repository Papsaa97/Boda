import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/widgets/discard_guard.dart';
import '../../../core/di/providers.dart';
import '../../../core/formatting/dates.dart';
import '../../../core/text/numbers.dart';
import '../../../core/time/calendar.dart';
import '../../../core/time/today.dart';
import '../../../core/widgets/load_error_view.dart';
import '../../../l10n/app_localizations.dart';
import '../../premium/presentation/paywall_screen.dart';
import '../../tasks/domain/task_entity.dart';
import '../../tasks/presentation/tasks_controller.dart';
import '../domain/garden_site.dart';
import '../domain/phenology.dart';
import '../domain/watering.dart';
import '../domain/weather.dart';
import 'weather_controller.dart';

String _mm(double v) => formatDecimal(v, maxFractionDigits: 1);

String _altitudeText(AppLocalizations l, WeatherState s) {
  if (s.site.altitudeM != null) {
    return l.weatherAltitudeValue('${s.site.altitudeM}');
  }
  final fromWeather = s.report?.elevationM;
  if (fromWeather != null) return l.weatherAltitudeFromWeather('$fromWeather');
  return l.weatherAltitudeUnknown;
}

String _weekday(DateTime d) => formatWeekdayIn(d);

/// Karta na dashboardu: mráz, zálivka po dešti a co je teď na řadě.
/// Když není co říct, nezobrazí se (klid místo stresu).
class WeatherCard extends ConsumerWidget {
  const WeatherCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final frost = ref.watch(frostWarningProvider);
    final postpone = ref.watch(wateringToPostponeProvider);
    final advice = ref.watch(wateringAdviceProvider);
    final agenda = ref.watch(phenologyAgendaProvider);
    final skip = advice.where((a) => a.skip).firstOrNull;
    final lines = <Widget>[
      if (frost != null)
        Text(
          '${l.weatherFrostTitle(formatDecimal(frost.tMinC, maxFractionDigits: 1), _weekday(frost.date))} '
          '${l.weatherFrostZones(frost.zones.map((z) => z.name).join(', '))}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.error,
          ),
        ),
      if (postpone.isNotEmpty && skip != null)
        Text(
          skip.reason == SkipReason.rainedEnough
              ? l.weatherCardRained(_mm(skip.rainMm))
              : l.weatherCardRainExpected,
        ),
      if (agenda.now.isNotEmpty)
        Text(
          l.weatherCardNow(
            agenda.now.take(2).map((w) => w.entry.title).join(', '),
          ),
        ),
    ];
    if (lines.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const WeatherScreen())),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      frost != null ? Icons.ac_unit : Icons.wb_cloudy_outlined,
                      color: frost != null
                          ? theme.colorScheme.error
                          : theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l.weatherTitle,
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
                const SizedBox(height: 8),
                for (final line in lines)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: line,
                  ),
                if (postpone.isNotEmpty)
                  Align(
                    alignment: Alignment.centerRight,
                    child: _PostponeButton(tasks: postpone),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Vstup na obrazovku z karty Zahrada.
class WeatherEntryCard extends StatelessWidget {
  const WeatherEntryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: ListTile(
        leading: const Icon(Icons.wb_cloudy_outlined),
        title: Text(l.weatherTitle),
        subtitle: Text(l.weatherCardSubtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const WeatherScreen())),
      ),
    );
  }
}

class _PostponeButton extends ConsumerWidget {
  const _PostponeButton({required this.tasks});

  final List<TaskEntity> tasks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return FilledButton.tonalIcon(
      icon: const Icon(Icons.water_drop_outlined),
      label: Text(l.weatherPostponeButton(tasks.length)),
      onPressed: () async {
        final messenger = ScaffoldMessenger.of(context);
        final count = await ref
            .read(weatherControllerProvider.notifier)
            .postponeWatering(tasks);
        messenger.showSnackBar(
          SnackBar(content: Text(l.weatherPostponed(count))),
        );
      },
    );
  }
}

/// Počasí, zálivka, mráz a fenologický kalendář (spec 5.6, V2).
class WeatherScreen extends ConsumerWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(weatherControllerProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.weatherTitle)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, stack) => LoadErrorView(error: e, stack: stack),
        data: (s) => RefreshIndicator(
          onRefresh: () =>
              ref.read(weatherControllerProvider.notifier).refresh(force: true),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              _SiteSection(state: s),
              const SizedBox(height: 12),
              _ForecastSection(state: s),
              if (s.report != null) ...[
                const SizedBox(height: 12),
                _WateringSection(state: s),
              ],
              const SizedBox(height: 12),
              _PhenologySection(state: s),
            ],
          ),
        ),
      ),
    );
  }
}

class _SiteSection extends StatelessWidget {
  const _SiteSection({required this.state});

  final WeatherState state;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final location = state.site.location;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 8, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.place_outlined),
                const SizedBox(width: 12),
                Text(
                  l.weatherSiteTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              location == null
                  ? l.weatherSiteNotSet
                  : l.weatherSiteSummary(
                      formatDecimal(location.lat),
                      formatDecimal(location.lng),
                      _altitudeText(l, state),
                    ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => GardenLocationScreen(state),
                  ),
                ),
                child: Text(
                  location == null ? l.weatherSiteSet : l.weatherSiteEdit,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ForecastSection extends ConsumerWidget {
  const _ForecastSection({required this.state});

  final WeatherState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final now = ref.watch(todayProvider);
    final report = state.report;
    final failure = state.failure;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l.weatherSectionForecast,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                if (state.loading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            if (failure != null) ...[
              const SizedBox(height: 8),
              Text(_failureText(l, failure)),
              if (failure == WeatherFailure.notPremium)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PaywallScreen()),
                    ),
                    child: Text(l.weatherShowPremium),
                  ),
                ),
              if (failure == WeatherFailure.offline ||
                  failure == WeatherFailure.providerError)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => ref
                        .read(weatherControllerProvider.notifier)
                        .refresh(force: true),
                    child: Text(l.weatherRetry),
                  ),
                ),
            ],
            if (report != null) ...[
              const SizedBox(height: 8),
              Text(l.weatherRainLast7(_mm(report.rainLast7Days(now)))),
              const SizedBox(height: 8),
              for (final d in report.forecast(now))
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Expanded(child: Text(capitalize(_weekday(d.date)))),
                      Text(
                        d.tMinC == null || d.tMaxC == null
                            ? l.weatherDayRowNoTemp(_mm(d.precipMm))
                            : l.weatherDayRow(
                                _mm(d.precipMm),
                                d.tMinC!.round().toString(),
                                d.tMaxC!.round().toString(),
                              ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                l.weatherFetchedAt(formatDateTime(report.fetchedAt)),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _failureText(AppLocalizations l, WeatherFailure f) =>
      switch (f) {
        WeatherFailure.unavailable => l.weatherUnavailable,
        WeatherFailure.notSignedIn => l.weatherNotSignedIn,
        WeatherFailure.notPremium => l.weatherNotPremium,
        WeatherFailure.noLocation => l.weatherNoLocation,
        WeatherFailure.offline => l.weatherOffline,
        WeatherFailure.providerError => l.weatherProviderError,
      };
}

class _WateringSection extends ConsumerWidget {
  const _WateringSection({required this.state});

  final WeatherState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final advice = ref.watch(wateringAdviceProvider);
    final postpone = ref.watch(wateringToPostponeProvider);
    final frost = ref.watch(frostWarningProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                l.weatherSectionWatering,
                style: theme.textTheme.titleMedium,
              ),
            ),
            if (frost != null)
              ListTile(
                leading: Icon(Icons.ac_unit, color: theme.colorScheme.error),
                title: Text(
                  l.weatherFrostTitle(
                    formatDecimal(frost.tMinC, maxFractionDigits: 1),
                    _weekday(frost.date),
                  ),
                ),
                subtitle: Text(
                  l.weatherFrostZones(
                    frost.zones.map((z) => z.name).join(', '),
                  ),
                ),
              ),
            if (advice.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Text(l.weatherWateringEmpty),
              ),
            for (final a in advice)
              ListTile(
                dense: true,
                leading: Icon(
                  a.skip ? Icons.check_circle_outline : Icons.water_drop,
                ),
                title: Text(a.zone.name),
                subtitle: Text(_adviceText(l, a)),
              ),
            if (postpone.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: _PostponeButton(tasks: postpone),
                ),
              ),
            SwitchListTile(
              title: Text(l.weatherAutoPostpone),
              subtitle: Text(l.weatherAutoPostponeSubtitle),
              value: state.prefs.autoPostpone,
              onChanged: (v) => ref
                  .read(weatherControllerProvider.notifier)
                  .setAutoPostpone(v),
            ),
          ],
        ),
      ),
    );
  }

  static String _adviceText(AppLocalizations l, WateringAdvice a) {
    if (a.covered) return l.weatherAdviceCovered;
    return switch (a.reason) {
      SkipReason.rainedEnough => l.weatherAdviceRained(
        _mm(a.rainMm),
        _mm(a.thresholdMm),
      ),
      SkipReason.rainExpected => l.weatherAdviceRainExpected,
      null => l.weatherAdviceWater(_mm(a.rainMm), _mm(a.thresholdMm)),
    };
  }
}

class _PhenologySection extends ConsumerWidget {
  const _PhenologySection({required this.state});

  final WeatherState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final agenda = ref.watch(phenologyAgendaProvider);
    final altitude = state.altitudeM == null
        ? l.weatherAltitudeValue('$defaultAltitudeM')
        : l.weatherAltitudeValue('${state.altitudeM}');
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.weatherSectionPhenology,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l.weatherPhenologyAltitude(altitude),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (agenda.now.isEmpty && agenda.soon.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Text(l.weatherPhenologyEmpty),
              ),
            if (agenda.now.isNotEmpty) ...[
              _Subheader(l.weatherPhenologyNow),
              for (final w in agenda.now) _PhenologyTile(window: w),
            ],
            if (agenda.soon.isNotEmpty) ...[
              _Subheader(l.weatherPhenologySoon),
              for (final w in agenda.soon) _PhenologyTile(window: w),
            ],
          ],
        ),
      ),
    );
  }
}

class _Subheader extends StatelessWidget {
  const _Subheader(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
    child: Text(text, style: Theme.of(context).textTheme.labelLarge),
  );
}

class _PhenologyTile extends ConsumerWidget {
  const _PhenologyTile({required this.window});

  final PhenologyWindow window;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final e = window.entry;
    final range = l.weatherPhenologyRange(
      DateFormat('d. M.', appLocale).format(window.from),
      DateFormat('d. M.', appLocale).format(window.to),
    );
    return ListTile(
      title: Text(e.title),
      subtitle: Text(e.note == null ? range : '$range\n${e.note}'),
      isThreeLine: e.note != null,
      trailing: IconButton(
        tooltip: l.weatherPhenologyAddTask,
        icon: const Icon(Icons.add_task),
        onPressed: () async {
          final messenger = ScaffoldMessenger.of(context);
          final today = dayOnly(ref.read(clockProvider)());
          final existing = ref.read(tasksControllerProvider).value ?? const [];
          if (existing.any((t) => t.isOpen && t.title == e.title)) {
            messenger.showSnackBar(
              SnackBar(content: Text(l.weatherPhenologyTaskExists)),
            );
            return;
          }
          await ref
              .read(tasksControllerProvider.notifier)
              .create(
                TaskEntity(
                  id: '',
                  title: e.title,
                  due: window.from.isAfter(today) ? window.from : today,
                  notes: e.note,
                ),
              );
          final failed = ref.read(tasksControllerProvider).hasError;
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                failed ? l.commonSaveFailed : l.weatherPhenologyTaskAdded,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Zadání polohy a výšky zahrady.
class GardenLocationScreen extends ConsumerStatefulWidget {
  const GardenLocationScreen(this.initial, {super.key});

  final WeatherState initial;

  @override
  ConsumerState<GardenLocationScreen> createState() =>
      _GardenLocationScreenState();
}

class _GardenLocationScreenState extends ConsumerState<GardenLocationScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _lat;
  late final TextEditingController _lng;
  late final TextEditingController _altitude;
  bool _locating = false;
  late final String _initialState;

  @override
  void initState() {
    super.initState();
    final site = widget.initial.site;
    _lat = TextEditingController(
      text: site.location == null ? '' : formatDecimal(site.location!.lat),
    );
    _lng = TextEditingController(
      text: site.location == null ? '' : formatDecimal(site.location!.lng),
    );
    _altitude = TextEditingController(text: site.altitudeM?.toString() ?? '');
    _initialState = _snapshot();
  }

  String _snapshot() => [_lat.text, _lng.text, _altitude.text].join('|');

  @override
  void dispose() {
    _lat.dispose();
    _lng.dispose();
    _altitude.dispose();
    super.dispose();
  }

  String? _coordinate(String? text, double min, double max) {
    if (text == null || text.trim().isEmpty) return null;
    final v = parseDecimal(text);
    if (v == null || v < min || v > max) {
      return AppLocalizations.of(context).weatherInvalidCoordinate;
    }
    return null;
  }

  Future<void> _useDevice() async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _locating = true);
    try {
      final loc = await ref.read(deviceLocationProvider).current();
      _lat.text = formatDecimal(loc.lat);
      _lng.text = formatDecimal(loc.lng);
    } on DeviceLocationException catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(switch (e.failure) {
            DeviceLocationFailure.serviceDisabled =>
              l.weatherDeviceLocationDisabled,
            DeviceLocationFailure.denied => l.weatherDeviceLocationDenied,
            DeviceLocationFailure.unsupported =>
              l.weatherDeviceLocationUnsupported,
            DeviceLocationFailure.failed => l.weatherDeviceLocationFailed,
          }),
        ),
      );
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    if (!_form.currentState!.validate()) return;
    final lat = parseDecimal(_lat.text);
    final lng = parseDecimal(_lng.text);
    if ((lat == null) != (lng == null)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.weatherLocationIncomplete)));
      return;
    }
    final location = lat == null ? null : GardenLocation(lat, lng!);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(weatherControllerProvider.notifier)
          .saveSite(
            GardenSite(
              location: location,
              altitudeM: parseDecimal(_altitude.text)?.round(),
            ),
          );
    } on Exception catch (e, stack) {
      // Formulář zůstane vyplněný, uživatel to může zkusit znovu.
      ref.read(crashReporterProvider).recordError(e, stack);
      messenger.showSnackBar(SnackBar(content: Text(l.commonSaveFailed)));
      return;
    }
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lat = parseDecimal(_lat.text);
    final lng = parseDecimal(_lng.text);
    final implausible =
        lat != null && lng != null && !GardenLocation(lat, lng).isPlausible;
    return DiscardGuard(
      hasChanges: () => _snapshot() != _initialState,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.weatherSiteTitle),
          actions: [TextButton(onPressed: _save, child: Text(l.commonSave))],
        ),
        body: Form(
          key: _form,
          onChanged: () => setState(() {}),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(l.weatherLocationIntro),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _locating ? null : _useDevice,
                icon: _locating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location),
                label: Text(l.weatherUseDeviceLocation),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lat,
                decoration: InputDecoration(
                  labelText: l.weatherLatLabel,
                  hintText: l.weatherLatHint,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                validator: (v) => _coordinate(v, -90, 90),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lng,
                decoration: InputDecoration(
                  labelText: l.weatherLngLabel,
                  hintText: l.weatherLngHint,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                validator: (v) => _coordinate(v, -180, 180),
              ),
              if (implausible) ...[
                const SizedBox(height: 8),
                Text(
                  l.weatherImplausibleLocation,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 12),
              TextFormField(
                controller: _altitude,
                decoration: InputDecoration(
                  labelText: l.weatherAltitudeLabel,
                  helperText: l.weatherAltitudeHelper,
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  final a = parseDecimal(v);
                  return a == null || a < 0 || a > 2000
                      ? l.weatherAltitudeInvalid
                      : null;
                },
              ),
              const SizedBox(height: 16),
              if (widget.initial.site.location != null)
                TextButton.icon(
                  onPressed: () {
                    _lat.clear();
                    _lng.clear();
                    setState(() {});
                  },
                  icon: const Icon(Icons.location_off_outlined),
                  label: Text(l.weatherClearLocation),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
