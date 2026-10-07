import 'package:intl/intl.dart';

import '../../features/dashboard/domain/today_summary.dart';

/// Locale pro formátování dat. Data pro 'cs' se inicializují v main.dart.
const appLocale = 'cs';

String formatTime(DateTime date) => DateFormat.Hm(appLocale).format(date);

String formatDateTime(DateTime date) =>
    DateFormat('d. M. y HH:mm', appLocale).format(date);

/// Nadpis dne v časové ose: „Dnes“, „Včera“, jinak „pondělí 6. října 2026“.
String formatDayHeader(DateTime date, DateTime now) {
  final diff = calendarDaysBetween(date, now);
  if (diff == 0) return 'Dnes';
  if (diff == 1) return 'Včera';
  final pattern = date.year == now.year ? 'EEEE d. MMMM' : 'EEEE d. MMMM y';
  return DateFormat(pattern, appLocale).format(date);
}

/// „dnes“, „včera“, „před 3 dny“.
String formatDaysAgo(int days) {
  if (days <= 0) return 'dnes';
  if (days == 1) return 'včera';
  return 'před $days dny';
}
