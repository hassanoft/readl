import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/config/env_config.dart';
import 'core/services/supabase_service.dart';
import 'core/theme/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!EnvConfig.isSupabaseConfigured) {
    runApp(const _MissingConfigApp());
    return;
  }

  await SupabaseService.initialize();

  runApp(const ProviderScope(child: ReadlApp()));
}

/// Affiché à la place de l'app si SUPABASE_URL / SUPABASE_ANON_KEY ne
/// sont pas fournis au lancement, plutôt que de planter sans explication.
class _MissingConfigApp extends StatelessWidget {
  const _MissingConfigApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.settings_suggest_outlined,
                  size: 48,
                  color: AppColors.error,
                ),
                SizedBox(height: 16),
                Text(
                  'Configuration manquante',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Text(
                  'SUPABASE_URL et SUPABASE_ANON_KEY doivent être fournis '
                  'via --dart-define au lancement. Voir .env.example et '
                  'le README.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}