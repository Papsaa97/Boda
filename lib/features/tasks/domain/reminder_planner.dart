import '../../../core/time/calendar.dart';
import '../../settings/domain/app_settings.dart';
import 'task_entity.dart';

/// Tiché hodiny (FR-U5): interval v rámci dne, může přecházet přes půlnoc.
class QuietHours {
  const QuietHours(this.start, this.end);

  /// Minuty od půlnoci.
  final int start;
  final int end;

  bool get isEnabled => start != end;

  bool contains(DateTime t) {
    if (!isEnabled) return false;
    final m = t.hour * 60 + t.minute;
    return start < end ? (m >= start && m < end) : (m >= start || m < end);
  }

  /// Nejbližší konec tichých hodin v [t] nebo po něm.
  DateTime nextEnd(DateTime t) {
    var candidate = DateTime(t.year, t.month, t.day, end ~/ 60, end % 60);
    if (candidate.isBefore(t)) {
      candidate = DateTime(t.year, t.month, t.day + 1, end ~/ 60, end % 60);
    }
    return candidate;
  }

  /// Začátek tichých hodin v den [t].
  DateTime startOn(DateTime t) =>
      DateTime(t.year, t.month, t.day, start ~/ 60, start % 60);
}

enum PlannedKind { task, digest }

/// Naplánovaná notifikace (bez textů; ty doplní prezentační vrstva
/// v jazyce aplikace).
class PlannedNotification {
  const PlannedNotification({
    required this.at,
    required this.kind,
    required this.tasks,
    this.weekly = false,
  });

  final DateTime at;
  final PlannedKind kind;

  /// U připomínky jeden úkol, u přehledu všechny úkoly v něm.
  final List<TaskEntity> tasks;

  /// Týdenní přehled (jinak denní).
  final bool weekly;

  @override
  String toString() => 'PlannedNotification($kind, $at, ${tasks.length})';
}

/// Plánovač lokálních notifikací: připomínky úkolů a ranní přehled.
///
/// Zaručuje, že žádná notifikace nepadne do tichých hodin: připomínka
/// v tichých hodinách se posune na jejich konec. Android navíc může
/// nepřesný alarm o několik minut zdržet, proto se připomínka v posledních
/// [quietGuard] před začátkem tichých hodin přesune na začátek této
/// ochranné doby (raději o chvíli dřív než přes noc).
class ReminderPlanner {
  const ReminderPlanner({
    this.horizonDays = 14,
    this.quietGuard = const Duration(minutes: 30),
  });

  /// Na kolik dní dopředu se plánuje. Plán se přepočítá při každé změně
  /// úkolů, nastavení a při spuštění aplikace.
  final int horizonDays;
  final Duration quietGuard;

  /// Měsíce, kdy je výchozí přehled týdenní (listopad–únor, FR-U6).
  static const winterMonths = {11, 12, 1, 2};

  List<PlannedNotification> plan({
    required List<TaskEntity> tasks,
    required AppSettings settings,
    required DateTime now,
  }) {
    final quiet = QuietHours(settings.quietStart, settings.quietEnd);
    final today = dayOnly(now);
    final horizonEnd = DateTime(
      today.year,
      today.month,
      today.day + horizonDays,
    );
    final open = tasks.where((t) => t.isOpen).toList();
    final result = <PlannedNotification>[];

    for (final task in open) {
      final at = task.reminderTime;
      if (at == null) continue;
      final shifted = shiftOutOfQuiet(at, quiet);
      if (shifted.isBefore(now) || !shifted.isBefore(horizonEnd)) continue;
      result.add(
        PlannedNotification(at: shifted, kind: PlannedKind.task, tasks: [task]),
      );
    }

    for (var i = 0; i < horizonDays; i++) {
      final day = DateTime(today.year, today.month, today.day + i);
      final weekly = switch (settings.digest) {
        DigestMode.off => null,
        DigestMode.daily => false,
        DigestMode.weekly => true,
        DigestMode.auto => winterMonths.contains(day.month),
      };
      if (weekly == null) continue;
      if (weekly && day.weekday != DateTime.monday) continue;

      final windowEnd = DateTime(
        day.year,
        day.month,
        day.day + (weekly ? 7 : 1),
      );
      final due =
          open.where((t) => t.effectiveDate.isBefore(windowEnd)).toList()
            ..sort((a, b) => a.effectiveDate.compareTo(b.effectiveDate));
      if (due.isEmpty) continue;

      final at = digestTime(day, quiet);
      if (at.isBefore(now)) continue;
      result.add(
        PlannedNotification(
          at: at,
          kind: PlannedKind.digest,
          tasks: due,
          weekly: weekly,
        ),
      );
    }

    result.sort((a, b) => a.at.compareTo(b.at));
    return result;
  }

  /// Ranní přehled: hned po konci tichých hodin, bez nich v 8:00.
  DateTime digestTime(DateTime day, QuietHours quiet) {
    final minutes = quiet.isEnabled ? quiet.end : 8 * 60;
    return DateTime(day.year, day.month, day.day, minutes ~/ 60, minutes % 60);
  }

  DateTime shiftOutOfQuiet(DateTime at, QuietHours quiet) {
    if (!quiet.isEnabled) return at;
    if (quiet.contains(at)) return quiet.nextEnd(at);
    final start = quiet.startOn(at);
    final guardStart = start.subtract(quietGuard);
    if (!at.isBefore(guardStart) && at.isBefore(start)) {
      // Ochranná doba nesmí sama zasahovat do tichých hodin (krátký den).
      return quiet.contains(guardStart) ? quiet.nextEnd(at) : guardStart;
    }
    return at;
  }
}
