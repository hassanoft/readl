import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/theme/app_colors.dart';
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

    final success = await ref.read(authControllerProvider.notifier).signOut();
    if (success && context.mounted) {
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(authRepositoryProvider);
    final firstName = repository.currentFirstName ?? '';
    final email = repository.currentEmail ?? '';
    final initials =
        firstName.isNotEmpty ? firstName.substring(0, 1).toUpperCase() : '?';

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
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
                        style:
                            const TextStyle(color: AppColors.textSecondary)),
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
                    onPressed: () => _comingSoon(context, 'Premium'),
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
            onTap: () => _comingSoon(context, 'La modification du profil'),
          ),
          _ProfileTile(
            icon: Icons.settings_outlined,
            label: 'Paramètres',
            onTap: () => _comingSoon(context, 'Les paramètres'),
          ),
          _ProfileTile(
            icon: Icons.notifications_outlined,
            label: 'Notifications',
            onTap: () => _comingSoon(context, 'Les notifications'),
          ),
          _ProfileTile(
            icon: Icons.history_rounded,
            label: 'Historique de lecture',
            onTap: () => _comingSoon(context, "L'historique de lecture"),
          ),
          const SizedBox(height: 12),
          _ProfileTile(
            icon: Icons.logout_rounded,
            label: 'Déconnexion',
            iconColor: AppColors.error,
            onTap: () => _signOut(context, ref),
          ),
        ],
      ),
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
