import 'package:equatable/equatable.dart';

import '../../zones/domain/zone_entity.dart';
import 'geometry.dart';

/// Tvar zóny na plánu.
class ZoneShape extends Equatable {
  const ZoneShape(this.polygon, {this.layer = ZoneLayer.reality});

  final List<Pt> polygon;
  final ZoneLayer layer;

  double get area => polygonArea(polygon);

  ZoneShape copyWith({List<Pt>? polygon, ZoneLayer? layer}) =>
      ZoneShape(polygon ?? this.polygon, layer: layer ?? this.layer);

  @override
  List<Object?> get props => [polygon, layer];
}

/// Plán zahrady: obrys a tvary zón (stav pro zpět/znovu, FR-P6).
class PlanDocument extends Equatable {
  const PlanDocument({this.outline = const [], this.shapes = const {}});

  /// Obrys zahrady; prázdný = ještě nenakreslený.
  final List<Pt> outline;

  /// Tvary podle id zóny (stejné `zoneId` jako v seznamu zón).
  final Map<String, ZoneShape> shapes;

  bool get hasOutline => outline.length >= 3;

  PlanDocument withOutline(List<Pt> outline) =>
      PlanDocument(outline: outline, shapes: shapes);

  PlanDocument withShape(String zoneId, ZoneShape? shape) => PlanDocument(
    outline: outline,
    shapes: {
      for (final e in shapes.entries)
        if (e.key != zoneId) e.key: e.value,
      if (shape != null) zoneId: shape,
    },
  );

  /// Kalibrace: celý plán se přepočte kolem [center] koeficientem [k].
  PlanDocument scaled(Pt center, double k) => PlanDocument(
    outline: scalePolygon(outline, center, k),
    shapes: {
      for (final e in shapes.entries)
        e.key: e.value.copyWith(
          polygon: scalePolygon(e.value.polygon, center, k),
        ),
    },
  );

  /// Všechny body plánu (pro velikost plátna).
  Iterable<Pt> get allPoints sync* {
    yield* outline;
    for (final s in shapes.values) {
      yield* s.polygon;
    }
  }

  @override
  List<Object?> get props => [outline, shapes];
}

/// Obrys zahrady jako `gardens.bounds`: `{"outline": [[x, y], ...]}`.
Map<String, Object?> outlineToBounds(List<Pt> outline) => {
  'outline': polygonToJson(outline),
};

List<Pt> outlineFromBounds(Object? bounds) =>
    bounds is Map ? polygonFromJson(bounds['outline']) ?? const [] : const [];
