import 'package:equatable/equatable.dart';

/// Jak často se úkol opakuje.
enum RepeatFrequency { weekly, monthly, yearly }

/// Jednoduché opakování pro MVP 0.2 (FR-U2): každý týden, měsíc nebo rok,
/// volitelně jen v některých měsících. Ukládá se jako podmnožina iCalendar
/// RRULE (RFC 5545), aby šlo později rozšířit bez migrace:
///
/// * `FREQ=WEEKLY`, `FREQ=WEEKLY;BYMONTH=4,5,6`
/// * `FREQ=MONTHLY;BYMONTHDAY=31` (den v měsíci; v kratším měsíci poslední den)
/// * `FREQ=YEARLY`
class Recurrence extends Equatable {
  const Recurrence(this.frequency, {this.months = const {}, this.monthDay});

  final RepeatFrequency frequency;

  /// Měsíce 1–12, ve kterých se opakuje; prázdné = celý rok.
  final Set<int> months;

  /// Den v měsíci pro měsíční opakování.
  final int? monthDay;

  /// Opakování podle prvního termínu [due].
  factory Recurrence.forDue(
    RepeatFrequency frequency,
    DateTime due, {
    Set<int> months = const {},
  }) {
    return Recurrence(
      frequency,
      months: frequency == RepeatFrequency.yearly ? const {} : months,
      monthDay: frequency == RepeatFrequency.monthly ? due.day : null,
    );
  }

  static Recurrence? parse(String? rrule) {
    if (rrule == null || rrule.isEmpty) return null;
    final parts = <String, String>{};
    for (final part in rrule.split(';')) {
      final i = part.indexOf('=');
      if (i > 0) {
        parts[part.substring(0, i).toUpperCase()] = part.substring(i + 1);
      }
    }
    final frequency = switch (parts['FREQ']?.toUpperCase()) {
      'WEEKLY' => RepeatFrequency.weekly,
      'MONTHLY' => RepeatFrequency.monthly,
      'YEARLY' => RepeatFrequency.yearly,
      _ => null,
    };
    if (frequency == null) return null;
    final months = <int>{
      for (final m in (parts['BYMONTH'] ?? '').split(','))
        if (int.tryParse(m) case final v? when v >= 1 && v <= 12) v,
    };
    return Recurrence(
      frequency,
      months: months,
      monthDay: int.tryParse(parts['BYMONTHDAY'] ?? ''),
    );
  }

  String toRrule() {
    final buffer = StringBuffer('FREQ=${frequency.name.toUpperCase()}');
    if (months.isNotEmpty) {
      buffer.write(';BYMONTH=${(months.toList()..sort()).join(',')}');
    }
    if (monthDay != null) buffer.write(';BYMONTHDAY=$monthDay');
    return buffer.toString();
  }

  /// Nejbližší termín po [from] (den bez času).
  DateTime nextAfter(DateTime from) {
    var d = DateTime(from.year, from.month, from.day);
    // Omezení na měsíce: posouvat, dokud termín nepadne do povoleného
    // měsíce. Týdně stačí 53 kroků, měsíčně 12.
    for (var i = 0; i < 60; i++) {
      d = _step(d);
      if (months.isEmpty || months.contains(d.month)) return d;
    }
    return d;
  }

  DateTime _step(DateTime d) {
    switch (frequency) {
      case RepeatFrequency.weekly:
        return DateTime(d.year, d.month, d.day + 7);
      case RepeatFrequency.monthly:
        final day = monthDay ?? d.day;
        final y = d.month == 12 ? d.year + 1 : d.year;
        final m = d.month == 12 ? 1 : d.month + 1;
        return DateTime(y, m, _clampDay(y, m, day));
      case RepeatFrequency.yearly:
        final y = d.year + 1;
        return DateTime(y, d.month, _clampDay(y, d.month, d.day));
    }
  }

  static int _clampDay(int year, int month, int day) {
    final last = DateTime(year, month + 1, 0).day;
    return day > last ? last : day;
  }

  @override
  List<Object?> get props => [frequency, months, monthDay];
}
