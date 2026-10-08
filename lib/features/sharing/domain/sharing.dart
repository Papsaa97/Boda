import 'package:equatable/equatable.dart';

/// Role ve sdílené zahradě (spec 8.1 `garden_members.role`). Pozvánka
/// zve vždy člena s rolí editor (DECLOG D89).
enum GardenRole {
  owner,
  editor,
  viewer;

  static GardenRole fromKey(String? key) =>
      values.firstWhere((r) => r.name == key, orElse: () => viewer);
}

class GardenMember extends Equatable {
  const GardenMember({
    required this.userId,
    required this.role,
    this.displayName,
    this.email,
    this.joinedAt,
  });

  final String userId;
  final GardenRole role;
  final String? displayName;
  final String? email;
  final DateTime? joinedAt;

  /// Jméno, jinak e-mail.
  String get label => displayName?.trim().isNotEmpty == true
      ? displayName!.trim()
      : (email ?? '');

  @override
  List<Object?> get props => [userId, role, displayName, email, joinedAt];
}

class GardenInvite extends Equatable {
  const GardenInvite({required this.code, required this.expiresAt});

  /// Kód z 8 znaků (bez 0/O a 1/I/L).
  final String code;
  final DateTime expiresAt;

  /// Kód po čtveřicích, ať se dobře přepisuje: „ABCD-EFGH“.
  String get display =>
      code.length == 8 ? '${code.substring(0, 4)}-${code.substring(4)}' : code;

  @override
  List<Object?> get props => [code, expiresAt];
}

/// Kód, jak ho uživatel napsal: bez mezer a pomlček, velkými písmeny.
/// Neplatný tvar = null.
String? normalizeInviteCode(String input) {
  final code = input.toUpperCase().replaceAll(RegExp('[^A-Z0-9]'), '');
  return RegExp(r'^[A-HJ-NP-Z2-9]{8}$').hasMatch(code) ? code : null;
}

enum SharingFailure {
  /// Build bez backendu.
  unavailable,
  notSignedIn,

  /// Pozvat člena může jen vlastník s Premium (kap. 11.2).
  notPremium,
  notOwner,

  /// Kód neexistuje, už byl použitý, nebo vypršel.
  invalidCode,
  offline,
  failed,
}

class SharingException implements Exception {
  const SharingException(this.failure);

  final SharingFailure failure;

  @override
  String toString() => 'SharingException($failure)';
}

/// Sdílení zahrady na serveru. Hází [SharingException].
abstract interface class SharingRemote {
  Future<List<GardenMember>> members(String gardenId);
  Future<GardenInvite> createInvite(String gardenId);

  /// Vrátí id zahrady, do které pozvánka vede.
  Future<String> acceptInvite(String code);
  Future<void> removeMember(String gardenId, String userId);
}
