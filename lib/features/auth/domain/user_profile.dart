import 'package:equatable/equatable.dart';

/// Represents a user profile in the app.
class UserProfile extends Equatable {
  const UserProfile({
    required this.id,
    required this.username,
    required this.displayName,
    this.bio = '',
    this.avatarUrl,
    this.coverImageUrl,
    this.website,
    this.isVerified = false,
    this.isArtistPro = false,
    this.followersCount = 0,
    this.followingCount = 0,
    this.postsCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String username;
  final String displayName;
  final String bio;
  final String? avatarUrl;
  final String? coverImageUrl;
  final String? website;
  final bool isVerified;
  final bool isArtistPro;
  final int followersCount;
  final int followingCount;
  final int postsCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      username: json['username'] as String,
      displayName: json['display_name'] as String,
      bio: (json['bio'] as String?) ?? '',
      avatarUrl: json['avatar_url'] as String?,
      coverImageUrl: json['cover_image_url'] as String?,
      website: json['website'] as String?,
      isVerified: (json['is_verified'] as bool?) ?? false,
      isArtistPro: (json['is_artist_pro'] as bool?) ?? false,
      followersCount: (json['followers_count'] as int?) ?? 0,
      followingCount: (json['following_count'] as int?) ?? 0,
      postsCount: (json['posts_count'] as int?) ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'display_name': displayName,
      'bio': bio,
      'avatar_url': avatarUrl,
      'cover_image_url': coverImageUrl,
      'website': website,
      'is_verified': isVerified,
      'is_artist_pro': isArtistPro,
    };
  }

  UserProfile copyWith({
    String? username,
    String? displayName,
    String? bio,
    String? avatarUrl,
    String? coverImageUrl,
    String? website,
    bool? isVerified,
    bool? isArtistPro,
    int? followersCount,
    int? followingCount,
    int? postsCount,
  }) {
    return UserProfile(
      id: id,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      website: website ?? this.website,
      isVerified: isVerified ?? this.isVerified,
      isArtistPro: isArtistPro ?? this.isArtistPro,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      postsCount: postsCount ?? this.postsCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        username,
        displayName,
        bio,
        avatarUrl,
        coverImageUrl,
        website,
        isVerified,
        isArtistPro,
        followersCount,
        followingCount,
        postsCount,
      ];
}
