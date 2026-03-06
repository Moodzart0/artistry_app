import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Result of a video encoding operation.
class VideoEncodeResult {
  const VideoEncodeResult({
    required this.success,
    this.outputPath,
    this.error,
    this.framesDirectory,
  });

  /// Whether the encoding was successful.
  final bool success;

  /// Path to the generated MP4 video file.
  final String? outputPath;

  /// Error message if encoding failed.
  final String? error;

  /// Path to the directory containing individual frame PNGs.
  /// Available even if MP4 encoding fails, so frames can be used externally.
  final String? framesDirectory;
}

/// Callback for reporting video encoding progress.
typedef VideoEncodeProgressCallback = void Function(
    int currentStep, int totalSteps, String phase);

/// Encodes a sequence of PNG frames into an MP4 video file.
///
/// Uses a two-step process:
/// 1. Save PNG frames to a temporary directory as numbered files
/// 2. Use FFmpeg (via system Process) to encode frames into H.264 MP4
///
/// On platforms where FFmpeg is not available, the frames are saved
/// as individual PNGs for manual encoding.
class VideoEncoder {
  VideoEncoder({
    this.onProgress,
  });

  final VideoEncodeProgressCallback? onProgress;

  /// Encodes a list of PNG frame bytes into an MP4 video.
  ///
  /// [frames] - List of PNG-encoded image bytes.
  /// [frameRate] - Target frames per second for the video.
  /// [crfValue] - FFmpeg CRF quality (0=lossless, 23=default, 51=worst).
  /// [preset] - FFmpeg encoding speed preset (e.g., 'medium', 'slow').
  /// [outputFileName] - Name for the output video file.
  Future<VideoEncodeResult> encode({
    required List<Uint8List> frames,
    int frameRate = 30,
    int crfValue = 18,
    String preset = 'medium',
    String outputFileName = 'timelapse.mp4',
  }) async {
    if (frames.isEmpty) {
      return const VideoEncodeResult(
        success: false,
        error: 'No frames to encode.',
      );
    }

    try {
      // ── Step 1: Save frames to temporary directory ──────────────
      onProgress?.call(0, frames.length + 1, 'Saving frames...');

      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final framesDir = Directory(
          '${tempDir.path}/artistry_timelapse_$timestamp');
      await framesDir.create(recursive: true);

      // Save each frame as a numbered PNG
      for (int i = 0; i < frames.length; i++) {
        final framePath =
            '${framesDir.path}/frame_${i.toString().padLeft(5, '0')}.png';
        await File(framePath).writeAsBytes(frames[i]);

        if (i % 10 == 0) {
          onProgress?.call(i + 1, frames.length + 1, 'Saving frames...');
        }
      }

      onProgress?.call(
          frames.length, frames.length + 1, 'Encoding video...');

      // ── Step 2: Encode to MP4 using FFmpeg ──────────────────────
      final outputPath = '${tempDir.path}/$outputFileName';

      final ffmpegResult = await _encodeWithFfmpeg(
        framesDir: framesDir.path,
        outputPath: outputPath,
        frameRate: frameRate,
        crfValue: crfValue,
        preset: preset,
      );

      if (ffmpegResult) {
        onProgress?.call(
            frames.length + 1, frames.length + 1, 'Complete!');
        return VideoEncodeResult(
          success: true,
          outputPath: outputPath,
          framesDirectory: framesDir.path,
        );
      } else {
        // FFmpeg not available or failed — frames are still saved
        return VideoEncodeResult(
          success: false,
          error: 'FFmpeg encoding failed. Frames saved to: ${framesDir.path}',
          framesDirectory: framesDir.path,
        );
      }
    } catch (e) {
      return VideoEncodeResult(
        success: false,
        error: 'Encoding error: $e',
      );
    }
  }

  /// Attempts to encode frames using system FFmpeg via Process.run.
  Future<bool> _encodeWithFfmpeg({
    required String framesDir,
    required String outputPath,
    required int frameRate,
    required int crfValue,
    required String preset,
  }) async {
    // Skip on web platform
    if (kIsWeb) return false;

    try {
      // Check if FFmpeg is available
      final whichResult = await Process.run('which', ['ffmpeg']);
      if (whichResult.exitCode != 0) {
        // Try common paths
        final commonPaths = [
          '/usr/bin/ffmpeg',
          '/usr/local/bin/ffmpeg',
          '/opt/homebrew/bin/ffmpeg',
        ];

        String? ffmpegPath;
        for (final path in commonPaths) {
          if (await File(path).exists()) {
            ffmpegPath = path;
            break;
          }
        }

        if (ffmpegPath == null) {
          debugPrint('FFmpeg not found on system.');
          return false;
        }
      }

      // Build FFmpeg command
      // Input: numbered PNG frames
      // Output: H.264 MP4 with specified quality
      final args = [
        '-y', // Overwrite output
        '-framerate', '$frameRate',
        '-i', '$framesDir/frame_%05d.png',
        '-c:v', 'libx264',
        '-pix_fmt', 'yuv420p',
        '-crf', '$crfValue',
        '-preset', preset,
        '-movflags', '+faststart', // Enable streaming
        outputPath,
      ];

      debugPrint('Running FFmpeg: ffmpeg ${args.join(' ')}');

      final result = await Process.run('ffmpeg', args);

      if (result.exitCode == 0) {
        debugPrint('FFmpeg encoding successful: $outputPath');
        return true;
      } else {
        debugPrint('FFmpeg error (exit ${result.exitCode}): ${result.stderr}');
        return false;
      }
    } catch (e) {
      debugPrint('FFmpeg process error: $e');
      return false;
    }
  }

  /// Cleans up temporary frame files.
  Future<void> cleanup(String framesDirectory) async {
    try {
      final dir = Directory(framesDirectory);
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    } catch (e) {
      debugPrint('Cleanup error: $e');
    }
  }
}
