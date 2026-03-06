/// Configuration for timelapse video generation.
class TimelapseSettings {
  const TimelapseSettings({
    this.frameRate = 30,
    this.speedMultiplier = 10.0,
    this.outputWidth = 1920,
    this.outputHeight = 1080,
    this.quality = TimelapseQuality.high,
    this.captureLayerEvents = true,
    this.includeUndoRedo = false,
  });

  /// Frames per second in the output video.
  final int frameRate;

  /// How many times faster than real-time to replay.
  /// e.g. 10.0 means a 10-minute drawing becomes ~1 minute video.
  final double speedMultiplier;

  /// Output video width in pixels.
  final int outputWidth;

  /// Output video height in pixels.
  final int outputHeight;

  /// Output quality preset.
  final TimelapseQuality quality;

  /// Whether to capture frames for layer add/delete/reorder events.
  final bool captureLayerEvents;

  /// Whether to include undo/redo operations in the timelapse.
  final bool includeUndoRedo;

  /// Returns the FFmpeg CRF (Constant Rate Factor) value for the quality.
  /// Lower = higher quality (0=lossless, 23=default, 51=worst).
  int get crfValue {
    switch (quality) {
      case TimelapseQuality.low:
        return 28;
      case TimelapseQuality.medium:
        return 23;
      case TimelapseQuality.high:
        return 18;
      case TimelapseQuality.maximum:
        return 12;
    }
  }

  /// Returns the FFmpeg encoding preset for the quality.
  String get ffmpegPreset {
    switch (quality) {
      case TimelapseQuality.low:
        return 'veryfast';
      case TimelapseQuality.medium:
        return 'medium';
      case TimelapseQuality.high:
        return 'slow';
      case TimelapseQuality.maximum:
        return 'veryslow';
    }
  }

  TimelapseSettings copyWith({
    int? frameRate,
    double? speedMultiplier,
    int? outputWidth,
    int? outputHeight,
    TimelapseQuality? quality,
    bool? captureLayerEvents,
    bool? includeUndoRedo,
  }) {
    return TimelapseSettings(
      frameRate: frameRate ?? this.frameRate,
      speedMultiplier: speedMultiplier ?? this.speedMultiplier,
      outputWidth: outputWidth ?? this.outputWidth,
      outputHeight: outputHeight ?? this.outputHeight,
      quality: quality ?? this.quality,
      captureLayerEvents: captureLayerEvents ?? this.captureLayerEvents,
      includeUndoRedo: includeUndoRedo ?? this.includeUndoRedo,
    );
  }
}

/// Quality presets for timelapse video output.
enum TimelapseQuality {
  low,
  medium,
  high,
  maximum,
}
