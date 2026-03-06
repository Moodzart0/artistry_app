import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/constants/env_config.dart';
import 'services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase with error handling to prevent stuck loading.
  if (EnvConfig.hasCredentials) {
    try {
      await SupabaseService.initialize(
        url: EnvConfig.supabaseUrl,
        anonKey: EnvConfig.supabaseAnonKey,
      );
    } catch (e) {
      debugPrint('Supabase initialization error: $e');
      // Continue running the app — the auth flow will handle
      // missing connections gracefully.
    }
  } else {
    debugPrint('Supabase credentials not provided. '
        'Use --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...');
  }

  runApp(
    const ProviderScope(
      child: ArtistryApp(),
    ),
  );
}
