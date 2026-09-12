import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:readl/core/constants/app_routes.dart';
import 'package:readl/core/providers/core_providers.dart';
import 'package:readl/features/auth/presentation/login_screen.dart';

import '../../support/fake_auth_repository.dart';

void main() {
  testWidgets('affiche des erreurs de validation si le formulaire est vide',
      (tester) async {
    final fakeRepo = FakeAuthRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(fakeRepo)],
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    await tester.tap(find.text('Se connecter'));
    await tester.pump();

    expect(fakeRepo.signInCalled, isFalse);
    expect(find.text('Veuillez saisir votre email.'), findsOneWidget);
    expect(find.text('Veuillez saisir votre mot de passe.'), findsOneWidget);
  });

  testWidgets(
      'appelle signIn avec les identifiants saisis et navigue vers l\'accueil',
      (tester) async {
    final fakeRepo = FakeAuthRepository();

    final router = GoRouter(
      initialLocation: AppRoutes.login,
      routes: [
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: AppRoutes.home,
          builder: (context, state) =>
              const Scaffold(body: Text('Accueil READL')),
        ),
        GoRoute(
          path: AppRoutes.signup,
          builder: (context, state) => const Scaffold(body: Text('Inscription')),
        ),
        GoRoute(
          path: AppRoutes.forgotPassword,
          builder: (context, state) =>
              const Scaffold(body: Text('Mot de passe oublié')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(fakeRepo)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.enterText(
        find.byType(TextFormField).at(0), 'hassan@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'motdepasse');

    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();

    expect(fakeRepo.signInCalled, isTrue);
    expect(fakeRepo.lastEmail, 'hassan@example.com');
    expect(fakeRepo.lastPassword, 'motdepasse');
    expect(find.text('Accueil READL'), findsOneWidget);
  });

  testWidgets('affiche le message d\'erreur du repository en cas d\'échec',
      (tester) async {
    final fakeRepo = FakeAuthRepository()
      ..shouldThrow = true
      ..errorMessage = 'Email ou mot de passe incorrect.';

    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(fakeRepo)],
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    await tester.enterText(
        find.byType(TextFormField).at(0), 'hassan@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'mauvais');

    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();

    expect(find.text('Email ou mot de passe incorrect.'), findsOneWidget);
  });
}
