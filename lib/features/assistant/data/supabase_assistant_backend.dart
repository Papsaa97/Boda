import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/backend/network_errors.dart';
import '../domain/assistant_backend.dart';

/// Bóďa přes Edge Function `boda-chat` (spec 5.2, kap. 7.1). Klíč
/// k jazykovému modelu je jen v secrets funkce, limit hlídá server.
class SupabaseAssistantBackend implements AssistantBackend {
  SupabaseAssistantBackend(this._client);

  final SupabaseClient _client;

  @override
  bool get isDemo => false;

  @override
  Future<AssistantReply> ask(AssistantRequest request) async {
    if (_client.auth.currentSession == null) {
      throw const AssistantFailure(AssistantFailureKind.notSignedIn);
    }
    try {
      final response = await _client.functions.invoke(
        'boda-chat',
        body: request.toJson(),
      );
      final reply = AssistantReply.fromJson(response.data);
      if (reply == null) {
        throw const AssistantFailure(AssistantFailureKind.upstream);
      }
      return reply;
    } on FunctionException catch (e) {
      throw assistantFailureFor(e.status, e.details);
    } on AssistantFailure {
      rethrow;
    } catch (e) {
      if (isNetworkError(e)) {
        throw const AssistantFailure(AssistantFailureKind.offline);
      }
      throw const AssistantFailure(AssistantFailureKind.upstream);
    }
  }
}

/// Chybová odpověď `boda-chat` jako [AssistantFailure].
AssistantFailure assistantFailureFor(int status, Object? body) =>
    switch (status) {
      401 => const AssistantFailure(AssistantFailureKind.notSignedIn),
      429 => AssistantFailure(
        AssistantFailureKind.limitReached,
        usage: body is Map ? AssistantUsage.fromJson(body['usage']) : null,
      ),
      503 => const AssistantFailure(AssistantFailureKind.notConfigured),
      _ => const AssistantFailure(AssistantFailureKind.upstream),
    };
