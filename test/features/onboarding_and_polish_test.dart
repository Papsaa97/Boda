import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:zahradnik_boda_mvp01/features/activity/presentation/controllers/activity_controller.dart';

import '../helpers/fakes.dart';

void main() {
  setUpAll(() => initializeDateFormatting('cs'));

  testWidgets('first run: welcome, pick zones, land on Co dnes?', (tester) async {
    final zones = InMemoryZoneRepository(const []);
    await pumpApp(tester, testOverrides(zones: zones));

    await tester.tap(find.text('Začít bez registrace'));
    await tester.pumpAndSettle();
    expect(find.text('Co máš na zahradě?'), findsOneWidget);

    // Zelenina je předvybraná, přidáme Bylinky a Zeleninu odebereme.
    await tester.tap(find.text('Bylinky'));
    await tester.tap(find.text('Zelenina'));
    await tester.pump();
    await tester.tap(find.text('Pokračovat'));
    await tester.pumpAndSettle();
    expect(find.text('Tvoje zahrada je připravená'), findsOneWidget);

    await tester.tap(find.text('Jdeme na zahradu'));
    await tester.pumpAndSettle();

    expect(zones.items.keys, ['Z6']);
    expect(find.text('Co dnes?'), findsOneWidget);
  });

  testWidgets('cannot continue onboarding with no zone selected', (tester) async {
    await pumpApp(tester, testOverrides(zones: InMemoryZoneRepository(const [])));
    await tester.tap(find.text('Začít bez registrace'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Zelenina'));
    await tester.pump();

    final button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Vyber aspoň jednu'));
    expect(button.onPressed, isNull);
  });

  testWidgets('quick pick fills the activity title', (tester) async {
    final repo = InMemoryActivityRepository();
    await pumpApp(tester, testOverrides(activities: repo));

    await tester.tap(find.byTooltip('Nový záznam'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ActionChip, 'Hnojení'));
    await tester.pump();
    await tester.ensureVisible(find.text('Uložit záznam'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Uložit záznam'));
    await tester.pumpAndSettle();

    expect(repo.items.values.single.title, 'Hnojení');
  });

  testWidgets('timeline can be filtered by zone', (tester) async {
    final repo = InMemoryActivityRepository([
      activity('a', date: DateTime(2026, 10, 6, 9), zoneId: 'Z1', title: 'Zálivka mrkve'),
      activity('b', date: DateTime(2026, 10, 5, 9), zoneId: 'Z3', title: 'Řez jabloně'),
    ]);
    await pumpApp(tester, testOverrides(activities: repo));
    await tester.tap(find.text('Deník'));
    await tester.pumpAndSettle();

    expect(find.text('Zálivka mrkve'), findsOneWidget);
    expect(find.text('Řez jabloně'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Ovocný sad'));
    await tester.pumpAndSettle();
    expect(find.text('Zálivka mrkve'), findsNothing);
    expect(find.text('Řez jabloně'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Vše'));
    await tester.pumpAndSettle();
    expect(find.text('Zálivka mrkve'), findsOneWidget);
  });

  testWidgets('failed save keeps the diary and the form open', (tester) async {
    final repo = FailingActivityRepository([
      activity('a', date: DateTime(2026, 10, 6, 9), title: 'Stará zálivka'),
    ]);
    await pumpApp(tester, testOverrides(activities: repo));

    await tester.tap(find.byTooltip('Nový záznam'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Název aktivity'), 'Nová zálivka');
    await tester.ensureVisible(find.text('Uložit záznam'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Uložit záznam'));
    await tester.pumpAndSettle();

    expect(find.text('Záznam se nepodařilo uložit.'), findsOneWidget);
    expect(find.text('Nový záznam'), findsOneWidget);

    await tester.tap(find.byTooltip('Zpět'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Deník'));
    await tester.pumpAndSettle();
    expect(find.text('Stará zálivka'), findsOneWidget);
  });

  test('failed delete keeps previous list in state', () async {
    final repo = FailingActivityRepository([
      activity('a', date: DateTime(2026, 10, 6, 9)),
    ]);
    final container = makeContainer(activities: repo);
    addTearDown(container.dispose);
    await container.read(activityControllerProvider.future);

    await container.read(activityControllerProvider.notifier).deleteActivity('a');

    final state = container.read(activityControllerProvider);
    expect(state.hasError, isTrue);
    expect(state.value!.single.id, 'a');
  });
}
