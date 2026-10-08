import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/backend/network_errors.dart';
import '../domain/sharing.dart';

/// Sdílení přes funkce v databázi (migrace `20261008000900`) a RLS
/// tabulky `garden_members`.
class SupabaseSharingRemote implements SharingRemote {
  SupabaseSharingRemote(this._client);

  final SupabaseClient _client;

  Future<T> _guard<T>(Future<T> Function() run) async {
    if (_client.auth.currentSession == null) {
      throw const SharingException(SharingFailure.notSignedIn);
    }
    try {
      return await run();
    } on PostgrestException catch (e) {
      throw SharingException(sharingFailureFor(e.message));
    } on SharingException {
      rethrow;
    } catch (e) {
      if (isNetworkError(e)) {
        throw const SharingException(SharingFailure.offline);
      }
      throw const SharingException(SharingFailure.failed);
    }
  }

  @override
  Future<List<GardenMember>> members(String gardenId) => _guard(() async {
    final rows = await _client.rpc<List<dynamic>>(
      'garden_member_list',
      params: {'p_garden_id': gardenId},
    );
    return [
      for (final r in rows.cast<Map<String, dynamic>>())
        GardenMember(
          userId: r['user_id'] as String,
          role: GardenRole.fromKey(r['role'] as String?),
          displayName: r['display_name'] as String?,
          email: r['email'] as String?,
          joinedAt: DateTime.tryParse(
            r['joined_at'] as String? ?? '',
          )?.toLocal(),
        ),
    ];
  });

  @override
  Future<GardenInvite> createInvite(String gardenId) => _guard(() async {
    final rows = await _client.rpc<List<dynamic>>(
      'create_garden_invite',
      params: {'p_garden_id': gardenId},
    );
    final row = rows.cast<Map<String, dynamic>>().first;
    return GardenInvite(
      code: row['code'] as String,
      expiresAt: DateTime.parse(row['expires_at'] as String).toLocal(),
    );
  });

  @override
  Future<String> acceptInvite(String code) => _guard(
    () async => await _client.rpc<String>(
      'accept_garden_invite',
      params: {'p_code': code},
    ),
  );

  @override
  Future<void> removeMember(String gardenId, String userId) => _guard(
    () => _client
        .from('garden_members')
        .delete()
        .eq('garden_id', gardenId)
        .eq('user_id', userId),
  );
}

/// Chyba z databázové funkce (text výjimky) jako [SharingFailure].
SharingFailure sharingFailureFor(String message) => switch (message) {
  'premium_required' => SharingFailure.notPremium,
  'not_owner' || 'not_member' => SharingFailure.notOwner,
  'invalid_invite' => SharingFailure.invalidCode,
  'not_signed_in' => SharingFailure.notSignedIn,
  _ => SharingFailure.failed,
};
