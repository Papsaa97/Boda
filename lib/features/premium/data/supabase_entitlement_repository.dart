import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/premium.dart';

/// Nárok z tabulky `entitlements` (uživatel smí číst jen svůj řádek).
class SupabaseEntitlementRepository implements EntitlementRepository {
  SupabaseEntitlementRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<Entitlement> load(String userId) async {
    final row = await _client
        .from('entitlements')
        .select('plan, valid_until, source')
        .eq('user_id', userId)
        .maybeSingle();
    return Entitlement.fromRow(row);
  }
}
