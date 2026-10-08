import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/consents.dart';

/// Profil v tabulce `profiles` (řádek zakládá trigger při registraci).
class SupabaseProfileRemote implements ProfileRemote {
  SupabaseProfileRemote(this._client);

  final SupabaseClient _client;

  @override
  Future<void> saveConsents(String userId, Map<String, Object?> consents) =>
      _client
          .from('profiles')
          .update({
            'consents': consents,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', userId);
}
