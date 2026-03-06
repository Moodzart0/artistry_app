/// Environment configuration for Supabase credentials.
///
/// Replace these placeholder values with your actual Supabase project
/// credentials before running the app. In production, use
/// `--dart-define` or a `.env` loader to inject these at build time.
///
/// Example build command:
/// ```
/// flutter run \
///   --dart-define=SUPABASE_URL=https://your-project.supabase.co \
///   --dart-define=SUPABASE_ANON_KEY=your-anon-key
/// ```
class EnvConfig {
  EnvConfig._();

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://your-project-ref.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'your-anon-key',
  );
}
