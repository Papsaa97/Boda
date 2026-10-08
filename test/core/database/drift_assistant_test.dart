import 'package:flutter_test/flutter_test.dart';
import 'package:zahradnik_boda/core/database/app_database.dart';
import 'package:zahradnik_boda/features/assistant/data/drift_assistant_repository.dart';
import 'package:zahradnik_boda/features/assistant/domain/assistant_backend.dart';
import 'package:zahradnik_boda/features/assistant/domain/assistant_context.dart';
import 'package:zahradnik_boda/features/assistant/domain/assistant_message.dart';
import 'package:zahradnik_boda/features/assistant/domain/dose_calculator.dart';

import '../../helpers/database.dart';
import '../../helpers/fakes.dart';

void main() {
  late AppDatabase db;
  late DriftAssistantRepository repo;

  setUp(() async {
    db = memoryDatabase();
    final gardenId = await db.ensureDefaultGarden(
      newId: () => 'g',
      now: testNow,
    );
    repo = DriftAssistantRepository(db, gardenId, () => testNow);
  });

  tearDown(() => db.close());

  test('threads and messages round-trip with their extras', () async {
    expect(await repo.latestThread(), isNull);
    await repo.saveThread(
      AssistantThread(id: 't1', title: 'Hnojení', createdAt: testNow),
    );
    final question = AssistantMessage(
      id: 'm1',
      threadId: 't1',
      role: AssistantRole.user,
      text: 'Kolik hnojiva?',
      createdAt: testNow,
      status: MessageStatus.pending,
    );
    final answer = AssistantMessage(
      id: 'm2',
      threadId: 't1',
      role: AssistantRole.assistant,
      text: 'Dej 1,2 kg.',
      createdAt: testNow.add(const Duration(milliseconds: 1)),
      meta: const MessageMeta(
        context: ContextSummary(
          zoneNames: ['Zelenina'],
          calculations: [
            Calculation(label: 'A', result: '1,2 kg', source: 'B'),
          ],
        ),
        actions: [ShoppingAction(name: 'Cererit')],
        demo: true,
      ),
      feedback: AnswerFeedback.up,
    );
    await repo.saveMessage(answer);
    await repo.saveMessage(question);
    await repo.saveMessage(question.copyWith(status: MessageStatus.sent));

    expect((await repo.latestThread())!.title, 'Hnojení');
    expect(await repo.messages('t1'), [
      question.copyWith(status: MessageStatus.sent),
      answer,
    ]);
    final row = await (db.select(
      db.assistantMessages,
    )..where((m) => m.id.equals('m1'))).getSingle();
    expect(row.contextSummary, isNull);
  });

  test('deleting a conversation is soft', () async {
    await repo.saveThread(const AssistantThread(id: 't1'));
    await repo.saveMessage(
      AssistantMessage(
        id: 'm1',
        threadId: 't1',
        role: AssistantRole.user,
        text: 'Ahoj',
        createdAt: testNow,
      ),
    );
    await repo.deleteThread('t1');
    expect(await repo.latestThread(), isNull);
    expect(await repo.messages('t1'), isEmpty);
    final rows = await db.select(db.assistantMessages).get();
    expect(rows.single.deletedAt, isNotNull);
  });
}
