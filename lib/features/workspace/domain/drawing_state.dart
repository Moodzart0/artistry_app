import 'canvas_layer.dart';
import 'canvas_stroke.dart';
import 'drawing_tool.dart';

/// Represents the complete state of the drawing canvas.
class DrawingState {
  DrawingState({
    required this.drawingId,
    this.title = 'Untitled',
    this.canvasWidth = 1920,
    this.canvasHeight = 1080,
    this.backgroundColor = 0xFFFFFFFF,
    List<CanvasLayer>? layers,
    this.activeLayerId,
    this.currentTool = const DrawingTool(),
    this.currentStroke,
    this.sequenceNumber = 0,
    this.startTimeMs,
    List<List<CanvasStroke>>? undoHistory,
    List<List<CanvasStroke>>? redoHistory,
  })  : layers = layers ?? [],
        undoHistory = undoHistory ?? [],
        redoHistory = redoHistory ?? [];

  final String drawingId;
  final String title;
  final int canvasWidth;
  final int canvasHeight;
  final int backgroundColor;
  final List<CanvasLayer> layers;
  final String? activeLayerId;
  final DrawingTool currentTool;
  final CanvasStroke? currentStroke;
  final int sequenceNumber;
  final int? startTimeMs;
  final List<List<CanvasStroke>> undoHistory;
  final List<List<CanvasStroke>> redoHistory;

  /// Returns the currently active layer, or null.
  CanvasLayer? get activeLayer {
    if (activeLayerId == null) return null;
    try {
      return layers.firstWhere((l) => l.id == activeLayerId);
    } catch (_) {
      return layers.isNotEmpty ? layers.first : null;
    }
  }

  /// Total number of strokes across all layers.
  int get totalStrokes =>
      layers.fold(0, (sum, layer) => sum + layer.strokes.length);

  DrawingState copyWith({
    String? drawingId,
    String? title,
    int? canvasWidth,
    int? canvasHeight,
    int? backgroundColor,
    List<CanvasLayer>? layers,
    String? activeLayerId,
    DrawingTool? currentTool,
    CanvasStroke? currentStroke,
    bool clearCurrentStroke = false,
    int? sequenceNumber,
    int? startTimeMs,
    List<List<CanvasStroke>>? undoHistory,
    List<List<CanvasStroke>>? redoHistory,
  }) {
    return DrawingState(
      drawingId: drawingId ?? this.drawingId,
      title: title ?? this.title,
      canvasWidth: canvasWidth ?? this.canvasWidth,
      canvasHeight: canvasHeight ?? this.canvasHeight,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      layers: layers ?? this.layers,
      activeLayerId: activeLayerId ?? this.activeLayerId,
      currentTool: currentTool ?? this.currentTool,
      currentStroke: clearCurrentStroke ? null : (currentStroke ?? this.currentStroke),
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
      startTimeMs: startTimeMs ?? this.startTimeMs,
      undoHistory: undoHistory ?? this.undoHistory,
      redoHistory: redoHistory ?? this.redoHistory,
    );
  }
}
