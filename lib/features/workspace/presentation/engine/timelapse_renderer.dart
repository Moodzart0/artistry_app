import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../domain/canvas_layer.dart';
import '../../domain/canvas_stroke.dart';
import '../../domain/drawing_tool.dart';
import '../../domain/stroke_event.dart';
import '../../domain/stroke_point.dart';
import '../../domain/timelapse_settings.dart';
import 'canvas_painter.dart';

/// Result of a timelapse rendering operation.
class TimelapseRenderResult {
  const TimelapseRenderResult({
    required this.frames,
    required this.totalFrames,
    required this.canvasWidth,
    required this.canvasHeight,
    required this.durationMs,
  });

  /// List of PNG-encoded frame bytes.
  final List<Uint8List> frames;

  /// Total number of frames generated.
  final int totalFrames;

  /// Canvas dimensions used for rendering.
  final int canvasWidth;
  final int canvasHeight;

  /// Total rendering duration in milliseconds.
  final int durationMs;
}

/// Callback for reporting rendering progress.
/// [currentFrame] is the frame being rendered (0-based).
/// [totalFrames] is the estimated total number of frames.
/// [phase] is a description of the current rendering phase.
typedef TimelapseProgressCallback = void Function(
    int currentFrame, int totalFrames, String phase);

/// Off-screen renderer that replays stroke events and captures frames
/// for timelapse video generation.
///
/// This implements the core Event Sourcing replay logic:
/// 1. Read stroke_events sorted by sequence_number
/// 2. Rebuild canvas state incrementally by processing each event
/// 3. After each significant event (stroke_end, layer changes), capture a frame
/// 4. Render each frame using dart:ui off-screen Canvas + PictureRecorder
/// 5. Export frames as PNG byte data for video encoding
class TimelapseRenderer {
  TimelapseRenderer({
    required this.settings,
    this.onProgress,
  });

  final TimelapseSettings settings;
  final TimelapseProgressCallback? onProgress;

  /// Renders a timelapse from a list of stroke events.
  ///
  /// [events] must be sorted by sequenceNumber ascending.
  /// Returns a [TimelapseRenderResult] with all captured PNG frames.
  Future<TimelapseRenderResult> render(List<StrokeEvent> events) async {
    final stopwatch = Stopwatch()..start();
    final frames = <Uint8List>[];

    // ── Phase 1: Filter and prepare events ──────────────────────
    onProgress?.call(0, 0, 'Preparing events...');

    final filteredEvents = _filterEvents(events);
    final frameEvents = _identifyFrameCaptures(filteredEvents);
    final totalFrames = frameEvents.length;

    if (totalFrames == 0) {
      return TimelapseRenderResult(
        frames: [],
        totalFrames: 0,
        canvasWidth: settings.outputWidth,
        canvasHeight: settings.outputHeight,
        durationMs: stopwatch.elapsedMilliseconds,
      );
    }

    // ── Phase 2: Rebuild canvas state and capture frames ────────
    onProgress?.call(0, totalFrames, 'Rendering frames...');

    // Canvas state: layers keyed by ID, with their strokes
    final layers = <String, _ReplayLayer>{};
    String? activeLayerId;
    // Track strokes for undo support
    final undoStack = <_UndoEntry>[];

    // Process all events, capturing frames at frame events
    int frameIndex = 0;

    for (final event in filteredEvents) {
      _processEvent(event, layers, undoStack, (newActiveId) {
        activeLayerId = newActiveId;
      }, activeLayerId);

      // Check if this event should produce a frame
      if (frameIndex < frameEvents.length &&
          frameEvents[frameIndex].sequenceNumber == event.sequenceNumber) {
        // Capture frame
        final frameBytes = await _captureFrame(layers, activeLayerId);
        if (frameBytes != null) {
          frames.add(frameBytes);
        }

        frameIndex++;
        onProgress?.call(frameIndex, totalFrames, 'Rendering frames...');
      }

    }

    stopwatch.stop();

    return TimelapseRenderResult(
      frames: frames,
      totalFrames: frames.length,
      canvasWidth: settings.outputWidth,
      canvasHeight: settings.outputHeight,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  }

  /// Filters events based on timelapse settings.
  List<StrokeEvent> _filterEvents(List<StrokeEvent> events) {
    return events.where((event) {
      // Always include stroke events
      if (event.eventType == StrokeEventType.strokeStart ||
          event.eventType == StrokeEventType.strokeMove ||
          event.eventType == StrokeEventType.strokeEnd) {
        return true;
      }

      // Include layer events if configured
      if (event.eventType == StrokeEventType.layerAdd ||
          event.eventType == StrokeEventType.layerDelete ||
          event.eventType == StrokeEventType.layerReorder ||
          event.eventType == StrokeEventType.layerVisibilityToggle ||
          event.eventType == StrokeEventType.layerOpacityChange) {
        return settings.captureLayerEvents;
      }

      // Include undo/redo if configured
      if (event.eventType == StrokeEventType.undo ||
          event.eventType == StrokeEventType.redo) {
        return settings.includeUndoRedo;
      }

      // Include clear events
      if (event.eventType == StrokeEventType.clear) {
        return true;
      }

      return false;
    }).toList();
  }

  /// Identifies which events should trigger a frame capture.
  /// We capture frames at stroke_end events and significant layer changes.
  List<StrokeEvent> _identifyFrameCaptures(List<StrokeEvent> events) {
    return events.where((event) {
      switch (event.eventType) {
        case StrokeEventType.strokeEnd:
          return true;
        case StrokeEventType.layerAdd:
        case StrokeEventType.layerDelete:
        case StrokeEventType.layerReorder:
        case StrokeEventType.layerVisibilityToggle:
          return settings.captureLayerEvents;
        case StrokeEventType.undo:
        case StrokeEventType.redo:
          return settings.includeUndoRedo;
        case StrokeEventType.clear:
          return true;
        default:
          return false;
      }
    }).toList();
  }

  /// Processes a single event, updating the replay canvas state.
  void _processEvent(
    StrokeEvent event,
    Map<String, _ReplayLayer> layers,
    List<_UndoEntry> undoStack,
    void Function(String?) setActiveLayer,
    String? currentActiveLayerId,
  ) {
    switch (event.eventType) {
      case StrokeEventType.layerAdd:
        final name = event.strokeData?['name'] as String? ?? 'Layer';
        layers[event.layerId] = _ReplayLayer(
          id: event.layerId,
          name: name,
        );
        setActiveLayer(event.layerId);
        break;

      case StrokeEventType.layerDelete:
        layers.remove(event.layerId);
        if (currentActiveLayerId == event.layerId && layers.isNotEmpty) {
          setActiveLayer(layers.keys.last);
        }
        break;

      case StrokeEventType.layerVisibilityToggle:
        final layer = layers[event.layerId];
        if (layer != null) {
          final isVisible = event.strokeData?['is_visible'] as bool?;
          layer.isVisible = isVisible ?? !layer.isVisible;
        }
        break;

      case StrokeEventType.layerOpacityChange:
        final layer = layers[event.layerId];
        if (layer != null) {
          layer.opacity =
              (event.strokeData?['opacity'] as num?)?.toDouble() ?? 1.0;
        }
        break;

      case StrokeEventType.layerReorder:
        // Reordering doesn't change content, just render order
        // We handle this by maintaining insertion order in the map
        break;

      case StrokeEventType.layerRename:
        final layer = layers[event.layerId];
        if (layer != null) {
          layer.name = event.strokeData?['name'] as String? ?? layer.name;
        }
        break;

      case StrokeEventType.strokeEnd:
        // Reconstruct the complete stroke from strokeData
        final strokeData = event.strokeData;
        if (strokeData == null) break;

        final layer = layers[event.layerId];
        if (layer == null) break;

        final stroke = _reconstructStroke(
          event.layerId,
          strokeData,
          event.toolType,
          event.toolProperties,
        );
        if (stroke != null) {
          layer.strokes.add(stroke);
          // Track for undo
          undoStack.add(_UndoEntry(
            layerId: event.layerId,
            stroke: stroke,
          ));
        }
        break;

      case StrokeEventType.strokeStart:
      case StrokeEventType.strokeMove:
        // Intermediate events — skip (we use stroke_end for full data)
        break;

      case StrokeEventType.undo:
        if (undoStack.isNotEmpty) {
          final entry = undoStack.removeLast();
          final layer = layers[entry.layerId];
          if (layer != null && layer.strokes.isNotEmpty) {
            layer.strokes.removeLast();
          }
        }
        break;

      case StrokeEventType.redo:
        // Redo re-applies the stroke — but we don't have a redo stack
        // in the replay context. In practice, redo events from the log
        // contain the stroke_ids, but since we process sequentially,
        // we skip redo during replay (the subsequent stroke_end will add it).
        break;

      case StrokeEventType.clear:
        final layer = layers[event.layerId];
        if (layer != null) {
          layer.strokes.clear();
        }
        break;
    }
  }

  /// Reconstructs a CanvasStroke from serialized stroke_end event data.
  CanvasStroke? _reconstructStroke(
    String layerId,
    Map<String, dynamic> strokeData,
    String? toolType,
    Map<String, dynamic>? toolProperties,
  ) {
    // Parse points
    final pointsList = strokeData['points'] as List<dynamic>?;
    if (pointsList == null || pointsList.isEmpty) return null;

    final points = pointsList
        .map((p) => StrokePoint.fromJson(p as Map<String, dynamic>))
        .toList();

    // Parse tool configuration
    DrawingTool tool;
    if (toolProperties != null) {
      tool = DrawingTool.fromJson(toolProperties);
    } else {
      // Reconstruct from stroke data fields
      final colorValue = strokeData['color'] as int? ?? 0xFF000000;
      final width = (strokeData['width'] as num?)?.toDouble() ?? 5.0;
      final opacity = (strokeData['opacity'] as num?)?.toDouble() ?? 1.0;
      final blendModeIndex = strokeData['blend_mode'] as int? ?? 0;

      ToolType parsedToolType = ToolType.brush;
      if (toolType != null) {
        parsedToolType = ToolType.values.firstWhere(
          (t) => t.name == toolType,
          orElse: () => ToolType.brush,
        );
      }

      tool = DrawingTool(
        type: parsedToolType,
        size: width,
        opacity: opacity,
        color: Color(colorValue),
        blendMode: blendModeIndex < BlendMode.values.length
            ? BlendMode.values[blendModeIndex]
            : BlendMode.srcOver,
      );
    }

    return CanvasStroke(
      id: strokeData['stroke_id'] as String? ?? 'replay-stroke',
      layerId: layerId,
      points: points,
      tool: tool,
    );
  }

  /// Captures the current canvas state as a PNG image using off-screen rendering.
  Future<Uint8List?> _captureFrame(
    Map<String, _ReplayLayer> replayLayers,
    String? activeLayerId,
  ) async {
    final width = settings.outputWidth;
    final height = settings.outputHeight;

    // Convert replay layers to CanvasLayers for the painter
    final canvasLayers = replayLayers.values.map((rl) {
      return CanvasLayer(
        id: rl.id,
        name: rl.name,
        isVisible: rl.isVisible,
        opacity: rl.opacity,
        strokes: List<CanvasStroke>.from(rl.strokes),
      );
    }).toList();

    // Use PictureRecorder for off-screen rendering
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0,
        width.toDouble(), height.toDouble()));

    // Use the same CanvasPainter from Phase 3 for consistent rendering
    final painter = CanvasPainter(
      layers: canvasLayers,
      currentStroke: null,
      backgroundColor: Colors.white,
    );

    painter.paint(canvas, Size(width.toDouble(), height.toDouble()));

    // Convert to image
    final picture = recorder.endRecording();
    final image = await picture.toImage(width, height);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    picture.dispose();
    image.dispose();

    if (byteData == null) return null;
    return byteData.buffer.asUint8List();
  }
}

/// Internal replay layer state used during timelapse rendering.
class _ReplayLayer {
  _ReplayLayer({
    required this.id,
    required this.name,
    this.isVisible = true,
    this.opacity = 1.0,
  });

  final String id;
  String name;
  bool isVisible;
  double opacity;
  final List<CanvasStroke> strokes = [];
}

/// Tracks an undo entry during replay.
class _UndoEntry {
  const _UndoEntry({
    required this.layerId,
    required this.stroke,
  });

  final String layerId;
  final CanvasStroke stroke;
}
