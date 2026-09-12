import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../data/repositories/auth_repository.dart';

/// Pilote les actions d'authentification (connexion, inscription, mot
/// de passe oublié) et expose un état de chargement/erreur unique que
/// les écrans peuvent observer pour afficher un indicateur ou un message.
class AuthController extends StateNotifier<AsyncValue<void>> {
  AuthController(this._repository) : super(const AsyncValue.data(null));

  final AuthRepository _repository;

  Future<bool> signIn({
    required String email,
    required String password,
  }) => _run(() => _repository.signIn(email: email, password: password));

  Future<bool> signUp({
    required String firstName,
    required String email,
    required String password,
  }) => _run(() => _repository.signUp(
        firstName: firstName,
        email: email,
        password: password,
      ));

  Future<bool> sendPasswordResetEmail(String email) =>
      _run(() => _repository.sendPasswordResetEmail(email));

  Future<bool> signOut() => _run(_repository.signOut);

  Future<bool> _run(Future<void> Function() action) async {
    state = const AsyncValue.loading();
    try {
      await action();
      state = const AsyncValue.data(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  return AuthController(ref.watch(authRepositoryProvider));
});
