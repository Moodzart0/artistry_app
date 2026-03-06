/// Status of a drawing challenge.
enum ChallengeStatus {
  upcoming,
  active,
  voting,
  ended,
}

/// Represents a drawing challenge.
/// Maps to the challenges table in Supabase.
class ChallengeModel {
  const ChallengeModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.theme,
    required this.status,
    this.creatorId,
    this.creatorUsername,
    this.creatorAvatarUrl,
    this.rules = '',
    this.prizeDescription,
    this.entriesCount = 0,
    this.maxEntries,
    this.startDate,
    this.endDate,
    this.votingEndDate,
    this.coverImageUrl,
    this.tags = const [],
    required this.createdAt,
  });

  final String id;
  final String title;
  final String description;
  final String theme;
  final ChallengeStatus status;
  final String? creatorId;
  final String? creatorUsername;
  final String? creatorAvatarUrl;
  final String rules;
  final String? prizeDescription;
  final int entriesCount;
  final int? maxEntries;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? votingEndDate;
  final String? coverImageUrl;
  final List<String> tags;
  final DateTime createdAt;

  bool get isActive => status == ChallengeStatus.active;
  bool get isUpcoming => status == ChallengeStatus.upcoming;
  bool get hasEnded =>
      status == ChallengeStatus.ended || status == ChallengeStatus.voting;

  /// Time remaining until the challenge ends, or null if ended.
  Duration? get timeRemaining {
    if (endDate == null) return null;
    final remaining = endDate!.difference(DateTime.now());
    return remaining.isNegative ? null : remaining;
  }

  factory ChallengeModel.fromJson(Map<String, dynamic> json) {
    return ChallengeModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'Challenge',
      description: json['description'] as String? ?? '',
      theme: json['theme'] as String? ?? '',
      status: _parseStatus(json['status'] as String?),
      creatorId: json['creator_id'] as String?,
      creatorUsername: json['creator_username'] as String?,
      creatorAvatarUrl: json['creator_avatar_url'] as String?,
      rules: json['rules'] as String? ?? '',
      prizeDescription: json['prize_description'] as String?,
      entriesCount: json['entries_count'] as int? ?? 0,
      maxEntries: json['max_entries'] as int?,
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'] as String)
          : null,
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      votingEndDate: json['voting_end_date'] != null
          ? DateTime.parse(json['voting_end_date'] as String)
          : null,
      coverImageUrl: json['cover_image_url'] as String?,
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
      'title': title,
      'description': description,
      'theme': theme,
      'status': status.name,
      if (creatorId != null) 'creator_id': creatorId,
      'rules': rules,
      if (prizeDescription != null) 'prize_description': prizeDescription,
      if (maxEntries != null) 'max_entries': maxEntries,
      if (startDate != null) 'start_date': startDate!.toIso8601String(),
      if (endDate != null) 'end_date': endDate!.toIso8601String(),
      if (votingEndDate != null)
        'voting_end_date': votingEndDate!.toIso8601String(),
      if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
      'tags': tags,
    };
  }

  static ChallengeStatus _parseStatus(String? status) {
    switch (status) {
      case 'active':
        return ChallengeStatus.active;
      case 'voting':
        return ChallengeStatus.voting;
      case 'ended':
        return ChallengeStatus.ended;
      case 'upcoming':
      default:
        return ChallengeStatus.upcoming;
    }
  }
}

/// Represents a user's entry into a challenge.
/// Maps to the challenge_entries table in Supabase.
class ChallengeEntryModel {
  const ChallengeEntryModel({
    required this.id,
    required this.challengeId,
    required this.userId,
    required this.username,
    this.avatarUrl,
    this.postId,
    this.imageUrl,
    this.title = '',
    this.description = '',
    this.votesCount = 0,
    this.rank,
    required this.submittedAt,
  });

  final String id;
  final String challengeId;
  final String userId;
  final String username;
  final String? avatarUrl;
  final String? postId;
  final String? imageUrl;
  final String title;
  final String description;
  final int votesCount;
  final int? rank;
  final DateTime submittedAt;

  factory ChallengeEntryModel.fromJson(Map<String, dynamic> json) {
    return ChallengeEntryModel(
      id: json['id'] as String,
      challengeId: json['challenge_id'] as String,
      userId: json['user_id'] as String,
      username: json['username'] as String? ?? 'Artist',
      avatarUrl: json['avatar_url'] as String?,
      postId: json['post_id'] as String?,
      imageUrl: json['image_url'] as String?,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      votesCount: json['votes_count'] as int? ?? 0,
      rank: json['rank'] as int?,
      submittedAt: json['submitted_at'] != null
          ? DateTime.parse(json['submitted_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'challenge_id': challengeId,
      'user_id': userId,
      if (postId != null) 'post_id': postId,
      if (imageUrl != null) 'image_url': imageUrl,
      'title': title,
      'description': description,
    };
  }
}
