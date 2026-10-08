import 'package:flutter/material.dart';

import '../../../core/text/numbers.dart';
import '../../zones/domain/zone_entity.dart';
import '../domain/geometry.dart';
import 'canvas_controller.dart';

/// Pixelů na metr při zvětšení 1 (InteractiveViewer zvětšuje dál).
const pixelsPerMeter = 24.0;

/// Výřez plánu v metrech: levý horní roh a velikost. Plátno je vždy
/// aspoň 60 × 40 m a roste s nakresleným plánem.
class PlanFrame {
  const PlanFrame(this.origin, this.width, this.height);

  factory PlanFrame.of(CanvasState s) {
    final points = [
      ...s.doc.allPoints,
      ...s.draft,
      if (s.background case final b?) ...[
        b.origin,
        b.origin + Pt(b.widthM, b.heightM),
      ],
    ];
    double floor10(double v) => (v / 10).floorToDouble() * 10;
    double ceil10(double v) => (v / 10).ceilToDouble() * 10;
    var minX = 0.0, minY = 0.0, maxX = 60.0, maxY = 40.0;
    for (final p in points) {
      if (p.x - 10 < minX) minX = floor10(p.x - 10);
      if (p.y - 10 < minY) minY = floor10(p.y - 10);
      if (p.x + 10 > maxX) maxX = ceil10(p.x + 10);
      if (p.y + 10 > maxY) maxY = ceil10(p.y + 10);
    }
    return PlanFrame(Pt(minX, minY), maxX - minX, maxY - minY);
  }

  final Pt origin;
  final double width;
  final double height;

  Size get size => Size(width * pixelsPerMeter, height * pixelsPerMeter);

  Offset toPx(Pt p) => Offset(
    (p.x - origin.x) * pixelsPerMeter,
    (p.y - origin.y) * pixelsPerMeter,
  );

  Pt toMeters(Offset o) =>
      Pt(o.dx / pixelsPerMeter + origin.x, o.dy / pixelsPerMeter + origin.y);
}

/// Barva zóny podle druhu.
Color zoneColor(ZoneType type) => switch (type) {
  ZoneType.vegetable => const Color(0xFF6A9F3A),
  ZoneType.herbs => const Color(0xFF3F8F6B),
  ZoneType.fruit => const Color(0xFFB5553C),
  ZoneType.ornamental => const Color(0xFFB0569A),
  ZoneType.lawn => const Color(0xFF8BC34A),
  ZoneType.greenhouse => const Color(0xFF4A90B8),
  ZoneType.pond => const Color(0xFF2F78C4),
  ZoneType.structure => const Color(0xFF8D7B68),
  ZoneType.other => const Color(0xFF7D8C6E),
};

/// Kreslí mřížku, obrys, zóny, rozkreslený tvar a uzly (FR-P1, P4, P5).
class PlanPainter extends CustomPainter {
  PlanPainter({
    required this.state,
    required this.frame,
    required this.zones,
    required this.scheme,
    required this.textStyle,
  });

  final CanvasState state;
  final PlanFrame frame;
  final Map<String, ZoneEntity> zones;
  final ColorScheme scheme;
  final TextStyle textStyle;

  Path _path(List<Pt> polygon, {bool close = true}) {
    final path = Path();
    for (var i = 0; i < polygon.length; i++) {
      final o = frame.toPx(polygon[i]);
      i == 0 ? path.moveTo(o.dx, o.dy) : path.lineTo(o.dx, o.dy);
    }
    if (close) path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    _grid(canvas, size);
    final doc = state.doc;
    if (doc.hasOutline) {
      final outline = _path(doc.outline);
      canvas
        ..drawPath(
          outline,
          Paint()..color = scheme.primaryContainer.withValues(alpha: 0.25),
        )
        ..drawPath(
          outline,
          Paint()
            ..color = scheme.primary
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3,
        );
    }
    // Větší tvary dospod, aby menší zůstaly klepnutelné i vidět.
    final shapes = [
      for (final e in doc.shapes.entries)
        if (state.shows(e.value.layer)) e,
    ]..sort((a, b) => b.value.area.compareTo(a.value.area));
    for (final e in shapes) {
      final zone = zones[e.key];
      final color = zoneColor(zone?.type ?? ZoneType.other);
      final planned = e.value.layer == ZoneLayer.plan;
      final path = _path(e.value.polygon);
      canvas.drawPath(
        path,
        Paint()..color = color.withValues(alpha: planned ? 0.18 : 0.45),
      );
      final stroke = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = e.key == state.selected ? 3.5 : 2;
      planned
          ? _dashed(canvas, e.value.polygon, stroke)
          : canvas.drawPath(path, stroke);
      _label(
        canvas,
        polygonCentroid(e.value.polygon),
        '${zone?.name ?? ''}\n${formatDecimal(e.value.area, maxFractionDigits: 1)} m²',
      );
    }
    final selected = state.selectedPolygon;
    if (selected != null) _handles(canvas, selected);
    if (state.draft.isNotEmpty) _draft(canvas);
  }

  void _grid(Canvas canvas, Size size) {
    final minor = Paint()
      ..color = scheme.outlineVariant.withValues(alpha: 0.35)
      ..strokeWidth = 0.5;
    final major = Paint()
      ..color = scheme.outlineVariant
      ..strokeWidth = 1;
    final startX = frame.origin.x.ceil();
    for (var x = startX; x <= frame.origin.x + frame.width; x++) {
      final dx = (x - frame.origin.x) * pixelsPerMeter;
      canvas.drawLine(
        Offset(dx, 0),
        Offset(dx, size.height),
        x % 5 == 0 ? major : minor,
      );
    }
    final startY = frame.origin.y.ceil();
    for (var y = startY; y <= frame.origin.y + frame.height; y++) {
      final dy = (y - frame.origin.y) * pixelsPerMeter;
      canvas.drawLine(
        Offset(0, dy),
        Offset(size.width, dy),
        y % 5 == 0 ? major : minor,
      );
    }
  }

  void _dashed(Canvas canvas, List<Pt> polygon, Paint paint) {
    for (final metric in _path(polygon).computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += 12) {
        canvas.drawPath(metric.extractPath(d, d + 7), paint);
      }
    }
  }

  void _label(Canvas canvas, Pt at, String text) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 160);
    final o = frame.toPx(at);
    painter.paint(canvas, o - Offset(painter.width / 2, painter.height / 2));
  }

  void _handles(Canvas canvas, List<Pt> polygon) {
    final editing = state.tool == CanvasTool.edit;
    final fill = Paint()..color = scheme.surface;
    final ring = Paint()
      ..color = scheme.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (var i = 0; i < polygon.length; i++) {
      final o = frame.toPx(polygon[i]);
      final r = i == state.selectedVertex ? 9.0 : (editing ? 7.0 : 4.0);
      canvas
        ..drawCircle(o, r, fill)
        ..drawCircle(
          o,
          r,
          i == state.selectedVertex ? (Paint()..color = scheme.primary) : ring,
        );
    }
    if (!editing) return;
    final mid = Paint()..color = scheme.primary.withValues(alpha: 0.6);
    for (final m in edgeMidpoints(polygon)) {
      canvas.drawCircle(frame.toPx(m), 4, mid);
    }
  }

  void _draft(Canvas canvas) {
    final line = Paint()
      ..color = scheme.tertiary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    final draft = state.draft;
    final measuring =
        state.tool == CanvasTool.calibrate || state.tool == CanvasTool.measure;
    canvas.drawPath(_path(draft, close: false), line);
    for (var i = 0; i < draft.length; i++) {
      canvas.drawCircle(
        frame.toPx(draft[i]),
        i == 0 && !measuring ? 8 : 5,
        Paint()..color = scheme.tertiary,
      );
    }
    if (measuring && draft.length == 2) {
      final length = draft[0].distanceTo(draft[1]);
      _label(
        canvas,
        (draft[0] + draft[1]) * 0.5,
        '${formatDecimal(length, maxFractionDigits: 2)} m',
      );
    }
  }

  @override
  bool shouldRepaint(PlanPainter old) =>
      old.state != state ||
      old.zones != zones ||
      old.scheme != scheme ||
      old.frame.origin != frame.origin;
}
