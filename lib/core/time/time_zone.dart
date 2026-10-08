/// Posun časové zóny jako text pro sloupec `occurred_tz`, např. `+02:00`.
String formatUtcOffset(Duration offset) {
  final sign = offset.isNegative ? '-' : '+';
  final minutes = offset.inMinutes.abs();
  final h = (minutes ~/ 60).toString().padLeft(2, '0');
  final m = (minutes % 60).toString().padLeft(2, '0');
  return '$sign$h:$m';
}
