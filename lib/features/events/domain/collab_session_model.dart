/// Represents a participant in a collaborative drawing session.
class CollabParticipant {
  const CollabParticipant({
    required this.userId,
    required this.username,
    this.avatarUrl,
    this.cursorColor = 0xFF2196F3,
    this.cursorX,
    this.cursorY,
    this.isActive = true,
    this.joinedAt,
  });

  final String userId;
  final String username;
  final String? avatarUrl;
  final int cursorColor;
  final double? cursorX;
  final double? cursorY;
  final bool isActive;
  final DateTime? joinedAt;

  factory CollabParticipant.fromJson(Map<String, dynamic> json) {
    return CollabParticipant(
      userId: json['user_id'] as String,
      username: json['username'] as String? ?? 'Artist',
      avatarUrl: json['avatar_url'] as String?,
      cursorColor: json['cursor_color'] as int? ?? 0xFF2196F3,
      cursorX: (json['cursor_x'] as num?)?.toDouble(),
      cursorY: (json['cursor_y'] as num?)?.toDouble(),
      isActive: json['is_active'] as bool? ?? true,
      joinedAt: json['joined_at'] != null
          ? DateTime.parse(json['joined_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'username': username,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      'cursor_color': cursorColor,
      if (cursorX != null) 'cursor_x': cursorX,
      if (cursorY != null) 'cursor_y': cursorY,
      'is_active': isActive,
    };
  }

  CollabParticipant copyWith({
    double? cursorX,
    double? cursorY,
    bool? isActive,
  }) {
    return CollabParticipant(
      userId: userId,
      username: username,
      avatarUrl: avatarUrl,
      cursorColor: cursorColor,
      cursorX: cursorX ?? this.cursorX,
      cursorY: cursorY ?? this.cursorY,
      isActive: isActive ?? this.isActive,
      joinedAt: joinedAt,
    );
  }
}

/// Represents a real-time collaborative drawing session.
/// Maps to the collab_sessions table in Supabase.
class CollabSessionModel {
  const CollabSessionModel({
    required this.id,
    required this.hostId,
    required this.hostUsername,
    this.hostAvatarUrl,
    required this.title,
    this.description = '',
    this.canvasWidth = 1920,
    this.canvasHeight = 1080,
    this.maxParticipants = 8,
    this.isPublic = true,
    this.inviteCode,
    this.participants = const [],
    this.isActive = true,
    this.drawingId,
    required this.createdAt,
  });

  final String id;
  final String hostId;
  final String hostUsername;
  final String? hostAvatarUrl;
  final String title;
  final String description;
  final int canvasWidth;
  final int canvasHeight;
  final int maxParticipants;
  final bool isPublic;
  final String? inviteCode;
  final List<CollabParticipant> participants;
  final bool isActive;
  final String? drawingId;
  final DateTime createdAt;

  int get participantCount => participants.length;
  bool get isFull => participantCount >= maxParticipants;

  factory CollabSessionModel.fromJson(Map<String, dynamic> json) {
    return CollabSessionModel(
      id: json['id'] as String,
      hostId: json['host_id'] as String,
      hostUsername: json['host_username'] as String? ?? 'Host',
      hostAvatarUrl: json['host_avatar_url'] as String?,
      title: json['title'] as String? ?? 'Collab Session',
      description: json['description'] as String? ?? '',
      canvasWidth: json['canvas_width'] as int? ?? 1920,
      canvasHeight: json['canvas_height'] as int? ?? 1080,
      maxParticipants: json['max_participants'] as int? ?? 8,
      isPublic: json['is_public'] as bool? ?? true,
      inviteCode: json['invite_code'] as String?,
      participants: (json['participants'] as List<dynamic>?)
              ?.map((p) =>
                  CollabParticipant.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      isActive: json['is_active'] as bool? ?? true,
      drawingId: json['drawing_id'] as String?,
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
      'canvas_width': canvasWidth,
      'canvas_height': canvasHeight,
      'max_participants': maxParticipants,
      'is_public': isPublic,
      if (inviteCode != null) 'invite_code': inviteCode,
      'is_active': isActive,
      if (drawingId != null) 'drawing_id': drawingId,
    };
  }
}
