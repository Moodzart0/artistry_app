import 'package:flutter/material.dart';

/// Supported tool types in the drawing workspace.
enum ToolType {
  brush,
  pencil,
  eraser,
  fill,
  shape,
}

/// Supported shape types when using the shape tool.
enum ShapeType {
  line,
  rectangle,
  circle,
  triangle,
}

/// Represents the current drawing tool configuration.
class DrawingTool {
  const DrawingTool({
    this.type = ToolType.brush,
    this.size = 5.0,
    this.opacity = 1.0,
    this.color = Colors.black,
    this.hardness = 0.8,
    this.flow = 1.0,
    this.shapeType,
    this.blendMode = BlendMode.srcOver,
  });

  final ToolType type;
  final double size;
  final double opacity;
  final Color color;
  final double hardness;
  final double flow;
  final ShapeType? shapeType;
  final BlendMode blendMode;

  /// Whether this tool erases content.
  bool get isEraser => type == ToolType.eraser;

  DrawingTool copyWith({
    ToolType? type,
    double? size,
    double? opacity,
    Color? color,
    double? hardness,
    double? flow,
    ShapeType? shapeType,
    BlendMode? blendMode,
  }) {
    return DrawingTool(
      type: type ?? this.type,
      size: size ?? this.size,
      opacity: opacity ?? this.opacity,
      color: color ?? this.color,
      hardness: hardness ?? this.hardness,
      flow: flow ?? this.flow,
      shapeType: shapeType ?? this.shapeType,
      blendMode: type == ToolType.eraser ? BlendMode.clear : (blendMode ?? this.blendMode),
    );
  }

  /// Serializes tool properties for event sourcing.
  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'size': size,
      'opacity': opacity,
      'color': color.value,
      'hardness': hardness,
      'flow': flow,
      'shape_type': shapeType?.name,
      'blend_mode': blendMode.index,
    };
  }

  factory DrawingTool.fromJson(Map<String, dynamic> json) {
    return DrawingTool(
      type: ToolType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => ToolType.brush,
      ),
      size: (json['size'] as num?)?.toDouble() ?? 5.0,
      opacity: (json['opacity'] as num?)?.toDouble() ?? 1.0,
      color: Color(json['color'] as int? ?? 0xFF000000),
      hardness: (json['hardness'] as num?)?.toDouble() ?? 0.8,
      flow: (json['flow'] as num?)?.toDouble() ?? 1.0,
      shapeType: json['shape_type'] != null
          ? ShapeType.values.firstWhere(
              (s) => s.name == json['shape_type'],
              orElse: () => ShapeType.line,
            )
          : null,
      blendMode: json['blend_mode'] != null
          ? BlendMode.values[json['blend_mode'] as int]
          : BlendMode.srcOver,
    );
  }
}
