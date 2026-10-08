import '../../../core/time/calendar.dart';
import '../../activity/domain/activity_entity.dart';
import '../../activity/domain/activity_type.dart';

/// Počet záznamů v jednom týdnu (od pondělí).
class WeekCount {
  const WeekCount(this.weekStart, this.count);

  final DateTime weekStart;
  final int count;
}

/// Statistika deníku pro testery (spec 3, MVP 0.2 bod 6; podklad pro H1).
class DiaryStats {
  const DiaryStats({
    required this.total,
    required this.weeks,
    required this.zoneCounts,
    required this.typeCounts,
  });

  final int total;

  /// Posledních N týdnů, nejstarší první; poslední je aktuální týden.
  final List<WeekCount> weeks;

  /// Id zóny → počet záznamů, od nejaktivnější.
  final List<MapEntry<String, int>> zoneCounts;

  /// Typ činnosti → počet záznamů, od nejčastějšího.
  final List<MapEntry<ActivityType, int>> typeCounts;

  /// Týdny, kdy přibyly aspoň 2 záznamy (měřítko hypotézy H1).
  int get activeWeeks => weeks.where((w) => w.count >= 2).length;

  int get thisWeek => weeks.isEmpty ? 0 : weeks.last.count;
}

DiaryStats buildDiaryStats({
  required List<ActivityEntity> activities,
  required DateTime now,
  int weekCount = 8,
}) {
  final currentWeek = startOfWeek(now);
  final weekStarts = [
    for (var i = weekCount - 1; i >= 0; i--)
      DateTime(currentWeek.year, currentWeek.month, currentWeek.day - 7 * i),
  ];
  final perWeek = {for (final w in weekStarts) w: 0};
  final zones = <String, int>{};
  final types = <ActivityType, int>{};

  for (final a in activities) {
    final week = startOfWeek(a.date);
    if (perWeek.containsKey(week)) perWeek[week] = perWeek[week]! + 1;
    zones[a.zoneId] = (zones[a.zoneId] ?? 0) + 1;
    types[a.type] = (types[a.type] ?? 0) + 1;
  }

  int byCount<K>(MapEntry<K, int> a, MapEntry<K, int> b) =>
      b.value.compareTo(a.value);

  return DiaryStats(
    total: activities.length,
    weeks: [for (final w in weekStarts) WeekCount(w, perWeek[w]!)],
    zoneCounts: zones.entries.toList()..sort(byCount),
    typeCounts: types.entries.toList()..sort(byCount),
  );
}
