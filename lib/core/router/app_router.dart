import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/auth_state.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/profile_setup_screen.dart';
import '../../features/auth/presentation/screens/sign_up_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../constants/route_constants.dart';
import '../widgets/main_shell.dart';

/// Application router configuration using GoRouter with auth-based redirects.
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: RouteConstants.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final currentPath = state.uri.path;
      final isAuthRoute = currentPath == RouteConstants.login ||
          currentPath == RouteConstants.signUp ||
          currentPath == RouteConstants.splash;
      final isProfileSetup = currentPath == RouteConstants.profileSetup;

      // Still loading — stay on splash.
      if (authState is AuthInitial || authState is AuthLoading) {
        return isAuthRoute ? null : RouteConstants.splash;
      }

      // Not authenticated — force to login.
      if (authState is Unauthenticated || authState is AuthError) {
        return isAuthRoute ? null : RouteConstants.login;
      }

      // Needs profile setup.
      if (authState is AuthNeedsProfileSetup) {
        return isProfileSetup ? null : RouteConstants.profileSetup;
      }

      // Authenticated — redirect away from auth routes.
      if (authState is Authenticated) {
        if (isAuthRoute || isProfileSetup) {
          return RouteConstants.home;
        }
        return null;
      }

      return null;
    },
    routes: [
      // Auth routes
      GoRoute(
        path: RouteConstants.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteConstants.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteConstants.signUp,
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: RouteConstants.profileSetup,
        builder: (context, state) => const ProfileSetupScreen(),
      ),

      // Main app shell with bottom navigation
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: RouteConstants.home,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: _PlaceholderScreen(title: 'Feed', icon: Icons.home),
            ),
          ),
          GoRoute(
            path: RouteConstants.explore,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: _PlaceholderScreen(title: 'Explore', icon: Icons.explore),
            ),
          ),
          GoRoute(
            path: RouteConstants.workspace,
            pageBuilder: (context, state) => const NoTransitionPage(
              child:
                  _PlaceholderScreen(title: 'Workspace', icon: Icons.brush),
            ),
          ),
          GoRoute(
            path: RouteConstants.messages,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: _PlaceholderScreen(
                  title: 'Messages', icon: Icons.chat_bubble_outline),
            ),
          ),
          GoRoute(
            path: RouteConstants.profile,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: _PlaceholderScreen(
                  title: 'Profile', icon: Icons.person_outline),
            ),
          ),
        ],
      ),
    ],
  );
});

/// Temporary placeholder screen used for tabs not yet implemented.
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Coming in Phase 2+',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
