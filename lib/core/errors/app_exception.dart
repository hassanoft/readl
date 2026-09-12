import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Exception applicative portant un message déjà prêt à être affiché
/// à l'utilisateur, en français.
class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Traduit une erreur technique (Supabase, réseau, fichier...) en un
/// message clair et en français, jamais une stack trace brute.
///
/// Toutes les opérations réseau/fichiers de READL doivent passer leurs
/// erreurs par cette fonction avant de les afficher (spec section 12).
String describeError(Object error) {
  if (error is AppException) {
    return error.message;
  }

  if (error is AuthException) {
    return _describeAuthError(error);
  }

  if (error is PostgrestException) {
    return 'Impossible de communiquer avec le serveur. '
        'Veuillez réessayer dans un instant.';
  }

  if (error is SocketException) {
    return 'Aucune connexion internet détectée. '
        'Vérifiez votre connexion et réessayez.';
  }

  if (error is FormatException) {
    return 'Le fichier semble endommagé ou dans un format non pris en charge.';
  }

  return 'Une erreur inattendue est survenue. Veuillez réessayer.';
}

String _describeAuthError(AuthException error) {
  final message = error.message.toLowerCase();

  if (message.contains('invalid login credentials') ||
      message.contains('invalid_credentials')) {
    return 'Email ou mot de passe incorrect.';
  }
  if (message.contains('user already registered') ||
      message.contains('already registered')) {
    return 'Un compte existe déjà avec cet email.';
  }
  if (message.contains('email not confirmed')) {
    return 'Veuillez confirmer votre email avant de vous connecter.';
  }
  if (message.contains('session') && message.contains('expired')) {
    return 'Votre session a expiré. Veuillez vous reconnecter.';
  }
  if (message.contains('password') && message.contains('least')) {
    return 'Le mot de passe doit contenir au moins 6 caractères.';
  }
  if (message.contains('rate limit') || message.contains('too many')) {
    return 'Trop de tentatives. Veuillez patienter avant de réessayer.';
  }

  return 'Impossible de vous authentifier pour le moment. Réessayez.';
}
