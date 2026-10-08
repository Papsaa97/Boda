/// Datum bez času (půlnoc v místním čase).
DateTime dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Počet kalendářních dní mezi dvěma daty (bez ohledu na čas a letní čas).
int calendarDaysBetween(DateTime from, DateTime to) {
  final a = DateTime.utc(from.year, from.month, from.day);
  final b = DateTime.utc(to.year, to.month, to.day);
  return b.difference(a).inDays;
}

/// Pondělí týdne, do kterého patří [d] (bez času).
DateTime startOfWeek(DateTime d) =>
    DateTime(d.year, d.month, d.day - (d.weekday - DateTime.monday));

/// Den jako text `YYYY-MM-DD` (sloupce typu `date`, export).
String formatDateKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

/// Opak [formatDateKey]; vrací místní půlnoc. Neplatný text = null.
DateTime? parseDateKey(String? s) {
  if (s == null) return null;
  final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(s);
  if (m == null) return null;
  final d = DateTime(
    int.parse(m.group(1)!),
    int.parse(m.group(2)!),
    int.parse(m.group(3)!),
  );
  return formatDateKey(d) == s ? d : null;
}
