import 'package:flutter_test/flutter_test.dart';
import 'package:zahradnik_boda_mvp01/main.dart';

void main() {
  testWidgets('App builds and shows timeline title', (tester) async {
    // Postavíme root widget aplikace
    await tester.pumpWidget(const ZahradnikBodaApp());

    // Ověříme, že se někde na obrazovce objeví text titulku timeline
    expect(find.text('Zahradník Bóďa - Timeline'), findsOneWidget);
  });
}
