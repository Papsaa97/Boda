import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/backend/network_errors.dart';
import '../domain/weather.dart';

/// Počasí přes Edge Function `weather` (FR-W1). Klíč poskytovatele je
/// jen v secrets funkce, Premium hlídá server.
class SupabaseWeatherSource implements WeatherSource {
  SupabaseWeatherSource(this._client);

  final SupabaseClient _client;

  @override
  bool get available => true;

  @override
  Future<WeatherReport> fetch(GardenLocation location) async {
    if (_client.auth.currentSession == null) {
      throw const WeatherException(WeatherFailure.notSignedIn);
    }
    try {
      final response = await _client.functions.invoke(
        'weather',
        body: {'lat': location.lat, 'lng': location.lng},
      );
      final report = WeatherReport.fromJson(response.data);
      if (report == null || report.days.isEmpty) {
        throw const WeatherException(WeatherFailure.providerError);
      }
      return report;
    } on FunctionException catch (e) {
      throw WeatherException(weatherFailureFor(e.status));
    } on WeatherException {
      rethrow;
    } catch (e) {
      if (isNetworkError(e)) {
        throw const WeatherException(WeatherFailure.offline);
      }
      throw const WeatherException(WeatherFailure.providerError);
    }
  }
}

/// Chybová odpověď funkce `weather` jako [WeatherFailure].
WeatherFailure weatherFailureFor(int status) => switch (status) {
  401 => WeatherFailure.notSignedIn,
  402 => WeatherFailure.notPremium,
  400 => WeatherFailure.noLocation,
  _ => WeatherFailure.providerError,
};
