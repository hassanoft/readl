import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/app_exception.dart';
import 'auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client);

  final SupabaseClient _client;

  @override
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  @override
  Session? get currentSession => _client.auth.currentSession;

  @override
  String? get currentFirstName =>
      _client.auth.currentUser?.userMetadata?['first_name'] as String?;

  @override
  String? get currentEmail => _client.auth.currentUser?.email;

  @override
  Future<void> signUp({
    required String firstName,
    required String email,
    required String password,
  }) async {
    try {
      await _client.auth.signUp(
        email: email,
        password: password,
        data: {'first_name': firstName},
      );
    } catch (error) {
      _fail('signUp', error);
    }
  }

  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
    } catch (error) {
      _fail('signIn', error);
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (error) {
      _fail('sendPasswordResetEmail', error);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (error) {
      _fail('signOut', error);
    }
  }

  /// Journalise l'erreur brute en mode debug (visible dans `flutter run` /
  /// logcat) avant de la traduire en message français pour l'UI. Utile
  /// pour diagnostiquer une mauvaise configuration Supabase (URL/clé
  /// incorrecte, schéma non exécuté...) sans exposer de détails
  /// techniques à l'utilisateur final.
  Never _fail(String action, Object error) {
    if (kDebugMode) {
      debugPrint('[READL][Auth] $action a échoué → $error');
    }
    throw AppException(describeError(error));
  }
}
