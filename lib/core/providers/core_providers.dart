import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/supabase_auth_repository.dart';
import '../services/supabase_service.dart';

/// Client Supabase déjà initialisé dans `main.dart`.
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return SupabaseService.client;
});

/// Point d'accès unique à l'authentification pour tout le reste de
/// l'app. Remplacer cette implémentation (ex. autre backend) ne
/// nécessite de modifier que cette ligne.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return SupabaseAuthRepository(ref.watch(supabaseClientProvider));
});

/// Flux d'état d'authentification, utilisé par le routeur pour rediriger
/// automatiquement entre les écrans connecté/non connecté.
final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});
