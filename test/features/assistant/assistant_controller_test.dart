import 'package:flutter_test/flutter_test.dart';
import 'package:zahradnik_boda/features/assistant/data/demo_assistant_backend.dart';
import 'package:zahradnik_boda/features/assistant/domain/assistant_backend.dart';
import 'package:zahradnik_boda/features/assistant/domain/assistant_message.dart';
import 'package:zahradnik_boda/features/assistant/domain/safety_check.dart';
import 'package:zahradnik_boda/features/assistant/presentation/assistant_controller.dart';
import 'package:zahradnik_boda/features/inventory/domain/inventory_item.dart';
import 'package:zahradnik_boda/features/inventory/domain/shopping_item.dart';
import 'package:zahradnik_boda/features/inventory/domain/units.dart';
import 'package:zahradnik_boda/features/tasks/domain/task_entity.dart';
import 'package:zahradnik_boda/features/zones/domain/zone_entity.dart';

import '../../helpers/fakes.dart';

/// Backend pro testy: odpoví [reply], nebo vyhodí [failure].
class FakeBackend implements AssistantBackend {
  FakeBackend({this.reply = const AssistantReply(answer: 'Dobře.')});

  AssistantReply reply;
  AssistantFailure? failure;
  final List<AssistantRequest> requests = [];

  @override
  bool get isDemo => false;

  @override
  Future<AssistantReply> ask(AssistantRequest request) async {
    requests.add(request);
    if (failure case final f?) throw f;
    return reply;
  }
}

const cererit = InventoryItem(
  id: 'i1',
  category: InventoryCategory.fertilizer,
  name: 'Cererit',
  unit: InventoryUnit.kg,
  stockQty: 0.5,
  lowStockThreshold: 1,
  details: FertilizerDetails(dose: LabelDose(60, InventoryUnit.g)),
);

InMemoryZoneRepository zonesWithArea() => InMemoryZoneRepository([
  const ZoneEntity(
    id: 'Z1',
    name: 'Zelenina',
    type: ZoneType.vegetable,
    areaM2: 20,
  ),
  const ZoneEntity(id: 'Z4', name: 'Trávník', type: ZoneType.lawn),
]);

void main() {
  test('a question gets an answer with sources and a safety check', () async {
    final backend = FakeBackend(
      reply: const AssistantReply(
        answer: 'Na Zeleninu dej 1,2 kg, pak klidně 90 g/m² hnojiva.',
        actions: [TaskAction(title: 'Pohnojit', zoneId: 'Z1')],
        usage: AssistantUsage(used: 1, limit: 10, plan: 'free'),
      ),
    );
    final repo = InMemoryAssistantRepository();
    final c = makeContainer(
      zones: zonesWithArea(),
      inventory: InMemoryInventoryRepository([cererit]),
      assistant: repo,
      backend: backend,
    );
    addTearDown(c.dispose);
    await c.read(assistantControllerProvider.future);

    await c
        .read(assistantControllerProvider.notifier)
        .ask('  Kolik hnojiva na zeleninu?  ');

    final state = c.read(assistantControllerProvider).value!;
    expect(state.sending, isFalse);
    expect(state.messages.map((m) => (m.role, m.status)), [
      (AssistantRole.user, MessageStatus.sent),
      (AssistantRole.assistant, MessageStatus.sent),
    ]);
    expect(state.messages.first.text, 'Kolik hnojiva na zeleninu?');
    final meta = state.messages.last.meta;
    expect(meta.context!.zoneNames, ['Zelenina']);
    expect(meta.context!.calculations.single.result, '1,2 kg');
    expect(meta.warnings, [const UnverifiedDose('90 g/m²')]);
    expect(meta.actions, hasLength(1));
    expect(state.usage!.remaining, 9);
    expect(repo.threads.values.single.title, 'Kolik hnojiva na zeleninu?');
    expect(repo.items, hasLength(2));

    final request = backend.requests.single.toJson();
    expect((request['context']! as Map)['calculations'], [
      {
        'label': 'Cererit na zónu Zelenina (20 m²)',
        'result': '1,2 kg',
        'source': '60 g/m² podle obalu',
      },
    ]);
    expect(request['history'], isEmpty);

    await c.read(assistantControllerProvider.notifier).ask('A kdy?');
    expect(backend.requests.last.history.map((h) => h.role), [
      AssistantRole.user,
      AssistantRole.assistant,
    ]);
  });

  test('offline questions wait and go out later (FR-B7)', () async {
    final backend = FakeBackend()
      ..failure = const AssistantFailure(AssistantFailureKind.offline);
    final c = makeContainer(backend: backend);
    addTearDown(c.dispose);
    await c.read(assistantControllerProvider.future);
    final controller = c.read(assistantControllerProvider.notifier);

    await controller.ask('Kdy sázet česnek?');
    var state = c.read(assistantControllerProvider).value!;
    expect(state.pending, hasLength(1));
    expect(state.messages, hasLength(1));

    backend.failure = null;
    await controller.retryPending();
    state = c.read(assistantControllerProvider).value!;
    expect(state.pending, isEmpty);
    expect(state.messages.last.text, 'Dobře.');
    expect(backend.requests, hasLength(2));
  });

  test('a reached limit is shown and not retried automatically', () async {
    final backend = FakeBackend()
      ..failure = const AssistantFailure(
        AssistantFailureKind.limitReached,
        usage: AssistantUsage(used: 10, limit: 10),
      );
    final c = makeContainer(backend: backend);
    addTearDown(c.dispose);
    await c.read(assistantControllerProvider.future);

    await c.read(assistantControllerProvider.notifier).ask('Ahoj');
    final state = c.read(assistantControllerProvider).value!;
    final message = state.messages.single;
    expect(message.status, MessageStatus.failed);
    expect(message.meta.failure, AssistantFailureKind.limitReached);
    expect(state.usage!.remaining, 0);
    expect(state.pending, isEmpty);
  });

  test('a conversation is restored and can be deleted', () async {
    final repo = InMemoryAssistantRepository();
    final first = makeContainer(assistant: repo, backend: FakeBackend());
    await first.read(assistantControllerProvider.future);
    await first.read(assistantControllerProvider.notifier).ask('Ahoj');
    first.dispose();

    final c = makeContainer(assistant: repo, backend: FakeBackend());
    addTearDown(c.dispose);
    final restored = await c.read(assistantControllerProvider.future);
    expect(restored.messages, hasLength(2));

    await c.read(assistantControllerProvider.notifier).deleteConversation();
    expect(c.read(assistantControllerProvider).value!.messages, isEmpty);
    expect(repo.items, isEmpty);
  });

  test('feedback with a comment, the same tap clears it (FR-B6)', () async {
    final c = makeContainer(backend: FakeBackend());
    addTearDown(c.dispose);
    await c.read(assistantControllerProvider.future);
    final controller = c.read(assistantControllerProvider.notifier);
    await controller.ask('Ahoj');
    final answer = c.read(assistantControllerProvider).value!.messages.last;

    await controller.setFeedback(
      answer.id,
      AnswerFeedback.down,
      comment: ' Málo konkrétní ',
    );
    var stored = c.read(assistantControllerProvider).value!.messages.last;
    expect(stored.feedback, AnswerFeedback.down);
    expect(stored.feedbackComment, 'Málo konkrétní');

    await controller.setFeedback(answer.id, null);
    stored = c.read(assistantControllerProvider).value!.messages.last;
    expect(stored.feedback, isNull);
    expect(stored.feedbackComment, isNull);
  });

  test('actions create a Bóďa task and a linked shopping item', () async {
    final tasks = InMemoryTaskRepository();
    final shopping = InMemoryShoppingRepository();
    final c = makeContainer(
      zones: zonesWithArea(),
      tasks: tasks,
      shopping: shopping,
      inventory: InMemoryInventoryRepository([cererit]),
    );
    addTearDown(c.dispose);
    await c.read(assistantControllerProvider.future);
    final controller = c.read(assistantControllerProvider.notifier);

    await controller.createTask(
      const TaskAction(title: 'Pohnojit', zoneId: 'neznámá'),
    );
    final task = tasks.items.values.single;
    expect(task.source, TaskSource.boda);
    expect(task.zoneId, isNull);
    expect(task.due, DateTime(2026, 10, 7));

    await controller.addToShopping(const ShoppingAction(name: 'cererit'));
    final item = shopping.items.values.single;
    expect(item.itemId, 'i1');
    expect(item.unit, InventoryUnit.kg);
    expect(item.source, ShoppingSource.boda);
  });

  test('the demo backend answers from local data, clearly marked', () async {
    final c = makeContainer(
      zones: zonesWithArea(),
      inventory: InMemoryInventoryRepository([cererit]),
      backend: const DemoAssistantBackend(),
    );
    addTearDown(c.dispose);
    await c.read(assistantControllerProvider.future);

    await c
        .read(assistantControllerProvider.notifier)
        .ask('Kolik hnojiva na zeleninu?');
    final answer = c.read(assistantControllerProvider).value!.messages.last;
    expect(answer.meta.demo, isTrue);
    expect(answer.text, contains('ukázkovém režimu bez AI'));
    expect(answer.text, contains('Cererit na zónu Zelenina (20 m²): 1,2 kg'));
    expect(answer.meta.warnings, isEmpty);
    expect(answer.meta.actions, [
      const TaskAction(
        title: 'Pohnojit Zelenina: Cererit 1,2 kg',
        zoneId: 'Z1',
      ),
      const ShoppingAction(name: 'Cererit', unit: InventoryUnit.kg),
    ]);
  });
}
