import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:zahradnik_boda/core/time/today.dart';
import 'package:zahradnik_boda/features/activity/presentation/screens/timeline_screen.dart';

import '../helpers/fakes.dart';

void main() {
  setUpAll(() => initializeDateFormatting('cs'));

  final sample = [
    activity(
      'a',
      date: DateTime(2026, 10, 7, 8),
      zoneId: 'Z1',
      title: 'Zálivka rajčat a paprik ve fóliovníku',
      notes: 'Hodně dlouhá poznámka',
    ),
    activity(
      'b',
      date: DateTime(2026, 10, 2, 9),
      zoneId: 'Z3',
      title: 'Řez jabloní',
    ),
  ];

  group('text scaled to 200 % (NFR-6) does not break layout', () {
    setUp(() {
      TestWidgetsFlutterBinding
              .instance
              .platformDispatcher
              .textScaleFactorTestValue =
          2.0;
    });
    tearDown(() {
      TestWidgetsFlutterBinding.instance.platformDispatcher
          .clearTextScaleFactorTestValue();
    });

    testWidgets('dashboard, diary, zones and form', (tester) async {
      await pumpApp(
        tester,
        testOverrides(activities: InMemoryActivityRepository(sample)),
      );
      expect(find.text('Co dnes?'), findsOneWidget);

      await tester.tap(find.text('Deník'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Zóny'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Deník'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Řez jabloní'),
        300,
        scrollable: find
            .descendant(
              of: find.byType(TimelineScreen),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Řez jabloní'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Upravit'));
      await tester.pumpAndSettle();
      expect(find.text('Upravit záznam'), findsOneWidget);
    });

    testWidgets('onboarding', (tester) async {
      await pumpApp(
        tester,
        testOverrides(zones: InMemoryZoneRepository(const [])),
      );
      expect(find.text('Co pěstuješ?'), findsOneWidget);
    });
  });

  testWidgets('dashboard rolls over to the next day', (tester) async {
    var now = DateTime(2026, 10, 7, 23, 50);
    await pumpApp(
      tester,
      testOverrides(
        activities: InMemoryActivityRepository([
          activity(
            'a',
            date: DateTime(2026, 10, 7, 20),
            title: 'Večerní zálivka',
          ),
        ]),
        clock: () => now,
      ),
    );
    expect(find.text('Dnes máš zapsaný 1 záznam'), findsOneWidget);

    // Aplikace zůstala otevřená přes půlnoc.
    now = DateTime(2026, 10, 8, 7, 0);
    final container = ProviderScope.containerOf(
      tester.element(find.text('Co dnes?')),
    );
    container.read(todayProvider.notifier).refresh();
    await tester.pumpAndSettle();

    expect(find.text('Dnes zatím nic'), findsOneWidget);
    expect(find.text('včera'), findsOneWidget);
  });

  testWidgets('leaving an untouched form does not ask anything', (
    tester,
  ) async {
    await pumpApp(tester, testOverrides());
    await tester.tap(find.byTooltip('Nový záznam'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Zpět'));
    await tester.pumpAndSettle();

    expect(find.text('Zahodit změny?'), findsNothing);
    expect(find.text('Co dnes?'), findsOneWidget);
  });

  testWidgets('leaving a form with text asks before discarding', (
    tester,
  ) async {
    final repo = InMemoryActivityRepository();
    await pumpApp(tester, testOverrides(activities: repo));
    await tester.tap(find.byTooltip('Nový záznam'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Název aktivity'),
      'Rozepsáno',
    );

    await tester.tap(find.byTooltip('Zpět'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pokračovat v úpravách'));
    await tester.pumpAndSettle();
    expect(find.text('Nový záznam'), findsOneWidget);
    expect(find.text('Rozepsáno'), findsOneWidget);
    expect(repo.items, isEmpty);
  });

  testWidgets('editing keeps the record and can remove its note', (
    tester,
  ) async {
    final repo = InMemoryActivityRepository([
      activity(
        'a',
        date: DateTime(2026, 10, 6, 9),
        title: 'Pletí',
        notes: 'mrkev',
      ),
    ]);
    await pumpApp(tester, testOverrides(activities: repo));
    await tester.tap(find.text('Deník'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pletí'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Upravit'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Poznámka (volitelné)'),
      '',
    );
    await tester.tap(find.widgetWithText(TextButton, 'Uložit'));
    await tester.pumpAndSettle();

    expect(repo.items['a']!.notes, isNull);
    expect(repo.items['a']!.title, 'Pletí');
    // Po uložení je zpátky detail záznamu.
    expect(find.text('Záznam'), findsOneWidget);
  });
}
