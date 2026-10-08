import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zahradnik_boda/features/assistant/domain/assistant_backend.dart';
import 'package:zahradnik_boda/features/tasks/domain/task_entity.dart';

import '../../helpers/fakes.dart';
import 'assistant_controller_test.dart'
    show FakeBackend, cererit, zonesWithArea;

Future<void> openAssistant(WidgetTester tester) async {
  await tester.tap(
    find.descendant(
      of: find.byType(NavigationBar),
      matching: find.text('Bóďa'),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('demo mode: ask, see the sources, save a task (FR-B1, B5)', (
    tester,
  ) async {
    final tasks = InMemoryTaskRepository();
    await pumpApp(
      tester,
      testOverrides(
        zones: zonesWithArea(),
        tasks: tasks,
        inventory: InMemoryInventoryRepository([cererit]),
      ),
    );
    await openAssistant(tester);
    expect(find.textContaining('Ukázkový režim bez AI'), findsOneWidget);
    expect(find.text('Zeptej se Bódi na svou zahradu'), findsOneWidget);
    // Záložka Bóďa nemá tlačítko pro nový záznam.
    expect(find.byType(FloatingActionButton), findsNothing);

    await tester.tap(find.text('Kolik hnojiva dát na zeleninu?'));
    await tester.pumpAndSettle();
    expect(find.text('Ukázkový režim'), findsOneWidget);
    expect(
      find.textContaining('Cererit na zónu Zelenina (20 m²): 1,2 kg'),
      findsOneWidget,
    );

    await tester.tap(find.text('Z čeho vycházím'));
    await tester.pumpAndSettle();
    expect(find.text('Zóny: Zelenina'), findsOneWidget);
    expect(
      find.text(
        '• Cererit na zónu Zelenina (20 m²): 1,2 kg (60 g/m² podle obalu)',
      ),
      findsOneWidget,
    );

    final action = find.text('Přidat úkol: Pohnojit Zelenina: Cererit 1,2 kg');
    await tester.ensureVisible(action);
    await tester.pumpAndSettle();
    await tester.tap(action);
    await tester.pumpAndSettle();
    expect(tasks.items.values.single.source, TaskSource.boda);
    expect(find.text('Úkol přidán'), findsOneWidget);
  });

  testWidgets('offline question waits, a warning is shown later (FR-B4, B7)', (
    tester,
  ) async {
    final backend = FakeBackend(
      reply: const AssistantReply(answer: 'Pohnoj dávkou 80 g/m².'),
    )..failure = const AssistantFailure(AssistantFailureKind.offline);
    await pumpApp(tester, testOverrides(backend: backend));
    await openAssistant(tester);
    expect(find.textContaining('Ukázkový režim'), findsNothing);

    await tester.enterText(find.byType(TextField), 'Jak hnojit?');
    await tester.tap(find.byTooltip('Odeslat dotaz'));
    await tester.pumpAndSettle();
    expect(find.text('1 dotaz čeká na připojení'), findsOneWidget);

    backend.failure = null;
    await tester.tap(find.text('Odeslat'));
    await tester.pumpAndSettle();
    expect(find.textContaining('čeká na připojení'), findsNothing);
    expect(find.textContaining('Číslo 80 g/m² nepochází'), findsOneWidget);

    await tester.tap(find.byTooltip('Špatná odpověď'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Vymyšlené číslo');
    await tester.tap(find.text('Uložit'));
    await tester.pumpAndSettle();
    expect(find.text('Díky za zpětnou vazbu.'), findsOneWidget);
  });
}
