import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:zahradnik_boda/core/di/providers.dart';
import 'package:zahradnik_boda/features/activity/domain/activity_type.dart';
import 'package:zahradnik_boda/features/canvas/data/drift_plan_repository.dart';
import 'package:zahradnik_boda/features/canvas/domain/geometry.dart';
import 'package:zahradnik_boda/features/canvas/domain/plan_document.dart';
import 'package:zahradnik_boda/features/canvas/domain/plan_repository.dart';
import 'package:zahradnik_boda/features/canvas/domain/edit_history.dart';
import 'package:zahradnik_boda/features/canvas/presentation/canvas_controller.dart';
import 'package:zahradnik_boda/features/canvas/presentation/canvas_screen.dart';
import 'package:zahradnik_boda/features/canvas/presentation/plan_painter.dart';
import 'package:zahradnik_boda/features/zones/data/drift_zone_repository.dart';
import 'package:zahradnik_boda/features/zones/domain/zone_entity.dart';
import 'package:zahradnik_boda/features/zones/presentation/zones_controller.dart';
import 'package:zahradnik_boda/l10n/app_localizations.dart';

import '../../helpers/database.dart';
import '../../helpers/fakes.dart';

class InMemoryPlanRepository implements PlanRepository {
  List<Pt> outline = const [];
  PlanBackground? background;

  @override
  Future<List<Pt>> loadOutline() async => outline;

  @override
  Future<void> saveOutline(List<Pt> outline) async => this.outline = outline;

  @override
  Future<PlanBackground?> loadBackground() async => background;

  @override
  Future<void> saveBackground(PlanBackground? background) async =>
      this.background = background;
}

const _rect10x5 = [Pt(0, 0), Pt(10, 0), Pt(10, 5), Pt(0, 5)];

void main() {
  group('geometry', () {
    test('area, perimeter and centroid of a rectangle', () {
      expect(polygonArea(_rect10x5), 50);
      expect(polygonArea(_rect10x5.reversed.toList()), 50);
      expect(polygonPerimeter(_rect10x5), 30);
      expect(polygonCentroid(_rect10x5), const Pt(5, 2.5));
      expect(polygonArea(const [Pt(0, 0), Pt(1, 1)]), 0);
    });

    test('snap, nearest vertex and edge midpoints', () {
      expect(snapToGrid(const Pt(1.26, 3.74), 0.5), const Pt(1.5, 3.5));
      expect(snapToGrid(const Pt(1.26, 3.74), 0), const Pt(1.26, 3.74));
      expect(nearestVertex(_rect10x5, const Pt(9.7, 0.2), 0.6), 1);
      expect(nearestVertex(_rect10x5, const Pt(5, 2), 0.6), isNull);
      expect(edgeMidpoints(_rect10x5).first, const Pt(5, 0));
    });

    test('containment uses turf', () {
      expect(polygonContainsPoint(_rect10x5, const Pt(3, 3)), isTrue);
      expect(polygonContainsPoint(_rect10x5, const Pt(11, 3)), isFalse);
      const inner = [Pt(1, 1), Pt(4, 1), Pt(4, 3), Pt(1, 3)];
      expect(polygonWithin(inner, _rect10x5), isTrue);
      const across = [Pt(8, 1), Pt(12, 1), Pt(12, 3), Pt(8, 3)];
      expect(polygonWithin(across, _rect10x5), isFalse);
    });

    test('JSON keeps centimetres and rejects garbage', () {
      final json = polygonToJson(const [
        Pt(1.23456, 2),
        Pt(3, 4.005),
        Pt(0, 0),
      ]);
      expect(json.first, [1.23, 2]);
      expect(polygonFromJson(json), hasLength(3));
      expect(polygonFromJson([1, 2, 3]), isNull);
      expect(
        polygonFromJson([
          [0, 0],
          [1, 1],
        ]),
        isNull,
      );
      expect(polygonFromJson('x'), isNull);
    });

    test('calibration of a 10 × 5 m bed lands within 3 % of 50 m²', () {
      // Nakresleno bez měřítka: delší strana vyšla 4,1 jednotky.
      const drawn = [Pt(2, 2), Pt(6.1, 2), Pt(6.1, 4.05), Pt(2, 4.05)];
      final k = calibrationFactor(drawn: 4.1, real: 10);
      final scaled = scalePolygon(drawn, drawn.first, k);
      expect(polygonArea(scaled), closeTo(50, 50 * 0.03));
      final check = scaled[1].distanceTo(scaled[2]);
      expect(
        deviationPercent(measured: check, real: 5),
        lessThan(maxCalibrationDeviationPercent),
      );
      expect(() => calibrationFactor(drawn: 0, real: 1), throwsArgumentError);
    });
  });

  group('fitPlanToView', () {
    // Zahrada 24 × 16 m na plátně 60 × 40 m s okrajem 10 m.
    const garden = [Pt(0, 0), Pt(24, 0), Pt(24, 16), Pt(0, 16)];
    const viewport = Size(390, 600);

    Offset apply(Matrix4 m, Offset o) => MatrixUtils.transformPoint(m, o);

    test('centres the drawn plan and fits it into the viewport', () {
      const frame = PlanFrame(Pt(-10, -10), 60, 40);
      final m = fitPlanToView(frame, garden, viewport)!;
      final topLeft = apply(m, frame.toPx(garden[0]));
      final bottomRight = apply(m, frame.toPx(garden[2]));
      expect(topLeft.dx, closeTo(16, 0.01));
      expect(bottomRight.dx, closeTo(374, 0.01));
      expect(topLeft.dy, greaterThanOrEqualTo(16));
      expect(bottomRight.dy, lessThanOrEqualTo(584));
      expect((topLeft.dy + bottomRight.dy) / 2, closeTo(300, 0.01));
    });

    test('does not blow up a tiny plan', () {
      const frame = PlanFrame(Pt(-10, -10), 60, 40);
      final m = fitPlanToView(frame, const [Pt(1, 1)], viewport)!;
      expect(m.getMaxScaleOnAxis(), 3);
    });

    test('leaves an empty canvas alone', () {
      const frame = PlanFrame(Pt(0, 0), 60, 40);
      expect(fitPlanToView(frame, const [], viewport), isNull);
    });
  });

  group('EditHistory', () {
    test('undo, redo and a new step clears redo', () {
      final h = EditHistory(0)
        ..push(1)
        ..push(2);
      expect(h.undo(), 1);
      expect(h.canRedo, isTrue);
      expect(h.redo(), 2);
      h
        ..undo()
        ..push(5);
      expect(h.canRedo, isFalse);
      expect(h.undo(), 1);
      expect(h.undo(), 0);
      expect(h.canUndo, isFalse);
    });

    test('keeps only the last steps and drag counts as one', () {
      final h = EditHistory(0, limit: 3);
      for (var i = 1; i <= 5; i++) {
        h.push(i);
      }
      h
        ..undo()
        ..undo()
        ..undo();
      expect(h.present, 2);
      expect(h.canUndo, isFalse);

      final d = EditHistory('a')
        ..replace('b')
        ..replace('c')
        ..commitFrom('a');
      expect(d.present, 'c');
      expect(d.undo(), 'a');
    });
  });

  test('PlanDocument scales outline and shapes together', () {
    const doc = PlanDocument(
      outline: _rect10x5,
      shapes: {
        'z': ZoneShape([Pt(1, 1), Pt(2, 1), Pt(2, 2)]),
      },
    );
    final scaled = doc.scaled(const Pt(0, 0), 2);
    expect(scaled.outline[2], const Pt(20, 10));
    expect(scaled.shapes['z']!.area, 2);
    expect(scaled.allPoints, hasLength(7));
    expect(outlineFromBounds(outlineToBounds(_rect10x5)), _rect10x5);
    expect(outlineFromBounds({'outline': 'x'}), isEmpty);
  });

  group('Drift', () {
    test('outline lives in gardens.bounds, background in settings', () async {
      final db = memoryDatabase();
      addTearDown(db.close);
      final gardenId = await db.ensureDefaultGarden(
        newId: sequentialIds(),
        now: testNow,
      );
      final repo = DriftPlanRepository(db, gardenId, () => testNow);
      expect(await repo.loadOutline(), isEmpty);
      await repo.saveOutline(_rect10x5);
      expect(await repo.loadOutline(), _rect10x5);
      final garden = await db.select(db.gardens).getSingle();
      expect(garden.bounds, contains('outline'));
      await repo.saveOutline(const []);
      expect((await db.select(db.gardens).getSingle()).bounds, isNull);

      const bg = PlanBackground(
        path: 'plan/background_x.jpg',
        widthPx: 1200,
        heightPx: 800,
        metersPerPixel: 0.025,
      );
      await repo.saveBackground(bg);
      expect(await repo.loadBackground(), bg);
      await repo.saveBackground(null);
      expect(await repo.loadBackground(), isNull);
    });

    test('zone polygon and layer round-trip', () async {
      final db = memoryDatabase();
      addTearDown(db.close);
      final gardenId = await db.ensureDefaultGarden(
        newId: sequentialIds(),
        now: testNow,
      );
      final repo = DriftZoneRepository(db, gardenId, () => testNow);
      await repo.saveZone(
        const ZoneEntity(
          id: 'p',
          name: 'Jezírko',
          type: ZoneType.pond,
          polygon: _rect10x5,
          layer: ZoneLayer.plan,
        ),
      );
      final zone = (await repo.getAllZones()).single;
      expect(zone.polygon, _rect10x5);
      expect(zone.layer, ZoneLayer.plan);
      expect(zone.isActive, isFalse);
      await repo.saveZone(zone.copyWith(polygon: () => null));
      expect((await repo.getAllZones()).single.polygon, isNull);
    });
  });

  group('CanvasController', () {
    late InMemoryPlanRepository plan;
    late InMemoryZoneRepository zones;
    late InMemoryActivityRepository activities;
    late ProviderContainer c;

    setUp(() {
      plan = InMemoryPlanRepository();
      zones = InMemoryZoneRepository([
        testZones[0].copyWith(areaM2: () => 20),
        testZones[1],
      ]);
      activities = InMemoryActivityRepository();
      c = ProviderContainer(
        overrides: [
          ...testOverrides(zones: zones, activities: activities),
          planRepositoryProvider.overrideWithValue(plan),
        ],
      );
      addTearDown(c.dispose);
    });

    Future<CanvasController> ready() async {
      // autoDispose: držet poslech po celý test.
      c.listen(canvasControllerProvider, (_, _) {});
      await c.read(canvasControllerProvider.future);
      return c.read(canvasControllerProvider.notifier);
    }

    CanvasState state() => c.read(canvasControllerProvider).requireValue;

    void tapAll(CanvasController ctrl, List<Pt> points) {
      for (final p in points) {
        ctrl.tap(p);
      }
    }

    test('draws the garden outline and saves it', () async {
      final ctrl = await ready()
        ..setTool(CanvasTool.outline);
      tapAll(ctrl, const [
        Pt(0.1, 0.2),
        Pt(20.2, 0),
        Pt(19.9, 12.1),
        Pt(0, 12),
      ]);
      expect(state().draft.first, const Pt(0, 0));
      expect(ctrl.tap(const Pt(0.3, 0.1)), TapOutcome.none);
      expect(state().doc.outline, const [
        Pt(0, 0),
        Pt(20, 0),
        Pt(20, 12),
        Pt(0, 12),
      ]);
      expect(state().tool, CanvasTool.select);
      expect(state().selected, outlineSelection);
      await pumpEventQueue();
      expect(plan.outline, hasLength(4));
    });

    test('a new zone gets its area from the plan', () async {
      final ctrl = await ready()
        ..setTool(CanvasTool.zone);
      tapAll(ctrl, _rect10x5);
      expect(ctrl.closeDraft(), TapOutcome.zoneClosed);
      expect(ctrl.draftInsideOutline, isTrue);
      expect(
        ctrl.assignableZones.map((z) => z.id),
        unorderedEquals(['Z1', 'Z2']),
      );
      final suggestion = await ctrl.assignDraft(
        newName: 'Záhon u plotu',
        newType: ZoneType.vegetable,
      );
      expect(suggestion, isNull);
      final saved = zones.items.values.firstWhere(
        (z) => z.name == 'Záhon u plotu',
      );
      expect(saved.polygon, _rect10x5);
      expect(saved.areaM2, 50);
      expect(saved.layer, ZoneLayer.reality);
      expect(state().selected, saved.id);
    });

    test('a shape for a zone with a different area suggests it', () async {
      final ctrl = await ready()
        ..setTool(CanvasTool.zone);
      tapAll(ctrl, _rect10x5);
      ctrl.closeDraft();
      final suggestion = await ctrl.assignDraft(zoneId: 'Z1');
      expect(
        suggestion,
        const AreaSuggestion(
          zoneId: 'Z1',
          zoneName: 'Zelenina',
          planArea: 50,
          currentArea: 20,
        ),
      );
      expect(zones.items['Z1']!.areaM2, 20);
      await ctrl.applyPlanArea('Z1');
      expect(zones.items['Z1']!.areaM2, 50);
      expect(zones.items['Z1']!.polygon, _rect10x5);
    });

    test('zone outside the outline is detected', () async {
      plan.outline = _rect10x5;
      final ctrl = await ready()
        ..setTool(CanvasTool.zone);
      tapAll(ctrl, const [Pt(8, 1), Pt(12, 1), Pt(12, 3), Pt(8, 3)]);
      expect(ctrl.closeDraft(), TapOutcome.zoneClosed);
      expect(ctrl.draftInsideOutline, isFalse);
    });

    test('calibration rescales the plan; undo and redo restore it', () async {
      plan.outline = const [Pt(0, 0), Pt(4, 0), Pt(4, 2), Pt(0, 2)];
      final ctrl = await ready()
        ..setTool(CanvasTool.calibrate);
      expect(ctrl.tap(const Pt(0, 0)), TapOutcome.none);
      expect(ctrl.tap(const Pt(4, 0)), TapOutcome.needLength);
      await ctrl.calibrate(10);
      expect(polygonArea(state().doc.outline), closeTo(50, 50 * 0.03));
      expect(state().tool, CanvasTool.measure);
      expect(plan.outline[2], const Pt(10, 5));

      ctrl
        ..tap(const Pt(10, 0))
        ..tap(const Pt(10, 5));
      expect(ctrl.measure(5), closeTo(0, 0.01));

      expect(state().canUndo, isTrue);
      await ctrl.undo();
      expect(plan.outline[2], const Pt(4, 2));
      expect(state().canRedo, isTrue);
      await ctrl.redo();
      expect(plan.outline[2], const Pt(10, 5));
    });

    test('dragging a vertex is one undo step', () async {
      plan.outline = _rect10x5;
      final ctrl = await ready();
      ctrl
        ..tap(const Pt(5, 2))
        ..editSelected();
      expect(state().tool, CanvasTool.edit);
      expect(ctrl.dragStart(const Pt(10.2, 5.1)), isTrue);
      ctrl
        ..dragUpdate(const Pt(11, 6))
        ..dragUpdate(const Pt(12.1, 7.2));
      await ctrl.dragEnd();
      expect(plan.outline[2], const Pt(12, 7));
      await ctrl.undo();
      expect(plan.outline[2], const Pt(10, 5));

      // Klepnutí na střed hrany přidá uzel, pak se dá smazat.
      ctrl.tap(const Pt(5, 0));
      expect(state().doc.outline, hasLength(5));
      await ctrl.deleteSelectedVertex();
      expect(state().doc.outline, hasLength(4));
    });

    test('planned zone stays out of pickers until realized', () async {
      final ctrl = await ready()
        ..setView(LayerView.plan)
        ..setTool(CanvasTool.zone);
      tapAll(ctrl, _rect10x5);
      ctrl.closeDraft();
      await ctrl.assignDraft(
        newName: 'Skleník 2027',
        newType: ZoneType.greenhouse,
      );
      final id = state().selected!;
      expect(zones.items[id]!.layer, ZoneLayer.plan);
      expect(c.read(activeZonesProvider).map((z) => z.id), isNot(contains(id)));

      await ctrl.realize(id, activityTitle: 'Zrealizováno: Skleník 2027');
      expect(zones.items[id]!.layer, ZoneLayer.reality);
      expect(c.read(activeZonesProvider).map((z) => z.id), contains(id));
      final logged = activities.items.values.single;
      expect(logged.zoneId, id);
      expect(logged.type, ActivityType.other);
      expect(logged.title, 'Zrealizováno: Skleník 2027');
    });

    test('removing a shape keeps the zone', () async {
      final ctrl = await ready()
        ..setTool(CanvasTool.zone);
      tapAll(ctrl, _rect10x5);
      ctrl.closeDraft();
      await ctrl.assignDraft(zoneId: 'Z2');
      await ctrl.removeShape('Z2');
      expect(zones.items['Z2']!.polygon, isNull);
      expect(zones.items['Z2']!.archived, isFalse);
      expect(state().doc.shapes, isEmpty);
    });
  });

  testWidgets('canvas screen shows the plan and switches tools', (
    tester,
  ) async {
    final plan = InMemoryPlanRepository()..outline = _rect10x5;
    final zones = InMemoryZoneRepository([
      testZones[0].copyWith(
        polygon: () => const [Pt(1, 1), Pt(4, 1), Pt(4, 3), Pt(1, 3)],
      ),
    ]);
    final List<Override> overrides = [
      ...testOverrides(zones: zones),
      planRepositoryProvider.overrideWithValue(plan),
    ];
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: MaterialApp(
          locale: const Locale('cs'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const CanvasScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Plán zahrady'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('1 zóna')), findsOneWidget);
    await tester.tap(find.text('Obrys'));
    await tester.pumpAndSettle();
    expect(find.textContaining('rohy obrysu'), findsOneWidget);
    await tester.tap(find.text('Návrh'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('canvas screen opens with the whole garden in view', (
    tester,
  ) async {
    final plan = InMemoryPlanRepository()
      ..outline = const [Pt(0, 0), Pt(24, 0), Pt(24, 16), Pt(0, 16)];
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...testOverrides(zones: InMemoryZoneRepository([])),
          planRepositoryProvider.overrideWithValue(plan),
        ],
        child: MaterialApp(
          locale: const Locale('cs'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const CanvasScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final viewer = find.byType(InteractiveViewer);
    final size = tester.getSize(viewer);
    final m = tester
        .widget<InteractiveViewer>(viewer)
        .transformationController!
        .value;
    // Obrys začíná 10 m od rohu plátna (PlanFrame), po otevření je celý vidět.
    const corner = 10 * pixelsPerMeter;
    final topLeft = MatrixUtils.transformPoint(m, const Offset(corner, corner));
    final bottomRight = MatrixUtils.transformPoint(
      m,
      const Offset(corner + 24 * pixelsPerMeter, corner + 16 * pixelsPerMeter),
    );
    expect(topLeft.dx, greaterThanOrEqualTo(0));
    expect(topLeft.dy, greaterThanOrEqualTo(0));
    expect(bottomRight.dx, lessThanOrEqualTo(size.width));
    expect(bottomRight.dy, lessThanOrEqualTo(size.height));
  });
}
