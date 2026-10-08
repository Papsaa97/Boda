import 'package:flutter_test/flutter_test.dart';
import 'package:zahradnik_boda/features/activity/domain/activity_filter.dart';
import 'package:zahradnik_boda/features/activity/domain/activity_type.dart';
import 'package:zahradnik_boda/features/backup/presentation/backup_actions.dart';
import 'package:zahradnik_boda/features/stats/domain/diary_stats.dart';

import '../../helpers/fakes.dart';

void main() {
  final diary = [
    activity(
      'a',
      date: DateTime(2026, 10, 6, 8),
      title: 'Zálivka rajčat',
      type: ActivityType.watering,
    ),
    activity(
      'b',
      date: DateTime(2026, 10, 7, 8),
      zoneId: 'Z3',
      title: 'Řez',
      notes: 'Jabloň u plotu',
      type: ActivityType.pruning,
    ),
    activity(
      'c',
      date: DateTime(2026, 9, 29, 8),
      title: 'Zalití skleníku',
      type: ActivityType.watering,
    ),
  ];

  group('filter (FR-D7)', () {
    test('by type and zone', () {
      expect(
        const ActivityFilter(
          type: ActivityType.watering,
        ).apply(diary).map((a) => a.id),
        ['a', 'c'],
      );
      expect(const ActivityFilter(zoneId: 'Z3').apply(diary).map((a) => a.id), [
        'b',
      ]);
    });

    test('fulltext ignores case and diacritics, searches notes', () {
      expect(
        const ActivityFilter(query: 'ZALIVKA').apply(diary).map((a) => a.id),
        ['a'],
      );
      expect(
        const ActivityFilter(query: 'jablon').apply(diary).map((a) => a.id),
        ['b'],
      );
      expect(const ActivityFilter(query: '  ').isActive, isFalse);
    });
  });

  test('stats count entries per week and the busiest zones', () {
    final stats = buildDiaryStats(activities: diary, now: testNow);
    expect(stats.total, 3);
    expect(stats.weeks, hasLength(8));
    expect(stats.weeks.last.weekStart, DateTime(2026, 10, 5));
    expect(stats.thisWeek, 2);
    expect(stats.weeks[6].count, 1);
    expect(stats.activeWeeks, 1);
    expect(stats.zoneCounts.first.key, 'Z1');
    expect(stats.zoneCounts.first.value, 2);
    expect(stats.typeCounts.first.key, ActivityType.watering);
  });

  test('backup reminder once a month when there is something to back up', () {
    expect(
      backupReminderDue(lastExportAt: null, activityCount: 0, now: testNow),
      isFalse,
    );
    expect(
      backupReminderDue(lastExportAt: null, activityCount: 1, now: testNow),
      isTrue,
    );
    expect(
      backupReminderDue(
        lastExportAt: testNow.subtract(const Duration(days: 29)),
        activityCount: 5,
        now: testNow,
      ),
      isFalse,
    );
    expect(
      backupReminderDue(
        lastExportAt: testNow.subtract(const Duration(days: 30)),
        activityCount: 5,
        now: testNow,
      ),
      isTrue,
    );
  });
}
