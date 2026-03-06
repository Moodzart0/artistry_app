import 'package:supabase_flutter/supabase_flutter.dart';

/// Wrapper around the Supabase client providing typed access
/// to authentication, database, and storage.
class SupabaseService {
  SupabaseService._();

  static SupabaseClient get client => Supabase.instance.client;

  static GoTrueClient get auth => client.auth;

  static SupabaseQueryBuilder from(String table) => client.from(table);

  static SupabaseStorageClient get storage => client.storage;

  /// Initialize Supabase. Call once in main().
  ///
  /// [url] and [anonKey] should be provided via environment config.
  static Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
  }

  /// Returns the currently signed-in user, or `null`.
  static User? get currentUser => auth.currentUser;

  /// Returns the current user's ID, or `null`.
  static String? get currentUserId => currentUser?.id;

  /// Stream of auth state changes.
  static Stream<AuthState> get onAuthStateChange =>
      auth.onAuthStateChange.map((data) => data.session != null
          ? AuthState.authenticated
          : AuthState.unauthenticated);
}

/// Simple enum for auth state from the stream.
enum AuthState { authenticated, unauthenticated }
