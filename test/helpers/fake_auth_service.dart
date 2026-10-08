import 'dart:async';

import 'package:zahradnik_boda/features/account/domain/auth_service.dart';

/// Účet bez serveru: kód je vždy `123456`.
class FakeAuthService implements AuthService {
  FakeAuthService({AccountUser? user}) : _user = user;

  static const code = '123456';

  AccountUser? _user;
  final _changes = StreamController<AccountUser?>.broadcast();
  final List<String> sentTo = [];
  var deleted = false;

  /// Bez připojení: všechna volání selžou.
  bool offline = false;

  void _check() {
    if (offline) throw const AuthFailure(AuthFailureKind.offline);
  }

  void _set(AccountUser? user) {
    _user = user;
    _changes.add(user);
  }

  @override
  bool get available => true;

  @override
  AccountUser? get currentUser => _user;

  @override
  Stream<AccountUser?> get userChanges => _changes.stream;

  @override
  Future<void> sendCode(String email) async {
    _check();
    if (!looksLikeEmail(email)) {
      throw const AuthFailure(AuthFailureKind.invalidEmail);
    }
    sentTo.add(email);
  }

  @override
  Future<void> verifyCode(String email, String code) async {
    _check();
    if (code.trim() != FakeAuthService.code) {
      throw const AuthFailure(AuthFailureKind.invalidCode);
    }
    _set(AccountUser(id: 'user-1', email: email));
  }

  @override
  Future<void> signOut() async => _set(null);

  @override
  Future<void> deleteAccount() async {
    _check();
    deleted = true;
    _set(null);
  }
}
