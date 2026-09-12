import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../library/application/library_providers.dart';
import '../../../core/constants/app_routes.dart';

import '../../../core/theme/app_colors.dart';
import '../../library/presentation/library_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../student_mode/presentation/student_mode_screen.dart';
import 'home_screen.dart';

/// Coquille de navigation principale, affichée une fois l'utilisateur
/// connecté. Regroupe les 4 sections principales de READL derrière une
/// barre de navigation, avec le bouton "Importer un PDF" toujours
/// accessible (spec section 21).
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;

  static const _tabs = [
    _TabItem('Accueil', Icons.home_outlined, Icons.home_rounded),
    _TabItem('Mes PDF', Icons.folder_outlined, Icons.folder_rounded),
    _TabItem('Étudiant', Icons.school_outlined, Icons.school_rounded),
    _TabItem('Profil', Icons.person_outline_rounded, Icons.person_rounded),
  ];

  Future<void> _onImportPdf() async {
    final library = ref.read(libraryControllerProvider);
    try {
      final document = await library.importPdf();
      if (!mounted || document == null) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PDF importé et texte extrait avec succès.')));
      context.push(AppRoutes.reader, extra: document);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Import impossible : $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          HomeScreen(onImportPdf: () { _onImportPdf(); }),
          LibraryScreen(onImportPdf: () { _onImportPdf(); }),
          const StudentModeScreen(),
          const ProfileScreen(),
        ],
      ),
      floatingActionButton: _index == 0 || _index == 1
          ? FloatingActionButton.extended(
              onPressed: () { _onImportPdf(); },
              backgroundColor: AppColors.primaryGreen,
              icon: const Icon(Icons.upload_file_rounded, color: Colors.white),
              label: const Text(
                'Importer un PDF',
                style: TextStyle(color: Colors.white),
              ),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: [
          for (final tab in _tabs)
            NavigationDestination(
              icon: Icon(tab.icon),
              selectedIcon: Icon(tab.selectedIcon),
              label: tab.label,
            ),
        ],
      ),
    );
  }
}

class _TabItem {
  const _TabItem(this.label, this.icon, this.selectedIcon);
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
