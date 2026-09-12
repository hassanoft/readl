import 'package:flutter_test/flutter_test.dart';
import 'package:readl/data/models/app_user.dart';

void main() {
  group('AppUser.fromProfileRow', () {
    test('construit un AppUser à partir d\'une ligne complète', () {
      final user = AppUser.fromProfileRow({
        'id': 'user-123',
        'email': 'hassan@example.com',
        'first_name': 'Hassan',
        'avatar_url': 'https://example.com/avatar.png',
      });

      expect(user.id, 'user-123');
      expect(user.email, 'hassan@example.com');
      expect(user.firstName, 'Hassan');
      expect(user.avatarUrl, 'https://example.com/avatar.png');
    });

    test('gère les champs optionnels manquants', () {
      final user = AppUser.fromProfileRow({'id': 'user-456'});

      expect(user.id, 'user-456');
      expect(user.email, '');
      expect(user.firstName, '');
      expect(user.avatarUrl, isNull);
    });
  });
}
