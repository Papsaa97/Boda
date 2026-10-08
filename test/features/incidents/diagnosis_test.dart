import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:zahradnik_boda/core/photos/photo_storage.dart';
import 'package:zahradnik_boda/features/account/domain/consents.dart';
import 'package:zahradnik_boda/features/activity/domain/activity_entity.dart';
import 'package:zahradnik_boda/features/incidents/data/supabase_diagnosis_backend.dart';
import 'package:zahradnik_boda/features/incidents/domain/diagnosis.dart';
import 'package:zahradnik_boda/features/incidents/domain/incident.dart';
import 'package:zahradnik_boda/features/incidents/presentation/incidents_screen.dart';
import 'package:zahradnik_boda/features/settings/domain/app_settings.dart';
import 'package:zahradnik_boda/l10n/app_localizations.dart';

import '../../helpers/fakes.dart';

class FakeDiagnosisBackend implements DiagnosisBackend {
  FakeDiagnosisBackend(this.result);

  final DiagnosisResult result;
  final sent = <Uint8List>[];
  String? zoneType;
  String? note;

  @override
  bool get available => true;

  @override
  Future<DiagnosisResult> diagnose(
    Uint8List jpeg, {
    String? zoneType,
    String? note,
  }) async {
    sent.add(jpeg);
    this.zoneType = zoneType;
    this.note = note;
    return result;
  }
}

/// JPEG s EXIF segmentem (APP1) před obrazovými daty.
final photoWithExif = Uint8List.fromList([
  0xff, 0xd8, //
  0xff, 0xe1, 0x00, 0x08, 0x45, 0x78, 0x69, 0x66, 0x00, 0x00,
  0xff, 0xda, 0x00, 0x02, 0x11, 0xff, 0xd9,
]);

bool hasApp1(Uint8List bytes) {
  for (var i = 0; i + 1 < bytes.length; i++) {
    if (bytes[i] == 0xff && bytes[i + 1] == 0xe1) return true;
  }
  return false;
}

void main() {
  test('result JSON keeps at most three candidates', () {
    final r = DiagnosisResult.fromJson({
      'candidates': [
        {'label': 'A', 'care': 'c'},
        {'label': ''},
        {'label': 'B'},
        {'label': 'C'},
        {'label': 'D'},
      ],
    })!;
    expect(r.candidates.map((c) => c.label), ['A', 'B']);
    expect(r.candidates.first.care, 'c');
    expect(DiagnosisResult.fromJson({'candidates': []})!.unclear, isTrue);
    expect(DiagnosisResult.fromJson('x'), isNull);
  });

  test('server errors map to failures', () {
    expect(diagnosisFailureFor(402), DiagnosisFailure.notPremium);
    expect(diagnosisFailureFor(403), DiagnosisFailure.noConsent);
    expect(diagnosisFailureFor(429), DiagnosisFailure.limitReached);
    expect(diagnosisFailureFor(400), DiagnosisFailure.badImage);
    expect(diagnosisFailureFor(503), DiagnosisFailure.failed);
  });

  test('photo consent goes to the profile as photoUpload', () {
    final json = consentsJson(
      AppSettings(photoConsentAt: DateTime.utc(2026, 10, 8)),
      changedAt: DateTime.utc(2026, 10, 9),
    );
    expect(json['photoUpload'], {
      'granted': true,
      'at': '2026-10-08T00:00:00.000Z',
    });
  });

  testWidgets('diagnosis asks for consent, strips EXIF and fills the form', (
    tester,
  ) async {
    final root = Directory.systemTemp.createTempSync('boda_diag').path;
    final file = File(p.join(root, PhotoStorage.folder, 'p1.jpg'))
      ..createSync(recursive: true)
      ..writeAsBytesSync(photoWithExif);
    addTearDown(() => Directory(root).deleteSync(recursive: true));
    final backend = FakeDiagnosisBackend(
      const DiagnosisResult([
        IncidentCandidate(
          label: 'Plíseň bramborová',
          reason: 'hnědé skvrny na listech',
          check: 'bílý povlak na rubu listu',
          care: 'odstranit napadené listy',
        ),
        IncidentCandidate(label: 'Sucho'),
      ]),
    );
    final settings = InMemorySettingsRepository();
    final incidents = InMemoryIncidentRepository();
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: testOverrides(
          incidents: incidents,
          settings: settings,
          diagnosis: backend,
          photos: PhotoStorage(root),
        ),
        child: MaterialApp(
          locale: const Locale('cs'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: IncidentFormScreen(
            zoneId: 'Z1',
            initial: Incident(
              id: 'inc',
              zoneId: 'Z1',
              label: 'skvrny',
              photos: [
                PhotoRef(id: 'p1', path: '${PhotoStorage.folder}/p1.jpg'),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(file.existsSync(), isTrue);

    final button = find.text('Zkusit poznat z fotky');
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(find.text('Poslat fotku k diagnóze?'), findsOneWidget);
    await tester.tap(find.text('Souhlasím a poslat'));
    await tester.pumpAndSettle();

    expect(settings.current.photoConsentAt, isNotNull);
    expect(backend.sent, hasLength(1));
    expect(hasApp1(backend.sent.single), isFalse);
    expect(backend.zoneType, 'vegetable');
    expect(backend.note, 'skvrny');

    expect(find.text('Možná jde o…'), findsOneWidget);
    expect(find.text('Ověř: bílý povlak na rubu listu'), findsOneWidget);
    await tester.tap(find.text('Použít').first);
    await tester.pumpAndSettle();
    expect(find.text('Možná jde o…'), findsNothing);

    await tester.tap(find.widgetWithText(TextButton, 'Uložit'));
    await tester.pumpAndSettle();
    final saved = incidents.items['inc']!;
    expect(saved.label, 'Plíseň bramborová');
    expect(saved.source, IncidentSource.model);
    expect(saved.candidates, hasLength(2));
    expect(saved.planBio, 'odstranit napadené listy');
  });

  testWidgets('no diagnosis button without backend', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: testOverrides(),
        child: MaterialApp(
          locale: const Locale('cs'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const IncidentFormScreen(
            zoneId: 'Z1',
            initial: Incident(
              id: 'inc',
              zoneId: 'Z1',
              label: 'x',
              photos: [PhotoRef(id: 'p1', path: 'activity_photos/p1.jpg')],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Zkusit poznat z fotky'), findsNothing);
  });
}
