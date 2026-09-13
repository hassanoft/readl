import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../widgets/primary_button.dart';
import '../../auth/application/auth_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _comingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$feature arrive bientôt.')));
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Se déconnecter'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // READL reste utilisable sans compte : après déconnexion, on
    // retourne à l'accueil en mode invité plutôt que de forcer l'écran
    // de connexion.
    final success = await ref.read(authControllerProvider.notifier).signOut();
    if (success && context.mounted) {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(authRepositoryProvider);
    final isGuest = repository.currentSession == null;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: isGuest
          ? _GuestProfileView(
              onCreateAccount: () => context.push(AppRoutes.signup),
              onSignIn: () => context.push(AppRoutes.login),
            )
          : _AuthenticatedProfileBody(
              repository: repository,
              onComingSoon: (feature) => _comingSoon(context, feature),
              onSignOut: () => _signOut(context, ref),
            ),
    );
  }
}

/// Affichée quand personne n'est connecté (mode invité, spec : l'app
/// est utilisable sans compte). Un compte n'est demandé qu'au moment de
/// sauvegarder — favoris, historique, synchronisation entre appareils.
class _GuestProfileView extends StatelessWidget {
  const _GuestProfileView({
    required this.onCreateAccount,
    required this.onSignIn,
  });

  final VoidCallback onCreateAccount;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                color: AppColors.primaryGreenLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_outline_rounded,
                size: 40,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Vous naviguez en invité',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Créez un compte pour sauvegarder votre progression, vos '
              'favoris et retrouver vos documents sur tous vos appareils.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                label: 'Créer un compte',
                onPressed: onCreateAccount,
              ),
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: onSignIn,
              child: const Text('J\'ai déjà un compte, me connecter'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Affichée quand un utilisateur est connecté : ses informations et les
/// actions de compte (identique au comportement de la V1 précédente).
class _AuthenticatedProfileBody extends StatelessWidget {
  const _AuthenticatedProfileBody({
    required this.repository,
    required this.onComingSoon,
    required this.onSignOut,
  });

  final AuthRepository repository;
  final void Function(String feature) onComingSoon;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final firstName = repository.currentFirstName ?? '';
    final email = repository.currentEmail ?? '';
    final initials =
        firstName.isNotEmpty ? firstName.substring(0, 1).toUpperCase() : '?';

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: AppColors.primaryGreenLight,
              child: Text(
                initials,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreenDark,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    firstName.isEmpty ? 'Utilisateur READL' : firstName,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(email,
                      style: const TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.workspace_premium_outlined,
                    color: AppColors.primaryGreen),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('Abonnement : Gratuit',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
                TextButton(
                  onPressed: () => onComingSoon('Premium'),
                  child: const Text('Découvrir'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        _ProfileTile(
          icon: Icons.edit_outlined,
          label: 'Modifier le profil',
          onTap: () => onComingSoon('La modification du profil'),
        ),
        _ProfileTile(
          icon: Icons.settings_outlined,
          label: 'Paramètres',
          onTap: () => onComingSoon('Les paramètres'),
        ),
        _ProfileTile(
          icon: Icons.notifications_outlined,
          label: 'Notifications',
          onTap: () => onComingSoon('Les notifications'),
        ),
        _ProfileTile(
          icon: Icons.history_rounded,
          label: 'Historique de lecture',
          onTap: () => onComingSoon('L\'historique de lecture'),
        ),
        const SizedBox(height: 12),
        _ProfileTile(
          icon: Icons.logout_rounded,
          label: 'Déconnexion',
          iconColor: AppColors.error,
          onTap: onSignOut,
        ),
      ],
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? AppColors.textSecondary),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.chevron_right_rounded,
            color: AppColors.textSecondary),
        onTap: onTap,
      ),
    );
  }
}