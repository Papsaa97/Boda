import '../../../core/text/numbers.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/build_params.dart';
import '../domain/build_plan.dart';

String templateLabel(AppLocalizations l, BuildTemplate t) => switch (t) {
  BuildTemplate.raisedBed => l.buildTemplateRaisedBed,
  BuildTemplate.path => l.buildTemplatePath,
  BuildTemplate.bridge => l.buildTemplateBridge,
  BuildTemplate.shelter => l.buildTemplateShelter,
};

String templateHint(AppLocalizations l, BuildTemplate t) => switch (t) {
  BuildTemplate.raisedBed => l.buildTemplateRaisedBedHint,
  BuildTemplate.path => l.buildTemplatePathHint,
  BuildTemplate.bridge => l.buildTemplateBridgeHint,
  BuildTemplate.shelter => l.buildTemplateShelterHint,
};

String paramLabel(AppLocalizations l, BuildTemplate t, String key) =>
    switch (key) {
      'length' => l.buildParamLength,
      'width' => l.buildParamWidth,
      'height' when t == BuildTemplate.shelter => l.buildParamFrontHeight,
      'height' => l.buildParamHeight,
      'boardThickness' => l.buildParamBoardThickness,
      'moleMesh' => l.buildParamMoleMesh,
      'liner' => l.buildParamLiner,
      'surface' => l.buildParamSurface,
      'edging' => l.buildParamEdging,
      'span' => l.buildParamSpan,
      'beamSection' => l.buildParamBeamSection,
      'beamCount' => l.buildParamBeamCount,
      'deckThickness' => l.buildParamDeckThickness,
      'heightAbove' => l.buildParamHeightAbove,
      'railing' => l.buildParamRailing,
      'depth' => l.buildParamDepth,
      'roofing' => l.buildParamRoofing,
      'rafterSection' => l.buildParamRafterSection,
      'postSection' => l.buildParamPostSection,
      'snowRegion' => l.buildParamSnowRegion,
      _ => key,
    };

/// „100x200“ → „100 × 200“.
String sectionText(String key) => key.replaceAll('x', ' × ');

String optionLabel(AppLocalizations l, String key, String option) =>
    switch (key) {
      'boardThickness' || 'deckThickness' => l.buildOptionMm(option),
      'beamSection' ||
      'rafterSection' ||
      'postSection' => l.buildOptionSection(sectionText(option)),
      _ => switch (option) {
        'gravel' => l.buildOptionGravel,
        'pavers' => l.buildOptionPavers,
        'stepping' => l.buildOptionStepping,
        'mulch' => l.buildOptionMulch,
        'polycarbonate' => l.buildOptionPolycarbonate,
        'metalSheet' => l.buildOptionMetalSheet,
        _ => option,
      },
    };

String unitLabel(AppLocalizations l, BomUnit u) => switch (u) {
  BomUnit.m => l.buildUnitM,
  BomUnit.m2 => l.buildUnitM2,
  BomUnit.m3 => l.buildUnitM3,
  BomUnit.t => l.buildUnitT,
  BomUnit.pcs => l.buildUnitPcs,
  BomUnit.l => l.buildUnitL,
};

String materialLabel(AppLocalizations l, BuildMaterial m) => switch (m) {
  BuildMaterial.board25 => l.buildMaterialBoard25,
  BuildMaterial.board32 => l.buildMaterialBoard32,
  BuildMaterial.board40 => l.buildMaterialBoard40,
  BuildMaterial.post50 => l.buildMaterialPost50,
  BuildMaterial.post70 => l.buildMaterialPost70,
  BuildMaterial.post100 => l.buildMaterialPost100,
  BuildMaterial.post120 => l.buildMaterialPost120,
  BuildMaterial.beam60x120 => l.buildMaterialBeam(sectionText('60x120')),
  BuildMaterial.beam80x160 => l.buildMaterialBeam(sectionText('80x160')),
  BuildMaterial.beam100x100 => l.buildMaterialBeam(sectionText('100x100')),
  BuildMaterial.beam100x200 => l.buildMaterialBeam(sectionText('100x200')),
  BuildMaterial.beam120x240 => l.buildMaterialBeam(sectionText('120x240')),
  BuildMaterial.beam140x280 => l.buildMaterialBeam(sectionText('140x280')),
  BuildMaterial.deck28 => l.buildMaterialDeck('28'),
  BuildMaterial.deck32 => l.buildMaterialDeck('32'),
  BuildMaterial.deck40 => l.buildMaterialDeck('40'),
  BuildMaterial.screws => l.buildMaterialScrews,
  BuildMaterial.tieRod => l.buildMaterialTieRod,
  BuildMaterial.moleMesh => l.buildMaterialMoleMesh,
  BuildMaterial.liner => l.buildMaterialLiner,
  BuildMaterial.fill => l.buildMaterialFill,
  BuildMaterial.woodOil => l.buildMaterialWoodOil,
  BuildMaterial.gravel032 => l.buildMaterialGravel032,
  BuildMaterial.chippings816 => l.buildMaterialChippings816,
  BuildMaterial.chippings48 => l.buildMaterialChippings48,
  BuildMaterial.geotextile => l.buildMaterialGeotextile,
  BuildMaterial.pavers => l.buildMaterialPavers,
  BuildMaterial.steppingStone => l.buildMaterialSteppingStone,
  BuildMaterial.mulch => l.buildMaterialMulch,
  BuildMaterial.edging => l.buildMaterialEdging,
  BuildMaterial.concreteBag => l.buildMaterialConcreteBag,
  BuildMaterial.railing => l.buildMaterialRailing,
  BuildMaterial.postAnchor => l.buildMaterialPostAnchor,
  BuildMaterial.polycarbonate => l.buildMaterialPolycarbonate,
  BuildMaterial.metalSheet => l.buildMaterialMetalSheet,
  BuildMaterial.roofScrews => l.buildMaterialRoofScrews,
};

String _m(Object? v) => formatDecimal(v as num);

String findingText(AppLocalizations l, Finding f) {
  final v = f.values;
  return switch (f.code) {
    FindingCode.bedTooWide => l.buildFindingBedTooWide(_m(v['width'])),
    FindingCode.bedThinBoards => l.buildFindingBedThinBoards,
    FindingCode.bedMidPosts => l.buildFindingBedMidPosts(
      v['count']! as int,
      _m(v['spacing']),
    ),
    FindingCode.bedTieRods => l.buildFindingBedTieRods(v['count']! as int),
    FindingCode.bedTallFill => l.buildFindingBedTallFill,
    FindingCode.pathNarrow => l.buildFindingPathNarrow,
    FindingCode.pathPaversNeedEdging => l.buildFindingPathPaversNeedEdging,
    FindingCode.pathGravelEdging => l.buildFindingPathGravelEdging,
    FindingCode.pathSteppingWide => l.buildFindingPathSteppingWide,
    FindingCode.pathMulchTopUp => l.buildFindingPathMulchTopUp,
    FindingCode.bridgeBeamFails => switch (v['section']) {
      final String s => l.buildFindingBridgeBeamFails(
        v['percent']! as int,
        sectionText(s),
      ),
      _ => l.buildFindingBridgeBeamFailsNoSection(v['percent']! as int),
    },
    FindingCode.bridgeSpanOverLimit => l.buildFindingBridgeSpanOverLimit(
      _m(v['limit']),
    ),
    FindingCode.bridgeTooHigh => l.buildFindingBridgeTooHigh(_m(v['limit'])),
    FindingCode.bridgeNeedsRailing => l.buildFindingBridgeNeedsRailing,
    FindingCode.bridgeNarrow => l.buildFindingBridgeNarrow,
    FindingCode.bridgeDeckSpan => l.buildFindingBridgeDeckSpan(
      v['beams'] as int,
    ),
    FindingCode.shelterRafterFails => switch (v['section']) {
      final String s => l.buildFindingShelterRafterFails(
        v['percent']! as int,
        sectionText(s),
      ),
      _ => l.buildFindingShelterRafterFailsNoSection(v['percent']! as int),
    },
    FindingCode.shelterHeaderFails => l.buildFindingShelterHeaderFails,
    FindingCode.shelterHeaderPosts => l.buildFindingShelterHeaderPosts(
      _m(v['spacing']),
    ),
    FindingCode.shelterPermit => l.buildFindingShelterPermit(_m(v['area'])),
    FindingCode.shelterAnchoring => l.buildFindingShelterAnchoring,
  };
}

/// Řádky shrnutí návrhu v pořadí, jak je výpočet vrátil.
List<String> summaryLines(AppLocalizations l, BuildPlan plan) {
  final s = plan.summary;
  return [
    if (s[SummaryKey.boardRows] case final int rows)
      l.buildSummaryRows(rows, formatDecimal(rows * 0.145)),
    if (s[SummaryKey.fillVolume] case final num v)
      l.buildSummaryFill(formatDecimal(v)),
    if (s[SummaryKey.excavation] case final num v)
      l.buildSummaryExcavation(formatDecimal(v)),
    if (s[SummaryKey.beamUtilization] case final int p) l.buildSummaryBeam(p),
    if (s[SummaryKey.rafterUtilization] case final int p)
      l.buildSummaryRafter(p),
    if ((s[SummaryKey.postSpacing], s[SummaryKey.headerSection]) case (
      final num spacing,
      final String section,
    ))
      l.buildSummaryPosts(formatDecimal(spacing), sectionText(section)),
    if ((s[SummaryKey.roofArea], s[SummaryKey.backHeight]) case (
      final num area,
      final num back,
    ))
      l.buildSummaryRoof(
        formatDecimal(area, maxFractionDigits: 1),
        formatDecimal(back),
      ),
  ];
}
