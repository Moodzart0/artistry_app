import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../services/supabase_service.dart';
import '../../auth/domain/user_profile.dart';
import '../domain/post_model.dart';

/// Repository for post-related operations, connecting to the Supabase backend.
class PostRepository {
  PostRepository(this._client);

  final SupabaseClient _client;

  /// Fetches the home feed posts (from followed users + trending).
  Future<List<PostModel>> getFeedPosts({int limit = 20, int offset = 0}) async {
    final response = await _client
        .from('posts')
        .select('*, profiles(*)')
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (response as List).map((json) {
      final profileJson = json['profiles'] as Map<String, dynamic>?;
      final user =
          profileJson != null ? UserProfile.fromJson(profileJson) : null;
      return PostModel.fromJson(json, user: user);
    }).toList();
  }

  /// Fetches posts for the explore/discover page.
  Future<List<PostModel>> getExplorePosts(
      {int limit = 30, int offset = 0, String? tag}) async {
    var query = _client
        .from('posts')
        .select('*, profiles(*)');

    if (tag != null && tag.isNotEmpty && tag != 'All') {
      query = query.contains('tags', [tag.toLowerCase()]);
    }

    final response = await query
        .order('likes_count', ascending: false)
        .range(offset, offset + limit - 1);

    return (response as List).map((json) {
      final profileJson = json['profiles'] as Map<String, dynamic>?;
      final user =
          profileJson != null ? UserProfile.fromJson(profileJson) : null;
      return PostModel.fromJson(json, user: user);
    }).toList();
  }

  /// Fetches posts by a specific user.
  Future<List<PostModel>> getUserPosts(String userId,
      {int limit = 30, int offset = 0}) async {
    final response = await _client
        .from('posts')
        .select('*, profiles(*)')
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (response as List).map((json) {
      final profileJson = json['profiles'] as Map<String, dynamic>?;
      final user =
          profileJson != null ? UserProfile.fromJson(profileJson) : null;
      return PostModel.fromJson(json, user: user);
    }).toList();
  }

  /// Toggles a like on a post.
  Future<bool> toggleLike(String postId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return false;

    // Check if already liked
    final existing = await _client
        .from('likes')
        .select()
        .eq('user_id', userId)
        .eq('target_id', postId)
        .eq('target_type', 'post')
        .maybeSingle();

    if (existing != null) {
      // Unlike
      await _client.from('likes').delete().eq('id', existing['id']);
      return false;
    } else {
      // Like
      await _client.from('likes').insert({
        'user_id': userId,
        'target_id': postId,
        'target_type': 'post',
      });
      return true;
    }
  }

  /// Creates a new post.
  Future<PostModel?> createPost({
    required String imageUrl,
    String? caption,
    List<String>? tags,
    String? thumbnailUrl,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

    final response = await _client
        .from('posts')
        .insert({
          'user_id': userId,
          'image_url': imageUrl,
          'caption': caption ?? '',
          'tags': tags ?? [],
          'thumbnail_url': thumbnailUrl,
        })
        .select('*, profiles(*)')
        .single();

    final profileJson = response['profiles'] as Map<String, dynamic>?;
    final user =
        profileJson != null ? UserProfile.fromJson(profileJson) : null;
    return PostModel.fromJson(response, user: user);
  }
}

/// Provider for PostRepository.
final postRepositoryProvider = Provider<PostRepository>((ref) {
  return PostRepository(ref.watch(supabaseClientProvider));
});
