import 'dart:math' as math;

import 'package:equatable/equatable.dart';
import 'package:turf/boolean.dart' as turf;

/// Bod plánu zahrady v lokálních souřadnicích v metrech (rovina, osa y
/// dolů jako na obrazovce). Spec 5.1: plochy a délky počítá vlastní kód,
/// rovinné predikáty balíček `turf`.
class Pt extends Equatable {
  const Pt(this.x, this.y);

  final double x;
  final double y;

  Pt operator +(Pt o) => Pt(x + o.x, y + o.y);
  Pt operator -(Pt o) => Pt(x - o.x, y - o.y);
  Pt operator *(double k) => Pt(x * k, y * k);

  double distanceTo(Pt o) =>
      math.sqrt(math.pow(x - o.x, 2) + math.pow(y - o.y, 2));

  /// Uložení na centimetry (víc přesnosti zahrada nepotřebuje).
  List<double> toJson() => [_cm(x), _cm(y)];

  static Pt? fromJson(Object? json) {
    if (json is! List || json.length < 2) return null;
    final x = json[0];
    final y = json[1];
    if (x is! num || y is! num) return null;
    return Pt(x.toDouble(), y.toDouble());
  }

  @override
  List<Object?> get props => [x, y];

  @override
  String toString() => 'Pt($x, $y)';
}

double _cm(double v) => (v * 100).roundToDouble() / 100;

/// Mnohoúhelník jako JSON `[[x, y], ...]`.
List<List<double>> polygonToJson(List<Pt> polygon) => [
  for (final p in polygon) p.toJson(),
];

/// Mnohoúhelník z JSONu; null, když JSON není seznam aspoň tří bodů.
List<Pt>? polygonFromJson(Object? json) {
  if (json is! List) return null;
  final points = [for (final p in json) ?Pt.fromJson(p)];
  return points.length >= 3 ? points : null;
}

/// Výměra mnohoúhelníku v m² (shoelace, nezáleží na směru obcházení).
double polygonArea(List<Pt> polygon) {
  if (polygon.length < 3) return 0;
  var twice = 0.0;
  for (var i = 0; i < polygon.length; i++) {
    final a = polygon[i];
    final b = polygon[(i + 1) % polygon.length];
    twice += a.x * b.y - b.x * a.y;
  }
  return twice.abs() / 2;
}

/// Obvod uzavřeného mnohoúhelníku v metrech.
double polygonPerimeter(List<Pt> polygon) {
  if (polygon.length < 2) return 0;
  var sum = 0.0;
  for (var i = 0; i < polygon.length; i++) {
    sum += polygon[i].distanceTo(polygon[(i + 1) % polygon.length]);
  }
  return sum;
}

/// Těžiště plochy (pro popisek zóny); u degenerovaného tvaru průměr bodů.
Pt polygonCentroid(List<Pt> polygon) {
  var a = 0.0;
  var cx = 0.0;
  var cy = 0.0;
  for (var i = 0; i < polygon.length; i++) {
    final p = polygon[i];
    final q = polygon[(i + 1) % polygon.length];
    final cross = p.x * q.y - q.x * p.y;
    a += cross;
    cx += (p.x + q.x) * cross;
    cy += (p.y + q.y) * cross;
  }
  if (a.abs() < 1e-9) {
    final n = polygon.isEmpty ? 1 : polygon.length;
    return Pt(
      polygon.fold(0.0, (s, p) => s + p.x) / n,
      polygon.fold(0.0, (s, p) => s + p.y) / n,
    );
  }
  return Pt(cx / (3 * a), cy / (3 * a));
}

/// Přitáhne bod k mřížce s krokem [grid] metrů (FR-P1).
Pt snapToGrid(Pt p, double grid) => grid <= 0
    ? p
    : Pt(
        (p.x / grid).roundToDouble() * grid,
        (p.y / grid).roundToDouble() * grid,
      );

/// Index nejbližšího bodu do vzdálenosti [tolerance]; jinak null.
int? nearestVertex(List<Pt> polygon, Pt p, double tolerance) {
  int? best;
  var bestDistance = tolerance;
  for (var i = 0; i < polygon.length; i++) {
    final d = polygon[i].distanceTo(p);
    if (d <= bestDistance) {
      best = i;
      bestDistance = d;
    }
  }
  return best;
}

/// Středy hran; klepnutím na střed se přidá nový uzel (FR-P1).
List<Pt> edgeMidpoints(List<Pt> polygon) => [
  for (var i = 0; i < polygon.length; i++)
    (polygon[i] + polygon[(i + 1) % polygon.length]) * 0.5,
];

/// Mnohoúhelník je použitelný: aspoň 3 uzly a nenulová plocha.
bool isUsablePolygon(List<Pt> polygon) =>
    polygon.length >= 3 && polygonArea(polygon) >= 0.01;

turf.Polygon _turf(List<Pt> polygon) => turf.Polygon(
  coordinates: [
    [
      for (final p in polygon) turf.Position(p.x, p.y),
      turf.Position(polygon.first.x, polygon.first.y),
    ],
  ],
);

/// Bod leží uvnitř mnohoúhelníku nebo na jeho hraně.
bool polygonContainsPoint(List<Pt> polygon, Pt p) =>
    polygon.length >= 3 &&
    turf.booleanPointInPolygon(turf.Position(p.x, p.y), _turf(polygon));

/// Celý mnohoúhelník [inner] leží uvnitř [outer] (zóna v obrysu, FR-P4).
bool polygonWithin(List<Pt> inner, List<Pt> outer) =>
    inner.length >= 3 &&
    outer.length >= 3 &&
    turf.booleanWithin(_turf(inner), _turf(outer));

/// Změna měřítka kolem bodu [center] koeficientem [k].
List<Pt> scalePolygon(List<Pt> polygon, Pt center, double k) => [
  for (final p in polygon) center + (p - center) * k,
];

/// Koeficient kalibrace (FR-P2): nakreslená délka → skutečná délka.
double calibrationFactor({required double drawn, required double real}) {
  if (drawn <= 0 || real <= 0) {
    throw ArgumentError('Délky musí být kladné.');
  }
  return real / drawn;
}

/// Odchylka kontrolní vzdálenosti v procentech (FR-P2).
double deviationPercent({required double measured, required double real}) =>
    real <= 0 ? 0 : ((measured - real).abs() / real) * 100;

/// Nad tuto odchylku je podklad zkreslený (FR-P2).
const maxCalibrationDeviationPercent = 5.0;
