/// Připojení k backendu Supabase (spec 7.1, DECLOG D71).
///
/// Adresa projektu a veřejný (publishable) klíč se předávají při buildu:
/// `flutter run --dart-define=SUPABASE_URL=… --dart-define=SUPABASE_PUBLISHABLE_KEY=…`.
/// Bez nich aplikace běží jen v telefonu (účet, synchronizace a Bóďa
/// s AI se nenabízejí). Servisní klíč do aplikace nikdy nepatří.
class BackendConfig {
  const BackendConfig({required this.url, required this.publishableKey});

  static const fromEnvironment = BackendConfig(
    url: String.fromEnvironment('SUPABASE_URL'),
    publishableKey: String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY'),
  );

  final String url;
  final String publishableKey;

  bool get isConfigured => url.isNotEmpty && publishableKey.isNotEmpty;
}
