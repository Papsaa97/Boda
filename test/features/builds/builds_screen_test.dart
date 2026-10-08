import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zahradnik_boda/features/builds/domain/build_design.dart';
import 'package:zahradnik_boda/features/builds/domain/build_params.dart';
import 'package:zahradnik_boda/features/builds/presentation/builds_screen.dart';
import 'package:zahradnik_boda/features/inventory/domain/units.dart';
import 'package:zahradnik_boda/l10n/app_localizations.dart';

import '../../helpers/fakes.dart';

Future<void> _pump(
  WidgetTester tester, {
  required InMemoryBuildRepository builds,
  InMemoryShoppingRepository? shopping,
}) async {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: testOverrides(builds: builds, shopping: shopping),
      child: const MaterialApp(
        locale: Locale('cs'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: BuildsScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _scrollTo(
  WidgetTester tester,
  Finder finder, {
  double delta = 300,
}) async {
  await tester.scrollUntilVisible(
    finder,
    delta,
    scrollable: find.byWidgetPredicate(
      (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
    ),
  );
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('new bridge: guardrails react to the span, design is saved', (
    tester,
  ) async {
    final builds = InMemoryBuildRepository();
    await _pump(tester, builds: builds);
    expect(
      find.text('Orientační návrh, nejde o autorizovaný statický výpočet.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Nový návrh'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mostek'));
    await tester.pumpAndSettle();

    // Trvalé upozornění je i v návrhu (FR-G3).
    expect(
      find.text('Orientační návrh, nejde o autorizovaný statický výpočet.'),
      findsOneWidget,
    );
    await _scrollTo(tester, find.text('Kontrola návrhu'));
    expect(find.text('Návrh je v mezích orientačních limitů.'), findsOneWidget);

    await _scrollTo(
      tester,
      find.byKey(const ValueKey('param-span')),
      delta: -300,
    );
    await tester.enterText(find.byKey(const ValueKey('param-span')), '9');
    await tester.pumpAndSettle();
    expect(find.text('Zadej číslo od 0,5 do 6'), findsOneWidget);
    await tester.enterText(find.byKey(const ValueKey('param-span')), '3,5');
    await tester.pumpAndSettle();
    expect(find.text('Zadej číslo od 0,5 do 6'), findsNothing);
    await _scrollTo(
      tester,
      find.textContaining('nech návrh posoudit statikem'),
      delta: -300,
    );
    await _scrollTo(tester, find.textContaining('Rozpětí nad 3 m'));
    expect(find.textContaining('Rozpětí nad 3 m'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Uložit'));
    await tester.pumpAndSettle();
    final saved = builds.items.values.single;
    expect(saved.template, BuildTemplate.bridge);
    expect(saved.name, 'Mostek');
    expect(saved.values.number('span'), 3.5);
    expect(find.text('Mostek'), findsWidgets);
    expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
  });

  testWidgets('own price changes the budget; material goes to shopping', (
    tester,
  ) async {
    final builds = InMemoryBuildRepository();
    await builds.save(
      BuildDesign(
        id: 'b1',
        name: 'Chodník k brance',
        values: BuildValues(BuildTemplate.path, const {
          'length': 10,
          'width': 1,
          'edging': false,
        }),
      ),
    );
    final shopping = InMemoryShoppingRepository();
    await _pump(tester, builds: builds, shopping: shopping);
    // 1,7 t × 450 + 0,8 t × 550 + 11 m² × 25 = 765 + 440 + 275.
    expect(
      find.textContaining(RegExp(r'Celkem orientačně 1\s480 Kč')),
      findsOneWidget,
    );
    await tester.tap(find.text('Chodník k brance'));
    await tester.pumpAndSettle();

    final gravel = find.text('Štěrk 0–32 na podklad');
    await _scrollTo(tester, gravel);
    await tester.tap(gravel);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, '300');
    await tester.tap(find.widgetWithText(FilledButton, 'Uložit'));
    await tester.pumpAndSettle();
    // 1,7 t × 300 = 510 místo 765.
    expect(
      find.textContaining(RegExp(r'Celkem orientačně 1\s225 Kč')),
      findsOneWidget,
    );

    final add = find.text('Přidat na nákupní seznam');
    await _scrollTo(tester, add);
    await tester.tap(add);
    await tester.pumpAndSettle();
    expect(find.text('Na nákupní seznam přibyly 3 položky'), findsOneWidget);
    final names = (await shopping.getAll()).map((s) => s.name).toList();
    expect(names, contains('Štěrk 0–32 na podklad (1,7 t)'));
    expect(
      (await shopping.getAll()).every((s) => s.unit != InventoryUnit.kg),
      isTrue,
    );

    await tester.tap(find.widgetWithText(TextButton, 'Uložit'));
    await tester.pumpAndSettle();
    expect(builds.items['b1']!.prices, {'gravel032': 300});
  });

  testWidgets('leaving with changes asks first; delete removes the design', (
    tester,
  ) async {
    final builds = InMemoryBuildRepository();
    await builds.save(
      BuildDesign(
        id: 'b1',
        name: 'Záhon',
        values: BuildValues(BuildTemplate.raisedBed),
      ),
    );
    await _pump(tester, builds: builds);
    await tester.tap(find.text('Záhon'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('param-width')), '1,6');
    await tester.pumpAndSettle();
    await _scrollTo(tester, find.textContaining('do středu nedosáhneš'));

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Zahodit změny v návrhu?'), findsOneWidget);
    await tester.tap(find.text('Pokračovat v úpravách'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Smazat návrh'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Smazat'));
    await tester.pumpAndSettle();
    expect(builds.items, isEmpty);
    expect(find.text('Návrh smazán'), findsOneWidget);
  });
}
