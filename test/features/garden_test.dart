import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:zahradnik_boda/features/inventory/domain/inventory_item.dart';
import 'package:zahradnik_boda/features/inventory/domain/units.dart';
import 'package:zahradnik_boda/features/tasks/domain/task_entity.dart';
import 'package:zahradnik_boda/features/tasks/presentation/screens/task_form_screen.dart';
import 'package:zahradnik_boda/features/zones/domain/zone_entity.dart';

import '../helpers/fakes.dart';

void main() {
  setUpAll(() => initializeDateFormatting('cs'));

  testWidgets('zone properties are filled in a form (MVP 1.0 item 2)', (
    tester,
  ) async {
    final zones = InMemoryZoneRepository();
    await pumpApp(tester, testOverrides(zones: zones));
    await tester.tap(find.text('Zahrada'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Zelenina'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Doplň výměru'), findsOneWidget);

    await tester.tap(find.byTooltip('Upravit'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Výměra (m²)'),
      '12,5',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'pH půdy'),
      '6,6',
    );
    await tester.tap(find.widgetWithText(SwitchListTile, 'Krytá zóna'));
    await tester.tap(find.widgetWithText(TextButton, 'Uložit'));
    await tester.pumpAndSettle();

    final saved = zones.items['Z1']!;
    expect(saved.areaM2, 12.5);
    expect(saved.ph, 6.6);
    expect(saved.covered, isTrue);
    expect(find.text('12,5 m²'), findsOneWidget);
  });

  testWidgets('a wrong area is explained and nothing is saved', (tester) async {
    final zones = InMemoryZoneRepository();
    await pumpApp(tester, testOverrides(zones: zones));
    await tester.tap(find.text('Zahrada'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Další akce pro Zelenina'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Upravit').last);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Výměra (m²)'),
      'hodně',
    );
    await tester.tap(find.widgetWithText(TextButton, 'Uložit'));
    await tester.pumpAndSettle();
    expect(find.text('Zadej číslo, třeba 12,5'), findsOneWidget);
    expect(zones.items['Z1']!.areaM2, isNull);
  });

  testWidgets('inventory: add a fertilizer, the watcher warns (FR-S1, S3)', (
    tester,
  ) async {
    final inventory = InMemoryInventoryRepository();
    await pumpApp(tester, testOverrides(inventory: inventory));
    await tester.tap(find.text('Zahrada'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sklad'));
    await tester.pumpAndSettle();
    expect(find.text('Sklad je zatím prázdný'), findsOneWidget);

    await tester.tap(find.text('Přidat do skladu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Osiva'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hnojiva').last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Název'),
      'Cererit',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Množství doma'),
      '0,5',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Upozornit, když klesne na'),
      '1',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Dávka na 1 m² podle obalu'),
      '60',
    );
    await tester.tap(find.widgetWithText(TextButton, 'Uložit'));
    await tester.pumpAndSettle();

    final saved = inventory.items.values.single;
    expect(saved.category, InventoryCategory.fertilizer);
    expect(saved.stockQty, 0.5);
    expect(saved.labelDose, const LabelDose(60, InventoryUnit.g));
    expect(find.text('Hlídač zásob'), findsOneWidget);

    await tester.tap(find.byTooltip('Na nákupní seznam'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Nákupní seznam'));
    await tester.pumpAndSettle();
    expect(find.text('Cererit'), findsOneWidget);
    expect(find.textContaining('dochází'), findsOneWidget);
  });

  testWidgets('weekend mode fits tasks into the time (FR-U8)', (tester) async {
    final tasks = InMemoryTaskRepository([
      TaskEntity(
        id: 't1',
        title: 'Posekat trávník',
        due: DateTime(2026, 10, 7),
        durationEstMin: 120,
        tools: const ['Sekačka'],
      ),
      TaskEntity(
        id: 't2',
        title: 'Shrabat listí',
        due: DateTime(2026, 10, 8),
        durationEstMin: 180,
      ),
      TaskEntity(
        id: 't3',
        title: 'Zazimovat hadice',
        due: DateTime(2026, 10, 9),
        durationEstMin: 30,
      ),
    ]);
    await pumpApp(tester, testOverrides(tasks: tasks));
    await tester.tap(find.text('Úkoly'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Víkend na chalupě'));
    await tester.pumpAndSettle();

    // Výchozí 4 hodiny: sekání a hadice ano, listí se nevejde.
    expect(find.textContaining('Stihneš 2 úkoly'), findsOneWidget);
    expect(find.text('Sekačka'), findsOneWidget);
    expect(find.text('Nevejde se'), findsOneWidget);
  });

  testWidgets('task form keeps duration, tools and materials', (tester) async {
    final tasks = InMemoryTaskRepository();
    final inventory = InMemoryInventoryRepository([
      const InventoryItem(
        id: 'i1',
        category: InventoryCategory.fertilizer,
        name: 'Cererit',
        unit: InventoryUnit.kg,
        stockQty: 3,
      ),
    ]);
    await pumpApp(tester, testOverrides(tasks: tasks, inventory: inventory));
    await tester.tap(find.text('Úkoly'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Nový úkol'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Co je potřeba udělat'),
      'Přihnojit rajčata',
    );
    await tester.tap(find.text('Neuvedeno'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('45 min').last);
    await tester.pumpAndSettle();

    final toolField = find.widgetWithText(
      TextField,
      'Přidej nářadí, např. rýč',
    );
    await tester.scrollUntilVisible(
      toolField,
      200,
      scrollable: find
          .descendant(
            of: find.byType(TaskFormScreen),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.enterText(toolField, 'Konev');
    await tester.tap(find.byTooltip('Přidat nářadí'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Přidat materiál'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Položka skladu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cererit').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Množství'), '1,2');
    await tester.tap(find.widgetWithText(FilledButton, 'Uložit'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(TextButton, 'Uložit'));
    await tester.pumpAndSettle();

    final saved = tasks.items.values.single;
    expect(saved.durationEstMin, 45);
    expect(saved.tools, ['Konev']);
    expect(saved.materials, [
      const TaskMaterial(itemId: 'i1', qty: 1.2, unit: 'kg'),
    ]);
  });

  testWidgets('harvest amount is logged with the harvest type (FR-D9)', (
    tester,
  ) async {
    final activities = InMemoryActivityRepository();
    await pumpApp(tester, testOverrides(activities: activities));
    await tester.tap(find.byTooltip('Nový záznam'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, 'Sklizeň'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Sklizeno'),
      '3,5',
    );
    await tester.tap(find.widgetWithText(TextButton, 'Uložit'));
    await tester.pumpAndSettle();

    final saved = activities.items.values.single;
    expect(saved.harvestQty, 3.5);
    expect(saved.harvestUnit, 'kg');
  });

  test('zone entity copyWith can clear properties', () {
    const zone = ZoneEntity(id: 'z', name: 'Z', areaM2: 10);
    expect(zone.copyWith(areaM2: () => null).areaM2, isNull);
    expect(zone.copyWith(name: 'Y').areaM2, 10);
  });
}
