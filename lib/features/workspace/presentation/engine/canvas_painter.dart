import 'package:flutter/material.dart';

import '../../domain/canvas_layer.dart';
import '../../domain/canvas_stroke.dart';

/// Custom painter that renders all layers and strokes on the canvas.
class CanvasPainter extends CustomPainter {
  CanvasPainter({
    required this.layers,
    this.currentStroke,
    this.backgroundColor = Colors.white,
  });

  final List<CanvasLayer> layers;
  final CanvasStroke? currentStroke;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    // Draw background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = backgroundColor,
    );

    // Draw each layer (bottom to top)
    for (final layer in layers) {
      if (!layer.isVisible) continue;

      // Save/restore for layer opacity
      canvas.saveLayer(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = Colors.white.withAlpha((layer.opacity * 255).toInt()),
      );

      // Draw all committed strokes in this layer
      for (final stroke in layer.strokes) {
        _drawStroke(canvas, stroke);
      }

      canvas.restore();
    }

    // Draw the current in-progress stroke (always on top)
    if (currentStroke != null) {
      _drawStroke(canvas, currentStroke!);
    }
  }

  void _drawStroke(Canvas canvas, CanvasStroke stroke) {
    if (stroke.points.isEmpty) return;

    final paint = stroke.toPaint();
    final path = stroke.toPath();

    // For pressure-sensitive strokes, vary the width
    if (stroke.points.length > 1 && _hasPressureVariation(stroke)) {
      _drawPressureSensitiveStroke(canvas, stroke, paint);
    } else {
      canvas.drawPath(path, paint);
    }
  }

  bool _hasPressureVariation(CanvasStroke stroke) {
    if (stroke.points.length < 2) return false;
    final pressures = stroke.points.map((p) => p.pressure).toSet();
    return pressures.length > 1;
  }

  void _drawPressureSensitiveStroke(
      Canvas canvas, CanvasStroke stroke, Paint basePaint) {
    final points = stroke.points;
    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];

      // Interpolate pressure for stroke width variation
      final pressure = (p1.pressure + p2.pressure) / 2;
      final strokePaint = Paint()
        ..color = basePaint.color
        ..strokeWidth = basePaint.strokeWidth * pressure
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke
        ..blendMode = basePaint.blendMode;

      canvas.drawLine(
        Offset(p1.x, p1.y),
        Offset(p2.x, p2.y),
        strokePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CanvasPainter oldDelegate) {
    return true; // Always repaint for smooth drawing
  }
}
