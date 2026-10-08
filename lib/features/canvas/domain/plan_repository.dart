import 'package:equatable/equatable.dart';

import 'geometry.dart';

/// Podklad plánu (FR-P3): obrázek vložený uživatelem. Jen v tomto
/// telefonu, nesynchronizuje se (DECLOG D78).
class PlanBackground extends Equatable {
  const PlanBackground({
    required this.path,
    required this.widthPx,
    required this.heightPx,
    required this.metersPerPixel,
    this.origin = const Pt(0, 0),
  });

  /// Cesta relativní ke složce aplikace (jako u fotek).
  final String path;
  final int widthPx;
  final int heightPx;

  /// Měřítko obrázku; mění ho kalibrace.
  final double metersPerPixel;

  /// Kde na plánu leží levý horní roh obrázku.
  final Pt origin;

  double get widthM => widthPx * metersPerPixel;
  double get heightM => heightPx * metersPerPixel;

  /// Kalibrace posune a zvětší obrázek stejně jako plán.
  PlanBackground scaled(Pt center, double k) => PlanBackground(
    path: path,
    widthPx: widthPx,
    heightPx: heightPx,
    metersPerPixel: metersPerPixel * k,
    origin: center + (origin - center) * k,
  );

  Map<String, Object?> toJson() => {
    'path': path,
    'widthPx': widthPx,
    'heightPx': heightPx,
    'metersPerPixel': metersPerPixel,
    'origin': origin.toJson(),
  };

  static PlanBackground? fromJson(Object? json) {
    if (json is! Map) return null;
    final path = json['path'];
    final w = json['widthPx'];
    final h = json['heightPx'];
    final mpp = json['metersPerPixel'];
    if (path is! String || w is! num || h is! num || mpp is! num || mpp <= 0) {
      return null;
    }
    return PlanBackground(
      path: path,
      widthPx: w.toInt(),
      heightPx: h.toInt(),
      metersPerPixel: mpp.toDouble(),
      origin: Pt.fromJson(json['origin']) ?? const Pt(0, 0),
    );
  }

  @override
  List<Object?> get props => [path, widthPx, heightPx, metersPerPixel, origin];
}

/// Obrys zahrady (`gardens.bounds`) a podklad plánu.
abstract interface class PlanRepository {
  Future<List<Pt>> loadOutline();
  Future<void> saveOutline(List<Pt> outline);
  Future<PlanBackground?> loadBackground();
  Future<void> saveBackground(PlanBackground? background);
}
