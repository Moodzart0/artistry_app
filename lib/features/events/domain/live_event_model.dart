/// Status of a live drawing session.
enum LiveEventStatus {
  scheduled,
  live,
  ended,
}

/// Represents a live drawing session hosted by an artist.
/// Maps to the collab_sessions table in Supabase.
class LiveEventModel {
  const LiveEventModel({
    required this.id,
    required this.hostId,
    required this.hostUsername,
    required this.hostAvatarUrl,
    required this.title,
    this.description = '',
    required this.status,
    this.viewerCount = 0,
    this.maxParticipants = 50,
    this.scheduledAt,
    this.startedAt,
    this.endedAt,
    this.thumbnailUrl,
    this.drawingId,
    this.tags = const [],
    required this.createdAt,
  });

  final String id;
  final String hostId;
  final String hostUsername;
  final String hostAvatarUrl;
  final String title;
  final String description;
  final LiveEventStatus status;
  final int viewerCount;
  final int maxParticipants;
  final DateTime? scheduledAt;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final String? thumbnailUrl;
  final String? drawingId;
  final List<String> tags;
  final DateTime createdAt;

  bool get isLive => status == LiveEventStatus.live;
  bool get isScheduled => status == LiveEventStatus.scheduled;
  bool get isEnded => status == LiveEventStatus.ended;

  factory LiveEventModel.fromJson(Map<String, dynamic> json) {
    return LiveEventModel(
      id: json['id'] as String,
      hostId: json['host_id'] as String,
      hostUsername: json['host_username'] as String? ?? 'Artist',
      hostAvatarUrl: json['host_avatar_url'] as String? ?? '',
      title: json['title'] as String? ?? 'Live Session',
      description: json['description'] as String? ?? '',
      status: _parseStatus(json['status'] as String?),
      viewerCount: json['viewer_count'] as int? ?? 0,
      maxParticipants: json['max_participants'] as int? ?? 50,
      scheduledAt: json['scheduled_at'] != null
          ? DateTime.parse(json['scheduled_at'] as String)
          : null,
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'] as String)
          : null,
      endedAt: json['ended_at'] != null
          ? DateTime.parse(json['ended_at'] as String)
          : null,
      thumbnailUrl: json['thumbnail_url'] as String?,
      drawingId: json['drawing_id'] as String?,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'host_id': hostId,
      'title': title,
      'description': description,
      'status': status.name,
      'max_participants': maxParticipants,
      if (scheduledAt != null)
        'scheduled_at': scheduledAt!.toIso8601String(),
      if (startedAt != null) 'started_at': startedAt!.toIso8601String(),
      if (endedAt != null) 'ended_at': endedAt!.toIso8601String(),
      if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
      if (drawingId != null) 'drawing_id': drawingId,
      'tags': tags,
    };
  }

  static LiveEventStatus _parseStatus(String? status) {
    switch (status) {
      case 'live':
        return LiveEventStatus.live;
      case 'ended':
        return LiveEventStatus.ended;
      case 'scheduled':
      default:
        return LiveEventStatus.scheduled;
    }
  }
}
