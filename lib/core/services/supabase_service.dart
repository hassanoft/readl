import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/env_config.dart';

/// Initialise le client Supabase et expose un accès centralisé à celui-ci.
///
/// Toute la Database utilise Row Level Security (voir supabase/schema.sql) :
/// le client ici n'utilise jamais la clé de service (service role), qui ne
/// doit exister que côté serveur (Edge Functions), jamais dans l'app.
abstract final class SupabaseService {
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    if (!EnvConfig.isSupabaseConfigured) {
      throw StateError(
        'Configuration Supabase manquante. Fournissez SUPABASE_URL et '
        'SUPABASE_ANON_KEY via --dart-define (voir .env.example).',
      );
    }

    await Supabase.initialize(
      url: EnvConfig.supabaseUrl,
      // `publishableKey` est le nom actuel du paramètre pour la clé
      // publique (anon). `anonKey` existe encore mais est déprécié.
      publishableKey: EnvConfig.supabaseAnonKey,
      debug: false,
    );

    _initialized = true;
  }

  static SupabaseClient get client => Supabase.instance.client;
}
