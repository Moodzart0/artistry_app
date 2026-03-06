/// Application-wide constants.
class AppConstants {
  AppConstants._();

  static const String appName = 'Artistry';
  static const String appTagline = 'Create. Share. Inspire.';

  // Default canvas dimensions
  static const int defaultCanvasWidth = 1920;
  static const int defaultCanvasHeight = 1080;

  // Pagination
  static const int postsPerPage = 20;
  static const int commentsPerPage = 30;
  static const int messagesPerPage = 50;

  // Image constraints
  static const int maxImageWidth = 4096;
  static const int maxImageHeight = 4096;
  static const int thumbnailSize = 300;
  static const int maxImageSizeBytes = 10 * 1024 * 1024; // 10 MB

  // Profile constraints
  static const int maxUsernameLength = 30;
  static const int minUsernameLength = 3;
  static const int maxBioLength = 300;
  static const int maxDisplayNameLength = 50;

  // Collab session
  static const int defaultMaxCollabParticipants = 4;
  static const int maxCollabParticipants = 8;
}
