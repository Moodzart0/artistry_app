import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../domain/canvas_layer.dart';
import '../../domain/canvas_stroke.dart';
import '../../domain/drawing_state.dart';
import '../../domain/drawing_tool.dart';
import '../../domain/stroke_event.dart';
import '../../domain/stroke_point.dart';

/// Manages the drawing canvas state, strokes, layers, and event sourcing.
class CanvasController extends ChangeNotifier {
  CanvasController({
    String? drawingId,
    int canvasWidth = 1920,
    int canvasHeight = 1080,
  }) {
    final uuid = const Uuid();
    final id = drawingId ?? uuid.v4();
    final defaultLayerId = uuid.v4();
    final startTime = DateTime.now().millisecondsSinceEpoch;

    _state = DrawingState(
      drawingId: id,
      canvasWidth: canvasWidth,
      canvasHeight: canvasHeight,
      startTimeMs: startTime,
      layers: [
        CanvasLayer(id: defaultLayerId, name: 'Layer 1'),
      ],
      activeLayerId: defaultLayerId,
    );

    // Log the initial layer creation event
    _logEvent(StrokeEvent(
      drawingId: id,
      eventType: StrokeEventType.layerAdd,
      layerId: defaultLayerId,
      sequenceNumber: 0,
      timestampMs: 0,
    ));
  }

  late DrawingState _state;
  DrawingState get state => _state;

  /// All recorded stroke events (event sourcing log).
  final List<StrokeEvent> _eventLog = [];
  List<StrokeEvent> get eventLog => List.unmodifiable(_eventLog);

  int get _elapsedMs =>
      DateTime.now().millisecondsSinceEpoch - (_state.startTimeMs ?? 0);

  // ── Tool Management ─────────────────────────────────────────

  void setTool(DrawingTool tool) {
    _state = _state.copyWith(currentTool: tool);
    notifyListeners();
  }

  void setToolType(ToolType type) {
    final newTool = _state.currentTool.copyWith(type: type);
    setTool(newTool);
  }

  void setColor(Color color) {
    setTool(_state.currentTool.copyWith(color: color));
  }

  void setBrushSize(double size) {
    setTool(_state.currentTool.copyWith(size: size));
  }

  void setOpacity(double opacity) {
    setTool(_state.currentTool.copyWith(opacity: opacity));
  }

  // ── Stroke Handling (Touch/Stylus) ──────────────────────────

  /// Called when the user begins a stroke (touch down / stylus down).
  void onStrokeStart(Offset position, {double pressure = 1.0, double tilt = 0.0}) {
    final activeLayer = _state.activeLayer;
    if (activeLayer == null || activeLayer.isLocked) return;

    final strokeId = const Uuid().v4();
    final point = StrokePoint(
      x: position.dx,
      y: position.dy,
      pressure: pressure,
      tilt: tilt,
      timestamp: _elapsedMs,
    );

    final stroke = CanvasStroke(
      id: strokeId,
      layerId: activeLayer.id,
      points: [point],
      tool: _state.currentTool,
      startTimestampMs: _elapsedMs,
    );

    _state = _state.copyWith(currentStroke: stroke);

    // Log stroke_start event
    final seq = _nextSequence();
    _logEvent(StrokeEvent(
      drawingId: _state.drawingId,
      eventType: StrokeEventType.strokeStart,
      layerId: activeLayer.id,
      strokeData: {
        'stroke_id': strokeId,
        'points': [point.toJson()],
        'color': _state.currentTool.color.value,
        'width': _state.currentTool.size,
        'opacity': _state.currentTool.opacity,
        'blend_mode': _state.currentTool.blendMode.index,
      },
      toolType: _state.currentTool.type.name,
      toolProperties: _state.currentTool.toJson(),
      sequenceNumber: seq,
      timestampMs: _elapsedMs,
    ));

    notifyListeners();
  }

  /// Called as the user drags (touch move / stylus move).
  void onStrokeUpdate(Offset position, {double pressure = 1.0, double tilt = 0.0}) {
    if (_state.currentStroke == null) return;

    final point = StrokePoint(
      x: position.dx,
      y: position.dy,
      pressure: pressure,
      tilt: tilt,
      timestamp: _elapsedMs,
    );

    _state.currentStroke!.points.add(point);

    // Log stroke_move events periodically (every 5 points to reduce volume)
    if (_state.currentStroke!.points.length % 5 == 0) {
      final recentPoints = _state.currentStroke!.points
          .skip(_state.currentStroke!.points.length - 5)
          .map((p) => p.toJson())
          .toList();

      final seq = _nextSequence();
      _logEvent(StrokeEvent(
        drawingId: _state.drawingId,
        eventType: StrokeEventType.strokeMove,
        layerId: _state.currentStroke!.layerId,
        strokeData: {
          'stroke_id': _state.currentStroke!.id,
          'points': recentPoints,
        },
        sequenceNumber: seq,
        timestampMs: _elapsedMs,
      ));
    }

    notifyListeners();
  }

  /// Called when the user lifts (touch up / stylus up).
  void onStrokeEnd() {
    final stroke = _state.currentStroke;
    if (stroke == null) return;

    // Add the completed stroke to the active layer
    final activeLayer = _state.activeLayer;
    if (activeLayer != null) {
      activeLayer.strokes.add(stroke);

      // Clear redo history when new stroke is added
      _state = _state.copyWith(
        clearCurrentStroke: true,
        redoHistory: [],
      );
    } else {
      _state = _state.copyWith(clearCurrentStroke: true);
    }

    // Log stroke_end event with complete stroke data
    final seq = _nextSequence();
    _logEvent(StrokeEvent(
      drawingId: _state.drawingId,
      eventType: StrokeEventType.strokeEnd,
      layerId: stroke.layerId,
      strokeData: stroke.toStrokeData(),
      toolType: stroke.tool.type.name,
      toolProperties: stroke.tool.toJson(),
      sequenceNumber: seq,
      timestampMs: _elapsedMs,
    ));

    notifyListeners();
  }

  // ── Layer Management ────────────────────────────────────────

  void addLayer({String? name}) {
    final uuid = const Uuid();
    final layerId = uuid.v4();
    final layerName = name ?? 'Layer ${_state.layers.length + 1}';

    final newLayer = CanvasLayer(id: layerId, name: layerName);
    final updatedLayers = List<CanvasLayer>.from(_state.layers)..add(newLayer);

    _state = _state.copyWith(
      layers: updatedLayers,
      activeLayerId: layerId,
    );

    final seq = _nextSequence();
    _logEvent(StrokeEvent(
      drawingId: _state.drawingId,
      eventType: StrokeEventType.layerAdd,
      layerId: layerId,
      strokeData: {'name': layerName},
      sequenceNumber: seq,
      timestampMs: _elapsedMs,
    ));

    notifyListeners();
  }

  void removeLayer(String layerId) {
    if (_state.layers.length <= 1) return; // Must keep at least one layer

    final updatedLayers =
        _state.layers.where((l) => l.id != layerId).toList();
    final newActiveId = _state.activeLayerId == layerId
        ? updatedLayers.last.id
        : _state.activeLayerId;

    _state = _state.copyWith(
      layers: updatedLayers,
      activeLayerId: newActiveId,
    );

    final seq = _nextSequence();
    _logEvent(StrokeEvent(
      drawingId: _state.drawingId,
      eventType: StrokeEventType.layerDelete,
      layerId: layerId,
      sequenceNumber: seq,
      timestampMs: _elapsedMs,
    ));

    notifyListeners();
  }

  void setActiveLayer(String layerId) {
    _state = _state.copyWith(activeLayerId: layerId);
    notifyListeners();
  }

  void toggleLayerVisibility(String layerId) {
    final layer = _state.layers.firstWhere((l) => l.id == layerId);
    layer.isVisible = !layer.isVisible;

    final seq = _nextSequence();
    _logEvent(StrokeEvent(
      drawingId: _state.drawingId,
      eventType: StrokeEventType.layerVisibilityToggle,
      layerId: layerId,
      strokeData: {'is_visible': layer.isVisible},
      sequenceNumber: seq,
      timestampMs: _elapsedMs,
    ));

    notifyListeners();
  }

  void setLayerOpacity(String layerId, double opacity) {
    final layer = _state.layers.firstWhere((l) => l.id == layerId);
    layer.opacity = opacity.clamp(0.0, 1.0);

    final seq = _nextSequence();
    _logEvent(StrokeEvent(
      drawingId: _state.drawingId,
      eventType: StrokeEventType.layerOpacityChange,
      layerId: layerId,
      strokeData: {'opacity': opacity},
      sequenceNumber: seq,
      timestampMs: _elapsedMs,
    ));

    notifyListeners();
  }

  void renameLayer(String layerId, String newName) {
    final layer = _state.layers.firstWhere((l) => l.id == layerId);
    layer.name = newName;

    final seq = _nextSequence();
    _logEvent(StrokeEvent(
      drawingId: _state.drawingId,
      eventType: StrokeEventType.layerRename,
      layerId: layerId,
      strokeData: {'name': newName},
      sequenceNumber: seq,
      timestampMs: _elapsedMs,
    ));

    notifyListeners();
  }

  void reorderLayers(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex -= 1;
    final layers = List<CanvasLayer>.from(_state.layers);
    final layer = layers.removeAt(oldIndex);
    layers.insert(newIndex, layer);

    _state = _state.copyWith(layers: layers);

    final seq = _nextSequence();
    _logEvent(StrokeEvent(
      drawingId: _state.drawingId,
      eventType: StrokeEventType.layerReorder,
      layerId: layer.id,
      strokeData: {'old_index': oldIndex, 'new_index': newIndex},
      sequenceNumber: seq,
      timestampMs: _elapsedMs,
    ));

    notifyListeners();
  }

  // ── Undo / Redo ─────────────────────────────────────────────

  void undo() {
    final activeLayer = _state.activeLayer;
    if (activeLayer == null || activeLayer.strokes.isEmpty) return;

    final lastStroke = activeLayer.strokes.removeLast();
    _state.undoHistory.add([lastStroke]);

    final seq = _nextSequence();
    _logEvent(StrokeEvent(
      drawingId: _state.drawingId,
      eventType: StrokeEventType.undo,
      layerId: activeLayer.id,
      strokeData: {'stroke_id': lastStroke.id},
      sequenceNumber: seq,
      timestampMs: _elapsedMs,
    ));

    notifyListeners();
  }

  void redo() {
    if (_state.undoHistory.isEmpty) return;

    final strokes = _state.undoHistory.removeLast();
    final activeLayer = _state.activeLayer;
    if (activeLayer == null) return;

    activeLayer.strokes.addAll(strokes);

    final seq = _nextSequence();
    _logEvent(StrokeEvent(
      drawingId: _state.drawingId,
      eventType: StrokeEventType.redo,
      layerId: activeLayer.id,
      strokeData: {'stroke_ids': strokes.map((s) => s.id).toList()},
      sequenceNumber: seq,
      timestampMs: _elapsedMs,
    ));

    notifyListeners();
  }

  bool get canUndo =>
      _state.activeLayer != null && _state.activeLayer!.strokes.isNotEmpty;

  bool get canRedo => _state.undoHistory.isNotEmpty;

  // ── Clear ───────────────────────────────────────────────────

  void clearActiveLayer() {
    final activeLayer = _state.activeLayer;
    if (activeLayer == null) return;

    activeLayer.strokes.clear();

    final seq = _nextSequence();
    _logEvent(StrokeEvent(
      drawingId: _state.drawingId,
      eventType: StrokeEventType.clear,
      layerId: activeLayer.id,
      sequenceNumber: seq,
      timestampMs: _elapsedMs,
    ));

    notifyListeners();
  }

  // ── Event Sourcing Internals ────────────────────────────────

  int _nextSequence() {
    final seq = _state.sequenceNumber + 1;
    _state = _state.copyWith(sequenceNumber: seq);
    return seq;
  }

  void _logEvent(StrokeEvent event) {
    _eventLog.add(event);
  }

  /// Returns all events as JSON for batch upload to Supabase.
  List<Map<String, dynamic>> exportEvents({String? userId}) {
    return _eventLog.map((e) {
      final json = e.toJson();
      if (userId != null) json['user_id'] = userId;
      return json;
    }).toList();
  }

  /// Returns the total count of events logged.
  int get eventCount => _eventLog.length;
}
