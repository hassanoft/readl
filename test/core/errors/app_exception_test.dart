import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:readl/core/errors/app_exception.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('describeError', () {
    test('retourne le message tel quel pour AppException', () {
      const exception = AppException('Message personnalisé.');
      expect(describeError(exception), 'Message personnalisé.');
    });

    test('traduit les identifiants invalides en français', () {
      const error = AuthException('Invalid login credentials');
      expect(describeError(error), 'Email ou mot de passe incorrect.');
    });

    test('traduit un compte déjà existant en français', () {
      const error = AuthException('User already registered');
      expect(
        describeError(error),
        'Un compte existe déjà avec cet email.',
      );
    });

    test('traduit une absence de réseau en français', () {
      final error = SocketException('Failed host lookup');
      expect(
        describeError(error),
        'Aucune connexion internet détectée. '
        'Vérifiez votre connexion et réessayez.',
      );
    });

    test('signale une clé/URL Supabase invalide', () {
      const error = AuthException('Invalid API key');
      expect(
        describeError(error),
        'Configuration Supabase invalide : vérifiez SUPABASE_URL et '
        'SUPABASE_ANON_KEY (Project Settings → API).',
      );
    });

    test('signale un échec du trigger de création de profil', () {
      const error = AuthException('Database error saving new user');
      expect(
        describeError(error),
        'Erreur côté base de données lors de la création du compte. '
        'Vérifiez que supabase/schema.sql a bien été exécuté sur votre '
        'projet Supabase.',
      );
    });

    test('retourne un message générique pour une erreur inconnue', () {
      expect(
        describeError(Exception('boom')),
        'Une erreur inattendue est survenue. Veuillez réessayer.',
      );
    });
  });
}
