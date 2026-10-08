import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/photos/jpeg_metadata.dart';
import '../../account/presentation/consent_sync.dart';
import '../../settings/presentation/settings_controller.dart';
import '../domain/diagnosis.dart';

/// Diagnostika z fotky (FR-V1, FR-V2); stav = právě běží.
class DiagnosisController extends Notifier<bool> {
  @override
  bool build() => false;

  bool get available => ref.read(diagnosisBackendProvider).available;

  bool get hasConsent =>
      ref.read(settingsControllerProvider).photoConsentAt != null;

  /// Souhlas s odesláním fotek; počká na zápis do profilu, protože ho
  /// server před diagnózou kontroluje.
  Future<void> grantConsent() async {
    await ref
        .read(settingsControllerProvider.notifier)
        .update(
          (s) => s.copyWith(photoConsentAt: () => ref.read(clockProvider)()),
        );
    await pushConsents(ref);
  }

  /// Odstraní z fotky metadata (EXIF s polohou) a pošle ji k diagnóze.
  /// Hází [DiagnosisException].
  Future<DiagnosisResult> diagnose(
    Uint8List photo, {
    String? zoneType,
    String? note,
  }) async {
    if (!hasConsent) {
      throw const DiagnosisException(DiagnosisFailure.noConsent);
    }
    final jpeg = stripJpegMetadata(photo);
    if (jpeg == null) throw const DiagnosisException(DiagnosisFailure.badImage);
    state = true;
    try {
      return await ref
          .read(diagnosisBackendProvider)
          .diagnose(
            jpeg,
            zoneType: zoneType,
            note: note == null || note.trim().isEmpty ? null : note.trim(),
          );
    } finally {
      if (ref.mounted) state = false;
    }
  }
}

final diagnosisControllerProvider = NotifierProvider<DiagnosisController, bool>(
  DiagnosisController.new,
);
