/// Chemins de routes utilisés par [GoRouter].
///
/// Centraliser les chemins ici évite les fautes de frappe et facilite
/// l'ajout des futurs écrans (lecteur, bibliothèque, mode étudiant...).
abstract final class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';

  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';

  static const String home = '/home';
  static const String library = '/library';
  static const String reader = '/reader';
  static const String student = '/student';
  static const String profile = '/profile';
  static const String history = '/history';
  static const String folders = '/folders';
  static const String premium = '/premium';
  static const String settings = '/settings';
  static const String notifications = '/notifications';
}
