import 'package:flutter/foundation.dart';

import '../../domain/stroke_event.dart';
import '../../domain/timelapse_settings.dart';
import 'timelapse_renderer.dart';
import 'video_encoder.dart';

/// Overall export progress state.
class TimelapseExportProgress {
  const TimelapseExportProgress({
    required this.phase,
    required this.progress,
    this.message = '',
  });

  /// Current phase of the export process.
  final TimelapseExportPhase phase;

  /// Progress as a value from 0.0 to 1.0.
  final double progress;

  /// Human-readable status message.
  final String message;
}

/// Phases of the timelapse export process.
enum TimelapseExportPhase {
  preparing,
  rendering,
  encoding,
  complete,
  error,
}

/// Result of the full timelapse export pipeline.
class TimelapseExportResult {
  const TimelapseExportResult({
    required this.success,
    this.videoPath,
    this.framesDirectory,
    this.error,
    this.totalFrames = 0,
    this.renderTimeMs = 0,
    this.encodeTimeMs = 0,
  });

  final bool success;
  final String? videoPath;
  final String? framesDirectory;
  final String? error;
  final int totalFrames;
  final int renderTimeMs;
  final int encodeTimeMs;
}

/// Orchestrates the full timelapse export pipeline:
/// 1. Renders frames from stroke events using off-screen canvas
/// 2. Encodes frames into MP4 video using FFmpeg
///
/// Usage:
/// ```dart
/// final service = TimelapseExportService();
/// final result = await service.export(
///   events: controller.eventLog,
///   settings: TimelapseSettings(),
///   onProgress: (progress) => setState(() => _progress = progress),
/// );
/// ```
class TimelapseExportService {
  /// Exports a timelapse video from recorded stroke events.
  Future<TimelapseExportResult> export({
    required List<StrokeEvent> events,
    TimelapseSettings settings = const TimelapseSettings(),
    ValueChanged<TimelapseExportProgress>? onProgress,
  }) async {
    final totalStopwatch = Stopwatch()..start();
    int renderTimeMs = 0;

    try {
      // ── Phase 1: Render frames ─────────────────────────────────
      onProgress?.call(const TimelapseExportProgress(
        phase: TimelapseExportPhase.preparing,
        progress: 0.0,
        message: 'Preparing stroke events...',
      ));

      final renderer = TimelapseRenderer(
        settings: settings,
        onProgress: (current, total, phase) {
          final progress = total > 0 ? current / total : 0.0;
          onProgress?.call(TimelapseExportProgress(
            phase: TimelapseExportPhase.rendering,
            progress: progress * 0.7, // Rendering is ~70% of total work
            message: '$phase ($current / $total frames)',
          ));
        },
      );

      final renderStopwatch = Stopwatch()..start();
      final renderResult = await renderer.render(events);
      renderStopwatch.stop();
      renderTimeMs = renderStopwatch.elapsedMilliseconds;

      if (renderResult.frames.isEmpty) {
        return const TimelapseExportResult(
          success: false,
          error: 'No frames were generated. Draw something first!',
        );
      }

      debugPrint(
        'Rendered ${renderResult.frames.length} frames in ${renderTimeMs}ms',
      );

      // ── Phase 2: Encode to video ───────────────────────────────
      onProgress?.call(TimelapseExportProgress(
        phase: TimelapseExportPhase.encoding,
        progress: 0.7,
        message: 'Encoding ${renderResult.frames.length} frames to MP4...',
      ));

      final encoder = VideoEncoder(
        onProgress: (current, total, phase) {
          final progress = 0.7 + (total > 0 ? (current / total) * 0.3 : 0.0);
          onProgress?.call(TimelapseExportProgress(
            phase: TimelapseExportPhase.encoding,
            progress: progress,
            message: phase,
          ));
        },
      );

      final encodeStopwatch = Stopwatch()..start();
      final encodeResult = await encoder.encode(
        frames: renderResult.frames,
        frameRate: settings.frameRate,
        crfValue: settings.crfValue,
        preset: settings.ffmpegPreset,
        outputFileName:
            'artistry_timelapse_${DateTime.now().millisecondsSinceEpoch}.mp4',
      );
      encodeStopwatch.stop();
      final encodeTimeMs = encodeStopwatch.elapsedMilliseconds;

      totalStopwatch.stop();

      // ── Phase 3: Report result ─────────────────────────────────
      if (encodeResult.success) {
        onProgress?.call(TimelapseExportProgress(
          phase: TimelapseExportPhase.complete,
          progress: 1.0,
          message:
              'Timelapse ready! ${renderResult.frames.length} frames, '
              '${(totalStopwatch.elapsedMilliseconds / 1000).toStringAsFixed(1)}s total',
        ));

        return TimelapseExportResult(
          success: true,
          videoPath: encodeResult.outputPath,
          framesDirectory: encodeResult.framesDirectory,
          totalFrames: renderResult.frames.length,
          renderTimeMs: renderTimeMs,
          encodeTimeMs: encodeTimeMs,
        );
      } else {
        // Encoding failed but frames are saved
        onProgress?.call(TimelapseExportProgress(
          phase: TimelapseExportPhase.complete,
          progress: 1.0,
          message:
              'Frames saved (${renderResult.frames.length} frames). '
              'MP4 encoding requires FFmpeg.',
        ));

        return TimelapseExportResult(
          success: false,
          framesDirectory: encodeResult.framesDirectory,
          error: encodeResult.error,
          totalFrames: renderResult.frames.length,
          renderTimeMs: renderTimeMs,
          encodeTimeMs: encodeTimeMs,
        );
      }
    } catch (e) {
      totalStopwatch.stop();

      onProgress?.call(TimelapseExportProgress(
        phase: TimelapseExportPhase.error,
        progress: 0.0,
        message: 'Export failed: $e',
      ));

      return TimelapseExportResult(
        success: false,
        error: 'Export failed: $e',
        renderTimeMs: renderTimeMs,
      );
    }
  }
}
