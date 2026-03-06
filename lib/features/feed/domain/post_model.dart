import 'package:equatable/equatable.dart';

import '../../auth/domain/user_profile.dart';

/// Represents an artwork post in the feed.
class PostModel extends Equatable {
  const PostModel({
    required this.id,
    required this.userId,
    this.user,
    this.caption = '',
    required this.imageUrl,
    this.thumbnailUrl,
    this.timelapseUrl,
    this.hasTimelapse = false,
    this.tags = const [],
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isLiked = false,
    this.isBookmarked = false,
    this.createdAt,
  });

  final String id;
  final String userId;
  final UserProfile? user;
  final String caption;
  final String imageUrl;
  final String? thumbnailUrl;
  final String? timelapseUrl;
  final bool hasTimelapse;
  final List<String> tags;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final bool isBookmarked;
  final DateTime? createdAt;

  factory PostModel.fromJson(Map<String, dynamic> json,
      {UserProfile? user}) {
    return PostModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      user: user,
      caption: (json['caption'] as String?) ?? '',
      imageUrl: json['image_url'] as String,
      thumbnailUrl: json['thumbnail_url'] as String?,
      timelapseUrl: json['timelapse_url'] as String?,
      hasTimelapse: json['timelapse_url'] != null,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      likesCount: (json['likes_count'] as int?) ?? 0,
      commentsCount: (json['comments_count'] as int?) ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'caption': caption,
      'image_url': imageUrl,
      'thumbnail_url': thumbnailUrl,
      'timelapse_url': timelapseUrl,
      'tags': tags,
    };
  }

  PostModel copyWith({
    UserProfile? user,
    String? caption,
    int? likesCount,
    int? commentsCount,
    bool? isLiked,
    bool? isBookmarked,
  }) {
    return PostModel(
      id: id,
      userId: userId,
      user: user ?? this.user,
      caption: caption ?? this.caption,
      imageUrl: imageUrl,
      thumbnailUrl: thumbnailUrl,
      timelapseUrl: timelapseUrl,
      hasTimelapse: hasTimelapse,
      tags: tags,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isLiked: isLiked ?? this.isLiked,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [id, userId, likesCount, commentsCount, isLiked, isBookmarked];
}
