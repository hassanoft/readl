import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class _StudentFeature {
  const _StudentFeature(this.icon, this.title, this.description);
  final IconData icon;
  final String title;
  final String description;
}

const _features = [
  _StudentFeature(Icons.summarize_outlined, 'Résumer un document',
      'Obtenez un résumé rapide de votre PDF.'),
  _StudentFeature(Icons.bookmark_outlined, 'Résumer un chapitre',
      'Résumez uniquement la section sélectionnée.'),
  _StudentFeature(Icons.lightbulb_outline, 'Expliquer un passage',
      'Faites clarifier un passage difficile.'),
  _StudentFeature(Icons.chat_bubble_outline, 'Poser une question',
      'Interrogez le contenu de votre PDF.'),
  _StudentFeature(Icons.translate_rounded, 'Traduire un passage',
      'Traduisez un extrait dans une autre langue.'),
  _StudentFeature(Icons.style_outlined, 'Créer une fiche de révision',
      'Générez une fiche synthétique.'),
  _StudentFeature(Icons.quiz_outlined, 'Générer un quiz',
      'Testez vos connaissances sur le document.'),
];

/// Mode Étudiant de READL.
///
/// V1 : présente la feuille de route des fonctionnalités IA (spec
/// section 3, "Mode Étudiant") sans faux boutons actifs. Ces
/// fonctionnalités nécessitent une bibliothèque de documents (import
/// PDF) et un service IA remplaçable — voir priorité 12 du cahier des
/// charges. Aucune clé API IA ne doit être intégrée directement dans
/// l'app (spec section 3).
class StudentModeScreen extends StatelessWidget {
  const StudentModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mode Étudiant')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          const Text(
            'Votre assistant d\'apprentissage',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            'Ces outils s\'activeront dès qu\'un document sera importé et '
            'connecté au service IA.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 16),
          for (final feature in _features)
            Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(feature.icon, color: AppColors.textSecondary),
                ),
                title: Text(feature.title,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(feature.description,
                    style: const TextStyle(fontSize: 12.5)),
                trailing: const _SoonBadge(),
                onTap: () {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(SnackBar(
                      content: Text(
                        '« ${feature.title} » sera disponible une fois la '
                        'bibliothèque et le service IA branchés.',
                      ),
                    ));
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _SoonBadge extends StatelessWidget {
  const _SoonBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryGreenLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'Bientôt',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryGreenDark,
        ),
      ),
    );
  }
}
