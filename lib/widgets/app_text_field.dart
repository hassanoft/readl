import 'package:flutter/material.dart';

/// Champ de texte réutilisé sur les écrans de connexion/inscription.
///
/// Gère nativement l'affichage/masquage du mot de passe quand
/// [isPassword] est vrai (spec : "afficher/masquer mot de passe").
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.isPassword = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.prefixIcon,
  });

  final TextEditingController controller;
  final String label;
  final bool isPassword;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword && _obscured,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      validator: widget.validator,
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon:
            widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                ),
                onPressed: () => setState(() => _obscured = !_obscured),
                tooltip: _obscured
                    ? 'Afficher le mot de passe'
                    : 'Masquer le mot de passe',
              )
            : null,
      ),
    );
  }
}
