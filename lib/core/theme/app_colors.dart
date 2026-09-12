import 'package:flutter/material.dart';

/// Palette de couleurs officielle de READL.
///
/// Blanc en couleur principale, vert (#16A34A) en couleur d'accent,
/// texte sombre pour une lisibilité maximale.
abstract final class AppColors {
  static const Color primaryGreen = Color(0xFF16A34A);
  static const Color primaryGreenDark = Color(0xFF15803D);
  static const Color primaryGreenLight = Color(0xFFDCFCE7);

  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF5F7F6);

  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textOnGreen = Color(0xFFFFFFFF);

  static const Color border = Color(0xFFE5E7EB);
  static const Color error = Color(0xFFDC2626);
  static const Color warning = Color(0xFFD97706);

  // Mode sombre
  static const Color backgroundDark = Color(0xFF0F1512);
  static const Color surfaceDark = Color(0xFF171F1B);
  static const Color textPrimaryDark = Color(0xFFF3F4F6);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);
  static const Color borderDark = Color(0xFF2A332E);
}
