import 'package:equatable/equatable.dart';

/// Jednotka položky výkazu materiálu.
enum BomUnit { m, m2, m3, t, pcs, l }

/// Materiál ve výkazu. Výchozí ceny jsou orientační ceny s DPH v Kč
/// (podzim 2026); uživatel je v návrhu přepíše skutečnými (DECLOG D90).
enum BuildMaterial {
  board25(BomUnit.m, 70),
  board32(BomUnit.m, 95),
  board40(BomUnit.m, 125),
  post50(BomUnit.m, 45),
  post70(BomUnit.m, 75),
  post100(BomUnit.m, 150),
  post120(BomUnit.m, 210),
  beam60x120(BomUnit.m, 120),
  beam80x160(BomUnit.m, 200),
  beam100x100(BomUnit.m, 150),
  beam100x200(BomUnit.m, 320),
  beam120x240(BomUnit.m, 480),
  beam140x280(BomUnit.m, 650),
  deck28(BomUnit.m, 120),
  deck32(BomUnit.m, 145),
  deck40(BomUnit.m, 185),
  screws(BomUnit.pcs, 2),
  tieRod(BomUnit.pcs, 90),
  moleMesh(BomUnit.m2, 60),
  liner(BomUnit.m2, 40),
  fill(BomUnit.m3, 900),
  woodOil(BomUnit.l, 400),
  gravel032(BomUnit.t, 450),
  chippings816(BomUnit.t, 550),
  chippings48(BomUnit.t, 600),
  geotextile(BomUnit.m2, 25),
  pavers(BomUnit.m2, 380),
  steppingStone(BomUnit.pcs, 150),
  mulch(BomUnit.m3, 700),
  edging(BomUnit.m, 120),
  concreteBag(BomUnit.pcs, 120),
  railing(BomUnit.m, 350),
  postAnchor(BomUnit.pcs, 250),
  polycarbonate(BomUnit.m2, 450),
  metalSheet(BomUnit.m2, 300),
  roofScrews(BomUnit.pcs, 6);

  const BuildMaterial(this.unit, this.defaultPrice);

  final BomUnit unit;

  /// Kč za jednotku.
  final double defaultPrice;

  static BuildMaterial? fromKey(String key) =>
      values.where((m) => m.name == key).firstOrNull;
}

class BomLine extends Equatable {
  const BomLine(this.material, this.quantity);

  final BuildMaterial material;
  final double quantity;

  @override
  List<Object?> get props => [material, quantity];
}

enum FindingSeverity { info, warning, danger }

/// Co mantinely (FR-G2) našly. Text skládá prezentační vrstva podle
/// [code] a [values]; doporučení je součástí textu.
enum FindingCode {
  // Záhon
  bedTooWide,
  bedThinBoards,
  bedMidPosts,
  bedTieRods,
  bedTallFill,
  // Chodník
  pathNarrow,
  pathPaversNeedEdging,
  pathGravelEdging,
  pathSteppingWide,
  pathMulchTopUp,
  // Mostek
  bridgeBeamFails,
  bridgeSpanOverLimit,
  bridgeTooHigh,
  bridgeNeedsRailing,
  bridgeNarrow,
  bridgeDeckSpan,
  // Přístřešek
  shelterRafterFails,
  shelterHeaderPosts,
  shelterHeaderFails,
  shelterPermit,
  shelterAnchoring,
}

class Finding extends Equatable {
  const Finding(this.code, this.severity, [this.values = const {}]);

  final FindingCode code;
  final FindingSeverity severity;
  final Map<String, Object> values;

  @override
  List<Object?> get props => [code, severity, values];
}

/// Výplň tvaru ve výkresu.
enum DrawStyle {
  outline,
  wood,
  post,
  soil,
  gravel,
  chippings,
  paver,
  mulch,
  fabric,
  roof,
  water,
}

sealed class DrawShape {
  const DrawShape();
}

/// Obdélník v centimetrech (y roste dolů).
class DrawRect extends DrawShape {
  const DrawRect(this.x, this.y, this.w, this.h, this.style);

  final double x;
  final double y;
  final double w;
  final double h;
  final DrawStyle style;
}

class DrawLine extends DrawShape {
  const DrawLine(this.x1, this.y1, this.x2, this.y2, {this.dashed = false});

  final double x1;
  final double y1;
  final double x2;
  final double y2;
  final bool dashed;
}

/// Kótovací čára s délkou v metrech.
class DrawDimension extends DrawShape {
  const DrawDimension(this.x1, this.y1, this.x2, this.y2, this.meters);

  final double x1;
  final double y1;
  final double x2;
  final double y2;
  final double meters;
}

enum DrawingView { top, section }

/// Výkres v 2D: půdorys, u chodníku příčný řez.
class Drawing {
  const Drawing(this.view, this.shapes);

  final DrawingView view;
  final List<DrawShape> shapes;

  /// Rozsah všech tvarů v centimetrech: (minX, minY, maxX, maxY).
  (double, double, double, double) get bounds {
    var minX = double.infinity;
    var minY = double.infinity;
    var maxX = double.negativeInfinity;
    var maxY = double.negativeInfinity;
    void add(double x, double y) {
      if (x < minX) minX = x;
      if (y < minY) minY = y;
      if (x > maxX) maxX = x;
      if (y > maxY) maxY = y;
    }

    for (final shape in shapes) {
      switch (shape) {
        case DrawRect(:final x, :final y, :final w, :final h):
          add(x, y);
          add(x + w, y + h);
        case DrawLine(:final x1, :final y1, :final x2, :final y2):
        case DrawDimension(:final x1, :final y1, :final x2, :final y2):
          add(x1, y1);
          add(x2, y2);
      }
    }
    return shapes.isEmpty ? (0, 0, 1, 1) : (minX, minY, maxX, maxY);
  }
}

/// Klíčové údaje návrhu pro shrnutí („náplň 1,2 m³“).
enum SummaryKey {
  fillVolume,
  boardRows,
  excavation,
  beamUtilization,
  postSpacing,
  rafterUtilization,
  headerSection,
  roofArea,
  backHeight,
}

/// Výsledek výpočtu šablony.
class BuildPlan {
  const BuildPlan({
    required this.drawing,
    required this.bom,
    required this.findings,
    this.summary = const {},
    this.engineerRecommended = false,
  });

  final Drawing drawing;
  final List<BomLine> bom;
  final List<Finding> findings;
  final Map<SummaryKey, Object> summary;

  /// Konstrukce nese osoby nad stanovenou mez (FR-G3).
  final bool engineerRecommended;

  bool get hasDanger =>
      findings.any((f) => f.severity == FindingSeverity.danger);

  /// Cena položky: uživatelova, jinak výchozí.
  static double priceOf(BuildMaterial m, Map<String, double> prices) =>
      prices[m.name] ?? m.defaultPrice;

  /// Rozpočet v Kč.
  double total(Map<String, double> prices) => bom.fold(
    0,
    (sum, line) => sum + line.quantity * priceOf(line.material, prices),
  );
}
