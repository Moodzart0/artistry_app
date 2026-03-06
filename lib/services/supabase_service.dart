import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Wrapper around the Supabase client providing typed access
/// to authentication, database, and storage.
class SupabaseService {
  SupabaseService._();

  /// Whether Supabase has been successfully initialized.
  static bool _initialized = false;
  static bool get isInitialized => _initialized;

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
      authOptions: FlutterAuthClientOptions(
        // Use implicit flow on web (PKCE requires server-side redirect handling).
        authFlowType: kIsWeb ? AuthFlowType.implicit : AuthFlowType.pkce,
      ),
    );
    _initialized = true;
  }

  /// Returns the currently signed-in user, or `null`.
  static User? get currentUser => _initialized ? auth.currentUser : null;

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

/// Riverpod provider for the Supabase client.
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return SupabaseService.client;
});
