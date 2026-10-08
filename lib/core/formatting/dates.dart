import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../time/calendar.dart';

/// Locale pro formátování dat. Data pro 'cs' se inicializují v main.dart.
const appLocale = 'cs';

String formatTime(DateTime date) => DateFormat.Hm(appLocale).format(date);

String formatDate(DateTime date) =>
    DateFormat('d. M. y', appLocale).format(date);

String formatDateTime(DateTime date) =>
    DateFormat('d. M. y HH:mm', appLocale).format(date);

/// „21:00“ z minut od půlnoci.
String formatMinuteOfDay(int minutes) =>
    '${minutes ~/ 60}:${(minutes % 60).toString().padLeft(2, '0')}';

/// Nadpis dne: „Dnes“, „Včera“, „Zítra“, jinak „pondělí 6. října 2026“.
String formatDayHeader(AppLocalizations l, DateTime date, DateTime now) {
  final diff = calendarDaysBetween(date, now);
  if (diff == 0) return l.dayHeaderToday;
  if (diff == 1) return l.dayHeaderYesterday;
  if (diff == -1) return l.dayHeaderTomorrow;
  final pattern = date.year == now.year ? 'EEEE d. MMMM' : 'EEEE d. MMMM y';
  return DateFormat(pattern, appLocale).format(date);
}

/// „dnes“, „včera“, „před 3 dny“.
String formatDaysAgo(AppLocalizations l, int days) {
  if (days <= 0) return l.relativeToday;
  if (days == 1) return l.relativeYesterday;
  return l.relativeDaysAgo(days);
}

String capitalize(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

/// Den v týdnu s předložkou, jak se říká („ve středu 12. 10.“). Intl umí
/// jen první pád (středa), proto vlastní tabulka.
String formatWeekdayIn(DateTime date) {
  const names = [
    'v pondělí',
    'v úterý',
    've středu',
    've čtvrtek',
    'v pátek',
    'v sobotu',
    'v neděli',
  ];
  final day = DateFormat('d. M.', appLocale).format(date);
  return '${names[date.weekday - 1]} $day';
}
