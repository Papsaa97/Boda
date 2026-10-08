import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'helpers/fakes.dart';

void main() {
  setUpAll(() => initializeDateFormatting('cs'));

  testWidgets('empty diary suggests a zone on the Co dnes? dashboard', (
    tester,
  ) async {
    await pumpApp(tester, testOverrides());

    expect(find.text('Co dnes?'), findsOneWidget);
    expect(find.text('Dnes zatím nic'), findsOneWidget);
    expect(find.text('Tip od Bódi'), findsOneWidget);
    expect(find.text('Zapsat aktivitu'), findsOneWidget);
  });

  testWidgets('adding an activity shows it on the dashboard and timeline', (
    tester,
  ) async {
    final repo = InMemoryActivityRepository();
    await pumpApp(tester, testOverrides(activities: repo));

    await tester.tap(find.byTooltip('Nový záznam'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Název aktivity'),
      'Výsadba česneku',
    );
    await tester.ensureVisible(find.text('Uložit záznam'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Uložit záznam'));
    await tester.pumpAndSettle();

    expect(repo.items.values.single.title, 'Výsadba česneku');
    expect(find.text('Dnes máš zapsaný 1 záznam'), findsOneWidget);
    expect(find.text('Výsadba česneku'), findsOneWidget);

    await tester.tap(find.text('Deník'));
    await tester.pumpAndSettle();
    expect(find.text('Dnes'), findsWidgets);
    expect(find.text('Výsadba česneku'), findsWidgets);
  });

  testWidgets('title is required', (tester) async {
    await pumpApp(tester, testOverrides());

    await tester.tap(find.byTooltip('Nový záznam'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Uložit záznam'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Uložit záznam'));
    await tester.pumpAndSettle();

    expect(find.text('Zadej název aktivity'), findsOneWidget);
  });

  testWidgets('activity can be deleted from its detail', (tester) async {
    final repo = InMemoryActivityRepository([
      activity('a', date: DateTime(2026, 10, 5, 9), title: 'Řez maliní'),
    ]);
    await pumpApp(tester, testOverrides(activities: repo));

    await tester.tap(find.text('Deník'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Řez maliní'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Smazat'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Smazat'));
    await tester.pumpAndSettle();

    expect(repo.items, isEmpty);
    expect(find.text('Zatím žádné záznamy'), findsOneWidget);
  });

  testWidgets('a zone with activities cannot be deleted', (tester) async {
    final repo = InMemoryActivityRepository([
      activity('a', date: DateTime(2026, 10, 5, 9), zoneId: 'Z1'),
    ]);
    final zones = InMemoryZoneRepository();
    await pumpApp(tester, testOverrides(activities: repo, zones: zones));

    await tester.tap(find.text('Zóny'));
    await tester.pumpAndSettle();
    final zeleninaTile = find.widgetWithText(ListTile, 'Zelenina');
    await tester.tap(
      find.descendant(
        of: zeleninaTile,
        matching: find.byTooltip('Smazat zónu Zelenina'),
      ),
    );
    await tester.pumpAndSettle();

    expect(zones.items.containsKey('Z1'), isTrue);
    expect(find.textContaining('nejde smazat'), findsOneWidget);
  });
}
