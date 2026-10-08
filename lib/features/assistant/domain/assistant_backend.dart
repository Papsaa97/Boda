import 'package:equatable/equatable.dart';

import '../../../core/time/calendar.dart';
import '../../activity/domain/activity_type.dart';
import '../../inventory/domain/units.dart';
import 'assistant_context.dart';

/// Kdo zprávu napsal.
enum AssistantRole {
  user,
  assistant;

  static AssistantRole fromKey(String? key) =>
      values.firstWhere((r) => r.name == key, orElse: () => assistant);
}

/// Předchozí zpráva rozhovoru, posílá se s dotazem (nejvýš 10).
class HistoryEntry extends Equatable {
  const HistoryEntry(this.role, this.text);

  final AssistantRole role;
  final String text;

  Map<String, Object?> toJson() => {'role': role.name, 'text': text};

  @override
  List<Object?> get props => [role, text];
}

/// Dotaz na Bóďu (kontrakt funkce `boda-chat`).
class AssistantRequest {
  const AssistantRequest({
    required this.question,
    required this.context,
    this.history = const [],
  });

  final String question;
  final AssistantContext context;
  final List<HistoryEntry> history;

  Map<String, Object?> toJson() => {
    'question': question,
    'context': context.toJson(),
    'history': [for (final h in history) h.toJson()],
  };
}

/// Akce navržená v odpovědi, uloží se jedním klepnutím (FR-B5).
sealed class AssistantAction extends Equatable {
  const AssistantAction();

  Map<String, Object?> toJson();

  static AssistantAction? fromJson(Object? json) {
    if (json is! Map) return null;
    String? str(String key) {
      final v = json[key];
      return v is String && v.trim().isNotEmpty ? v.trim() : null;
    }

    switch (json['type']) {
      case 'task':
        final title = str('title');
        if (title == null) return null;
        final due = str('due');
        return TaskAction(
          title: title,
          due: parseDateKey(due),
          zoneId: str('zoneId'),
        );
      case 'shopping':
        final name = str('name');
        if (name == null) return null;
        final qty = json['qty'];
        return ShoppingAction(
          name: name,
          qty: qty is num && qty.isFinite && qty >= 0 ? qty.toDouble() : null,
          unit: InventoryUnit.fromKey(str('unit')),
        );
      case 'activity':
        final title = str('title');
        if (title == null) return null;
        return ActivityAction(
          title: title,
          type: ActivityType.fromKey(str('activityType')),
          zoneId: str('zoneId'),
        );
    }
    return null;
  }
}

/// Nový úkol (s termínem, když z dotazu vyplývá).
class TaskAction extends AssistantAction {
  const TaskAction({required this.title, this.due, this.zoneId});

  final String title;
  final DateTime? due;
  final String? zoneId;

  @override
  Map<String, Object?> toJson() => {
    'type': 'task',
    'title': title,
    'due': due == null ? null : formatDateKey(due!),
    'zoneId': zoneId,
  };

  @override
  List<Object?> get props => [title, due, zoneId];
}

/// Položka nákupního seznamu.
class ShoppingAction extends AssistantAction {
  const ShoppingAction({required this.name, this.qty, this.unit});

  final String name;
  final double? qty;
  final InventoryUnit? unit;

  @override
  Map<String, Object?> toJson() => {
    'type': 'shopping',
    'name': name,
    'qty': qty,
    'unit': unit?.name,
  };

  @override
  List<Object?> get props => [name, qty, unit];
}

/// Záznam do deníku (otevře se předvyplněný formulář).
class ActivityAction extends AssistantAction {
  const ActivityAction({required this.title, required this.type, this.zoneId});

  final String title;
  final ActivityType type;
  final String? zoneId;

  @override
  Map<String, Object?> toJson() => {
    'type': 'activity',
    'title': title,
    'activityType': type.key,
    'zoneId': zoneId,
  };

  @override
  List<Object?> get props => [title, type, zoneId];
}

/// Čerpání měsíčního limitu dotazů (FR-B8). Limit hlídá backend.
class AssistantUsage extends Equatable {
  const AssistantUsage({required this.used, required this.limit, this.plan});

  final int used;
  final int limit;

  /// `free` nebo `premium`.
  final String? plan;

  int get remaining => (limit - used).clamp(0, limit);

  Map<String, Object?> toJson() => {'used': used, 'limit': limit, 'plan': plan};

  static AssistantUsage? fromJson(Object? json) {
    if (json is! Map) return null;
    final used = json['used'];
    final limit = json['limit'];
    if (used is! num || limit is! num) return null;
    final plan = json['plan'];
    return AssistantUsage(
      used: used.toInt(),
      limit: limit.toInt(),
      plan: plan is String ? plan : null,
    );
  }

  @override
  List<Object?> get props => [used, limit, plan];
}

/// Odpověď Bódi.
class AssistantReply extends Equatable {
  const AssistantReply({
    required this.answer,
    this.actions = const [],
    this.usage,
  });

  final String answer;
  final List<AssistantAction> actions;
  final AssistantUsage? usage;

  /// Tělo odpovědi `boda-chat` (HTTP 200); null, když nemá tvar odpovědi.
  static AssistantReply? fromJson(Object? json) {
    if (json is! Map) return null;
    final answer = json['answer'];
    if (answer is! String || answer.trim().isEmpty) return null;
    return AssistantReply(
      answer: answer.trim(),
      actions: [
        for (final a in (json['actions'] as List?) ?? const [])
          ?AssistantAction.fromJson(a),
      ],
      usage: AssistantUsage.fromJson(json['usage']),
    );
  }

  @override
  List<Object?> get props => [answer, actions, usage];
}

/// Proč se dotaz nepodařil.
enum AssistantFailureKind {
  /// Bez připojení; dotaz počká na odeslání (FR-B7).
  offline,

  /// Bóďa potřebuje účet (přihlášení přijde s backendem).
  notSignedIn,

  /// Vyčerpaný měsíční limit (FR-B8).
  limitReached,

  /// Backend nemá nastavený klíč k modelu.
  notConfigured,

  /// Chyba na straně serveru nebo modelu.
  upstream,
}

class AssistantFailure implements Exception {
  const AssistantFailure(this.kind, {this.usage});

  final AssistantFailureKind kind;

  /// U [AssistantFailureKind.limitReached] aktuální čerpání.
  final AssistantUsage? usage;

  /// Dotaz má smysl poslat znovu později beze změny.
  bool get retryable =>
      kind == AssistantFailureKind.offline ||
      kind == AssistantFailureKind.upstream;

  @override
  String toString() => 'AssistantFailure(${kind.name})';
}

/// Kam se dotazy posílají. V 1.0 Supabase Edge Function `boda-chat`,
/// do připojení účtu ukázkový režim bez AI.
abstract interface class AssistantBackend {
  /// Ukázkový režim: odpovídá deterministicky v telefonu, nic neodesílá.
  bool get isDemo;

  /// Vyhodí [AssistantFailure], když odpověď nepřijde.
  Future<AssistantReply> ask(AssistantRequest request);
}
