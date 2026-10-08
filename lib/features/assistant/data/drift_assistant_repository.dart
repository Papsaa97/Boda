import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/assistant_backend.dart';
import '../domain/assistant_message.dart';

/// Rozhovory s Bóďou v lokální databázi; smazání je měkké.
class DriftAssistantRepository implements AssistantRepository {
  DriftAssistantRepository(this._db, this._gardenId, this._clock);

  final AppDatabase _db;
  final String _gardenId;
  final DateTime Function() _clock;

  @override
  Future<AssistantThread?> latestThread() async {
    final row =
        await (_db.select(_db.assistantThreads)
              ..where((t) => t.deletedAt.isNull())
              ..orderBy([
                (t) => OrderingTerm(
                  expression: t.updatedAt,
                  mode: OrderingMode.desc,
                ),
              ])
              ..limit(1))
            .getSingleOrNull();
    if (row == null) return null;
    return AssistantThread(
      id: row.id,
      title: row.title,
      createdAt: row.createdAt.toLocal(),
      updatedAt: row.updatedAt.toLocal(),
    );
  }

  @override
  Future<void> saveThread(AssistantThread thread) async {
    final now = _clock().toUtc();
    final row = AssistantThreadsCompanion.insert(
      id: thread.id,
      gardenId: Value(_gardenId),
      title: Value(thread.title),
      createdAt: (thread.createdAt ?? now).toUtc(),
      updatedAt: now,
    );
    await _db
        .into(_db.assistantThreads)
        .insert(
          row,
          onConflict: DoUpdate(
            (_) => row.copyWith(createdAt: const Value.absent()),
          ),
        );
  }

  @override
  Future<List<AssistantMessage>> messages(String threadId) async {
    final rows =
        await (_db.select(_db.assistantMessages)
              ..where((m) => m.threadId.equals(threadId) & m.deletedAt.isNull())
              ..orderBy([
                (m) => OrderingTerm(expression: m.createdAt),
                (m) =>
                    OrderingTerm(expression: m.role, mode: OrderingMode.desc),
              ]))
            .get();
    return [for (final r in rows) _fromRow(r)];
  }

  @override
  Future<void> saveMessage(AssistantMessage message) async {
    final now = _clock().toUtc();
    final meta = message.meta;
    final row = AssistantMessagesCompanion.insert(
      id: message.id,
      threadId: message.threadId,
      role: message.role.name,
      body: message.text,
      contextSummary: Value(meta.isEmpty ? null : jsonEncode(meta.toJson())),
      status: Value(message.status.name),
      feedback: Value(message.feedback?.name),
      feedbackComment: Value(message.feedbackComment),
      createdAt: message.createdAt.toUtc(),
      updatedAt: now,
    );
    await _db.transaction(() async {
      await _db
          .into(_db.assistantMessages)
          .insert(
            row,
            onConflict: DoUpdate(
              (_) => row.copyWith(createdAt: const Value.absent()),
            ),
          );
      await (_db.update(_db.assistantThreads)
            ..where((t) => t.id.equals(message.threadId)))
          .write(AssistantThreadsCompanion(updatedAt: Value(now)));
    });
  }

  @override
  Future<void> deleteThread(String threadId) async {
    final now = _clock().toUtc();
    await _db.transaction(() async {
      await (_db.update(_db.assistantMessages)
            ..where((m) => m.threadId.equals(threadId) & m.deletedAt.isNull()))
          .write(
            AssistantMessagesCompanion(
              deletedAt: Value(now),
              updatedAt: Value(now),
            ),
          );
      await (_db.update(
        _db.assistantThreads,
      )..where((t) => t.id.equals(threadId))).write(
        AssistantThreadsCompanion(deletedAt: Value(now), updatedAt: Value(now)),
      );
    });
  }
}

AssistantMessage _fromRow(AssistantMessageRow r) {
  Object? meta;
  final raw = r.contextSummary;
  if (raw != null) {
    try {
      meta = jsonDecode(raw);
    } on FormatException {
      // Poškozená doplňková data: zpráva se ukáže bez nich.
    }
  }
  return AssistantMessage(
    id: r.id,
    threadId: r.threadId,
    role: AssistantRole.fromKey(r.role),
    text: r.body,
    createdAt: r.createdAt.toLocal(),
    status: MessageStatus.fromKey(r.status),
    meta: MessageMeta.fromJson(meta),
    feedback: AnswerFeedback.fromKey(r.feedback),
    feedbackComment: r.feedbackComment,
  );
}
