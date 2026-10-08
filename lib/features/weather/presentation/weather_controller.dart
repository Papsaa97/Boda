import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/time/calendar.dart';
import '../../../core/time/today.dart';
import '../../activity/presentation/controllers/activity_controller.dart';
import '../../tasks/domain/task_entity.dart';
import '../../tasks/presentation/tasks_controller.dart';
import '../../zones/domain/zone_entity.dart';
import '../../zones/presentation/zones_controller.dart';
import '../domain/garden_site.dart';
import '../domain/phenology.dart';
import '../domain/watering.dart';
import '../domain/weather.dart';

/// Po jaké době se počasí stahuje znovu (předpověď se tak často nemění
/// a každé stažení něco stojí).
const weatherMaxAge = Duration(hours: 3);

/// Stav počasí na kartě a obrazovce Počasí a kalendář.
class WeatherState extends Equatable {
  const WeatherState({
    this.site = const GardenSite(),
    this.report,
    this.failure,
    this.loading = false,
    this.prefs = const WeatherPrefs(),
  });

  final GardenSite site;

  /// Poslední stažené počasí (může být starší, když stažení selhalo).
  final WeatherReport? report;

  /// Proč se počasí naposledy nepodařilo stáhnout.
  final WeatherFailure? failure;
  final bool loading;
  final WeatherPrefs prefs;

  /// Výška pro fenologii: zadaná, jinak podle poskytovatele počasí.
  int? get altitudeM => site.altitudeM ?? report?.elevationM;

  WeatherState copyWith({
    GardenSite? site,
    WeatherReport? Function()? report,
    WeatherFailure? Function()? failure,
    bool? loading,
    WeatherPrefs? prefs,
  }) => WeatherState(
    site: site ?? this.site,
    report: report != null ? report() : this.report,
    failure: failure != null ? failure() : this.failure,
    loading: loading ?? this.loading,
    prefs: prefs ?? this.prefs,
  );

  @override
  List<Object?> get props => [site, report, failure, loading, prefs];
}

class WeatherController extends AsyncNotifier<WeatherState> {
  @override
  Future<WeatherState> build() async {
    // Po přihlášení nebo zakoupení Premium se počasí zkusí znovu.
    ref.watch(currentUserProvider.select((u) => u.value?.id));
    final repo = ref.watch(gardenSiteRepositoryProvider);
    final site = await repo.loadSite();
    final cache = await repo.loadCache();
    final prefs = await repo.loadPrefs();
    final initial = WeatherState(
      site: site,
      prefs: prefs,
      report: cache != null && cache.location == site.location
          ? cache.report
          : null,
    );
    if (!ref.read(weatherSourceProvider).available) {
      return initial.copyWith(failure: () => WeatherFailure.unavailable);
    }
    if (site.location == null) {
      return initial.copyWith(failure: () => WeatherFailure.noLocation);
    }
    if (_isStale(initial.report)) {
      // Stáhne se až po zveřejnění stavu (uložené počasí se ukáže hned).
      unawaited(
        Future.microtask(() async {
          await future;
          if (ref.mounted) await refresh();
        }),
      );
    }
    return initial;
  }

  DateTime get _now => ref.read(clockProvider)();

  bool _isStale(WeatherReport? report) =>
      report == null || _now.difference(report.fetchedAt) > weatherMaxAge;

  /// Stáhne počasí; bez [force] jen když je uložené starší než 3 h.
  Future<void> refresh({bool force = false}) async {
    final current = state.value;
    if (current == null || current.loading) return;
    final source = ref.read(weatherSourceProvider);
    final location = current.site.location;
    if (!source.available) {
      state = AsyncData(
        current.copyWith(failure: () => WeatherFailure.unavailable),
      );
      return;
    }
    if (location == null) {
      state = AsyncData(
        current.copyWith(failure: () => WeatherFailure.noLocation),
      );
      return;
    }
    if (!force && !_isStale(current.report)) return;
    state = AsyncData(current.copyWith(loading: true));
    try {
      final report = await source.fetch(location);
      await ref
          .read(gardenSiteRepositoryProvider)
          .saveCache(CachedWeather(location, report));
      if (!ref.mounted) return;
      final latest = state.value ?? current;
      if (latest.site.location != location) return;
      state = AsyncData(
        latest.copyWith(
          report: () => report,
          failure: () => null,
          loading: false,
        ),
      );
      await _autoPostpone();
    } on WeatherException catch (e) {
      if (!ref.mounted) return;
      final latest = state.value ?? current;
      state = AsyncData(
        latest.copyWith(failure: () => e.failure, loading: false),
      );
    }
  }

  /// Uloží polohu a výšku; po změně polohy staré počasí neplatí.
  Future<void> saveSite(GardenSite site) async {
    final current = state.value ?? const WeatherState();
    final repo = ref.read(gardenSiteRepositoryProvider);
    await repo.saveSite(site);
    final moved = site.location != current.site.location;
    if (moved) await repo.saveCache(null);
    state = AsyncData(
      current.copyWith(
        site: site,
        report: moved ? () => null : null,
        failure: moved ? () => null : null,
      ),
    );
    if (moved) await refresh(force: true);
  }

  Future<void> setAutoPostpone(bool value) async {
    final current = state.value ?? const WeatherState();
    final prefs = current.prefs.copyWith(autoPostpone: value);
    await ref.read(gardenSiteRepositoryProvider).savePrefs(prefs);
    state = AsyncData(current.copyWith(prefs: prefs));
    if (value) await _autoPostpone();
  }

  /// Odloží zálivku po dešti (FR-W3, jedno klepnutí). Vrací počet úkolů.
  Future<int> postponeWatering(List<TaskEntity> tasks) async {
    final now = _now;
    final controller = ref.read(tasksControllerProvider.notifier);
    for (final t in tasks) {
      await controller.postponeTo(t.id, postponeTarget(t, now));
    }
    return tasks.length;
  }

  /// Automatika (FR-W3): nejvýš jednou denně, aby se zálivka
  /// neposouvala s každým stažením počasí dál.
  Future<void> _autoPostpone() async {
    final current = state.value;
    if (current == null || !current.prefs.autoPostpone) return;
    final report = current.report;
    if (report == null) return;
    final now = _now;
    final today = formatDateKey(now);
    if (current.prefs.autoPostponedOn == today) return;
    try {
      final zones = await ref.read(zonesControllerProvider.future);
      final tasks = await ref.read(tasksControllerProvider.future);
      final due = wateringTasksToPostpone(
        tasks: tasks,
        advice: wateringAdvice(zones: zones, weather: report, now: now),
        now: now,
      );
      await postponeWatering(due);
      final prefs = current.prefs.copyWith(autoPostponedOn: () => today);
      await ref.read(gardenSiteRepositoryProvider).savePrefs(prefs);
      if (!ref.mounted) return;
      state = AsyncData((state.value ?? current).copyWith(prefs: prefs));
    } on Exception catch (e) {
      debugPrint('Automatické odložení zálivky selhalo: $e');
    }
  }
}

final weatherControllerProvider =
    AsyncNotifierProvider<WeatherController, WeatherState>(
      WeatherController.new,
    );

/// Rada k zálivce po zónách (FR-W2, FR-W3); prázdná bez počasí.
final wateringAdviceProvider = Provider<List<WateringAdvice>>((ref) {
  final report = ref.watch(weatherControllerProvider).value?.report;
  if (report == null) return const [];
  return wateringAdvice(
    zones: ref.watch(zonesControllerProvider).value ?? const [],
    weather: report,
    now: ref.watch(todayProvider),
  );
});

/// Úkoly zálivky, které jde po dešti odložit.
final wateringToPostponeProvider = Provider<List<TaskEntity>>((ref) {
  final advice = ref.watch(wateringAdviceProvider);
  if (advice.isEmpty) return const [];
  return wateringTasksToPostpone(
    tasks: ref.watch(tasksControllerProvider).value ?? const [],
    advice: advice,
    now: ref.watch(todayProvider),
  );
});

/// Varování před mrazem (FR-W4); null bez počasí nebo bez rizika.
final frostWarningProvider = Provider<FrostWarning?>((ref) {
  final report = ref.watch(weatherControllerProvider).value?.report;
  if (report == null) return null;
  return frostWarning(
    weather: report,
    zones: ref.watch(zonesControllerProvider).value ?? const [],
    activities: ref.watch(activityControllerProvider).value ?? const [],
    now: ref.watch(todayProvider),
  );
});

/// Fenologický kalendář pro druhy zón, které zahrada má (FR-W5).
/// Funguje bez účtu i bez počasí; výška podle zadání nebo počasí.
final phenologyAgendaProvider =
    Provider<({List<PhenologyWindow> now, List<PhenologyWindow> soon})>((ref) {
      final zones = ref.watch(activeZonesProvider);
      final altitude = ref.watch(
        weatherControllerProvider.select((s) => s.value?.altitudeM),
      );
      return phenologyAgenda(
        today: ref.watch(todayProvider),
        altitudeM: altitude,
        zoneTypes: {for (final ZoneEntity z in zones) z.type},
      );
    });
