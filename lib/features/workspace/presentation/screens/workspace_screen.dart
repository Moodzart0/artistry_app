import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../engine/canvas_controller.dart';
import '../engine/canvas_painter.dart';
import '../widgets/brush_settings_sheet.dart';
import '../widgets/color_picker_sheet.dart';
import '../widgets/drawing_toolbar.dart';
import '../widgets/layer_panel.dart';

/// The main workspace screen with drawing canvas, toolbar, and layer management.
class WorkspaceScreen extends StatefulWidget {
  const WorkspaceScreen({super.key});

  @override
  State<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends State<WorkspaceScreen> {
  late CanvasController _controller;
  final TransformationController _transformController =
      TransformationController();
  bool _showEventLog = false;

  @override
  void initState() {
    super.initState();
    _controller = CanvasController();
    _controller.addListener(_onControllerUpdate);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    _transformController.dispose();
    super.dispose();
  }

  void _onControllerUpdate() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Workspace',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          // Event log toggle (for debugging / demo)
          IconButton(
            icon: Icon(
              _showEventLog ? Icons.receipt_long : Icons.receipt_long_outlined,
              color: _showEventLog ? AppColors.primary : null,
            ),
            tooltip: 'Event Log',
            onPressed: () => setState(() => _showEventLog = !_showEventLog),
          ),
          // Clear canvas
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear Layer',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear Layer'),
                  content: const Text(
                      'Clear all strokes on the active layer? This cannot be undone.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        _controller.clearActiveLayer();
                        Navigator.pop(context);
                      },
                      child: const Text('Clear',
                          style: TextStyle(color: AppColors.error)),
                    ),
                  ],
                ),
              );
            },
          ),
          // Export / save info
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Drawing Info',
            onPressed: () => _showDrawingInfo(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Canvas area ─────────────────────────────────────
          Expanded(
            child: Stack(
              children: [
                // Interactive canvas with pan/zoom
                InteractiveViewer(
                  transformationController: _transformController,
                  minScale: 0.1,
                  maxScale: 5.0,
                  boundaryMargin: const EdgeInsets.all(200),
                  child: Center(
                    child: Container(
                      width: _controller.state.canvasWidth.toDouble(),
                      height: _controller.state.canvasHeight.toDouble(),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(40),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: GestureDetector(
                        onPanStart: _onPanStart,
                        onPanUpdate: _onPanUpdate,
                        onPanEnd: _onPanEnd,
                        child: ClipRect(
                          child: CustomPaint(
                            painter: CanvasPainter(
                              layers: _controller.state.layers,
                              currentStroke:
                                  _controller.state.currentStroke,
                            ),
                            size: Size(
                              _controller.state.canvasWidth.toDouble(),
                              _controller.state.canvasHeight.toDouble(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Active layer indicator
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(153),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _controller.state.activeLayer?.name ?? 'No Layer',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                // Stroke count / event count
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(153),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_controller.state.totalStrokes} strokes · ${_controller.eventCount} events',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),

                // Event log overlay
                if (_showEventLog) _buildEventLogOverlay(),
              ],
            ),
          ),

          // ── Toolbar ─────────────────────────────────────────
          DrawingToolbar(
            controller: _controller,
            onColorPickerTap: () => _showColorPicker(context),
            onLayerPanelTap: () => _showLayerPanel(context),
            onBrushSettingsTap: () => _showBrushSettings(context),
          ),
        ],
      ),
    );
  }

  // ── Touch / Stylus Handling ──────────────────────────────────

  void _onPanStart(DragStartDetails details) {
    final localPos = details.localPosition;
    // Extract pressure if available (stylus support)
    _controller.onStrokeStart(
      localPos,
      pressure: 1.0,
    );
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final localPos = details.localPosition;
    _controller.onStrokeUpdate(
      localPos,
      pressure: 1.0,
    );
  }

  void _onPanEnd(DragEndDetails details) {
    _controller.onStrokeEnd();
  }

  // ── Bottom Sheets ────────────────────────────────────────────

  void _showColorPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ColorPickerSheet(
        currentColor: _controller.state.currentTool.color,
        onColorSelected: (color) {
          _controller.setColor(color);
        },
      ),
    );
  }

  void _showLayerPanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          // Listen to controller changes to update the modal
          return ListenableBuilder(
            listenable: _controller,
            builder: (context, _) => LayerPanel(controller: _controller),
          );
        },
      ),
    );
  }

  void _showBrushSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => BrushSettingsSheet(controller: _controller),
    );
  }

  void _showDrawingInfo(BuildContext context) {
    final state = _controller.state;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Drawing Info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow('Canvas Size',
                '${state.canvasWidth} × ${state.canvasHeight}'),
            _infoRow('Layers', '${state.layers.length}'),
            _infoRow('Total Strokes', '${state.totalStrokes}'),
            _infoRow('Events Logged', '${_controller.eventCount}'),
            _infoRow(
                'Current Tool', state.currentTool.type.name.toUpperCase()),
            _infoRow(
                'Brush Size', '${state.currentTool.size.toInt()}px'),
            const Divider(),
            const Text(
              'Event Sourcing Active',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Every stroke is being recorded for timelapse generation (Phase 4).',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Text(value,
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ── Event Log Overlay ────────────────────────────────────────

  Widget _buildEventLogOverlay() {
    final events = _controller.eventLog;
    final recentEvents = events.length > 20
        ? events.sublist(events.length - 20)
        : events;

    return Positioned(
      bottom: 8,
      left: 8,
      right: 8,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(204),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Event Log (${events.length} total)',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _showEventLog = false),
                  child: const Icon(Icons.close,
                      color: Colors.white, size: 16),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                reverse: true,
                itemCount: recentEvents.length,
                itemBuilder: (context, index) {
                  final event = recentEvents[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 1),
                    child: Text(
                      '#${event.sequenceNumber} ${_eventTypeLabel(event.eventType)} '
                      '[${event.timestampMs}ms]'
                      '${event.toolType != null ? ' (${event.toolType})' : ''}',
                      style: TextStyle(
                        color: _eventColor(event.eventType),
                        fontSize: 10,
                        fontFamily: 'monospace',
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _eventTypeLabel(dynamic eventType) {
    return eventType.toString().split('.').last;
  }

  Color _eventColor(dynamic eventType) {
    final name = eventType.toString();
    if (name.contains('stroke')) return const Color(0xFF4FC3F7);
    if (name.contains('layer')) return const Color(0xFFFFD54F);
    if (name.contains('undo') || name.contains('redo')) {
      return const Color(0xFFFF8A65);
    }
    return Colors.white70;
  }
}
