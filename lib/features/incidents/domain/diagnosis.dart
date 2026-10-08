import 'dart:typed_data';

import 'incident.dart';

/// Proč diagnostika z fotky neprošla (vysvětlí se uživateli).
enum DiagnosisFailure {
  /// Build bez backendu.
  unavailable,
  notSignedIn,

  /// Diagnostika je v Premium (kap. 11).
  notPremium,

  /// Chybí souhlas s odesláním fotek (FR-V1).
  noConsent,

  /// Vyčerpaný měsíční limit (sdílený s dotazy na Bóďu).
  limitReached,

  /// Fotku nejde poslat (není to JPEG, nebo jsou v ní metadata).
  badImage,
  offline,

  /// Server nebo model selhal, případně není nastavený.
  failed,
}

class DiagnosisException implements Exception {
  const DiagnosisException(this.failure);

  final DiagnosisFailure failure;

  @override
  String toString() => 'DiagnosisException($failure)';
}

/// Výsledek: 1–3 možné příčiny (FR-V2). Prázdný = z fotky nejde nic poznat.
class DiagnosisResult {
  const DiagnosisResult(this.candidates);

  final List<IncidentCandidate> candidates;

  bool get unclear => candidates.isEmpty;

  static DiagnosisResult? fromJson(Object? json) {
    if (json is! Map) return null;
    final list = json['candidates'];
    if (list is! List) return null;
    return DiagnosisResult([
      for (final c in list.take(3)) ?IncidentCandidate.fromJson(c),
    ]);
  }
}

/// Diagnostika z fotky přes Edge Function `diagnose`.
abstract interface class DiagnosisBackend {
  bool get available;

  /// [jpeg] musí být bez metadat. Hází [DiagnosisException].
  Future<DiagnosisResult> diagnose(
    Uint8List jpeg, {
    String? zoneType,
    String? note,
  });
}

class UnavailableDiagnosisBackend implements DiagnosisBackend {
  const UnavailableDiagnosisBackend();

  @override
  bool get available => false;

  @override
  Future<DiagnosisResult> diagnose(
    Uint8List jpeg, {
    String? zoneType,
    String? note,
  }) => Future.error(const DiagnosisException(DiagnosisFailure.unavailable));
}
