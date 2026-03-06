/// Supabase table names, bucket names, and configuration constants.
///
/// The actual Supabase URL and Anon Key are provided at runtime
/// via environment configuration or the Supabase init call.
class SupabaseConstants {
  SupabaseConstants._();

  // ── Table names ──────────────────────────────────────────────
  static const String profilesTable = 'profiles';
  static const String postsTable = 'posts';
  static const String commentsTable = 'comments';
  static const String likesTable = 'likes';
  static const String followsTable = 'follows';
  static const String drawingMetadataTable = 'drawing_metadata';
  static const String strokeEventsTable = 'stroke_events';
  static const String conversationsTable = 'conversations';
  static const String conversationParticipantsTable =
      'conversation_participants';
  static const String messagesTable = 'messages';
  static const String challengesTable = 'challenges';
  static const String challengeEntriesTable = 'challenge_entries';
  static const String collabSessionsTable = 'collab_sessions';

  // ── Storage bucket names ─────────────────────────────────────
  static const String avatarsBucket = 'avatars';
  static const String postImagesBucket = 'post-images';
  static const String timelapsesBucket = 'timelapses';
  static const String drawingsBucket = 'drawings';
  static const String chatMediaBucket = 'chat-media';
}
