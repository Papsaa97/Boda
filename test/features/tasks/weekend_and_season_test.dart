import 'package:flutter_test/flutter_test.dart';
import 'package:zahradnik_boda/features/activity/domain/activity_entity.dart';
import 'package:zahradnik_boda/features/activity/domain/activity_type.dart';
import 'package:zahradnik_boda/features/stats/domain/season_summary.dart';
import 'package:zahradnik_boda/features/tasks/domain/task_entity.dart';
import 'package:zahradnik_boda/features/tasks/domain/weekend_planner.dart';

void main() {
  group('weekend at the cottage (FR-U8)', () {
    final today = DateTime(2026, 10, 10, 8); // sobota
    TaskEntity task(
      String id,
      DateTime due, {
      int? minutes,
      List<String> tools = const [],
      TaskStatus status = TaskStatus.open,
    }) => TaskEntity(
      id: id,
      title: id,
      due: due,
      durationEstMin: minutes,
      tools: tools,
      status: status,
    );

    test('overdue first, then by date, skipping what does not fit', () {
      final plan = planWeekend(
        [
          task('later', DateTime(2026, 10, 14), minutes: 60),
          task('overdue', DateTime(2026, 10, 1), minutes: 90),
          task('today-long', DateTime(2026, 10, 10), minutes: 120),
          task('today-short', DateTime(2026, 10, 10), minutes: 15),
          task('next-month', DateTime(2026, 11, 20), minutes: 10),
          task(
            'done',
            DateTime(2026, 10, 9),
            minutes: 10,
            status: TaskStatus.done,
          ),
        ],
        today: today,
        availableMinutes: 3 * 60,
      );
      expect(
        [for (final p in plan.planned) p.task.id],
        ['overdue', 'today-short', 'later'],
      );
      expect([for (final p in plan.leftOver) p.task.id], ['today-long']);
      expect(plan.plannedMinutes, 165);
    });

    test('tasks without an estimate count as 30 min and are marked', () {
      final plan = planWeekend(
        [task('a', DateTime(2026, 10, 10))],
        today: today,
        availableMinutes: 60,
      );
      expect(plan.planned.single.minutes, defaultTaskMinutes);
      expect(plan.planned.single.estimated, isTrue);
    });

    test('tools are listed once', () {
      final plan = planWeekend(
        [
          task('a', DateTime(2026, 10, 10), tools: ['Rýč', 'Hrábě']),
          task('b', DateTime(2026, 10, 11), tools: ['rýč ', 'Konev']),
        ],
        today: today,
        availableMinutes: 120,
      );
      expect(plan.tools, ['Rýč', 'Hrábě', 'Konev']);
    });
  });

  group('season overview (FR-D11)', () {
    ActivityEntity a(
      String id,
      DateTime date, {
      double? harvest,
      String? unit,
      double? cost,
      String photo = '',
      String zone = 'Z1',
    }) => ActivityEntity(
      id: id,
      title: id,
      date: date,
      zoneId: zone,
      type: harvest == null ? ActivityType.watering : ActivityType.harvest,
      harvestQty: harvest,
      harvestUnit: unit,
      costCzk: cost,
      photos: [if (photo.isNotEmpty) PhotoRef(id: photo, path: '$photo.jpg')],
    );

    test('counts, harvest in kg, cost and one photo per month', () {
      final s = buildSeasonSummary([
        a('1', DateTime(2027, 7, 1, 8), harvest: 2, unit: 'kg', photo: 'p1'),
        a('2', DateTime(2027, 7, 1, 18), harvest: 500, unit: 'g', cost: 40),
        a('3', DateTime(2027, 7, 20), photo: 'p3', zone: 'Z2'),
        a('4', DateTime(2027, 8, 2), harvest: 12, unit: 'ks', photo: 'p4'),
        a('old', DateTime(2026, 7, 1), harvest: 99, unit: 'kg'),
      ], 2027);
      expect(s.activityCount, 4);
      expect(s.activeDays, 3);
      expect(s.harvest, {'kg': 2.5, 'ks': 12});
      expect(s.costCzk, 40);
      expect(s.topZones.first.key, 'Z1');
      expect([for (final p in s.photos) p.id], ['p4', 'p3']);
    });

    test('winter shows last season until February', () {
      expect(seasonYearFor(DateTime(2028, 1, 15)), 2027);
      expect(seasonYearFor(DateTime(2027, 11, 15)), 2027);
      expect(isWinter(DateTime(2027, 12, 1)), isTrue);
      expect(isWinter(DateTime(2027, 5, 1)), isFalse);
    });
  });
}
