import '../../activity/domain/activity_entity.dart';
import '../../activity/domain/activity_type.dart';

/// Přehled sezóny (FR-D11): zimní důvod aplikaci otevřít.
class SeasonSummary {
  const SeasonSummary({
    required this.year,
    required this.activityCount,
    required this.activeDays,
    required this.harvest,
    required this.costCzk,
    required this.topZones,
    required this.typeCounts,
    required this.photos,
  });

  final int year;
  final int activityCount;

  /// Dny, kdy přibyl aspoň jeden záznam.
  final int activeDays;

  /// Sklizeň sečtená po jednotkách (`kg` zahrnuje i gramy).
  final Map<String, double> harvest;
  final double costCzk;

  /// Id zóny → počet záznamů, nejvýš tři nejaktivnější.
  final List<MapEntry<String, int>> topZones;
  final List<MapEntry<ActivityType, int>> typeCounts;

  /// Fotky sezóny: z každého měsíce ta poslední, nejnovější první.
  final List<PhotoRef> photos;

  bool get isEmpty => activityCount == 0;
}

/// Sezóna, kterou má smysl ukázat: v lednu a únoru ještě ta loňská.
int seasonYearFor(DateTime now) => now.month <= 2 ? now.year - 1 : now.year;

/// Je zima (listopad–únor), kdy se přehled nabízí na dashboardu?
bool isWinter(DateTime now) => now.month >= 11 || now.month <= 2;

SeasonSummary buildSeasonSummary(List<ActivityEntity> all, int year) {
  final activities = [
    for (final a in all)
      if (a.date.year == year) a,
  ]..sort((a, b) => b.date.compareTo(a.date));

  final days = <DateTime>{};
  final harvest = <String, double>{};
  final zones = <String, int>{};
  final types = <ActivityType, int>{};
  final photoByMonth = <int, PhotoRef>{};
  var cost = 0.0;

  for (final a in activities) {
    days.add(DateTime(a.date.year, a.date.month, a.date.day));
    zones[a.zoneId] = (zones[a.zoneId] ?? 0) + 1;
    types[a.type] = (types[a.type] ?? 0) + 1;
    cost += a.costCzk ?? 0;
    final qty = a.harvestQty;
    if (qty != null) {
      final (unit, value) = a.harvestUnit == 'g'
          ? ('kg', qty / 1000)
          : (a.harvestUnit ?? 'kg', qty);
      harvest[unit] = (harvest[unit] ?? 0) + value;
    }
    final cover = a.coverPhoto;
    // Seznam je od nejnovějšího, takže první fotka měsíce je ta poslední.
    if (cover != null) photoByMonth.putIfAbsent(a.date.month, () => cover);
  }

  int byCount<K>(MapEntry<K, int> a, MapEntry<K, int> b) =>
      b.value.compareTo(a.value);
  final months = photoByMonth.keys.toList()..sort((a, b) => b.compareTo(a));

  return SeasonSummary(
    year: year,
    activityCount: activities.length,
    activeDays: days.length,
    harvest: harvest,
    costCzk: cost,
    topZones: (zones.entries.toList()..sort(byCount)).take(3).toList(),
    typeCounts: types.entries.toList()..sort(byCount),
    photos: [for (final m in months) photoByMonth[m]!],
  );
}
