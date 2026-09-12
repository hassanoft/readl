/// Représente l'utilisateur authentifié, tel qu'exposé par l'app.
///
/// Correspond à la table `profiles` (voir supabase/schema.sql), créée
/// automatiquement à l'inscription par un trigger côté base de données.
class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.firstName,
    this.avatarUrl,
  });

  final String id;
  final String email;
  final String firstName;
  final String? avatarUrl;

  factory AppUser.fromProfileRow(Map<String, dynamic> row) {
    return AppUser(
      id: row['id'] as String,
      email: row['email'] as String? ?? '',
      firstName: row['first_name'] as String? ?? '',
      avatarUrl: row['avatar_url'] as String?,
    );
  }
}
