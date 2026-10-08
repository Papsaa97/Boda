import 'package:flutter/foundation.dart';

/// Klíče služeb třetích stran pro vydání (DECLOG D102). Předávají se při
/// buildu přes `--dart-define` (nebo `--dart-define-from-file=env/prod.json`),
/// nikdy nejsou v gitu. Prázdný klíč = služba vypnutá, aplikace běží bez ní.
///
/// Žádný z těchto klíčů není tajný v pravém smyslu (jsou určené do
/// klientské aplikace), ale servisní klíče (RevenueCat secret, Sentry auth
/// token) sem nepatří.
class ReleaseConfig {
  const ReleaseConfig({
    required this.sentryDsn,
    required this.posthogApiKey,
    required this.posthogHost,
    required this.revenueCatAndroidKey,
    required this.revenueCatIosKey,
    required this.environment,
  });

  static const fromEnvironment = ReleaseConfig(
    sentryDsn: String.fromEnvironment('SENTRY_DSN'),
    posthogApiKey: String.fromEnvironment('POSTHOG_API_KEY'),
    posthogHost: String.fromEnvironment(
      'POSTHOG_HOST',
      defaultValue: 'https://eu.i.posthog.com',
    ),
    revenueCatAndroidKey: String.fromEnvironment('REVENUECAT_ANDROID_KEY'),
    revenueCatIosKey: String.fromEnvironment('REVENUECAT_IOS_KEY'),
    environment: String.fromEnvironment('APP_ENV', defaultValue: 'dev'),
  );

  /// Sentry DSN projektu (EU). Prázdné = pády jen do konzole.
  final String sentryDsn;

  /// Project API key PostHogu (EU) a adresa instance.
  final String posthogApiKey;
  final String posthogHost;

  /// Veřejné klíče RevenueCat pro každý obchod zvlášť.
  final String revenueCatAndroidKey;
  final String revenueCatIosKey;

  /// `dev` nebo `prod`; jde do Sentry a PostHogu, aby se vývoj nemíchal
  /// s uživateli.
  final String environment;

  bool get hasSentry => sentryDsn.isNotEmpty;
  bool get hasPosthog => posthogApiKey.isNotEmpty;

  /// Klíč RevenueCat pro běžící platformu; null na webu a bez klíče.
  String? get revenueCatKey {
    if (kIsWeb) return null;
    final key = switch (defaultTargetPlatform) {
      TargetPlatform.android => revenueCatAndroidKey,
      TargetPlatform.iOS => revenueCatIosKey,
      _ => '',
    };
    return key.isEmpty ? null : key;
  }
}
