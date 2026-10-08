import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zahradnik_boda/core/time/calendar.dart';
import 'package:zahradnik_boda/features/activity/domain/activity_type.dart';
import 'package:zahradnik_boda/features/tasks/domain/task_entity.dart';
import 'package:zahradnik_boda/features/tasks/presentation/tasks_controller.dart';
import 'package:zahradnik_boda/features/weather/data/drift_garden_site_repository.dart';
import 'package:zahradnik_boda/features/weather/data/supabase_weather_source.dart';
import 'package:zahradnik_boda/features/weather/domain/garden_site.dart';
import 'package:zahradnik_boda/features/weather/domain/phenology.dart';
import 'package:zahradnik_boda/features/weather/domain/watering.dart';
import 'package:zahradnik_boda/features/weather/domain/weather.dart';
import 'package:zahradnik_boda/features/weather/presentation/weather_controller.dart';
import 'package:zahradnik_boda/features/weather/presentation/weather_screen.dart';
import 'package:zahradnik_boda/features/zones/domain/zone_entity.dart';
import 'package:zahradnik_boda/l10n/app_localizations.dart';

import '../../helpers/database.dart';
import '../../helpers/fakes.dart';

/// Počasí kolem [testNow] (7. 10. 2026): 7 dní zpět, 7 dní dopředu.
WeatherReport report({
  double pastDaily = 0,
  double today = 0,
  double tomorrow = 0,
  double? frostOn,
  DateTime? fetchedAt,
}) {
  final t = dayOnly(testNow);
  return WeatherReport(
    fetchedAt: fetchedAt ?? testNow,
    elevationM: 240,
    days: [
      for (var i = -7; i < 7; i++)
        DailyWeather(
          date: DateTime(t.year, t.month, t.day + i),
          precipMm: i < 0
              ? pastDaily
              : i == 0
              ? today
              : i == 1
              ? tomorrow
              : 0,
          tMinC: frostOn != null && i == frostOn ? -2 : 6,
          tMaxC: 15,
        ),
    ],
  );
}

class FakeWeatherSource implements WeatherSource {
  FakeWeatherSource(this.result);

  WeatherReport? result;
  WeatherFailure? failure;
  int calls = 0;

  @override
  bool get available => true;

  @override
  Future<WeatherReport> fetch(GardenLocation location) async {
    calls++;
    if (failure != null) throw WeatherException(failure!);
    return result!;
  }
}

TaskEntity wateringTask(String id, {String? zoneId, DateTime? due}) =>
    TaskEntity(
      id: id,
      title: 'Zálivka',
      zoneId: zoneId,
      due: due ?? dayOnly(testNow),
    );

final brno = GardenLocation(49.1951, 16.6068);

void main() {
  group('weather report', () {
    test('rain sums, next 24 h and JSON round trip', () {
      final r = report(pastDaily: 2, today: 1, tomorrow: 6);
      expect(r.rainLast7Days(testNow), 14);
      expect(r.rainNext24h(testNow), 6);
      expect(r.forecast(testNow), hasLength(7));
      expect(WeatherReport.fromJson(r.toJson()), r);
      final cached = CachedWeather(brno, r);
      expect(CachedWeather.fromJson(cached.toJson()), cached);
      expect(WeatherReport.fromJson({'days': []}), isNull);
    });

    test('location is rounded to ~1 km and checked for Czechia', () {
      expect(brno.lat, 49.2);
      expect(brno.lng, 16.61);
      expect(brno.isPlausible, isTrue);
      expect(GardenLocation(16.6, 49.2).isPlausible, isFalse);
    });

    test('server errors map to failures', () {
      expect(weatherFailureFor(401), WeatherFailure.notSignedIn);
      expect(weatherFailureFor(402), WeatherFailure.notPremium);
      expect(weatherFailureFor(503), WeatherFailure.providerError);
      expect(weatherFailureFor(502), WeatherFailure.providerError);
    });
  });

  group('watering (FR-W2, FR-W3)', () {
    const zones = [
      ZoneEntity(id: 'V', name: 'Zelenina', type: ZoneType.vegetable),
      ZoneEntity(id: 'H', name: 'Bylinky', type: ZoneType.herbs),
      ZoneEntity(id: 'L', name: 'Trávník', type: ZoneType.lawn),
      ZoneEntity(id: 'G', name: 'Skleník', type: ZoneType.greenhouse),
      ZoneEntity(
        id: 'F',
        name: 'Fóliovník',
        type: ZoneType.vegetable,
        covered: true,
      ),
      ZoneEntity(id: 'P', name: 'Jezírko', type: ZoneType.pond),
    ];

    test('thresholds per zone type, covered zones ignore rain', () {
      // 14 mm za týden: bylinky (12) stačí, zelenina (15) a trávník (20) ne.
      final advice = wateringAdvice(
        zones: zones,
        weather: report(pastDaily: 2),
        now: testNow,
      );
      final byId = {for (final a in advice) a.zone.id: a};
      expect(byId.keys, unorderedEquals(['V', 'H', 'L', 'G', 'F']));
      expect(byId['H']!.skip, isTrue);
      expect(byId['H']!.reason, SkipReason.rainedEnough);
      expect(byId['V']!.skip, isFalse);
      expect(byId['V']!.thresholdMm, 15);
      expect(byId['L']!.thresholdMm, 20);
      expect(byId['G']!.covered, isTrue);
      expect(byId['F']!.covered, isTrue);
      expect(byId['F']!.skip, isFalse);
    });

    test('rain in the forecast postpones watering', () {
      final advice = wateringAdvice(
        zones: zones,
        weather: report(tomorrow: 5),
        now: testNow,
      );
      final v = advice.firstWhere((a) => a.zone.id == 'V');
      expect(v.skip, isTrue);
      expect(v.reason, SkipReason.rainExpected);
      expect(advice.firstWhere((a) => a.zone.id == 'G').skip, isFalse);
    });

    test('which watering tasks can wait', () {
      final today = dayOnly(testNow);
      final advice = wateringAdvice(
        zones: zones,
        weather: report(pastDaily: 2),
        now: testNow,
      );
      final tasks = [
        wateringTask('herbs', zoneId: 'H'),
        wateringTask('veg', zoneId: 'V'),
        wateringTask(
          'later',
          zoneId: 'H',
          due: DateTime(today.year, today.month, today.day + 3),
        ),
        TaskEntity(id: 'weed', title: 'Pletí', zoneId: 'H', due: _d),
        wateringTask('garden'),
      ];
      final due = wateringTasksToPostpone(
        tasks: tasks,
        advice: advice,
        now: testNow,
      );
      expect(due.map((t) => t.id), ['herbs']);

      // Po vydatném dešti počká i zálivka bez zóny (všechny venkovní zóny).
      final wet = wateringAdvice(
        zones: zones,
        weather: report(pastDaily: 4),
        now: testNow,
      );
      expect(
        wateringTasksToPostpone(
          tasks: tasks,
          advice: wet,
          now: testNow,
        ).map((t) => t.id),
        unorderedEquals(['herbs', 'veg', 'garden']),
      );
      expect(
        postponeTarget(tasks.first, testNow),
        DateTime(today.year, today.month, today.day + 1),
      );
      expect(
        postponeTarget(
          wateringTask(
            't',
            due: DateTime(today.year, today.month, today.day + 1),
          ),
          testNow,
        ),
        DateTime(today.year, today.month, today.day + 2),
      );
    });

    test('frost warning for fresh plantings in season (FR-W4)', () {
      final acts = [
        activity(
          's',
          date: testNow.subtract(const Duration(days: 10)),
          zoneId: 'V',
          type: ActivityType.sowing,
        ),
        activity(
          'f',
          date: testNow.subtract(const Duration(days: 10)),
          zoneId: 'F',
          type: ActivityType.planting,
        ),
      ];
      final warning = frostWarning(
        weather: report(frostOn: 2),
        zones: zones,
        activities: acts,
        now: testNow,
      );
      expect(warning, isNotNull);
      expect(warning!.tMinC, -2);
      expect(warning.zones.map((z) => z.id), ['V']);
      expect(
        frostWarning(
          weather: report(frostOn: 5),
          zones: zones,
          activities: acts,
          now: testNow,
        ),
        isNull,
        reason: 'frost beyond 3 days',
      );
      expect(
        frostWarning(
          weather: report(frostOn: 1),
          zones: zones,
          activities: acts,
          now: DateTime(2026, 12, 7),
        ),
        isNull,
        reason: 'out of season',
      );
    });
  });

  group('phenology (FR-W5)', () {
    test('altitude shifts spring later and autumn earlier', () {
      expect(altitudeShiftDays(250, Season.spring), 0);
      expect(altitudeShiftDays(550, Season.spring), 9);
      expect(altitudeShiftDays(550, Season.autumn), -9);
      final apple = phenologyTable.firstWhere((e) => e.key == 'prune_apple');
      final w = windowFor(apple, 2027, 550);
      expect(w.from, DateTime(2027, 2, 24));
      expect(w.to, DateTime(2027, 4, 9));
      // Přes změnu času zůstává půlnoc.
      expect(w.to.hour, 0);
    });

    test('agenda shows only zone types the garden has', () {
      final orchard = phenologyAgenda(
        today: DateTime(2027, 3, 10),
        altitudeM: 250,
        zoneTypes: {ZoneType.fruit},
      );
      expect(
        orchard.now.map((w) => w.entry.key),
        containsAll(['prune_apple', 'prune_currant']),
      );
      expect(
        orchard.now.every((w) => w.entry.zoneTypes.contains(ZoneType.fruit)),
        isTrue,
      );
      final nothing = phenologyAgenda(
        today: DateTime(2027, 3, 10),
        altitudeM: 250,
        zoneTypes: {ZoneType.pond},
      );
      expect(nothing.now, isEmpty);
      expect(nothing.soon, isEmpty);
    });
  });

  group('DriftGardenSiteRepository', () {
    test('site in the garden row, cache and prefs in settings', () async {
      final db = memoryDatabase();
      addTearDown(db.close);
      final gardenId = await db.ensureDefaultGarden(
        newId: sequentialIds(),
        now: testNow,
      );
      final repo = DriftGardenSiteRepository(db, gardenId, () => testNow);
      expect(await repo.loadSite(), const GardenSite());
      await repo.saveSite(GardenSite(location: brno, altitudeM: 237));
      expect(await repo.loadSite(), GardenSite(location: brno, altitudeM: 237));
      final row = await db.select(db.gardens).getSingle();
      expect(row.locationLat, 49.2);

      final cache = CachedWeather(brno, report(pastDaily: 1));
      await repo.saveCache(cache);
      expect(await repo.loadCache(), cache);
      await repo.saveCache(null);
      expect(await repo.loadCache(), isNull);

      expect(await repo.loadPrefs(), const WeatherPrefs());
      const prefs = WeatherPrefs(autoPostpone: true, autoPostponedOn: 'x');
      await repo.savePrefs(prefs);
      expect(await repo.loadPrefs(), prefs);
    });
  });

  group('WeatherController', () {
    test('without backend or location nothing is fetched', () async {
      final c = makeWeatherContainer();
      addTearDown(c.dispose);
      final s = await c.read(weatherControllerProvider.future);
      expect(s.failure, WeatherFailure.unavailable);

      final source = FakeWeatherSource(report());
      final c2 = makeWeatherContainer(weather: source);
      addTearDown(c2.dispose);
      final s2 = await c2.read(weatherControllerProvider.future);
      expect(s2.failure, WeatherFailure.noLocation);
      expect(source.calls, 0);
    });

    test('fetches a stale report and caches it', () async {
      final site = InMemoryGardenSiteRepository(
        site: GardenSite(location: brno),
      );
      final source = FakeWeatherSource(report(pastDaily: 3));
      final c = makeWeatherContainer(site: site, weather: source);
      addTearDown(c.dispose);
      await c.read(weatherControllerProvider.future);
      await pumpEventQueue();
      final s = c.read(weatherControllerProvider).value!;
      expect(source.calls, 1);
      expect(s.report, source.result);
      expect(s.failure, isNull);
      expect(s.altitudeM, 240, reason: 'altitude from the weather provider');
      expect(site.cache?.report, source.result);

      // Čerstvé počasí se znovu nestahuje.
      await c.read(weatherControllerProvider.notifier).refresh();
      expect(source.calls, 1);
    });

    test('a failure keeps the cached report', () async {
      final cached = report(
        pastDaily: 1,
        fetchedAt: testNow.subtract(const Duration(hours: 5)),
      );
      final site = InMemoryGardenSiteRepository(
        site: GardenSite(location: brno),
        cache: CachedWeather(brno, cached),
      );
      final source = FakeWeatherSource(null)
        ..failure = WeatherFailure.notPremium;
      final c = makeWeatherContainer(site: site, weather: source);
      addTearDown(c.dispose);
      await c.read(weatherControllerProvider.future);
      await pumpEventQueue();
      final s = c.read(weatherControllerProvider).value!;
      expect(s.failure, WeatherFailure.notPremium);
      expect(s.report, cached);
    });

    test('moving the garden drops the old report and refetches', () async {
      final site = InMemoryGardenSiteRepository(
        site: GardenSite(location: brno),
        cache: CachedWeather(brno, report(pastDaily: 9)),
      );
      final source = FakeWeatherSource(report(pastDaily: 1));
      final c = makeWeatherContainer(site: site, weather: source);
      addTearDown(c.dispose);
      await c.read(weatherControllerProvider.future);
      final praha = GardenLocation(50.08, 14.42);
      await c
          .read(weatherControllerProvider.notifier)
          .saveSite(GardenSite(location: praha, altitudeM: 200));
      final s = c.read(weatherControllerProvider).value!;
      expect(site.site.location, praha);
      expect(s.report, source.result);
      expect(s.altitudeM, 200);
      expect(site.cache?.location, praha);
    });

    test('postponing and the once-a-day automation', () async {
      final tasks = InMemoryTaskRepository([
        wateringTask('w1', zoneId: 'Z1'),
        wateringTask('w2', zoneId: 'Z5'),
      ]);
      final site = InMemoryGardenSiteRepository(
        site: GardenSite(location: brno),
        prefs: const WeatherPrefs(autoPostpone: true),
      );
      final source = FakeWeatherSource(report(pastDaily: 3));
      final c = makeWeatherContainer(site: site, weather: source, tasks: tasks);
      addTearDown(c.dispose);
      await c.read(tasksControllerProvider.future);
      await c.read(weatherControllerProvider.future);
      await pumpEventQueue();
      final tomorrow = DateTime(2026, 10, 8);
      final list = c.read(tasksControllerProvider).value!;
      expect(list.firstWhere((t) => t.id == 'w1').snoozedUntil, tomorrow);
      expect(
        list.firstWhere((t) => t.id == 'w2').snoozedUntil,
        isNull,
        reason: 'greenhouse does not get rain',
      );
      expect(site.prefs.autoPostponedOn, '2026-10-07');

      // Další stažení téhož dne už úkol neposouvá.
      await c.read(weatherControllerProvider.notifier).refresh(force: true);
      expect(
        c
            .read(tasksControllerProvider)
            .value!
            .firstWhere((t) => t.id == 'w1')
            .snoozedUntil,
        tomorrow,
      );
    });
  });

  group('screens', () {
    testWidgets('weather screen shows advice and postpones watering', (
      tester,
    ) async {
      final tasks = InMemoryTaskRepository([wateringTask('w1', zoneId: 'Z1')]);
      final site = InMemoryGardenSiteRepository(
        site: GardenSite(location: brno, altitudeM: 300),
        cache: CachedWeather(brno, report(pastDaily: 3, frostOn: 1)),
      );
      await pumpScreen(
        tester,
        const WeatherScreen(),
        testOverrides(
          site: site,
          tasks: tasks,
          weather: FakeWeatherSource(report(pastDaily: 3)),
        ),
      );
      expect(find.text('Za posledních 7 dní napršelo 21 mm'), findsOneWidget);
      final button = find.text('Odložit 1 zálivku');
      await tester.scrollUntilVisible(
        button,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(button);
      await tester.pumpAndSettle();
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(find.text('Zálivka odložena o den'), findsOneWidget);
      expect(tasks.items['w1']!.snoozedUntil, DateTime(2026, 10, 8));
    });

    testWidgets('not premium shows the offer, phenology stays free', (
      tester,
    ) async {
      final source = FakeWeatherSource(null)
        ..failure = WeatherFailure.notPremium;
      await pumpScreen(
        tester,
        const WeatherScreen(),
        testOverrides(
          site: InMemoryGardenSiteRepository(site: GardenSite(location: brno)),
          weather: source,
        ),
      );
      expect(find.text('Zobrazit Premium'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Kalendář prací'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Kalendář prací'), findsOneWidget);
    });

    testWidgets('location form validates and saves', (tester) async {
      final site = InMemoryGardenSiteRepository();
      await pumpScreen(
        tester,
        const WeatherScreen(),
        testOverrides(site: site),
      );
      await tester.tap(find.text('Zadat polohu'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Zeměpisná šířka'),
        '49,1951',
      );
      await tester.tap(find.text('Uložit'));
      await tester.pumpAndSettle();
      expect(
        find.text('Vyplň šířku i délku, nebo obojí nech prázdné.'),
        findsOneWidget,
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Zeměpisná délka'),
        '16,6068',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nadmořská výška (m)'),
        '237',
      );
      await tester.tap(find.text('Uložit'));
      await tester.pumpAndSettle();
      expect(site.site, GardenSite(location: brno, altitudeM: 237));
      expect(find.text('Poloha zahrady'), findsOneWidget);
    });

    testWidgets('phone location failure is explained', (tester) async {
      await pumpScreen(
        tester,
        GardenLocationScreen(const WeatherState()),
        testOverrides(),
      );
      await tester.tap(find.text('Použít polohu telefonu'));
      await tester.pumpAndSettle();
      expect(
        find.text('Tady polohu telefonu zjistit nejde. Zadej ji ručně.'),
        findsOneWidget,
      );
    });
  });
}

final _d = DateTime(2026, 10, 7);

ProviderContainer makeWeatherContainer({
  InMemoryGardenSiteRepository? site,
  WeatherSource? weather,
  InMemoryTaskRepository? tasks,
}) => ProviderContainer(
  overrides: testOverrides(site: site, weather: weather, tasks: tasks),
);

Future<void> pumpScreen(
  WidgetTester tester,
  Widget screen,
  List<Override> overrides,
) async {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        locale: const Locale('cs'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: screen,
      ),
    ),
  );
  await tester.pumpAndSettle();
}
