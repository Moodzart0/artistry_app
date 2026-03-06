import 'package:equatable/equatable.dart';

import 'user_profile.dart';

/// Represents the current authentication state.
sealed class AuthState extends Equatable {
  const AuthState();
}

/// Initial state — auth status hasn't been determined yet.
class AuthInitial extends AuthState {
  const AuthInitial();

  @override
  List<Object?> get props => [];
}

/// Auth check is in progress.
class AuthLoading extends AuthState {
  const AuthLoading();

  @override
  List<Object?> get props => [];
}

/// User is authenticated.
class Authenticated extends AuthState {
  const Authenticated({
    required this.userId,
    required this.profile,
  });

  final String userId;
  final UserProfile profile;

  @override
  List<Object?> get props => [userId, profile];
}

/// User is authenticated but needs to complete profile setup.
class AuthNeedsProfileSetup extends AuthState {
  const AuthNeedsProfileSetup({required this.userId});

  final String userId;

  @override
  List<Object?> get props => [userId];
}

/// User is not authenticated.
class Unauthenticated extends AuthState {
  const Unauthenticated();

  @override
  List<Object?> get props => [];
}

/// An authentication error occurred.
class AuthError extends AuthState {
  const AuthError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
