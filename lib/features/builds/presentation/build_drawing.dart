import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/text/numbers.dart';
import '../domain/build_plan.dart';

/// Výkres návrhu přizpůsobený šířce obrazovky (FR-G1).
class BuildDrawingView extends StatelessWidget {
  const BuildDrawingView({
    required this.drawing,
    required this.label,
    super.key,
  });

  final Drawing drawing;

  /// Popis pro čtečku obrazovky („Půdorys“).
  final String label;

  @override
  Widget build(BuildContext context) {
    final (minX, minY, maxX, maxY) = drawing.bounds;
    final aspect = ((maxX - minX) / math.max(1, maxY - minY)).clamp(1.0, 2.5);
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: label,
      image: true,
      child: AspectRatio(
        aspectRatio: aspect,
        child: CustomPaint(
          painter: BuildDrawingPainter(
            drawing,
            ink: scheme.onSurface,
            roof: scheme.primaryContainer,
            textStyle: Theme.of(context).textTheme.labelSmall!,
          ),
        ),
      ),
    );
  }
}

class BuildDrawingPainter extends CustomPainter {
  BuildDrawingPainter(
    this.drawing, {
    required this.ink,
    required this.roof,
    required this.textStyle,
  });

  final Drawing drawing;
  final Color ink;
  final Color roof;
  final TextStyle textStyle;

  static const _pad = 18.0;

  Color _fill(DrawStyle style) => switch (style) {
    DrawStyle.outline => Colors.transparent,
    DrawStyle.wood => const Color(0xFFD7B37A),
    DrawStyle.post => const Color(0xFF8B5E34),
    DrawStyle.soil => const Color(0xFF7B5B45),
    DrawStyle.gravel => const Color(0xFFB0B0AA),
    DrawStyle.chippings => const Color(0xFF8E8E88),
    DrawStyle.paver => const Color(0xFF90A4AE),
    DrawStyle.mulch => const Color(0xFFA1785C),
    DrawStyle.fabric => const Color(0xFFE0E0E0),
    DrawStyle.roof => roof.withValues(alpha: 0.45),
    DrawStyle.water => const Color(0xFF81D4FA).withValues(alpha: 0.6),
  };

  @override
  void paint(Canvas canvas, Size size) {
    final (minX, minY, maxX, maxY) = drawing.bounds;
    final scale = math.min(
      (size.width - 2 * _pad) / math.max(1, maxX - minX),
      (size.height - 2 * _pad) / math.max(1, maxY - minY),
    );
    final dx = (size.width - (maxX - minX) * scale) / 2;
    final dy = (size.height - (maxY - minY) * scale) / 2;
    Offset at(double x, double y) =>
        Offset(dx + (x - minX) * scale, dy + (y - minY) * scale);

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = ink.withValues(alpha: 0.6);
    for (final shape in drawing.shapes) {
      switch (shape) {
        case DrawRect(:final x, :final y, :final w, :final h, :final style):
          final rect = Rect.fromPoints(at(x, y), at(x + w, y + h));
          canvas
            ..drawRect(rect, Paint()..color = _fill(style))
            ..drawRect(rect, stroke);
        case DrawLine(
          :final x1,
          :final y1,
          :final x2,
          :final y2,
          :final dashed,
        ):
          final paint = Paint()
            ..strokeWidth = dashed ? 1 : 2
            ..color = ink.withValues(alpha: dashed ? 0.5 : 0.8);
          if (dashed) {
            _dashed(canvas, at(x1, y1), at(x2, y2), paint);
          } else {
            canvas.drawLine(at(x1, y1), at(x2, y2), paint);
          }
        case DrawDimension(
          :final x1,
          :final y1,
          :final x2,
          :final y2,
          :final meters,
        ):
          _dimension(canvas, at(x1, y1), at(x2, y2), meters);
      }
    }
  }

  void _dashed(Canvas canvas, Offset a, Offset b, Paint paint) {
    final length = (b - a).distance;
    if (length == 0) return;
    final dir = (b - a) / length;
    for (var d = 0.0; d < length; d += 8) {
      canvas.drawLine(a + dir * d, a + dir * math.min(d + 4, length), paint);
    }
  }

  void _dimension(Canvas canvas, Offset a, Offset b, double meters) {
    final paint = Paint()
      ..strokeWidth = 1
      ..color = ink;
    final vertical = (a.dx - b.dx).abs() < (a.dy - b.dy).abs();
    final tick = vertical ? const Offset(4, 0) : const Offset(0, 4);
    canvas
      ..drawLine(a, b, paint)
      ..drawLine(a - tick, a + tick, paint)
      ..drawLine(b - tick, b + tick, paint);
    final text = TextPainter(
      text: TextSpan(
        text: '${formatDecimal(meters)} m',
        style: textStyle.copyWith(color: ink),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final mid = (a + b) / 2;
    canvas.save();
    canvas.translate(mid.dx, mid.dy);
    if (vertical) canvas.rotate(-math.pi / 2);
    text.paint(canvas, Offset(-text.width / 2, -text.height - 2));
    canvas.restore();
  }

  @override
  bool shouldRepaint(BuildDrawingPainter old) =>
      old.drawing != drawing || old.ink != ink || old.roof != roof;
}
