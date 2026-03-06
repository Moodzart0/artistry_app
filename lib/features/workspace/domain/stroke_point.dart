/// A single point in a stroke, capturing position and stylus data.
class StrokePoint {
  const StrokePoint({
    required this.x,
    required this.y,
    this.pressure = 1.0,
    this.tilt = 0.0,
    this.timestamp,
  });

  final double x;
  final double y;
  final double pressure;
  final double tilt;
  final int? timestamp;

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
      'pressure': pressure,
      'tilt': tilt,
      if (timestamp != null) 'timestamp': timestamp,
    };
  }

  factory StrokePoint.fromJson(Map<String, dynamic> json) {
    return StrokePoint(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      pressure: (json['pressure'] as num?)?.toDouble() ?? 1.0,
      tilt: (json['tilt'] as num?)?.toDouble() ?? 0.0,
      timestamp: json['timestamp'] as int?,
    );
  }
}
