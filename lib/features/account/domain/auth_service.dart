import 'package:equatable/equatable.dart';

/// Přihlášený uživatel. Telefon zná jen id a e-mail (kap. 9).
class AccountUser extends Equatable {
  const AccountUser({required this.id, this.email});

  final String id;
  final String? email;

  @override
  List<Object?> get props => [id, email];
}

/// Proč se přihlášení nebo práce s účtem nepovedla.
enum AuthFailureKind {
  invalidEmail,

  /// Špatný nebo prošlý kód z e-mailu.
  invalidCode,

  /// Moc pokusů za krátkou dobu.
  rateLimited,
  offline,
  unknown,
}

class AuthFailure implements Exception {
  const AuthFailure(this.kind, [this.detail]);

  final AuthFailureKind kind;
  final String? detail;

  @override
  String toString() => 'AuthFailure(${kind.name}, $detail)';
}

/// Účet (Supabase Auth, DECLOG D71). Přihlášení e-mailem jednorázovým
/// kódem, bez hesla; Google a Apple přijdou s nastavením v konzolích.
abstract interface class AuthService {
  /// Aplikace má nastavený backend; jinak se účet nenabízí.
  bool get available;

  AccountUser? get currentUser;

  /// Změny přihlášení (přihlášení, odhlášení, obnovení relace).
  Stream<AccountUser?> get userChanges;

  /// Pošle na [email] jednorázový kód (účet se založí, když neexistuje).
  Future<void> sendCode(String email);

  /// Přihlásí kódem z e-mailu.
  Future<void> verifyCode(String email, String code);

  Future<void> signOut();

  /// Smaže účet a data na serveru (Edge Function `delete-account`),
  /// pak odhlásí. Data v telefonu zůstanou.
  Future<void> deleteAccount();
}

/// Build bez backendu: účet není k dispozici.
class UnavailableAuthService implements AuthService {
  const UnavailableAuthService();

  @override
  bool get available => false;

  @override
  AccountUser? get currentUser => null;

  @override
  Stream<AccountUser?> get userChanges => const Stream.empty();

  Never _unavailable() => throw const AuthFailure(AuthFailureKind.unknown);

  @override
  Future<void> sendCode(String email) async => _unavailable();

  @override
  Future<void> verifyCode(String email, String code) async => _unavailable();

  @override
  Future<void> signOut() async {}

  @override
  Future<void> deleteAccount() async => _unavailable();
}

/// Rozumně vypadající e-mail (přesnou kontrolu dělá server).
bool looksLikeEmail(String email) =>
    RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email.trim());
