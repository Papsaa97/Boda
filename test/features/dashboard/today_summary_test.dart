import 'package:flutter_test/flutter_test.dart';
import 'package:zahradnik_boda_mvp01/features/dashboard/domain/boda_tips.dart';
import 'package:zahradnik_boda_mvp01/features/dashboard/domain/today_summary.dart';
import 'package:zahradnik_boda_mvp01/features/zones/domain/zone_entity.dart';

import '../../helpers/fakes.dart';

void main() {
  const zones = [
    ZoneEntity(id: 'Z1', name: 'Zelenina'),
    ZoneEntity(id: 'Z2', name: 'Okrasná zahrada'),
    ZoneEntity(id: 'Z3', name: 'Ovocný sad'),
  ];

  test('empty diary: nothing today, every zone needs attention', () {
    final summary = buildTodaySummary(activities: [], zones: zones, now: testNow);

    expect(summary.today, isEmpty);
    expect(summary.lastActivity, isNull);
    expect(summary.lastWeekCount, 0);
    expect(summary.needsAttention.map((s) => s.zone.id), ['Z2', 'Z3', 'Z1']);
  });

  test('picks today activities newest first and counts the last 7 days', () {
    final summary = buildTodaySummary(
      activities: [
        activity('a', date: DateTime(2026, 10, 7, 8)),
        activity('b', date: DateTime(2026, 10, 7, 9)),
        activity('c', date: DateTime(2026, 10, 1, 9)), // 6 dní zpět
        activity('d', date: DateTime(2026, 9, 30, 9)), // 7 dní zpět
      ],
      zones: zones,
      now: testNow,
    );

    expect(summary.today.map((a) => a.id), ['b', 'a']);
    expect(summary.lastActivity!.id, 'b');
    expect(summary.lastWeekCount, 3);
  });

  test('zones untouched for 7+ days come first, most neglected on top', () {
    final summary = buildTodaySummary(
      activities: [
        activity('a', date: DateTime(2026, 10, 6, 20), zoneId: 'Z1'), // včera
        activity('b', date: DateTime(2026, 9, 30, 7), zoneId: 'Z2'), // 7 dní
        activity('c', date: DateTime(2026, 9, 1, 7), zoneId: 'Z3'), // 36 dní
      ],
      zones: zones,
      now: testNow,
    );

    expect(summary.needsAttention.map((s) => s.zone.id), ['Z3', 'Z2']);
    expect(summary.needsAttention.first.daysSince, 36);
  });

  test('calendarDaysBetween counts calendar days, not 24h blocks', () {
    expect(calendarDaysBetween(DateTime(2026, 10, 6, 23, 59), DateTime(2026, 10, 7, 0, 1)), 1);
    expect(calendarDaysBetween(DateTime(2026, 10, 7, 1), DateTime(2026, 10, 7, 23)), 0);
    // Přes změnu času (25. 10. 2026).
    expect(calendarDaysBetween(DateTime(2026, 10, 24, 12), DateTime(2026, 10, 26, 12)), 2);
  });

  test('Bóďa has a tip for every day of the year', () {
    for (var d = DateTime(2026, 1, 1); d.year == 2026; d = d.add(const Duration(days: 1))) {
      expect(BodaTips.forDate(d), isNotEmpty);
    }
  });
}
