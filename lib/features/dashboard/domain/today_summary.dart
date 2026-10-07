import '../../activity/domain/activity_entity.dart';
import '../../zones/domain/zone_entity.dart';

/// Kolik dní bez záznamu už stojí za připomenutí.
const neglectedAfterDays = 7;

/// Stav jedné zóny pro dashboard „Co dnes?“.
class ZoneStatus {
  final ZoneEntity zone;

  /// Datum posledního záznamu v zóně, nebo null, pokud tam ještě nic není.
  final DateTime? lastActivity;

  /// Počet celých kalendářních dní od posledního záznamu.
  final int? daysSince;

  const ZoneStatus({required this.zone, this.lastActivity, this.daysSince});

  bool get isNeglected => daysSince == null || daysSince! >= neglectedAfterDays;
}

/// Podklad pro dashboard „Co dnes?“ spočítaný čistě z lokálních dat.
class TodaySummary {
  /// Dnešní záznamy, nejnovější první.
  final List<ActivityEntity> today;

  /// Zóny bez záznamu aspoň [neglectedAfterDays] dní, nejdéle opomíjené první.
  final List<ZoneStatus> needsAttention;

  /// Úplně poslední záznam v deníku.
  final ActivityEntity? lastActivity;

  /// Počet záznamů za posledních 7 dní včetně dneška.
  final int lastWeekCount;

  const TodaySummary({
    required this.today,
    required this.needsAttention,
    required this.lastActivity,
    required this.lastWeekCount,
  });
}

DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

/// Počet kalendářních dní mezi dvěma daty (bez ohledu na čas a letní čas).
int calendarDaysBetween(DateTime from, DateTime to) {
  final a = DateTime.utc(from.year, from.month, from.day);
  final b = DateTime.utc(to.year, to.month, to.day);
  return b.difference(a).inDays;
}

TodaySummary buildTodaySummary({
  required List<ActivityEntity> activities,
  required List<ZoneEntity> zones,
  required DateTime now,
}) {
  final today = _day(now);
  final sorted = [...activities]..sort((a, b) => b.date.compareTo(a.date));

  final todays = sorted.where((a) => _day(a.date) == today).toList();

  final lastWeekCount = sorted.where((a) {
    final diff = calendarDaysBetween(a.date, now);
    return diff >= 0 && diff < 7;
  }).length;

  final lastByZone = <String, DateTime>{};
  for (final a in sorted) {
    lastByZone.putIfAbsent(a.zoneId, () => a.date);
  }

  final statuses = zones.map((zone) {
    final last = lastByZone[zone.id];
    return ZoneStatus(
      zone: zone,
      lastActivity: last,
      daysSince: last == null ? null : calendarDaysBetween(last, now),
    );
  }).where((s) => s.isNeglected).toList()
    ..sort((a, b) {
      // Zóny bez jediného záznamu až za ty, které jsou dlouho opomíjené.
      if (a.daysSince == null && b.daysSince == null) {
        return a.zone.name.compareTo(b.zone.name);
      }
      if (a.daysSince == null) return 1;
      if (b.daysSince == null) return -1;
      return b.daysSince!.compareTo(a.daysSince!);
    });

  return TodaySummary(
    today: todays,
    needsAttention: statuses,
    lastActivity: sorted.isEmpty ? null : sorted.first,
    lastWeekCount: lastWeekCount,
  );
}
