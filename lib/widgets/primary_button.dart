import 'package:flutter/material.dart';

/// Bouton principal réutilisé sur tous les écrans (connexion,
/// inscription, onboarding...). Affiche un indicateur de chargement à
/// la place du texte quand [isLoading] est vrai, et se désactive
/// automatiquement pour éviter les doubles soumissions.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(label),
    );
  }
}
