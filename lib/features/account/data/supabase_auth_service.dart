import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/backend/network_errors.dart';
import '../domain/auth_service.dart';

/// Účet přes Supabase Auth.
class SupabaseAuthService implements AuthService {
  SupabaseAuthService(this._client);

  final SupabaseClient _client;

  @override
  bool get available => true;

  static AccountUser? _user(User? u) =>
      u == null ? null : AccountUser(id: u.id, email: u.email);

  @override
  AccountUser? get currentUser => _user(_client.auth.currentUser);

  @override
  Stream<AccountUser?> get userChanges =>
      _client.auth.onAuthStateChange.map((s) => _user(s.session?.user));

  Future<T> _guard<T>(Future<T> Function() op) async {
    try {
      return await op();
    } on AuthException catch (e) {
      if (isNetworkError(e)) {
        throw const AuthFailure(AuthFailureKind.offline);
      }
      final code = e.code ?? '';
      throw AuthFailure(switch (e.statusCode) {
        '429' => AuthFailureKind.rateLimited,
        _ when code.contains('otp') || code.contains('token') =>
          AuthFailureKind.invalidCode,
        _ when code.contains('email') => AuthFailureKind.invalidEmail,
        _ => AuthFailureKind.unknown,
      }, e.message);
    } on FunctionException catch (e) {
      throw AuthFailure(AuthFailureKind.unknown, '${e.status}');
    } catch (e) {
      if (isNetworkError(e)) {
        throw const AuthFailure(AuthFailureKind.offline);
      }
      rethrow;
    }
  }

  @override
  Future<void> sendCode(String email) {
    if (!looksLikeEmail(email)) {
      throw const AuthFailure(AuthFailureKind.invalidEmail);
    }
    return _guard(() => _client.auth.signInWithOtp(email: email.trim()));
  }

  @override
  Future<void> verifyCode(String email, String code) => _guard(
    () => _client.auth.verifyOTP(
      type: OtpType.email,
      email: email.trim(),
      token: code.trim(),
    ),
  );

  @override
  Future<void> signOut() => _guard(() => _client.auth.signOut());

  @override
  Future<void> deleteAccount() => _guard(() async {
    await _client.functions.invoke('delete-account');
    // Uživatel na serveru už není; místní relaci stačí zahodit.
    await _client.auth.signOut(scope: SignOutScope.local);
  });
}
