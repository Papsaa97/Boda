import 'package:equatable/equatable.dart';

import '../../../core/time/calendar.dart';
import '../../activity/domain/activity_entity.dart';
import '../../activity/domain/activity_type.dart';
import '../../tasks/domain/task_entity.dart';
import '../../zones/domain/zone_entity.dart';
import 'weather.dart';

/// Výchozí práh srážek za 7 dní, nad kterým zóna zálivku nepotřebuje
/// (FR-W3). Startovní hodnoty k ověření v praxi (DECLOG D86).
double rainThresholdMm(ZoneType type) => switch (type) {
  ZoneType.herbs => 12,
  ZoneType.fruit || ZoneType.lawn => 20,
  _ => 15,
};

/// Předpověď na 24 h, se kterou se zálivka odloží (FR-W3).
const forecastSkipMm = 5.0;

/// Zóny, které zálivku nikdy neřeší (jezírko, stavba).
bool _needsWater(ZoneEntity z) =>
    z.type != ZoneType.pond && z.type != ZoneType.structure;

/// Proč zálivku odložit.
enum SkipReason { rainedEnough, rainExpected }

/// Rada k zálivce jedné zóny (FR-W2, FR-W3).
class WateringAdvice extends Equatable {
  const WateringAdvice({
    required this.zone,
    required this.skip,
    required this.rainMm,
    required this.thresholdMm,
    this.reason,
    this.covered = false,
  });

  final ZoneEntity zone;

  /// Krytá zóna: déšť nedostane, zalévá se vždy podle potřeby.
  final bool covered;

  /// Zálivku jde odložit.
  final bool skip;
  final SkipReason? reason;

  /// Srážky, které zóna dostala (krytá zóna 0).
  final double rainMm;
  final double thresholdMm;

  @override
  List<Object?> get props => [zone, skip, reason, rainMm, thresholdMm, covered];
}

/// Srážky se vztahují k zahradě, zóna jen určuje, jestli déšť dostane
/// (FR-W2): krytá zóna (skleník, fóliovník) srážky nezapočítává.
List<WateringAdvice> wateringAdvice({
  required List<ZoneEntity> zones,
  required WeatherReport weather,
  required DateTime now,
}) {
  final past = weather.rainLast7Days(now);
  final next = weather.rainNext24h(now);
  return [
    for (final z in zones)
      if (z.isActive && _needsWater(z)) _advice(z, past: past, next: next),
  ];
}

WateringAdvice _advice(
  ZoneEntity z, {
  required double past,
  required double next,
}) {
  final threshold = rainThresholdMm(z.type);
  final covered = z.covered || z.type == ZoneType.greenhouse;
  if (covered) {
    return WateringAdvice(
      zone: z,
      skip: false,
      rainMm: 0,
      thresholdMm: threshold,
      covered: true,
    );
  }
  final reason = past >= threshold
      ? SkipReason.rainedEnough
      : next >= forecastSkipMm
      ? SkipReason.rainExpected
      : null;
  return WateringAdvice(
    zone: z,
    skip: reason != null,
    reason: reason,
    rainMm: past,
    thresholdMm: threshold,
  );
}

/// Je úkol zálivka? Úkoly nemají typ, pozná se podle názvu.
bool isWateringTask(TaskEntity t) =>
    ActivityType.guessFromTitle(t.title) == ActivityType.watering;

/// Otevřené úkoly zálivky na dnešek nebo zítřek v zónách, kde jde
/// zálivku odložit (FR-W3). Úkol bez zóny se řídí deštěm na zahradě:
/// odloží se, jen když jde odložit ve všech nekrytých zónách.
List<TaskEntity> wateringTasksToPostpone({
  required List<TaskEntity> tasks,
  required List<WateringAdvice> advice,
  required DateTime now,
}) {
  final today = dayOnly(now);
  final tomorrow = DateTime(today.year, today.month, today.day + 1);
  final byZone = {for (final a in advice) a.zone.id: a};
  final outdoor = advice.where((a) => !a.covered);
  final gardenSkip = outdoor.isNotEmpty && outdoor.every((a) => a.skip);
  return [
    for (final t in tasks)
      if (t.isOpen &&
          isWateringTask(t) &&
          !t.effectiveDate.isAfter(tomorrow) &&
          (t.zoneId == null ? gardenSkip : byZone[t.zoneId]?.skip == true))
        t,
  ];
}

/// Kam odložit zálivku: o den za den, kdy je na řadě, nejdřív na zítřek.
DateTime postponeTarget(TaskEntity t, DateTime now) {
  final today = dayOnly(now);
  final due = dayOnly(t.effectiveDate);
  final from = due.isBefore(today) ? today : due;
  return DateTime(from.year, from.month, from.day + 1);
}

/// Měsíce, kdy hrozí mráz výsadbám (FR-W4): jaro a podzim.
const frostSeasonMonths = {3, 4, 5, 6, 9, 10};

/// Varování před mrazem (FR-W4).
class FrostWarning extends Equatable {
  const FrostWarning({
    required this.date,
    required this.tMinC,
    required this.zones,
  });

  /// První den s mrazem v předpovědi.
  final DateTime date;
  final double tMinC;

  /// Nekryté zóny s čerstvým výsevem nebo výsadbou.
  final List<ZoneEntity> zones;

  @override
  List<Object?> get props => [date, tMinC, zones];
}

/// Mráz (≤ 0 °C) v příštích 3 dnech v sezóně a zóny, kde se za
/// posledních 8 týdnů sázelo nebo selo (citlivé výsadby).
FrostWarning? frostWarning({
  required WeatherReport weather,
  required List<ZoneEntity> zones,
  required List<ActivityEntity> activities,
  required DateTime now,
}) {
  if (!frostSeasonMonths.contains(now.month)) return null;
  final today = dayOnly(now);
  final until = DateTime(today.year, today.month, today.day + 3);
  final frost = weather
      .forecast(now)
      .where((d) => d.date.isBefore(until))
      .where((d) => (d.tMinC ?? 99) <= 0)
      .firstOrNull;
  if (frost == null) return null;
  final since = DateTime(today.year, today.month, today.day - 56);
  final fresh = {
    for (final a in activities)
      if ((a.type == ActivityType.sowing || a.type == ActivityType.planting) &&
          !a.date.isBefore(since))
        a.zoneId,
  };
  final sensitive = [
    for (final z in zones)
      if (z.isActive && !z.covered && fresh.contains(z.id)) z,
  ];
  if (sensitive.isEmpty) return null;
  return FrostWarning(date: frost.date, tMinC: frost.tMinC!, zones: sensitive);
}
