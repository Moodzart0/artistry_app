import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../services/supabase_service.dart';
import '../../auth/domain/user_profile.dart';

/// Repository for user profile operations, connecting to the Supabase backend.
class ProfileRepository {
  ProfileRepository(this._client);

  final SupabaseClient _client;

  /// Fetches a user profile by ID.
  Future<UserProfile?> getProfile(String userId) async {
    final response = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) return null;
    return UserProfile.fromJson(response);
  }

  /// Fetches the current user's profile.
  Future<UserProfile?> getCurrentProfile() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;
    return getProfile(userId);
  }

  /// Updates the current user's profile.
  Future<UserProfile?> updateProfile({
    String? displayName,
    String? username,
    String? bio,
    String? avatarUrl,
    String? coverImageUrl,
    String? website,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

    final updates = <String, dynamic>{};
    if (displayName != null) updates['display_name'] = displayName;
    if (username != null) updates['username'] = username;
    if (bio != null) updates['bio'] = bio;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
    if (coverImageUrl != null) updates['cover_image_url'] = coverImageUrl;
    if (website != null) updates['website'] = website;

    if (updates.isEmpty) return getCurrentProfile();

    final response = await _client
        .from('profiles')
        .update(updates)
        .eq('id', userId)
        .select()
        .single();

    return UserProfile.fromJson(response);
  }

  /// Follows a user.
  Future<void> followUser(String targetUserId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    await _client.from('follows').insert({
      'follower_id': userId,
      'following_id': targetUserId,
    });
  }

  /// Unfollows a user.
  Future<void> unfollowUser(String targetUserId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    await _client
        .from('follows')
        .delete()
        .eq('follower_id', userId)
        .eq('following_id', targetUserId);
  }

  /// Checks if the current user follows a target user.
  Future<bool> isFollowing(String targetUserId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return false;

    final response = await _client
        .from('follows')
        .select()
        .eq('follower_id', userId)
        .eq('following_id', targetUserId)
        .maybeSingle();

    return response != null;
  }

  /// Searches for users by username or display name.
  Future<List<UserProfile>> searchUsers(String query,
      {int limit = 20}) async {
    final response = await _client
        .from('profiles')
        .select()
        .or('username.ilike.%$query%,display_name.ilike.%$query%')
        .limit(limit);

    return (response as List)
        .map((json) => UserProfile.fromJson(json))
        .toList();
  }
}

/// Provider for ProfileRepository.
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(supabaseClientProvider));
});
