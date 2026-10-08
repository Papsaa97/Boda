import 'package:flutter_test/flutter_test.dart';
import 'package:zahradnik_boda/features/builds/domain/build_params.dart';
import 'package:zahradnik_boda/features/builds/domain/build_plan.dart';
import 'package:zahradnik_boda/features/builds/domain/calculators.dart';
import 'package:zahradnik_boda/features/builds/domain/timber.dart';

BuildPlan plan(BuildTemplate t, [Map<String, Object?> raw = const {}]) =>
    planFor(BuildValues(t, raw));

double qty(BuildPlan p, BuildMaterial m) =>
    p.bom.firstWhere((l) => l.material == m).quantity;

Set<FindingCode> codes(BuildPlan p) => {for (final f in p.findings) f.code};

void main() {
  group('values', () {
    test('missing, invalid and out-of-range values fall back safely', () {
      final v = BuildValues(BuildTemplate.bridge, {
        'span': 99,
        'width': 'x',
        'beamSection': '1x1',
        'railing': 'ano',
      });
      expect(v.number('span'), 6);
      expect(v.number('width'), 1);
      expect(v.choice('beamSection'), '100x200');
      expect(v.toggle('railing'), isFalse);
      expect(v.toJson().keys, containsAll(['span', 'width', 'heightAbove']));
    });
  });

  group('timber', () {
    test('a stronger section has lower utilization', () {
      BeamCheck c(String s) => checkBeam(
        section: TimberSection.parse(s),
        spanM: 3,
        gK: 0.1,
        qK: 2.5,
        exposure: Exposure.outdoor,
      );
      expect(c('80x160').ok, isFalse);
      expect(c('100x200').ok, isTrue);
      expect(c('120x240').utilization, lessThan(c('100x200').utilization));
    });
  });

  group('raised bed', () {
    test('default bed: boards, posts, tie rod and fill', () {
      final p = plan(BuildTemplate.raisedBed);
      // 4 řady prken 145 mm = 0,58 m, obvod 6 m.
      expect(p.summary[SummaryKey.boardRows], 4);
      expect(qty(p, BuildMaterial.board32), closeTo(24, 1e-9));
      // Rohy + mezisloupek uprostřed obou dlouhých stran.
      expect(qty(p, BuildMaterial.post50), closeTo(6 * 0.88, 0.11));
      expect(qty(p, BuildMaterial.tieRod), 1);
      expect(qty(p, BuildMaterial.fill), closeTo(1.2, 0.05));
      expect(codes(p), containsAll([FindingCode.bedMidPosts]));
      expect(
        p.findings.any((f) => f.severity != FindingSeverity.info),
        isFalse,
      );
    });

    test('wide bed with thin tall boards gets warnings', () {
      final p = plan(BuildTemplate.raisedBed, {
        'width': 1.6,
        'height': 0.9,
        'boardThickness': '25',
        'moleMesh': false,
      });
      expect(
        codes(p),
        containsAll([
          FindingCode.bedTooWide,
          FindingCode.bedThinBoards,
          FindingCode.bedTallFill,
        ]),
      );
      expect(p.bom.any((l) => l.material == BuildMaterial.moleMesh), isFalse);
      expect(p.bom.any((l) => l.material == BuildMaterial.post70), isTrue);
    });
  });

  group('path', () {
    test('gravel path: tonnes of aggregate, fabric, edging', () {
      final p = plan(BuildTemplate.path);
      // 10 m² × 0,10 m × 1,7 t/m³.
      expect(qty(p, BuildMaterial.gravel032), closeTo(1.7, 1e-9));
      expect(qty(p, BuildMaterial.chippings816), closeTo(0.8, 1e-9));
      expect(qty(p, BuildMaterial.geotextile), closeTo(11, 1e-9));
      expect(qty(p, BuildMaterial.edging), closeTo(20, 1e-9));
      expect(p.drawing.view, DrawingView.section);
      expect(p.summary[SummaryKey.excavation], closeTo(1.5, 1e-9));
    });

    test('pavers without edging are a warning', () {
      final p = plan(BuildTemplate.path, {
        'surface': 'pavers',
        'edging': false,
      });
      expect(codes(p), contains(FindingCode.pathPaversNeedEdging));
      expect(qty(p, BuildMaterial.pavers), closeTo(10.5, 1e-9));
    });

    test('stepping stones one per step', () {
      final p = plan(BuildTemplate.path, {
        'surface': 'stepping',
        'length': 6.2,
      });
      expect(qty(p, BuildMaterial.steppingStone), 10);
      expect(p.bom.any((l) => l.material == BuildMaterial.edging), isFalse);
    });
  });

  group('bridge', () {
    test('default bridge passes without warnings', () {
      final p = plan(BuildTemplate.bridge);
      expect(p.findings, isEmpty);
      expect(p.engineerRecommended, isFalse);
      expect(qty(p, BuildMaterial.beam100x200), closeTo(3 * 2.6, 1e-9));
    });

    test('long span needs an engineer, weak beams suggest a section', () {
      final p = plan(BuildTemplate.bridge, {
        'span': 3.5,
        'beamSection': '80x160',
        'beamCount': '2',
      });
      expect(p.engineerRecommended, isTrue);
      expect(p.hasDanger, isTrue);
      final fail = p.findings.firstWhere(
        (f) => f.code == FindingCode.bridgeBeamFails,
      );
      expect(fail.values['section'], isNotNull);
      expect(codes(p), contains(FindingCode.bridgeSpanOverLimit));
      expect(codes(p), contains(FindingCode.bridgeDeckSpan));
    });

    test('high bridge without railing', () {
      final p = plan(BuildTemplate.bridge, {'heightAbove': 0.8});
      expect(codes(p), {FindingCode.bridgeNeedsRailing});
      final high = plan(BuildTemplate.bridge, {
        'heightAbove': 1.5,
        'railing': true,
      });
      expect(codes(high), {FindingCode.bridgeTooHigh});
      expect(high.engineerRecommended, isTrue);
      expect(qty(high, BuildMaterial.railing), closeTo(4, 1e-9));
    });
  });

  group('shelter', () {
    test('default shelter is fine and has a budget', () {
      final p = plan(BuildTemplate.shelter);
      expect(p.hasDanger, isFalse);
      expect(codes(p), {FindingCode.shelterAnchoring});
      expect(p.summary[SummaryKey.postSpacing], closeTo(1.5, 1e-9));
      expect(p.total(const {}), greaterThan(0));
    });

    test(
      'heavy snow breaks thin rafters; big shelter needs a permit check',
      () {
        final p = plan(BuildTemplate.shelter, {
          'width': 6,
          'depth': 5,
          'rafterSection': '60x120',
          'snowRegion': 'V',
        });
        final fail = p.findings.firstWhere(
          (f) => f.code == FindingCode.shelterRafterFails,
        );
        expect(fail.severity, FindingSeverity.danger);
        expect(codes(p), contains(FindingCode.shelterPermit));
      },
    );
  });

  test('user prices override defaults in the budget', () {
    final p = plan(BuildTemplate.path);
    final base = p.total(const {});
    final cheaper = p.total({'gravel032': 0});
    expect(base - cheaper, closeTo(1.7 * 450, 1e-6));
  });
}
