import 'package:readl/core/errors/app_exception.dart';
import 'package:readl/data/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthState, Session;

/// Double de test pour [AuthRepository].
///
/// Ne dépend d'aucun backend réel : permet de tester les écrans
/// d'authentification en isolant complètement Supabase.
class FakeAuthRepository implements AuthRepository {
  bool signInCalled = false;
  bool signUpCalled = false;
  bool sendPasswordResetEmailCalled = false;
  bool signOutCalled = false;

  String? lastEmail;
  String? lastPassword;
  String? lastFirstName;

  /// Si vrai, la prochaine action lèvera une [AppException].
  bool shouldThrow = false;
  String errorMessage = 'Une erreur est survenue.';

  @override
  Stream<AuthState> get authStateChanges => const Stream.empty();

  @override
  Session? get currentSession => null;

  @override
  String? get currentFirstName => null;

  @override
  String? get currentEmail => null;

  @override
  Future<void> signIn({required String email, required String password}) async {
    signInCalled = true;
    lastEmail = email;
    lastPassword = password;
    if (shouldThrow) throw AppException(errorMessage);
  }

  @override
  Future<void> signUp({
    required String firstName,
    required String email,
    required String password,
  }) async {
    signUpCalled = true;
    lastFirstName = firstName;
    lastEmail = email;
    lastPassword = password;
    if (shouldThrow) throw AppException(errorMessage);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    sendPasswordResetEmailCalled = true;
    lastEmail = email;
    if (shouldThrow) throw AppException(errorMessage);
  }

  @override
  Future<void> signOut() async {
    signOutCalled = true;
    if (shouldThrow) throw AppException(errorMessage);
  }
}
