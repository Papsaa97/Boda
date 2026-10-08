import '../../activity/domain/activity_entity.dart';
import '../../activity/domain/activity_type.dart';

/// Hlavičky sloupců CSV exportu deníku (FR-E4), v pořadí sloupců.
const diaryCsvHeaders = [
  'Datum',
  'Čas',
  'Zóna',
  'Typ práce',
  'Název',
  'Poznámka',
  'Sklizeň',
  'Jednotka sklizně',
  'Náklady Kč',
  'Počet fotek',
];

/// Deník jako CSV pro tabulkové programy (FR-E4): středník jako oddělovač
/// a desetinná čárka, jak to čeká český Excel i Google Tabulky, řádky
/// ukončené CRLF, na začátku BOM, aby Excel poznal UTF-8. Nejstarší
/// záznam první.
String diaryCsv(
  List<ActivityEntity> activities, {
  required String Function(String zoneId) zoneName,
  required String Function(ActivityType type) typeLabel,
}) {
  final sorted = [...activities]..sort((a, b) => a.date.compareTo(b.date));
  final buffer = StringBuffer('\u{FEFF}');
  buffer.write(_row(diaryCsvHeaders));
  for (final a in sorted) {
    final d = a.date;
    buffer.write(
      _row([
        '${d.day}. ${d.month}. ${d.year}',
        '${d.hour}:${d.minute.toString().padLeft(2, '0')}',
        zoneName(a.zoneId),
        typeLabel(a.type),
        a.title,
        a.notes ?? '',
        _number(a.harvestQty),
        a.harvestUnit ?? '',
        _number(a.costCzk),
        '${a.photos.length}',
      ]),
    );
  }
  return buffer.toString();
}

String _number(double? value) {
  if (value == null) return '';
  final text = value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toString();
  return text.replaceAll('.', ',');
}

String _row(List<String> cells) => '${cells.map(_cell).join(';')}\r\n';

/// Buňka v uvozovkách, když obsahuje oddělovač, uvozovku nebo nový řádek;
/// uvozovka uvnitř se zdvojí (RFC 4180).
String _cell(String value) {
  if (!value.contains(RegExp(r'[;"\r\n]'))) return value;
  return '"${value.replaceAll('"', '""')}"';
}
