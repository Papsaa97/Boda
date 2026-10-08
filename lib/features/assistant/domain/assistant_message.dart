import 'package:equatable/equatable.dart';

import 'assistant_backend.dart';
import 'assistant_context.dart';
import 'safety_check.dart';

/// Stav dotazu v telefonu (FR-B7).
enum MessageStatus {
  /// Čeká na připojení.
  pending,
  sent,

  /// Nepodařil se z jiného důvodu než bez připojení.
  failed;

  static MessageStatus fromKey(String? key) =>
      values.firstWhere((s) => s.name == key, orElse: () => sent);
}

/// Hodnocení odpovědi (FR-B6).
enum AnswerFeedback {
  up,
  down;

  static AnswerFeedback? fromKey(String? key) {
    for (final f in values) {
      if (f.name == key) return f;
    }
    return null;
  }
}

/// Rozhovor s Bóďou.
class AssistantThread extends Equatable {
  const AssistantThread({
    required this.id,
    this.title,
    this.createdAt,
    this.updatedAt,
  });

  final String id;

  /// Začátek prvního dotazu.
  final String? title;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [id, title, createdAt, updatedAt];
}

/// Doplňky zprávy (v databázi JSON `context_summary`).
class MessageMeta extends Equatable {
  const MessageMeta({
    this.context,
    this.actions = const [],
    this.warnings = const [],
    this.usage,
    this.demo = false,
    this.failure,
  });

  /// Z čeho Bóďa vycházel (u odpovědi).
  final ContextSummary? context;
  final List<AssistantAction> actions;
  final List<SafetyWarning> warnings;
  final AssistantUsage? usage;

  /// Odpověď z ukázkového režimu bez AI.
  final bool demo;

  /// Proč dotaz neprošel (u dotazu se stavem `failed`).
  final AssistantFailureKind? failure;

  bool get isEmpty =>
      context == null &&
      actions.isEmpty &&
      warnings.isEmpty &&
      usage == null &&
      !demo &&
      failure == null;

  Map<String, Object?> toJson() => {
    if (context != null) 'context': context!.toJson(),
    if (actions.isNotEmpty) 'actions': [for (final a in actions) a.toJson()],
    if (warnings.isNotEmpty) 'warnings': [for (final w in warnings) w.toJson()],
    if (usage != null) 'usage': usage!.toJson(),
    if (demo) 'demo': true,
    if (failure != null) 'failure': failure!.name,
  };

  factory MessageMeta.fromJson(Object? json) {
    if (json is! Map) return const MessageMeta();
    final failure = json['failure'];
    return MessageMeta(
      context: json['context'] == null
          ? null
          : ContextSummary.fromJson(json['context']),
      actions: [
        for (final a in (json['actions'] as List?) ?? const [])
          ?AssistantAction.fromJson(a),
      ],
      warnings: [
        for (final w in (json['warnings'] as List?) ?? const [])
          ?SafetyWarning.fromJson(w),
      ],
      usage: AssistantUsage.fromJson(json['usage']),
      demo: json['demo'] == true,
      failure: AssistantFailureKind.values
          .where((k) => k.name == failure)
          .firstOrNull,
    );
  }

  @override
  List<Object?> get props => [context, actions, warnings, usage, demo, failure];
}

/// Jedna zpráva rozhovoru.
class AssistantMessage extends Equatable {
  const AssistantMessage({
    required this.id,
    required this.threadId,
    required this.role,
    required this.text,
    required this.createdAt,
    this.status = MessageStatus.sent,
    this.meta = const MessageMeta(),
    this.feedback,
    this.feedbackComment,
  });

  final String id;
  final String threadId;
  final AssistantRole role;
  final String text;
  final DateTime createdAt;
  final MessageStatus status;
  final MessageMeta meta;
  final AnswerFeedback? feedback;
  final String? feedbackComment;

  bool get isUser => role == AssistantRole.user;

  AssistantMessage copyWith({
    MessageStatus? status,
    MessageMeta? meta,
    AnswerFeedback? Function()? feedback,
    String? Function()? feedbackComment,
  }) => AssistantMessage(
    id: id,
    threadId: threadId,
    role: role,
    text: text,
    createdAt: createdAt,
    status: status ?? this.status,
    meta: meta ?? this.meta,
    feedback: feedback == null ? this.feedback : feedback(),
    feedbackComment: feedbackComment == null
        ? this.feedbackComment
        : feedbackComment(),
  );

  @override
  List<Object?> get props => [
    id,
    threadId,
    role,
    text,
    createdAt,
    status,
    meta,
    feedback,
    feedbackComment,
  ];
}

/// Uložené rozhovory.
abstract interface class AssistantRepository {
  /// Naposledy použitý rozhovor, nebo null.
  Future<AssistantThread?> latestThread();

  Future<void> saveThread(AssistantThread thread);

  /// Zprávy rozhovoru od nejstarší.
  Future<List<AssistantMessage>> messages(String threadId);

  Future<void> saveMessage(AssistantMessage message);

  /// Měkce smaže rozhovor i jeho zprávy.
  Future<void> deleteThread(String threadId);
}
