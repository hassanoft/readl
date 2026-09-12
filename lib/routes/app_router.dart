import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_routes.dart';
import '../core/providers/core_providers.dart';
import '../core/theme/app_colors.dart';
import '../features/auth/presentation/forgot_password_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/signup_screen.dart';
import '../features/home/presentation/home_shell.dart';
import '../features/library/presentation/library_screen.dart';
import '../features/library/domain/pdf_document.dart';
import '../features/reader/presentation/reader_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/splash/presentation/splash_screen.dart';
import '../features/student_mode/presentation/student_mode_screen.dart';

/// Permet à [GoRouter] de se réévaluer via [redirect] chaque fois que
/// l'état d'authentification Supabase change.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (_) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

const _preAuthRoutes = {
  AppRoutes.splash,
  AppRoutes.onboarding,
  AppRoutes.login,
  AppRoutes.signup,
  AppRoutes.forgotPassword,
};

const _authOnlyRoutes = {
  AppRoutes.login,
  AppRoutes.signup,
  AppRoutes.forgotPassword,
};

final appRouterProvider = Provider<GoRouter>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,

    refreshListenable: GoRouterRefreshStream(
      authRepository.authStateChanges,
    ),

    redirect: (context, state) {
      final loggedIn = authRepository.currentSession != null;
      final location = state.matchedLocation;

      // Le splash gère lui-même sa première redirection.
      if (location == AppRoutes.splash) {
        return null;
      }

      if (!loggedIn && !_preAuthRoutes.contains(location)) {
        return AppRoutes.login;
      }

      if (loggedIn && _authOnlyRoutes.contains(location)) {
        return AppRoutes.home;
      }

      return null;
    },

    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),

      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),

      GoRoute(
        path: AppRoutes.signup,
        builder: (context, state) => const SignupScreen(),
      ),

      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeShell(),
      ),

      GoRoute(
        path: AppRoutes.library,
        builder: (context, state) => const LibraryScreen(),
      ),

      GoRoute(
        path: AppRoutes.reader,
        builder: (context, state) {
          final document = state.extra;

          if (document is! PdfDocumentModel) {
            return const _NotFoundScreen();
          }

          return ReaderScreen(
            document: document,
          );
        },
      ),

      GoRoute(
        path: AppRoutes.student,
        builder: (context, state) => const StudentModeScreen(),
      ),

      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
    ],

    errorBuilder: (context, state) => const _NotFoundScreen(),
  );
});

class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.search_off_rounded,
                size: 48,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 12),
              const Text(
                'Page introuvable',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.go(AppRoutes.home),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                ),
                child: const Text("Retour à l'accueil"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}