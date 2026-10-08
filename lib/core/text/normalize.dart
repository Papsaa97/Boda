const _from = 'áäčďéěëíňóöřšťúůüýžÁÄČĎÉĚËÍŇÓÖŘŠŤÚŮÜÝŽ';
const _to = 'aacdeeeinoorstuuuyzAACDEEEINOORSTUUUYZ';

/// Malá písmena bez diakritiky, aby „zalivka“ našla „Zálivka“.
String normalizeForSearch(String text) {
  final buffer = StringBuffer();
  for (final rune in text.runes) {
    final char = String.fromCharCode(rune);
    final i = _from.indexOf(char);
    buffer.write(i >= 0 ? _to[i] : char);
  }
  return buffer.toString().toLowerCase();
}
