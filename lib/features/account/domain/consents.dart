import '../../settings/domain/app_settings.dart';

/// Verze zásad ochrany soukromí, se kterou uživatel souhlasil. Při
/// podstatné změně zásad se zvýší a souhlasy se vyžádají znovu.
const privacyPolicyVersion = '2026-10';

/// Odkaz na zásady ochrany soukromí (stránku zakládá Papi, DECLOG D74).
const privacyPolicyUrl = String.fromEnvironment(
  'PRIVACY_POLICY_URL',
  defaultValue: 'https://zahradnikboda.cz/soukromi',
);

/// Souhlasy pro `profiles.consents` na serveru (spec 8.1, kap. 9):
/// `{aiProcessing: {granted, at}, analytics: {granted, at}, policyVersion}`.
///
/// Odvolaný souhlas má `granted: false` a čas odvolání [changedAt].
Map<String, Object?> consentsJson(
  AppSettings settings, {
  required DateTime changedAt,
}) {
  Map<String, Object?> entry(DateTime? at) => {
    'granted': at != null,
    'at': (at ?? changedAt).toUtc().toIso8601String(),
  };
  return {
    'aiProcessing': entry(settings.aiConsentAt),
    'analytics': entry(settings.analyticsConsentAt),
    'policyVersion': privacyPolicyVersion,
  };
}

/// Profil uživatele na serveru.
abstract interface class ProfileRemote {
  Future<void> saveConsents(String userId, Map<String, Object?> consents);
}
