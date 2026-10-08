import 'package:equatable/equatable.dart';

import '../../../core/time/calendar.dart';

/// Počasí jednoho dne v místě zahrady (FR-W1).
class DailyWeather extends Equatable {
  const DailyWeather({
    required this.date,
    required this.precipMm,
    this.tMinC,
    this.tMaxC,
  });

  /// Den (místní kalendářní den, bez času).
  final DateTime date;
  final double precipMm;
  final double? tMinC;
  final double? tMaxC;

  Map<String, Object?> toJson() => {
    'date': formatDateKey(date),
    'precipMm': precipMm,
    'tMinC': tMinC,
    'tMaxC': tMaxC,
  };

  static DailyWeather? fromJson(Object? json) {
    if (json is! Map) return null;
    final date = json['date'] is String
        ? parseDateKey(json['date'] as String)
        : null;
    final precip = json['precipMm'];
    if (date == null || precip is! num) return null;
    return DailyWeather(
      date: date,
      precipMm: precip.toDouble(),
      tMinC: (json['tMinC'] as num?)?.toDouble(),
      tMaxC: (json['tMaxC'] as num?)?.toDouble(),
    );
  }

  @override
  List<Object?> get props => [date, precipMm, tMinC, tMaxC];
}

/// Srážky za posledních 7 dní a předpověď na 7 dní (FR-W1).
class WeatherReport extends Equatable {
  const WeatherReport({
    required this.fetchedAt,
    required this.days,
    this.elevationM,
  });

  final DateTime fetchedAt;

  /// Dny seřazené od nejstaršího: minulé i předpověď.
  final List<DailyWeather> days;

  /// Nadmořská výška místa podle poskytovatele počasí.
  final int? elevationM;

  /// Srážky za posledních 7 dní před [today] (bez dneška).
  double rainLast7Days(DateTime today) {
    final t = dayOnly(today);
    final from = DateTime(t.year, t.month, t.day - 7);
    return days
        .where((d) => !d.date.isBefore(from) && d.date.isBefore(t))
        .fold(0.0, (sum, d) => sum + d.precipMm);
  }

  /// Předpověď srážek na dnešek a zítřek jako „příštích 24 h“ (denní
  /// data nemají hodiny; bere se vyšší z obou dnů).
  double rainNext24h(DateTime today) {
    final t = dayOnly(today);
    final tomorrow = DateTime(t.year, t.month, t.day + 1);
    var max = 0.0;
    for (final d in days) {
      if ((d.date == t || d.date == tomorrow) && d.precipMm > max) {
        max = d.precipMm;
      }
    }
    return max;
  }

  /// Dny od [today] dál.
  List<DailyWeather> forecast(DateTime today) {
    final t = dayOnly(today);
    return [
      for (final d in days)
        if (!d.date.isBefore(t)) d,
    ];
  }

  Map<String, Object?> toJson() => {
    'fetchedAt': fetchedAt.toUtc().toIso8601String(),
    'elevationM': elevationM,
    'days': [for (final d in days) d.toJson()],
  };

  static WeatherReport? fromJson(Object? json) {
    if (json is! Map) return null;
    final fetched = json['fetchedAt'] is String
        ? DateTime.tryParse(json['fetchedAt'] as String)
        : null;
    final days = json['days'];
    if (fetched == null || days is! List) return null;
    return WeatherReport(
      fetchedAt: fetched.toLocal(),
      elevationM: (json['elevationM'] as num?)?.round(),
      days: [for (final d in days) ?DailyWeather.fromJson(d)]
        ..sort((a, b) => a.date.compareTo(b.date)),
    );
  }

  @override
  List<Object?> get props => [fetchedAt, days, elevationM];
}

/// Poloha zahrady zaokrouhlená na ~1 km (spec 8.1, kap. 9).
class GardenLocation extends Equatable {
  GardenLocation(double lat, double lng)
    : lat = _round2(lat),
      lng = _round2(lng);

  final double lat;
  final double lng;

  static double _round2(double v) => (v * 100).roundToDouble() / 100;

  /// Česká republika a okolí: jiné souřadnice jsou nejspíš překlep
  /// (prohozená šířka a délka).
  bool get isPlausible => lat >= 47 && lat <= 52 && lng >= 11 && lng <= 20;

  @override
  List<Object?> get props => [lat, lng];
}

/// Chyby počasí, které jde uživateli vysvětlit.
enum WeatherFailure {
  /// Backend není nastavený (build bez Supabase).
  unavailable,
  notSignedIn,

  /// Počasí a zálivka jsou v Premium (kap. 11).
  notPremium,
  noLocation,
  offline,

  /// Poskytovatel počasí odpověděl chybou nebo není nastavený.
  providerError,
}

class WeatherException implements Exception {
  const WeatherException(this.failure);

  final WeatherFailure failure;

  @override
  String toString() => 'WeatherException($failure)';
}

/// Zdroj počasí (Edge Function `weather` s klíčem poskytovatele).
abstract interface class WeatherSource {
  bool get available;

  /// Srážky za 7 dní zpět a předpověď na 7 dní. Hází [WeatherException].
  Future<WeatherReport> fetch(GardenLocation location);
}

class UnavailableWeatherSource implements WeatherSource {
  const UnavailableWeatherSource();

  @override
  bool get available => false;

  @override
  Future<WeatherReport> fetch(GardenLocation location) =>
      Future.error(const WeatherException(WeatherFailure.unavailable));
}
