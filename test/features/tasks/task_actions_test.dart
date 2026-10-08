import 'package:flutter_test/flutter_test.dart';
import 'package:zahradnik_boda/features/tasks/domain/recurrence.dart';
import 'package:zahradnik_boda/features/tasks/domain/task_actions.dart';
import 'package:zahradnik_boda/features/tasks/domain/task_entity.dart';

void main() {
  group('recurrence (FR-U2)', () {
    test('round-trips through RRULE', () {
      const r = Recurrence(RepeatFrequency.weekly, months: {4, 5, 6});
      expect(r.toRrule(), 'FREQ=WEEKLY;BYMONTH=4,5,6');
      expect(Recurrence.parse(r.toRrule()), r);
      expect(Recurrence.parse('FREQ=DAILY'), isNull);
      expect(Recurrence.parse(null), isNull);
    });

    test('monthly on the 31st falls back to the last day', () {
      final r = Recurrence.forDue(
        RepeatFrequency.monthly,
        DateTime(2027, 1, 31),
      );
      expect(r.nextAfter(DateTime(2027, 1, 31)), DateTime(2027, 2, 28));
      expect(r.nextAfter(DateTime(2027, 2, 28)), DateTime(2027, 3, 31));
    });

    test('weekly only in some months skips the rest of the year', () {
      const r = Recurrence(RepeatFrequency.weekly, months: {4, 5});
      expect(r.nextAfter(DateTime(2027, 5, 28)), DateTime(2028, 4, 7));
    });
  });

  group('snooze (FR-U3)', () {
    // Úterý 7. 10. 2026.
    final tuesday = DateTime(2026, 10, 7, 15);

    test('one day, one week and to the weekend', () {
      expect(snoozeTarget(SnoozeOption.oneDay, tuesday), DateTime(2026, 10, 8));
      expect(
        snoozeTarget(SnoozeOption.oneWeek, tuesday),
        DateTime(2026, 10, 14),
      );
      expect(
        snoozeTarget(SnoozeOption.weekend, tuesday),
        DateTime(2026, 10, 10),
      );
      // V sobotu „na víkend“ znamená příští sobotu.
      expect(
        snoozeTarget(SnoozeOption.weekend, DateTime(2026, 10, 10)),
        DateTime(2026, 10, 17),
      );
    });
  });

  group('closing a task', () {
    final now = DateTime(2026, 10, 7, 15);

    test('one-off task just closes', () {
      final c = closeTask(
        TaskEntity(id: 't', title: 'Zalít', due: DateTime(2026, 10, 7)),
        status: TaskStatus.done,
        now: now,
        nextId: 'n',
      );
      expect(c.closed.status, TaskStatus.done);
      expect(c.closed.completedAt, now);
      expect(c.next, isNull);
    });

    test('overdue recurring task gets one next date after today', () {
      final c = closeTask(
        TaskEntity(
          id: 't',
          title: 'Posekat',
          due: DateTime(2026, 9, 16),
          rrule: 'FREQ=WEEKLY',
          remindAt: 17 * 60,
        ),
        status: TaskStatus.skipped,
        now: now,
        nextId: 'n',
      );
      expect(c.closed.status, TaskStatus.skipped);
      expect(c.next!.id, 'n');
      expect(c.next!.due, DateTime(2026, 10, 14));
      expect(c.next!.remindAt, 17 * 60);
      expect(c.next!.isOpen, isTrue);
    });
  });
}
