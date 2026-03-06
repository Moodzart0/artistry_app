import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/stroke_event.dart';
import '../../domain/timelapse_settings.dart';
import '../engine/timelapse_export_service.dart';

/// Dialog for configuring and exporting a timelapse video from stroke events.
class TimelapseExportDialog extends StatefulWidget {
  const TimelapseExportDialog({
    super.key,
    required this.events,
    required this.canvasWidth,
    required this.canvasHeight,
  });

  final List<StrokeEvent> events;
  final int canvasWidth;
  final int canvasHeight;

  @override
  State<TimelapseExportDialog> createState() => _TimelapseExportDialogState();
}

class _TimelapseExportDialogState extends State<TimelapseExportDialog> {
  TimelapseSettings _settings = const TimelapseSettings();
  TimelapseExportProgress? _progress;
  TimelapseExportResult? _result;
  bool _isExporting = false;

  int get _strokeEndCount => widget.events
      .where((e) => e.eventType == StrokeEventType.strokeEnd)
      .length;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(context),
            const Divider(height: 1),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _isExporting
                    ? _buildProgressView()
                    : _result != null
                        ? _buildResultView()
                        : _buildSettingsView(),
              ),
            ),

            // Actions
            if (!_isExporting) ...[
              const Divider(height: 1),
              _buildActions(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const Icon(Icons.timelapse, color: AppColors.primary, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Export Timelapse',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$_strokeEndCount strokes · ${widget.events.length} events recorded',
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (!_isExporting)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
        ],
      ),
    );
  }

  Widget _buildSettingsView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Info card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withAlpha(40)),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.primary, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Your drawing will be replayed on a hidden canvas and '
                  'each completed stroke captured as a frame for the video.',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Quality
        const Text('Quality',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        SegmentedButton<TimelapseQuality>(
          segments: const [
            ButtonSegment(
              value: TimelapseQuality.low,
              label: Text('Low'),
            ),
            ButtonSegment(
              value: TimelapseQuality.medium,
              label: Text('Med'),
            ),
            ButtonSegment(
              value: TimelapseQuality.high,
              label: Text('High'),
            ),
            ButtonSegment(
              value: TimelapseQuality.maximum,
              label: Text('Max'),
            ),
          ],
          selected: {_settings.quality},
          onSelectionChanged: (values) {
            setState(() {
              _settings = _settings.copyWith(quality: values.first);
            });
          },
        ),
        const SizedBox(height: 20),

        // Frame rate
        _buildSlider(
          label: 'Frame Rate',
          value: _settings.frameRate.toDouble(),
          min: 15,
          max: 60,
          divisions: 3,
          suffix: 'fps',
          onChanged: (v) => setState(() {
            _settings = _settings.copyWith(frameRate: v.toInt());
          }),
        ),
        const SizedBox(height: 12),

        // Speed multiplier
        _buildSlider(
          label: 'Speed',
          value: _settings.speedMultiplier,
          min: 2,
          max: 50,
          divisions: 24,
          suffix: 'x',
          onChanged: (v) => setState(() {
            _settings = _settings.copyWith(speedMultiplier: v);
          }),
        ),
        const SizedBox(height: 16),

        // Options
        SwitchListTile(
          title: const Text('Include layer changes', style: TextStyle(fontSize: 14)),
          subtitle: const Text('Show layer add/remove/reorder in timelapse',
              style: TextStyle(fontSize: 11)),
          value: _settings.captureLayerEvents,
          onChanged: (v) => setState(() {
            _settings = _settings.copyWith(captureLayerEvents: v);
          }),
          contentPadding: EdgeInsets.zero,
        ),
        SwitchListTile(
          title: const Text('Include undo/redo', style: TextStyle(fontSize: 14)),
          subtitle: const Text('Show undo/redo operations in timelapse',
              style: TextStyle(fontSize: 11)),
          value: _settings.includeUndoRedo,
          onChanged: (v) => setState(() {
            _settings = _settings.copyWith(includeUndoRedo: v);
          }),
          contentPadding: EdgeInsets.zero,
        ),

        const SizedBox(height: 12),

        // Estimated output info
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              _infoRow('Output Resolution',
                  '${_settings.outputWidth} × ${_settings.outputHeight}'),
              _infoRow('Est. Frames', '~$_strokeEndCount'),
              _infoRow('Est. Duration',
                  '~${(_strokeEndCount / _settings.frameRate).toStringAsFixed(1)}s'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressView() {
    final progress = _progress;
    final progressValue = progress?.progress ?? 0.0;
    final message = progress?.message ?? 'Starting...';
    final phase = progress?.phase ?? TimelapseExportPhase.preparing;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        SizedBox(
          width: 100,
          height: 100,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: progressValue > 0 ? progressValue : null,
                strokeWidth: 6,
                color: AppColors.primary,
              ),
              Text(
                '${(progressValue * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          _phaseLabel(phase),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildResultView() {
    final result = _result!;

    return Column(
      children: [
        const SizedBox(height: 12),
        Icon(
          result.success ? Icons.check_circle : Icons.warning_amber,
          size: 64,
          color: result.success ? AppColors.success : Colors.orange,
        ),
        const SizedBox(height: 16),
        Text(
          result.success
              ? 'Timelapse Generated!'
              : 'Frames Exported',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (result.success && result.videoPath != null)
          Text(
            'Saved to: ${result.videoPath}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        if (!result.success && result.framesDirectory != null)
          Text(
            'Frames saved to:\n${result.framesDirectory}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        if (result.error != null && !result.success)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              result.error!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.orange),
            ),
          ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              _infoRow('Total Frames', '${result.totalFrames}'),
              _infoRow('Render Time',
                  '${(result.renderTimeMs / 1000).toStringAsFixed(1)}s'),
              _infoRow('Encode Time',
                  '${(result.encodeTimeMs / 1000).toStringAsFixed(1)}s'),
            ],
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_result != null ? 'Close' : 'Cancel'),
          ),
          if (_result == null) ...[
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: _strokeEndCount > 0 ? _startExport : null,
              icon: const Icon(Icons.movie_creation, size: 18),
              label: const Text('Generate Timelapse'),
            ),
          ],
          if (_result != null) ...[
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: () {
                setState(() {
                  _result = null;
                  _progress = null;
                });
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Re-export'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    int? divisions,
    required String suffix,
    required ValueChanged<double> onChanged,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            activeColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 50,
          child: Text(
            '${value.toInt()}$suffix',
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          Text(value,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  String _phaseLabel(TimelapseExportPhase phase) {
    switch (phase) {
      case TimelapseExportPhase.preparing:
        return 'Preparing...';
      case TimelapseExportPhase.rendering:
        return 'Rendering Frames';
      case TimelapseExportPhase.encoding:
        return 'Encoding Video';
      case TimelapseExportPhase.complete:
        return 'Complete!';
      case TimelapseExportPhase.error:
        return 'Error';
    }
  }

  Future<void> _startExport() async {
    setState(() {
      _isExporting = true;
      _progress = null;
      _result = null;
    });

    final service = TimelapseExportService();

    final result = await service.export(
      events: widget.events,
      settings: _settings.copyWith(
        outputWidth: widget.canvasWidth,
        outputHeight: widget.canvasHeight,
      ),
      onProgress: (progress) {
        if (mounted) {
          setState(() => _progress = progress);
        }
      },
    );

    if (mounted) {
      setState(() {
        _isExporting = false;
        _result = result;
      });
    }
  }
}
