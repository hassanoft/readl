import 'package:supabase_flutter/supabase_flutter.dart' show AuthState, Session;

/// Contrat d'authentification de READL.
///
/// Toute la logique métier (contrôleurs, écrans) dépend de cette
/// interface, jamais directement de Supabase. Cela permet de remplacer
/// l'implémentation plus tard sans réécrire les écrans.
abstract class AuthRepository {
  /// Flux des changements d'état d'authentification (connexion,
  /// déconnexion, rafraîchissement de session...).
  Stream<AuthState> get authStateChanges;

  /// Session active, si l'utilisateur est déjà connecté.
  Session? get currentSession;

  /// Prénom de l'utilisateur connecté, lu depuis les métadonnées du
  /// compte pour un affichage immédiat (ex. "Bonjour, Hassan") sans
  /// attendre une requête réseau supplémentaire.
  String? get currentFirstName;

  String? get currentEmail;

  Future<void> signUp({
    required String firstName,
    required String email,
    required String password,
  });

  Future<void> signIn({
    required String email,
    required String password,
  });

  Future<void> sendPasswordResetEmail(String email);

  Future<void> signOut();
}
