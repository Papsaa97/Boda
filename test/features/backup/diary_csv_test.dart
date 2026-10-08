import 'package:flutter_test/flutter_test.dart';
import 'package:zahradnik_boda/features/activity/domain/activity_entity.dart';
import 'package:zahradnik_boda/features/activity/domain/activity_type.dart';
import 'package:zahradnik_boda/features/backup/domain/diary_csv.dart';

void main() {
  test('diary CSV uses semicolons, decimal commas and quotes tricky cells', () {
    final csv = diaryCsv(
      [
        ActivityEntity(
          id: 'b',
          type: ActivityType.harvest,
          title: 'Sklizeň rajčat',
          date: DateTime(2026, 10, 8, 7, 5),
          zoneId: 'Z1',
          notes: 'Odrůda "Tigerella"; zralé',
          harvestQty: 2.5,
          harvestUnit: 'kg',
          costCzk: 120,
        ),
        ActivityEntity(
          id: 'a',
          type: ActivityType.watering,
          title: 'Zálivka',
          date: DateTime(2026, 10, 7, 18, 30),
          zoneId: 'Z2',
        ),
      ],
      zoneName: (id) => id == 'Z1' ? 'Skleník' : 'Záhon',
      typeLabel: (t) => t.name,
    );
    final lines = csv.split('\r\n');
    expect(lines.first, '\u{FEFF}${diaryCsvHeaders.join(';')}');
    // Nejstarší záznam je první.
    expect(lines[1], '7. 10. 2026;18:30;Záhon;watering;Zálivka;;;;;0');
    expect(
      lines[2],
      '8. 10. 2026;7:05;Skleník;harvest;Sklizeň rajčat;'
      '"Odrůda ""Tigerella""; zralé";2,5;kg;120;0',
    );
    expect(lines.last, '');
  });
}
