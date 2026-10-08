import 'dart:math' as math;

import 'build_params.dart';
import 'build_plan.dart';
import 'timber.dart';

/// Výkres, výkaz materiálu a mantinely pro návrh (FR-G1, FR-G2).
/// Všechno počítá kód; AI do návrhů nevstupuje (D23).
BuildPlan planFor(BuildValues v) => switch (v.template) {
  BuildTemplate.raisedBed => planRaisedBed(v),
  BuildTemplate.path => planPath(v),
  BuildTemplate.bridge => planBridge(v),
  BuildTemplate.shelter => planShelter(v),
};

/// Zaokrouhlí nahoru na [step] (bez chyb typu 2,0 → 2,1).
double _up(double value, double step) => ((value / step) - 1e-6).ceil() * step;

int _pcs(double value) => (value - 1e-6).ceil();

double _liters(double areaM2) => _up(areaM2 * 0.12, 0.5);

// ---------------------------------------------------------------------------
// Vyvýšený záhon

/// Výška prkna (palubka 145 mm).
const _boardHeight = 0.145;

/// Nejdelší pole prkna mezi sloupky podle tloušťky (orientačně, zemina
/// tlačí na stěnu víc u vyšších záhonů).
const _bedPostSpacing = {25: 1.0, 32: 1.3, 40: 1.6};

BuildPlan planRaisedBed(BuildValues v) {
  final length = v.number('length');
  final width = v.number('width');
  final height = v.number('height');
  final thickness = int.parse(v.choice('boardThickness'));
  final rows = math.max(1, (height / _boardHeight).round());
  final realHeight = rows * _boardHeight;
  final maxSpacing =
      _bedPostSpacing[thickness]! * (realHeight > 0.6 ? 0.8 : 1.0);
  final midLong = _pcs(length / maxSpacing) - 1;
  final midShort = _pcs(width / maxSpacing) - 1;
  final posts = 4 + 2 * midLong + 2 * midShort;
  final tall = realHeight > 0.6;
  final ties = realHeight > 0.5 && length > 1.5
      ? math.max(1, _pcs(length / 1.2) - 1)
      : 0;

  final findings = <Finding>[
    if (width > 1.2)
      Finding(FindingCode.bedTooWide, FindingSeverity.warning, {
        'width': width,
      }),
    if (thickness == 25 && tall)
      const Finding(FindingCode.bedThinBoards, FindingSeverity.warning),
    if (midLong + midShort > 0)
      Finding(FindingCode.bedMidPosts, FindingSeverity.info, {
        'count': 2 * (midLong + midShort),
        'spacing': maxSpacing,
      }),
    if (ties > 0)
      Finding(FindingCode.bedTieRods, FindingSeverity.info, {'count': ties}),
    if (realHeight >= 0.7)
      const Finding(FindingCode.bedTallFill, FindingSeverity.info),
  ];

  final board = switch (thickness) {
    25 => BuildMaterial.board25,
    32 => BuildMaterial.board32,
    _ => BuildMaterial.board40,
  };
  final outerArea = 2 * (length + width) * realHeight;
  final bom = [
    BomLine(board, _up(rows * 2 * (length + width), 0.1)),
    BomLine(
      tall ? BuildMaterial.post70 : BuildMaterial.post50,
      _up(posts * (realHeight + 0.3), 0.1),
    ),
    BomLine(
      BuildMaterial.screws,
      (rows * (8 + 2 * midLong + 2 * midShort) * 2).toDouble(),
    ),
    if (ties > 0) BomLine(BuildMaterial.tieRod, ties.toDouble()),
    if (v.toggle('moleMesh'))
      BomLine(BuildMaterial.moleMesh, _up(length * width * 1.1, 0.1)),
    if (v.toggle('liner'))
      BomLine(BuildMaterial.liner, _up(outerArea * 1.1, 0.1)),
    BomLine(BuildMaterial.fill, _up(length * width * realHeight, 0.05)),
    BomLine(BuildMaterial.woodOil, _liters(outerArea * 2)),
  ];

  // Půdorys: věnec z prken, sloupky uvnitř rohů a mezisloupky.
  final l = length * 100;
  final w = width * 100;
  final t = thickness / 10;
  final p = tall ? 7.0 : 5.0;
  final shapes = <DrawShape>[
    DrawRect(0, 0, l, w, DrawStyle.wood),
    DrawRect(t, t, l - 2 * t, w - 2 * t, DrawStyle.soil),
    for (final x in _positions(l - 2 * t - p, midLong))
      for (final y in [t, w - t - p]) DrawRect(t + x, y, p, p, DrawStyle.post),
    for (final y in _positions(w - 2 * t - p, midShort))
      for (final x in [t, l - t - p])
        if (y > 0 && y < w - 2 * t - p)
          DrawRect(x, t + y, p, p, DrawStyle.post),
    DrawDimension(0, w + 25, l, w + 25, length),
    DrawDimension(l + 25, 0, l + 25, w, width),
  ];
  return BuildPlan(
    drawing: Drawing(DrawingView.top, shapes),
    bom: bom,
    findings: findings,
    summary: {
      SummaryKey.boardRows: rows,
      SummaryKey.fillVolume: length * width * realHeight,
    },
  );
}

/// Rovnoměrné pozice od 0 do [span] včetně krajů pro [inner] vnitřních.
List<double> _positions(double span, int inner) => [
  for (var i = 0; i <= inner + 1; i++) span * i / (inner + 1),
];

// ---------------------------------------------------------------------------
// Chodník

const _gravelDensity = 1.7; // t/m³
const _chippingsDensity = 1.6;
const _stepEvery = 0.62; // m, délka kroku
const _stoneSize = 0.4;

BuildPlan planPath(BuildValues v) {
  final length = v.number('length');
  final width = v.number('width');
  final surface = v.choice('surface');
  final stepping = surface == 'stepping';
  final edging = v.toggle('edging') && !stepping;
  final area = length * width;
  final stones = stepping ? _pcs(length / _stepEvery) : 0;

  // Vrstvy shora dolů: (styl, tloušťka v cm).
  final layers = switch (surface) {
    'gravel' => const [(DrawStyle.chippings, 5.0), (DrawStyle.gravel, 10.0)],
    'pavers' => const [
      (DrawStyle.paver, 6.0),
      (DrawStyle.chippings, 4.0),
      (DrawStyle.gravel, 15.0),
    ],
    'stepping' => const [(DrawStyle.paver, 5.0), (DrawStyle.chippings, 5.0)],
    _ => const [(DrawStyle.mulch, 8.0)],
  };
  final depth = layers.fold(0.0, (sum, l) => sum + l.$2);
  final excavation = stepping
      ? stones * _stoneSize * _stoneSize * depth / 100
      : area * depth / 100;

  final bom = <BomLine>[
    ...switch (surface) {
      'gravel' => [
        BomLine(
          BuildMaterial.gravel032,
          _up(area * 0.10 * _gravelDensity, 0.1),
        ),
        BomLine(
          BuildMaterial.chippings816,
          _up(area * 0.05 * _chippingsDensity, 0.1),
        ),
      ],
      'pavers' => [
        BomLine(BuildMaterial.pavers, _up(area * 1.05, 0.1)),
        BomLine(
          BuildMaterial.gravel032,
          _up(area * 0.15 * _gravelDensity, 0.1),
        ),
        BomLine(
          BuildMaterial.chippings48,
          _up(area * 0.04 * _chippingsDensity, 0.1),
        ),
      ],
      'stepping' => [
        BomLine(BuildMaterial.steppingStone, stones.toDouble()),
        BomLine(
          BuildMaterial.chippings48,
          _up(stones * _stoneSize * _stoneSize * 0.05 * _chippingsDensity, 0.1),
        ),
      ],
      _ => [BomLine(BuildMaterial.mulch, _up(area * 0.08, 0.1))],
    },
    if (!stepping) BomLine(BuildMaterial.geotextile, _up(area * 1.1, 0.1)),
    if (edging) ...[
      BomLine(BuildMaterial.edging, _up(2 * length, 0.1)),
      BomLine(BuildMaterial.concreteBag, _pcs(2 * length / 1.5).toDouble()),
    ],
  ];

  final findings = <Finding>[
    if (width < 0.6)
      const Finding(FindingCode.pathNarrow, FindingSeverity.info),
    if (surface == 'pavers' && !edging)
      const Finding(FindingCode.pathPaversNeedEdging, FindingSeverity.warning),
    if (surface == 'gravel' && !edging)
      const Finding(FindingCode.pathGravelEdging, FindingSeverity.info),
    if (stepping && width > 0.8)
      const Finding(FindingCode.pathSteppingWide, FindingSeverity.info),
    if (surface == 'mulch')
      const Finding(FindingCode.pathMulchTopUp, FindingSeverity.info),
  ];

  // Příčný řez: rostlá zemina, vrstvy, textilie a obrubníky.
  final w = (stepping ? _stoneSize : width) * 100;
  const side = 20.0;
  final shapes = <DrawShape>[
    DrawRect(0, 0, w + 2 * side, depth + 15, DrawStyle.soil),
  ];
  var y = 0.0;
  for (final (style, thickness) in layers) {
    shapes.add(DrawRect(side, y, w, thickness, style));
    y += thickness;
  }
  if (!stepping) {
    shapes.add(DrawLine(side, depth, side + w, depth, dashed: true));
  }
  if (edging) {
    shapes
      ..add(DrawRect(side - 5, -2, 5, depth + 2, DrawStyle.post))
      ..add(DrawRect(side + w, -2, 5, depth + 2, DrawStyle.post));
  }
  shapes
    ..add(DrawDimension(side, -12, side + w, -12, w / 100))
    ..add(
      DrawDimension(
        w + 2 * side + 10,
        0,
        w + 2 * side + 10,
        depth,
        depth / 100,
      ),
    );
  return BuildPlan(
    drawing: Drawing(DrawingView.section, shapes),
    bom: bom,
    findings: findings,
    summary: {SummaryKey.excavation: excavation},
  );
}

// ---------------------------------------------------------------------------
// Mostek pro pěší

/// Užitné zatížení lávky pro pěší (kN/m², opatrně jako dav).
const _crowd = 5.0;

/// Rozpětí, nad které dřevěný mostek bez podpory ve vodě nenavrhujeme
/// bez statika (FR-G2).
const bridgeSpanLimit = 3.0;

/// Výška nad hladinou nebo terénem, nad kterou doporučíme statika.
const bridgeHeightLimit = 1.0;

/// Nejdelší pole podlahového prkna mezi nosníky podle tloušťky.
const _deckSpan = {28: 0.5, 32: 0.6, 40: 0.8};

const _beamSections = ['100x100', '80x160', '100x200', '120x240', '140x280'];

BuildPlan planBridge(BuildValues v) {
  final span = v.number('span');
  final width = v.number('width');
  final section = TimberSection.parse(v.choice('beamSection'));
  final count = int.parse(v.choice('beamCount'));
  final deck = int.parse(v.choice('deckThickness'));
  final height = v.number('heightAbove');
  final railing = v.toggle('railing');

  final tributary = count == 2 ? width / 2 : width / (count - 1);
  final deckLoad = deck / 1000 * 4.2;
  BeamCheck check(TimberSection s) => checkBeam(
    section: s,
    spanM: span,
    gK: deckLoad * tributary + (railing ? 0.15 : 0),
    qK: _crowd * tributary,
    exposure: Exposure.outdoor,
  );
  final result = check(section);
  final better = _beamSections
      .map(TimberSection.parse)
      .where((s) => s.h * s.b > section.h * section.b && check(s).ok)
      .firstOrNull;
  final deckSpacing = width / (count - 1);
  final maxDeck = _deckSpan[deck]!;
  final neededBeams = _pcs(width / maxDeck) + 1;
  final overSpan = span > bridgeSpanLimit;
  final tooHigh = height > bridgeHeightLimit;

  final findings = <Finding>[
    if (overSpan)
      Finding(FindingCode.bridgeSpanOverLimit, FindingSeverity.danger, {
        'limit': bridgeSpanLimit,
      }),
    if (!result.ok)
      Finding(FindingCode.bridgeBeamFails, FindingSeverity.danger, {
        'percent': (result.utilization * 100).round(),
        'section': ?better?.key,
      }),
    if (tooHigh)
      Finding(FindingCode.bridgeTooHigh, FindingSeverity.danger, {
        'limit': bridgeHeightLimit,
      }),
    if (height > 0.5 && !railing)
      const Finding(FindingCode.bridgeNeedsRailing, FindingSeverity.warning),
    if (width < 0.6)
      const Finding(FindingCode.bridgeNarrow, FindingSeverity.warning),
    if (deckSpacing > maxDeck)
      Finding(FindingCode.bridgeDeckSpan, FindingSeverity.warning, {
        'beams': neededBeams,
      }),
  ];

  const boardWidth = 0.145;
  const gap = 0.008;
  final boards = _pcs(span / (boardWidth + gap));
  final beamLength = span + 0.6;
  final beamMaterial = switch (section.key) {
    '100x100' => BuildMaterial.beam100x100,
    '80x160' => BuildMaterial.beam80x160,
    '100x200' => BuildMaterial.beam100x200,
    '120x240' => BuildMaterial.beam120x240,
    _ => BuildMaterial.beam140x280,
  };
  final deckMaterial = switch (deck) {
    28 => BuildMaterial.deck28,
    32 => BuildMaterial.deck32,
    _ => BuildMaterial.deck40,
  };
  final woodArea =
      span * width * 2 +
      count * beamLength * 2 * (section.b + section.h) / 1000;
  final bom = [
    BomLine(beamMaterial, _up(count * beamLength, 0.1)),
    BomLine(deckMaterial, _up(boards * width, 0.1)),
    BomLine(BuildMaterial.screws, (boards * count * 2).toDouble()),
    BomLine(BuildMaterial.concreteBag, (count * 2 * 2).toDouble()),
    if (railing) BomLine(BuildMaterial.railing, _up(2 * span, 0.1)),
    BomLine(BuildMaterial.woodOil, _liters(woodArea)),
  ];

  // Půdorys: voda pod mostkem, nosníky (přesahují na břehy), prkna.
  final s = span * 100;
  final w = width * 100;
  const bank = 30.0;
  final shapes = <DrawShape>[
    DrawRect(bank, -15, s, w + 30, DrawStyle.water),
    for (final y in _positions(w - section.b / 10, count - 2))
      DrawRect(0, y, s + 2 * bank, section.b / 10, DrawStyle.post),
    for (var i = 0; i < boards; i++)
      DrawRect(
        bank + i * (boardWidth + gap) * 100,
        0,
        math.min(boardWidth * 100, s - i * (boardWidth + gap) * 100),
        w,
        DrawStyle.wood,
      ),
    if (railing) ...[
      DrawLine(bank, 0, bank + s, 0),
      DrawLine(bank, w, bank + s, w),
    ],
    DrawDimension(bank, w + 35, bank + s, w + 35, span),
    DrawDimension(s + 2 * bank + 20, 0, s + 2 * bank + 20, w, width),
  ];
  return BuildPlan(
    drawing: Drawing(DrawingView.top, shapes),
    bom: bom,
    findings: findings,
    summary: {SummaryKey.beamUtilization: (result.utilization * 100).round()},
    engineerRecommended: overSpan || tooHigh,
  );
}

// ---------------------------------------------------------------------------
// Přístřešek s pultovou střechou

/// Charakteristické zatížení sněhem podle sněhové oblasti (kN/m²).
const _snow = {'I': 0.7, 'II': 1.0, 'III': 1.5, 'IV': 2.0, 'V': 2.5};

const _rafterSections = ['60x120', '80x160', '100x200'];
const _headerSections = ['100x200', '120x240', '140x280'];

/// Plocha, nad kterou stavba obvykle potřebuje povolení (orientačně).
const shelterPermitArea = 25.0;

BuildPlan planShelter(BuildValues v) {
  final width = v.number('width');
  final depth = v.number('depth');
  final height = v.number('height');
  final poly = v.choice('roofing') == 'polycarbonate';
  final rafter = TimberSection.parse(v.choice('rafterSection'));
  final post = TimberSection.parse(v.choice('postSection'));
  final snow = 0.8 * _snow[v.choice('snowRegion')]!;
  final roofLoad = poly ? 0.05 : 0.08;

  final fall = math.max(0.15, depth * 0.1);
  final backHeight = height - fall;
  final rafters = _pcs(width / (poly ? 0.7 : 0.9)) + 1;
  final rafterSpacing = width / (rafters - 1);
  BeamCheck rafterCheck(TimberSection s) => checkBeam(
    section: s,
    spanM: depth,
    gK: roofLoad * rafterSpacing,
    qK: snow * rafterSpacing,
    exposure: Exposure.covered,
    deflectionRatio: 200,
  );
  final rafterResult = rafterCheck(rafter);
  final betterRafter = _rafterSections
      .map(TimberSection.parse)
      .where((s) => s.b * s.h > rafter.b * rafter.h && rafterCheck(s).ok)
      .firstOrNull;

  // Vaznice nese polovinu střechy; nejmenší vyhovující průřez, jinak
  // víc sloupků (nejméně 1 m od sebe).
  final headerG = (roofLoad + rafter.selfWeight / rafterSpacing) * depth / 2;
  final headerQ = snow * depth / 2;
  final initialPosts = _pcs(width / 2.5) + 1;
  var posts = initialPosts;
  TimberSection? header;
  while (header == null && width / (posts - 1) >= 1.0) {
    final spacing = width / (posts - 1);
    header = _headerSections
        .map(TimberSection.parse)
        .where(
          (s) => checkBeam(
            section: s,
            spanM: spacing,
            gK: headerG,
            qK: headerQ,
            exposure: Exposure.covered,
            deflectionRatio: 200,
          ).ok,
        )
        .firstOrNull;
    if (header == null) posts++;
  }
  header ??= TimberSection.parse(_headerSections.last);
  final postSpacing = width / (posts - 1);

  final findings = <Finding>[
    if (!rafterResult.ok)
      Finding(FindingCode.shelterRafterFails, FindingSeverity.danger, {
        'percent': (rafterResult.utilization * 100).round(),
        'section': ?betterRafter?.key,
      }),
    if (width / (posts - 1) < 1.0)
      const Finding(FindingCode.shelterHeaderFails, FindingSeverity.danger),
    if (posts > initialPosts)
      Finding(FindingCode.shelterHeaderPosts, FindingSeverity.info, {
        'spacing': postSpacing,
      }),
    if (width * depth > shelterPermitArea)
      const Finding(FindingCode.shelterPermit, FindingSeverity.info, {
        'area': shelterPermitArea,
      }),
    const Finding(FindingCode.shelterAnchoring, FindingSeverity.info),
  ];

  final rafterLength = math.sqrt(depth * depth + fall * fall) + 0.4;
  final roofArea = (width + 0.4) * rafterLength;
  final headerLength = width + 0.4;
  final postMaterial = post.b == 100
      ? BuildMaterial.post100
      : BuildMaterial.post120;
  final rafterMaterial = switch (rafter.key) {
    '60x120' => BuildMaterial.beam60x120,
    '80x160' => BuildMaterial.beam80x160,
    _ => BuildMaterial.beam100x200,
  };
  final headerMaterial = switch (header.key) {
    '100x200' => BuildMaterial.beam100x200,
    '120x240' => BuildMaterial.beam120x240,
    _ => BuildMaterial.beam140x280,
  };
  final woodArea =
      posts * (height + backHeight) * 4 * post.b / 1000 +
      2 * headerLength * 2 * (header.b + header.h) / 1000 +
      rafters * rafterLength * 2 * (rafter.b + rafter.h) / 1000;
  final bom = [
    BomLine(postMaterial, _up(posts * (height + backHeight), 0.1)),
    BomLine(headerMaterial, _up(2 * headerLength, 0.1)),
    BomLine(rafterMaterial, _up(rafters * rafterLength, 0.1)),
    BomLine(
      poly ? BuildMaterial.polycarbonate : BuildMaterial.metalSheet,
      _up(roofArea * 1.05, 0.1),
    ),
    BomLine(BuildMaterial.roofScrews, _pcs(roofArea * 6).toDouble()),
    BomLine(BuildMaterial.postAnchor, (2 * posts).toDouble()),
    BomLine(BuildMaterial.concreteBag, (2 * posts * 3).toDouble()),
    BomLine(BuildMaterial.screws, (rafters * 4 + 2 * posts * 4).toDouble()),
    BomLine(BuildMaterial.woodOil, _liters(woodArea)),
  ];

  // Půdorys: obrys střechy s přesahem, krokve, vaznice a sloupky.
  final w = width * 100;
  final d = depth * 100;
  const over = 20.0;
  final p = post.b / 10;
  final shapes = <DrawShape>[
    DrawRect(0, 0, w + 2 * over, d + 2 * over, DrawStyle.roof),
    for (final x in _positions(w, rafters - 2))
      DrawLine(over + x, 0, over + x, d + 2 * over, dashed: true),
    for (final y in [over, over + d - header.b / 10])
      DrawRect(0, y, w + 2 * over, header.b / 10, DrawStyle.wood),
    for (final x in _positions(w - p, posts - 2))
      for (final y in [over, over + d - p])
        DrawRect(over + x, y, p, p, DrawStyle.post),
    DrawDimension(over, d + 2 * over + 25, over + w, d + 2 * over + 25, width),
    DrawDimension(w + 2 * over + 25, over, w + 2 * over + 25, over + d, depth),
  ];
  return BuildPlan(
    drawing: Drawing(DrawingView.top, shapes),
    bom: bom,
    findings: findings,
    summary: {
      SummaryKey.postSpacing: postSpacing,
      SummaryKey.rafterUtilization: (rafterResult.utilization * 100).round(),
      SummaryKey.headerSection: header.key,
      SummaryKey.roofArea: roofArea,
      SummaryKey.backHeight: backHeight,
    },
  );
}
