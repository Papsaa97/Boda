import 'package:flutter_test/flutter_test.dart';
import 'package:zahradnik_boda/features/settings/domain/app_settings.dart';
import 'package:zahradnik_boda/features/tasks/domain/reminder_planner.dart';
import 'package:zahradnik_boda/features/tasks/domain/task_entity.dart';

TaskEntity task(
  String id,
  DateTime due, {
  int? remindAt,
  DateTime? snoozedUntil,
  TaskStatus status = TaskStatus.open,
}) => TaskEntity(
  id: id,
  title: 'Úkol $id',
  due: due,
  remindAt: remindAt,
  snoozedUntil: snoozedUntil,
  status: status,
);

void main() {
  const planner = ReminderPlanner();
  // Úterý 7. 10. 2026 10:00.
  final now = DateTime(2026, 10, 7, 10);

  group('quiet hours (FR-U5)', () {
    const quiet = QuietHours(21 * 60, 8 * 60);

    test('reminder inside quiet hours moves to their end', () {
      expect(
        planner.shiftOutOfQuiet(DateTime(2026, 10, 7, 22, 30), quiet),
        DateTime(2026, 10, 8, 8),
      );
      expect(
        planner.shiftOutOfQuiet(DateTime(2026, 10, 8, 6), quiet),
        DateTime(2026, 10, 8, 8),
      );
    });

    test('reminder just before quiet hours comes a bit earlier', () {
      expect(
        planner.shiftOutOfQuiet(DateTime(2026, 10, 7, 20, 45), quiet),
        DateTime(2026, 10, 7, 20, 30),
      );
      expect(
        planner.shiftOutOfQuiet(DateTime(2026, 10, 7, 18), quiet),
        DateTime(2026, 10, 7, 18),
      );
    });

    test('no notification ever lands in quiet hours (exhaustive)', () {
      // Všechny kombinace tichých hodin po půlhodinách a připomínek
      // po čtvrthodinách během dvou dnů, včetně přechodu na zimní čas.
      for (var start = 0; start < 24 * 60; start += 30) {
        for (var end = 0; end < 24 * 60; end += 90) {
          final q = QuietHours(start, end);
          final tasks = [
            for (var m = 0; m < 2 * 24 * 60; m += 15)
              task(
                '$m',
                DateTime(2026, 10, 24 + m ~/ (24 * 60)),
                remindAt: m % (24 * 60),
              ),
          ];
          final plan = planner.plan(
            tasks: tasks,
            settings: AppSettings(quietStart: start, quietEnd: end),
            now: DateTime(2026, 10, 24),
          );
          for (final n in plan) {
            expect(
              q.contains(n.at),
              isFalse,
              reason: 'quiet $start–$end, ${n.kind} at ${n.at}',
            );
          }
        }
      }
    });
  });

  test('reminders in the past or beyond the horizon are skipped', () {
    final plan = planner.plan(
      tasks: [
        task('past', DateTime(2026, 10, 7), remindAt: 9 * 60),
        task('later', DateTime(2026, 10, 7), remindAt: 18 * 60),
        task('far', DateTime(2026, 11, 30), remindAt: 18 * 60),
        task(
          'done',
          DateTime(2026, 10, 8),
          remindAt: 18 * 60,
          status: TaskStatus.done,
        ),
      ],
      settings: const AppSettings(digest: DigestMode.off),
      now: now,
    );
    expect(plan.map((n) => n.tasks.single.id), ['later']);
  });

  test('snoozed task is reminded on the new day', () {
    final plan = planner.plan(
      tasks: [
        task(
          'a',
          DateTime(2026, 10, 7),
          remindAt: 18 * 60,
          snoozedUntil: DateTime(2026, 10, 9),
        ),
      ],
      settings: const AppSettings(digest: DigestMode.off),
      now: now,
    );
    expect(plan.single.at, DateTime(2026, 10, 9, 18));
  });

  group('digest (FR-U6)', () {
    test('daily digest at the end of quiet hours lists the day\'s tasks', () {
      final plan = planner.plan(
        tasks: [
          task('a', DateTime(2026, 10, 8)),
          task('b', DateTime(2026, 10, 8)),
          task('c', DateTime(2026, 10, 10)),
        ],
        settings: const AppSettings(digest: DigestMode.daily),
        now: now,
      );
      final first = plan.first;
      expect(first.kind, PlannedKind.digest);
      expect(first.at, DateTime(2026, 10, 8, 8));
      expect(first.tasks.map((t) => t.id), ['a', 'b']);
    });

    test('auto mode is weekly on Mondays in winter', () {
      final winterNow = DateTime(2026, 12, 2, 10); // středa
      final plan = planner.plan(
        tasks: [
          task('a', DateTime(2026, 12, 8)),
          task('b', DateTime(2026, 12, 11)),
        ],
        settings: const AppSettings(),
        now: winterNow,
      );
      final digests = plan.where((n) => n.kind == PlannedKind.digest);
      expect(digests.first.weekly, isTrue);
      expect(digests.first.at, DateTime(2026, 12, 7, 8));
      expect(digests.first.tasks.map((t) => t.id), ['a', 'b']);
    });

    test('off means no digest', () {
      final plan = planner.plan(
        tasks: [task('a', DateTime(2026, 10, 8))],
        settings: const AppSettings(digest: DigestMode.off),
        now: now,
      );
      expect(plan, isEmpty);
    });
  });
}
