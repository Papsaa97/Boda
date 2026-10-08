import 'package:intl/intl.dart';

import '../formatting/dates.dart';

/// Desetinné číslo zadané uživatelem: „12,5“ i „12.5“, mezery jako
/// oddělovač tisíců. Prázdný nebo neplatný text = null.
double? parseDecimal(String? text) {
  if (text == null) return null;
  final cleaned = text
      .trim()
      .replaceAll(RegExp(r'[\s  ]'), '')
      .replaceAll(',', '.');
  if (cleaned.isEmpty) return null;
  if (!RegExp(r'^-?\d+(\.\d+)?$').hasMatch(cleaned) &&
      !RegExp(r'^-?\.\d+$').hasMatch(cleaned)) {
    return null;
  }
  final value = double.tryParse(cleaned);
  return value == null || !value.isFinite ? null : value;
}

/// Číslo v českém zápisu („1 234,5“), nejvýš [maxFractionDigits]
/// desetinných míst, bez zbytečných nul.
String formatDecimal(num value, {int maxFractionDigits = 2}) {
  final format = NumberFormat.decimalPattern(appLocale)
    ..minimumFractionDigits = 0
    ..maximumFractionDigits = maxFractionDigits;
  return format.format(value);
}
