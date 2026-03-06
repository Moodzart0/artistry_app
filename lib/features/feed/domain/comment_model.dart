import 'package:equatable/equatable.dart';

import '../../auth/domain/user_profile.dart';

/// Represents a comment on a post.
class CommentModel extends Equatable {
  const CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    this.user,
    required this.content,
    this.parentCommentId,
    this.likesCount = 0,
    this.createdAt,
  });

  final String id;
  final String postId;
  final String userId;
  final UserProfile? user;
  final String content;
  final String? parentCommentId;
  final int likesCount;
  final DateTime? createdAt;

  factory CommentModel.fromJson(Map<String, dynamic> json,
      {UserProfile? user}) {
    return CommentModel(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      userId: json['user_id'] as String,
      user: user,
      content: json['content'] as String,
      parentCommentId: json['parent_comment_id'] as String?,
      likesCount: (json['likes_count'] as int?) ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [id, postId, userId, content, likesCount];
}
