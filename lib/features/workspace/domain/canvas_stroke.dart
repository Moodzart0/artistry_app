import 'package:flutter/material.dart';

import 'drawing_tool.dart';
import 'stroke_point.dart';

/// Represents a complete stroke drawn on the canvas.
/// Contains all points and the tool configuration used.
class CanvasStroke {
  CanvasStroke({
    required this.id,
    required this.layerId,
    required this.points,
    required this.tool,
    this.startTimestampMs,
    this.endTimestampMs,
  });

  final String id;
  final String layerId;
  final List<StrokePoint> points;
  final DrawingTool tool;
  final int? startTimestampMs;
  final int? endTimestampMs;

  /// Builds a Paint object from the tool configuration.
  Paint toPaint() {
    return Paint()
      ..color = tool.color.withAlpha((tool.opacity * 255).toInt())
      ..strokeWidth = tool.size
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..blendMode = tool.isEraser ? BlendMode.clear : tool.blendMode;
  }

  /// Builds a Path from the stroke points.
  Path toPath() {
    final path = Path();
    if (points.isEmpty) return path;

    path.moveTo(points.first.x, points.first.y);

    if (points.length == 1) {
      // Single point — draw a dot
      path.lineTo(points.first.x + 0.1, points.first.y + 0.1);
      return path;
    }

    // Use quadratic bezier curves for smooth strokes
    for (int i = 1; i < points.length - 1; i++) {
      final current = points[i];
      final next = points[i + 1];
      final midX = (current.x + next.x) / 2;
      final midY = (current.y + next.y) / 2;
      path.quadraticBezierTo(current.x, current.y, midX, midY);
    }

    // Connect to the last point
    final last = points.last;
    path.lineTo(last.x, last.y);

    return path;
  }

  /// Serializes stroke data for event sourcing / Supabase storage.
  Map<String, dynamic> toStrokeData() {
    return {
      'points': points.map((p) => p.toJson()).toList(),
      'color': tool.color.value,
      'width': tool.size,
      'opacity': tool.opacity,
      'blend_mode': tool.blendMode.index,
    };
  }
}
