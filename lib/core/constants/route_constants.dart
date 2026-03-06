/// Named route paths used throughout the app.
class RouteConstants {
  RouteConstants._();

  // Auth
  static const String splash = '/';
  static const String login = '/login';
  static const String signUp = '/sign-up';
  static const String profileSetup = '/profile-setup';

  // Main tabs
  static const String home = '/home';
  static const String explore = '/explore';
  static const String workspace = '/workspace';
  static const String messages = '/messages';
  static const String profile = '/profile';

  // Detail screens
  static const String postDetail = '/post/:id';
  static const String userProfile = '/user/:id';
  static const String chatDetail = '/messages/:id';
  static const String challengeDetail = '/challenge/:id';
  static const String collabSession = '/collab/:id';
}
