import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/telemetry/telemetry.dart';
import '../../../core/text/normalize.dart';
import '../../../core/time/calendar.dart';
import '../../../core/time/today.dart';
import '../../activity/presentation/controllers/activity_controller.dart';
import '../../inventory/domain/shopping_item.dart';
import '../../inventory/presentation/inventory_controller.dart';
import '../../tasks/domain/task_entity.dart';
import '../../tasks/presentation/tasks_controller.dart';
import '../../zones/presentation/zones_controller.dart';
import '../domain/assistant_backend.dart';
import '../domain/assistant_context.dart';
import '../domain/assistant_message.dart';
import '../domain/safety_check.dart';

/// Kolik předchozích zpráv jde s dotazem (stejný limit má backend).
const historyLimit = 10;

/// Nejdelší dotaz (stejný limit má backend).
const maxQuestionLength = 2000;

/// Otevřený rozhovor s Bóďou.
class AssistantConversation extends Equatable {
  const AssistantConversation({
    this.thread,
    this.messages = const [],
    this.sending = false,
  });

  /// Null, dokud uživatel nepoložil první dotaz.
  final AssistantThread? thread;
  final List<AssistantMessage> messages;

  /// Čeká se na odpověď.
  final bool sending;

  /// Dotazy, které čekají na připojení (FR-B7).
  List<AssistantMessage> get pending => [
    for (final m in messages)
      if (m.isUser && m.status == MessageStatus.pending) m,
  ];

  /// Poslední známé čerpání limitu (FR-B8).
  AssistantUsage? get usage {
    for (final m in messages.reversed) {
      final usage = m.meta.usage;
      if (usage != null) return usage;
    }
    return null;
  }

  AssistantConversation copyWith({
    AssistantThread? thread,
    List<AssistantMessage>? messages,
    bool? sending,
  }) => AssistantConversation(
    thread: thread ?? this.thread,
    messages: messages ?? this.messages,
    sending: sending ?? this.sending,
  );

  @override
  List<Object?> get props => [thread, messages, sending];
}

/// Rozhovor s Bóďou: dotaz s kontextem zahrady, odpověď s výpočty,
/// akcemi a kontrolou bezpečnosti, fronta dotazů bez připojení.
class AssistantController extends AsyncNotifier<AssistantConversation> {
  @override
  Future<AssistantConversation> build() async {
    final repo = ref.watch(assistantRepositoryProvider);
    final thread = await repo.latestThread();
    if (thread == null) return const AssistantConversation();
    return AssistantConversation(
      thread: thread,
      messages: await repo.messages(thread.id),
    );
  }

  AssistantConversation get _current =>
      state.value ?? const AssistantConversation();

  /// Čas nové zprávy: teď, ale vždy po poslední zprávě (pořadí).
  DateTime _nextTime() {
    final now = ref.read(clockProvider)();
    final last = _current.messages.lastOrNull?.createdAt;
    if (last == null || now.isAfter(last)) return now;
    return last.add(const Duration(milliseconds: 1));
  }

  Future<void> _store(List<AssistantMessage> changed, {bool? sending}) async {
    final repo = ref.read(assistantRepositoryProvider);
    for (final m in changed) {
      await repo.saveMessage(m);
    }
    final ids = {for (final m in changed) m.id};
    final kept = [
      for (final m in _current.messages)
        if (!ids.contains(m.id)) m,
    ];
    final merged = [...kept, ...changed]
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    state = AsyncData(_current.copyWith(messages: merged, sending: sending));
  }

  /// Zápis přes [AsyncValue.guard]; při chybě úložiště zůstanou zprávy
  /// zobrazené a rozhovor se odblokuje.
  Future<void> _guard(Future<AssistantConversation> Function() op) async {
    final result = await AsyncValue.guard(op);
    if (result.hasError) {
      state = AsyncData(_current.copyWith(sending: false));
    }
    state = result;
  }

  /// Položí dotaz. Bez připojení ho uloží a pošle později.
  Future<void> ask(String question) async {
    final text = question.trim();
    if (text.isEmpty || _current.sending) return;
    final clipped = text.length > maxQuestionLength
        ? text.substring(0, maxQuestionLength)
        : text;
    await _guard(() async {
      var thread = _current.thread;
      if (thread == null) {
        thread = AssistantThread(
          id: ref.read(newIdProvider)(),
          title: clipped.length > 60 ? '${clipped.substring(0, 59)}…' : clipped,
          createdAt: ref.read(clockProvider)(),
        );
        await ref.read(assistantRepositoryProvider).saveThread(thread);
        state = AsyncData(_current.copyWith(thread: thread));
      }
      final message = AssistantMessage(
        id: ref.read(newIdProvider)(),
        threadId: thread.id,
        role: AssistantRole.user,
        text: clipped,
        createdAt: _nextTime(),
        status: MessageStatus.pending,
      );
      await _store([message], sending: true);
      ref.read(analyticsProvider).track(AnalyticsEvent.assistantAsked, {
        'demo': ref.read(assistantBackendProvider).isDemo,
      });
      await _send(message);
      return _current;
    });
  }

  /// Pošle znovu dotazy čekající na připojení (od nejstaršího). Skončí
  /// u prvního, který zase neprojde.
  Future<void> retryPending() async {
    if (_current.sending || _current.pending.isEmpty) return;
    await _guard(() async {
      state = AsyncData(_current.copyWith(sending: true));
      for (final m in _current.pending) {
        await _send(m);
        if (_current.messages.any(
          (x) => x.id == m.id && x.status != MessageStatus.sent,
        )) {
          break;
        }
      }
      return _current.copyWith(sending: false);
    });
  }

  /// Zkusí znovu dotaz, který neprošel.
  Future<void> retry(String messageId) async {
    final message = _current.messages
        .where((m) => m.id == messageId && m.isUser)
        .firstOrNull;
    if (message == null || _current.sending) return;
    await _guard(() async {
      state = AsyncData(_current.copyWith(sending: true));
      await _send(message);
      return _current.copyWith(sending: false);
    });
  }

  Future<void> _send(AssistantMessage message) async {
    final zones = await ref.read(zonesControllerProvider.future);
    final activities = await ref.read(activityControllerProvider.future);
    final tasks = await ref.read(tasksControllerProvider.future);
    final inventory = await ref.read(inventoryControllerProvider.future);
    final context = buildAssistantContext(
      question: message.text,
      zones: zones,
      activities: activities,
      tasks: tasks,
      inventory: inventory,
    );
    final earlier = [
      for (final m in _current.messages)
        if (m.createdAt.isBefore(message.createdAt) &&
            m.status == MessageStatus.sent)
          HistoryEntry(m.role, m.text),
    ];
    final history = earlier.length > historyLimit
        ? earlier.sublist(earlier.length - historyLimit)
        : earlier;
    final backend = ref.read(assistantBackendProvider);

    try {
      final reply = await backend.ask(
        AssistantRequest(
          question: message.text,
          context: context,
          history: history,
        ),
      );
      final answer = AssistantMessage(
        id: ref.read(newIdProvider)(),
        threadId: message.threadId,
        role: AssistantRole.assistant,
        text: reply.answer,
        createdAt: _nextTime(),
        meta: MessageMeta(
          context: context.summary,
          actions: reply.actions,
          warnings: checkAnswer(
            answer: reply.answer,
            question: message.text,
            calculations: context.calculations,
            inventory: inventory,
          ),
          usage: reply.usage,
          demo: backend.isDemo,
        ),
      );
      await _store([
        message.copyWith(status: MessageStatus.sent, meta: const MessageMeta()),
        answer,
      ], sending: false);
    } on AssistantFailure catch (f) {
      await _store([
        message.copyWith(
          status: f.kind == AssistantFailureKind.offline
              ? MessageStatus.pending
              : MessageStatus.failed,
          meta: MessageMeta(failure: f.kind, usage: f.usage),
        ),
      ], sending: false);
    } on Exception {
      await _store([
        message.copyWith(
          status: MessageStatus.failed,
          meta: const MessageMeta(failure: AssistantFailureKind.upstream),
        ),
      ], sending: false);
    }
  }

  /// Hodnocení odpovědi 👍/👎 s volitelným komentářem (FR-B6). Stejné
  /// hodnocení podruhé ho zruší.
  Future<void> setFeedback(
    String messageId,
    AnswerFeedback? feedback, {
    String? comment,
  }) async {
    final message = _current.messages
        .where((m) => m.id == messageId)
        .firstOrNull;
    if (message == null) return;
    final trimmed = comment?.trim();
    await _guard(() async {
      await _store([
        message.copyWith(
          feedback: () => feedback,
          feedbackComment: () =>
              feedback == null || trimmed == null || trimmed.isEmpty
              ? null
              : trimmed,
        ),
      ]);
      return _current;
    });
  }

  /// Další dotaz začne nový rozhovor; starý zůstane uložený.
  void newConversation() {
    if (_current.sending) return;
    state = const AsyncData(AssistantConversation());
  }

  /// Smaže otevřený rozhovor.
  Future<void> deleteConversation() async {
    final thread = _current.thread;
    if (thread == null || _current.sending) return;
    await _guard(() async {
      await ref.read(assistantRepositoryProvider).deleteThread(thread.id);
      return const AssistantConversation();
    });
  }

  /// Uloží úkol z odpovědi (FR-B5); bez termínu dnes.
  Future<void> createTask(TaskAction action) async {
    final today = dayOnly(ref.read(todayProvider));
    final zones = await ref.read(zonesControllerProvider.future);
    final zoneId = zones.any((z) => z.id == action.zoneId)
        ? action.zoneId
        : null;
    await ref
        .read(tasksControllerProvider.notifier)
        .create(
          TaskEntity(
            id: '',
            title: action.title,
            due: action.due ?? today,
            zoneId: zoneId,
            source: TaskSource.boda,
          ),
        );
  }

  /// Přidá položku na nákupní seznam (FR-B5); položku skladu se stejným
  /// názvem propojí, aby nákup šel doplnit do skladu.
  Future<void> addToShopping(ShoppingAction action) async {
    final inventory = await ref.read(inventoryControllerProvider.future);
    final name = normalizeForSearch(action.name.trim());
    final item = inventory
        .where((i) => normalizeForSearch(i.name.trim()) == name)
        .firstOrNull;
    await ref
        .read(shoppingControllerProvider.notifier)
        .add(
          name: action.name,
          qty: action.qty,
          unit: action.unit ?? item?.unit,
          itemId: item?.id,
          source: ShoppingSource.boda,
        );
  }
}

final assistantControllerProvider =
    AsyncNotifierProvider<AssistantController, AssistantConversation>(
      AssistantController.new,
    );
