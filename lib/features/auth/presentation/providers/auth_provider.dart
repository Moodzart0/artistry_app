import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

import '../../../../services/supabase_service.dart';
import '../../data/auth_repository.dart';
import '../../domain/auth_state.dart';
import '../../domain/user_profile.dart';

/// Provider for the [AuthRepository].
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return const AuthRepository();
});

/// Notifier that manages authentication state.
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._repository) : super(const AuthInitial()) {
    _init();
  }

  final AuthRepository _repository;
  StreamSubscription<dynamic>? _authSubscription;

  void _init() {
    // Guard against Supabase not being initialized (e.g. bad credentials).
    if (!SupabaseService.isInitialized) {
      state = const AuthError(
        message: 'Unable to connect to the server. Please try again later.',
      );
      return;
    }

    // Listen to Supabase auth state changes.
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange
        .listen((data) async {
      if (data.session != null) {
        await _loadProfile(data.session!.user.id);
      } else {
        state = const Unauthenticated();
      }
    }, onError: (Object error) {
      state = const Unauthenticated();
    });

    // Check if already signed in.
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      _loadProfile(session.user.id);
    } else {
      state = const Unauthenticated();
    }
  }

  Future<void> _loadProfile(String userId) async {
    state = const AuthLoading();
    try {
      final profile = await _repository.getProfile(userId);
      if (profile != null) {
        state = Authenticated(userId: userId, profile: profile);
      } else {
        state = AuthNeedsProfileSetup(userId: userId);
      }
    } catch (e) {
      state = AuthError(message: e.toString());
    }
  }

  /// Sign up with email/password.
  Future<void> signUp({
    required String email,
    required String password,
    String? username,
    String? displayName,
  }) async {
    state = const AuthLoading();
    try {
      await _repository.signUp(
        email: email,
        password: password,
        username: username,
        displayName: displayName,
      );
      // Auth state change listener will handle the rest.
    } on AuthException catch (e) {
      state = AuthError(message: e.message);
    } catch (e) {
      state = AuthError(message: 'Sign up failed: $e');
    }
  }

  /// Sign in with email/password.
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AuthLoading();
    try {
      await _repository.signIn(email: email, password: password);
      // Auth state change listener will handle the rest.
    } on AuthException catch (e) {
      state = AuthError(message: e.message);
    } catch (e) {
      state = AuthError(message: 'Sign in failed: $e');
    }
  }

  /// Sign out.
  Future<void> signOut() async {
    await _repository.signOut();
    state = const Unauthenticated();
  }

  /// Send password-reset email.
  Future<void> resetPassword(String email) async {
    await _repository.resetPassword(email);
  }

  /// Complete profile setup after first sign-up.
  Future<void> completeProfileSetup({
    required String userId,
    required String username,
    required String displayName,
    String? bio,
    String? avatarUrl,
  }) async {
    state = const AuthLoading();
    try {
      final profile = await _repository.updateProfile(
        userId: userId,
        username: username,
        displayName: displayName,
        bio: bio,
        avatarUrl: avatarUrl,
      );
      state = Authenticated(userId: userId, profile: profile);
    } catch (e) {
      state = AuthError(message: 'Profile setup failed: $e');
    }
  }

  /// Refresh the current profile data.
  Future<void> refreshProfile() async {
    final currentState = state;
    if (currentState is Authenticated) {
      final profile = await _repository.getProfile(currentState.userId);
      if (profile != null) {
        state = Authenticated(userId: currentState.userId, profile: profile);
      }
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

/// Provider for the [AuthNotifier].
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});

/// Convenience provider for the current user profile.
final currentProfileProvider = Provider<UserProfile?>((ref) {
  final authState = ref.watch(authProvider);
  if (authState is Authenticated) {
    return authState.profile;
  }
  return null;
});
