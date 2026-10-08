import 'dart:convert';
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/backend/network_errors.dart';
import '../domain/diagnosis.dart';

/// Diagnostika přes Edge Function `diagnose` (FR-V1). Klíč k modelu je
/// jen v secrets funkce; Premium, souhlas a limit hlídá server.
class SupabaseDiagnosisBackend implements DiagnosisBackend {
  SupabaseDiagnosisBackend(this._client);

  final SupabaseClient _client;

  @override
  bool get available => true;

  @override
  Future<DiagnosisResult> diagnose(
    Uint8List jpeg, {
    String? zoneType,
    String? note,
  }) async {
    if (_client.auth.currentSession == null) {
      throw const DiagnosisException(DiagnosisFailure.notSignedIn);
    }
    try {
      final response = await _client.functions.invoke(
        'diagnose',
        body: {
          'image': base64Encode(jpeg),
          'zoneType': ?zoneType,
          'note': ?note,
        },
      );
      final result = DiagnosisResult.fromJson(response.data);
      if (result == null) {
        throw const DiagnosisException(DiagnosisFailure.failed);
      }
      return result;
    } on FunctionException catch (e) {
      throw DiagnosisException(diagnosisFailureFor(e.status));
    } on DiagnosisException {
      rethrow;
    } catch (e) {
      if (isNetworkError(e)) {
        throw const DiagnosisException(DiagnosisFailure.offline);
      }
      throw const DiagnosisException(DiagnosisFailure.failed);
    }
  }
}

/// Chybová odpověď funkce `diagnose` jako [DiagnosisFailure].
DiagnosisFailure diagnosisFailureFor(int status) => switch (status) {
  401 => DiagnosisFailure.notSignedIn,
  402 => DiagnosisFailure.notPremium,
  403 => DiagnosisFailure.noConsent,
  429 => DiagnosisFailure.limitReached,
  400 => DiagnosisFailure.badImage,
  _ => DiagnosisFailure.failed,
};
