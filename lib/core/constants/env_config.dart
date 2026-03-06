/// Environment configuration for Supabase credentials.
///
/// Credentials are injected at build/run time using `--dart-define`:
/// ```
/// flutter run -d chrome \
///   --dart-define=SUPABASE_URL=https://your-project.supabase.co \
///   --dart-define=SUPABASE_ANON_KEY=your-anon-key
/// ```
class EnvConfig {
  EnvConfig._();

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  /// Returns true if Supabase credentials have been provided.
  static bool get hasCredentials =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
