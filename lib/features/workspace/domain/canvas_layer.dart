import 'canvas_stroke.dart';

/// Represents a single layer in the canvas layer stack.
class CanvasLayer {
  CanvasLayer({
    required this.id,
    this.name = 'Layer',
    this.isVisible = true,
    this.isLocked = false,
    this.opacity = 1.0,
    List<CanvasStroke>? strokes,
  }) : strokes = strokes ?? [];

  final String id;
  String name;
  bool isVisible;
  bool isLocked;
  double opacity;
  final List<CanvasStroke> strokes;

  /// Serializes layer metadata for storage.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'is_visible': isVisible,
      'is_locked': isLocked,
      'opacity': opacity,
      'stroke_count': strokes.length,
    };
  }

  factory CanvasLayer.fromJson(Map<String, dynamic> json) {
    return CanvasLayer(
      id: json['id'] as String,
      name: (json['name'] as String?) ?? 'Layer',
      isVisible: (json['is_visible'] as bool?) ?? true,
      isLocked: (json['is_locked'] as bool?) ?? false,
      opacity: (json['opacity'] as num?)?.toDouble() ?? 1.0,
    );
  }
}
