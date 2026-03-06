/// Event types for the event sourcing system.
enum StrokeEventType {
  strokeStart,
  strokeMove,
  strokeEnd,
  layerAdd,
  layerDelete,
  layerReorder,
  layerVisibilityToggle,
  layerOpacityChange,
  layerRename,
  undo,
  redo,
  clear,
}

/// Represents a single event in the event sourcing log.
/// Maps directly to the stroke_events table in Supabase.
class StrokeEvent {
  const StrokeEvent({
    this.id,
    required this.drawingId,
    this.userId,
    required this.eventType,
    required this.layerId,
    this.strokeData,
    this.toolType,
    this.toolProperties,
    required this.sequenceNumber,
    required this.timestampMs,
  });

  final String? id;
  final String drawingId;
  final String? userId;
  final StrokeEventType eventType;
  final String layerId;
  final Map<String, dynamic>? strokeData;
  final String? toolType;
  final Map<String, dynamic>? toolProperties;
  final int sequenceNumber;
  final int timestampMs;

  /// Convert event type to the string stored in the DB.
  static String eventTypeToString(StrokeEventType type) {
    switch (type) {
      case StrokeEventType.strokeStart:
        return 'stroke_start';
      case StrokeEventType.strokeMove:
        return 'stroke_move';
      case StrokeEventType.strokeEnd:
        return 'stroke_end';
      case StrokeEventType.layerAdd:
        return 'layer_add';
      case StrokeEventType.layerDelete:
        return 'layer_delete';
      case StrokeEventType.layerReorder:
        return 'layer_reorder';
      case StrokeEventType.layerVisibilityToggle:
        return 'layer_visibility_toggle';
      case StrokeEventType.layerOpacityChange:
        return 'layer_opacity_change';
      case StrokeEventType.layerRename:
        return 'layer_rename';
      case StrokeEventType.undo:
        return 'undo';
      case StrokeEventType.redo:
        return 'redo';
      case StrokeEventType.clear:
        return 'clear';
    }
  }

  static StrokeEventType eventTypeFromString(String value) {
    switch (value) {
      case 'stroke_start':
        return StrokeEventType.strokeStart;
      case 'stroke_move':
        return StrokeEventType.strokeMove;
      case 'stroke_end':
        return StrokeEventType.strokeEnd;
      case 'layer_add':
        return StrokeEventType.layerAdd;
      case 'layer_delete':
        return StrokeEventType.layerDelete;
      case 'layer_reorder':
        return StrokeEventType.layerReorder;
      case 'layer_visibility_toggle':
        return StrokeEventType.layerVisibilityToggle;
      case 'layer_opacity_change':
        return StrokeEventType.layerOpacityChange;
      case 'layer_rename':
        return StrokeEventType.layerRename;
      case 'undo':
        return StrokeEventType.undo;
      case 'redo':
        return StrokeEventType.redo;
      case 'clear':
        return StrokeEventType.clear;
      default:
        return StrokeEventType.strokeStart;
    }
  }

  /// Serializes to JSON for Supabase insertion.
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'drawing_id': drawingId,
      if (userId != null) 'user_id': userId,
      'event_type': eventTypeToString(eventType),
      'layer_id': layerId,
      'stroke_data': strokeData,
      'tool_type': toolType,
      'tool_properties': toolProperties,
      'sequence_number': sequenceNumber,
      'timestamp_ms': timestampMs,
    };
  }

  factory StrokeEvent.fromJson(Map<String, dynamic> json) {
    return StrokeEvent(
      id: json['id'] as String?,
      drawingId: json['drawing_id'] as String,
      userId: json['user_id'] as String?,
      eventType: eventTypeFromString(json['event_type'] as String),
      layerId: json['layer_id'] as String,
      strokeData: json['stroke_data'] as Map<String, dynamic>?,
      toolType: json['tool_type'] as String?,
      toolProperties: json['tool_properties'] as Map<String, dynamic>?,
      sequenceNumber: json['sequence_number'] as int,
      timestampMs: json['timestamp_ms'] as int,
    );
  }
}
