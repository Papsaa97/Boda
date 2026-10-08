import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../settings/presentation/settings_controller.dart';
import '../domain/consents.dart';

/// Zapisuje souhlasy do profilu na serveru po přihlášení a po každé změně
/// (záznam verze a času souhlasu, kap. 9). Bez připojení se zapíšou při
/// příští změně nebo přihlášení; v telefonu platí vždy hned.
final consentSyncProvider = Provider<void>((ref) {
  Future<void> push() async {
    final user = ref.read(currentUserProvider).value;
    final remote = ref.read(profileRemoteProvider);
    if (user == null || remote == null) return;
    try {
      await remote.saveConsents(
        user.id,
        consentsJson(
          ref.read(settingsControllerProvider),
          changedAt: ref.read(clockProvider)(),
        ),
      );
    } on Exception catch (e) {
      debugPrint('Souhlasy se na server neuložily: $e');
    }
  }

  ref
    ..listen(currentUserProvider, (prev, next) {
      final user = next.value;
      if (user != null && prev?.value?.id != user.id) push();
    })
    ..listen(
      settingsControllerProvider.select(
        (s) => (s.aiConsentAt, s.analyticsConsentAt),
      ),
      (_, _) => push(),
    );
});
