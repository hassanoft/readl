/// Accès centralisé aux variables d'environnement de READL.
///
/// IMPORTANT (spec section 4 et 16) : aucune clé secrète n'est écrite en
/// dur dans le code. Les valeurs sont injectées au moment du build via
/// `--dart-define`, jamais commitées.
///
/// En local :
///   flutter run \
///     --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
///     --dart-define=SUPABASE_ANON_KEY=xxxx
///
/// Ou avec un fichier (voir .env.example, à copier en env.json localement,
/// jamais commité) :
///   flutter run --dart-define-from-file=env.json
///
/// En CI (GitHub Actions), ces valeurs viennent de Secrets du dépôt —
/// voir .github/workflows (ajoutés à une prochaine étape).
abstract final class EnvConfig {
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY');

  static const String aiApiUrl = String.fromEnvironment('AI_API_URL');
  static const String aiApiKey = String.fromEnvironment('AI_API_KEY');

  /// Vérifie que la configuration minimale (Supabase) est présente.
  /// Appelé au démarrage pour échouer tôt et clairement plutôt que
  /// d'obtenir une erreur réseau confuse plus tard.
  static bool get isSupabaseConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
