import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/supabase_constants.dart';
import '../../../services/supabase_service.dart';
import '../domain/user_profile.dart';

/// Repository handling all authentication and profile operations.
class AuthRepository {
  const AuthRepository();

  // ── Authentication ───────────────────────────────────────────

  /// Sign up with email and password.
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? username,
    String? displayName,
  }) async {
    return SupabaseService.auth.signUp(
      email: email,
      password: password,
      data: {
        if (username != null) 'username': username,
        if (displayName != null) 'display_name': displayName,
      },
    );
  }

  /// Sign in with email and password.
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return SupabaseService.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign in with an OAuth provider (Google, Apple, etc.).
  Future<bool> signInWithOAuth(OAuthProvider provider) async {
    return SupabaseService.auth.signInWithOAuth(provider);
  }

  /// Sign out.
  Future<void> signOut() async {
    await SupabaseService.auth.signOut();
  }

  /// Send a password-reset email.
  Future<void> resetPassword(String email) async {
    await SupabaseService.auth.resetPasswordForEmail(email);
  }

  // ── Profile ──────────────────────────────────────────────────

  /// Fetch the current user's profile.
  Future<UserProfile?> getCurrentProfile() async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) return null;
    return getProfile(userId);
  }

  /// Fetch a profile by user ID.
  Future<UserProfile?> getProfile(String userId) async {
    final response = await SupabaseService.from(SupabaseConstants.profilesTable)
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) return null;
    return UserProfile.fromJson(response);
  }

  /// Check if a username is available.
  Future<bool> isUsernameAvailable(String username) async {
    final response = await SupabaseService.from(SupabaseConstants.profilesTable)
        .select('id')
        .eq('username', username.toLowerCase())
        .maybeSingle();

    return response == null;
  }

  /// Update the current user's profile.
  Future<UserProfile> updateProfile({
    required String userId,
    String? username,
    String? displayName,
    String? bio,
    String? avatarUrl,
    String? coverImageUrl,
    String? website,
  }) async {
    final updates = <String, dynamic>{};
    if (username != null) updates['username'] = username;
    if (displayName != null) updates['display_name'] = displayName;
    if (bio != null) updates['bio'] = bio;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
    if (coverImageUrl != null) updates['cover_image_url'] = coverImageUrl;
    if (website != null) updates['website'] = website;

    final response = await SupabaseService.from(SupabaseConstants.profilesTable)
        .update(updates)
        .eq('id', userId)
        .select()
        .single();

    return UserProfile.fromJson(response);
  }

  /// Upload an avatar image and return its public URL.
  Future<String> uploadAvatar({
    required String userId,
    required String filePath,
    required List<int> fileBytes,
  }) async {
    final extension = filePath.split('.').last;
    final storagePath = '$userId/avatar.$extension';

    await SupabaseService.storage
        .from(SupabaseConstants.avatarsBucket)
        .uploadBinary(
          storagePath,
          fileBytes as dynamic,
          fileOptions: const FileOptions(upsert: true),
        );

    return SupabaseService.storage
        .from(SupabaseConstants.avatarsBucket)
        .getPublicUrl(storagePath);
  }
}
