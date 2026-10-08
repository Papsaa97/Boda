import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zahradnik_boda/features/activity/domain/activity_entity.dart';
import 'package:zahradnik_boda/features/incidents/data/drift_incident_repository.dart';
import 'package:zahradnik_boda/features/incidents/domain/incident.dart';
import 'package:zahradnik_boda/features/incidents/presentation/incidents_controller.dart';
import 'package:zahradnik_boda/features/incidents/presentation/incidents_screen.dart';
import 'package:zahradnik_boda/features/tasks/data/drift_task_repository.dart';
import 'package:zahradnik_boda/features/tasks/domain/task_entity.dart';
import 'package:zahradnik_boda/features/tasks/presentation/tasks_controller.dart';
import 'package:zahradnik_boda/features/zones/data/drift_zone_repository.dart';
import 'package:zahradnik_boda/l10n/app_localizations.dart';

import '../../helpers/database.dart';
import '../../helpers/fakes.dart';

void main() {
  test('Drift keeps incident, candidates, photos and check link', () async {
    final db = memoryDatabase();
    addTearDown(db.close);
    final gardenId = await db.ensureDefaultGarden(
      newId: sequentialIds(),
      now: testNow,
    );
    DateTime clock() => testNow;
    await DriftZoneRepository(db, gardenId, clock).saveZone(testZones[2]);
    final repo = DriftIncidentRepository(db, gardenId, clock);
    final incident = Incident(
      id: 'inc',
      zoneId: 'Z3',
      label: 'Strupovitost',
      source: IncidentSource.model,
      candidates: const [
        IncidentCandidate(label: 'Strupovitost jabloně', reason: 'skvrny'),
        IncidentCandidate(label: 'Nedostatek vápníku'),
      ],
      planBio: 'Shrabat listí',
      photos: const [
        PhotoRef(id: 'p1', path: 'activity_photos/p1.jpg'),
        PhotoRef(id: 'p2', path: 'activity_photos/p2.jpg'),
      ],
      createdAt: testNow,
    );
    await repo.save(incident);
    await DriftTaskRepository(db, gardenId, clock).saveTask(
      TaskEntity(
        id: 't',
        title: 'Kontrola',
        due: DateTime(2026, 10, 10),
        incidentId: 'inc',
      ),
    );
    final loaded = (await repo.getAll()).single;
    expect(loaded.candidates, incident.candidates);
    expect(loaded.photos, incident.photos);
    expect(loaded.source, IncidentSource.model);
    expect(
      (await DriftTaskRepository(
        db,
        gardenId,
        clock,
      ).getAllTasks()).single.incidentId,
      'inc',
    );

    await repo.save(loaded.copyWith(photos: [loaded.photos.first]));
    expect((await repo.getAll()).single.photos, hasLength(1));
    await repo.delete('inc');
    expect(await repo.getAll(), isEmpty);
    final photos = await db.select(db.photos).get();
    expect(photos.every((p) => p.deletedAt != null), isTrue);
  });

  group('IncidentsController', () {
    late InMemoryIncidentRepository incidents;
    late InMemoryTaskRepository tasks;
    late ProviderContainer c;

    setUp(() {
      incidents = InMemoryIncidentRepository();
      tasks = InMemoryTaskRepository();
      c = ProviderContainer(
        overrides: testOverrides(incidents: incidents, tasks: tasks),
      );
      addTearDown(c.dispose);
    });

    test('a new incident schedules checks after 3 and 7 days', () async {
      await c.read(incidentsControllerProvider.future);
      await c.read(tasksControllerProvider.future);
      final incident = await c
          .read(incidentsControllerProvider.notifier)
          .create(
            zoneId: 'Z1',
            label: '  Mšice  ',
            planBio: ' ',
            planChem: 'Podle etikety',
            checkTitle: (d) => 'Kontrola za $d dní',
          );
      expect(incident!.label, 'Mšice');
      expect(incident.planBio, isNull);
      expect(incidents.items.keys, [incident.id]);
      final checks = c.read(incidentChecksProvider(incident.id));
      expect(checks.map((t) => t.due), [
        DateTime(2026, 10, 10),
        DateTime(2026, 10, 14),
      ]);
      expect(checks.map((t) => t.title), [
        'Kontrola za 3 dní',
        'Kontrola za 7 dní',
      ]);
      expect(checks.every((t) => t.zoneId == 'Z1'), isTrue);
      expect(c.read(openIncidentCountProvider), 1);

      await c
          .read(incidentsControllerProvider.notifier)
          .setStatus(incident.id, IncidentStatus.resolved);
      expect(incidents.items[incident.id]!.status, IncidentStatus.resolved);
      expect(
        c.read(incidentChecksProvider(incident.id)).map((t) => t.status),
        everyElement(TaskStatus.skipped),
      );
      expect(c.read(openIncidentCountProvider), 0);
    });

    test('open incidents come first', () async {
      incidents.items['old'] = Incident(
        id: 'old',
        zoneId: 'Z1',
        label: 'Vyřešený',
        status: IncidentStatus.resolved,
        createdAt: testNow.add(const Duration(days: 1)),
      );
      incidents.items['new'] = Incident(
        id: 'new',
        zoneId: 'Z1',
        label: 'Otevřený',
        createdAt: testNow,
      );
      final list = await c.read(incidentsControllerProvider.future);
      expect(list.map((i) => i.id), ['new', 'old']);
    });
  });

  testWidgets('create an incident by hand and resolve it', (tester) async {
    final incidents = InMemoryIncidentRepository();
    final tasks = InMemoryTaskRepository();
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: testOverrides(incidents: incidents, tasks: tasks),
        child: MaterialApp(
          locale: const Locale('cs'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const IncidentsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Zatím žádný problém'), findsOneWidget);

    await tester.tap(find.text('Nový problém'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Uložit'));
    await tester.pumpAndSettle();
    expect(find.text('Napiš, co se děje.'), findsOneWidget);
    expect(find.text('Vyber zónu.'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Co se děje'),
      'Mšice na rybízu',
    );
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ovocný sad').last);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Uložit'));
    await tester.pumpAndSettle();
    expect(incidents.items.values.single.zoneId, 'Z3');
    expect(tasks.items.values, hasLength(2));

    await tester.tap(find.text('Mšice na rybízu'));
    await tester.pumpAndSettle();
    expect(find.text('Kontroly'), findsOneWidget);
    expect(find.textContaining('Kontrola po 3 dnech'), findsOneWidget);
    await tester.tap(find.text('Označit jako vyřešené'));
    await tester.pumpAndSettle();
    expect(incidents.items.values.single.status, IncidentStatus.resolved);
    expect(find.text('Znovu otevřít'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
