# READL

**Vos PDF, votre voix.**

READL est une application mobile Flutter (Android + iOS) qui permet d'importer un PDF, de le lire visuellement et de se le faire lire à voix haute.

> Ce README décrit l'état **V1** du projet : le socle compilable, l'identité visuelle et l'authentification Supabase. Les fonctionnalités PDF/TTS/OCR/IA arrivent aux étapes suivantes (voir [Feuille de route](#feuille-de-route-et-limitations-connues) plus bas) — ce document sera complété à chaque étape.

---

## Sommaire

1. [Présentation](#présentation)
2. [Fonctionnalités](#fonctionnalités)
3. [Architecture](#architecture)
4. [Installation](#installation)
5. [Configuration Supabase](#configuration-supabase)
6. [Variables d'environnement](#variables-denvironnement)
7. [Lancement local](#lancement-local)
8. [Tests](#tests)
9. [Icône de l'application](#icône-de-lapplication)
10. [Feuille de route et limitations connues](#feuille-de-route-et-limitations-connues)
11. [Checklist](#checklist)

---

## Présentation

- **Nom** : READL
- **Slogan** : Vos PDF, votre voix.
- **Stack** : Flutter (Dart), Material 3, Supabase, Riverpod, go_router
- **Couleur d'accent** : `#16A34A` (vert)
- **Langue de l'interface** : Français

## Fonctionnalités

### Disponible en V1
- Splash screen animé
- Onboarding (3 pages, "Passer" / "Suivant" / "Commencer")
- Authentification complète et réelle via Supabase (connexion, inscription, mot de passe oublié) avec messages d'erreur en français
- Navigation protégée (redirection automatique connecté / non connecté)
- Coquille de navigation principale (Accueil / Mes PDF / Étudiant / Profil)
- Écran Profil avec déconnexion fonctionnelle
- Thème clair/sombre Material 3 aux couleurs READL
- Icône de l'application générée à partir du logo fourni

### À venir (voir feuille de route)
Import PDF, affichage/lecteur PDF, extraction de texte, lecture audio (TTS), OCR, Mode Étudiant (IA), bibliothèque complète, historique, favoris, dossiers, Premium, notifications, GitHub Actions, tests étendus.

## Architecture

```
lib/
├── main.dart                     # Point d'entrée, initialisation Supabase
├── app.dart                      # MaterialApp.router (thème, locale, routing)
├── core/
│   ├── config/env_config.dart    # Lecture des secrets via --dart-define
│   ├── constants/                # Routes, clés de stockage local
│   ├── errors/app_exception.dart # Traduction des erreurs en français
│   ├── providers/                # Providers Riverpod globaux
│   ├── services/                 # SupabaseService (initialisation)
│   └── theme/                    # Couleurs et thème Material 3
├── data/
│   ├── models/app_user.dart
│   └── repositories/             # AuthRepository (interface + impl Supabase)
├── features/
│   ├── auth/                     # login, signup, forgot-password
│   ├── splash/
│   ├── onboarding/
│   ├── home/                     # HomeShell (navigation) + HomeScreen
│   ├── library/                  # V1 : état vide
│   ├── student_mode/             # V1 : feuille de route des fonctions IA
│   └── profile/
├── routes/app_router.dart        # GoRouter + garde d'authentification
└── widgets/                      # Composants réutilisés (bouton, champ texte)
```

**Pourquoi cette architecture ?** Chaque fonctionnalité dépend d'une interface (`AuthRepository`) plutôt que directement de Supabase : remplacer le backend plus tard ne demande de modifier qu'un seul provider (`core/providers/core_providers.dart`), jamais les écrans.

## Installation

Prérequis : [Flutter](https://docs.flutter.dev/get-started/install) (canal stable, ≥ 3.32), un projet [Supabase](https://supabase.com) gratuit.

```bash
git clone <url-de-votre-dépôt> readl
cd readl
flutter pub get
```

### Générer les dossiers natifs Android/iOS

Ce projet contient `lib/`, `assets/`, `pubspec.yaml`, `supabase/` et `.github/`, mais **pas** les dossiers `android/` et `ios/` : générez-les localement pour éviter que `flutter create` n'écrase le code déjà présent.

```bash
# Depuis un dossier temporaire à côté de readl/
flutter create --platforms=android,ios --org com.aura.readl readl_native_tmp

# Copiez uniquement les dossiers natifs générés dans le projet READL
cp -r readl_native_tmp/android readl/
cp -r readl_native_tmp/ios readl/
rm -rf readl_native_tmp
```

Puis générez les icônes (voir [Icône de l'application](#icône-de-lapplication)) :

```bash
cd readl
dart run flutter_launcher_icons
```

## Configuration Supabase

1. Créez un projet sur [supabase.com](https://supabase.com).
2. Dans **SQL Editor**, exécutez le contenu de [`supabase/schema.sql`](supabase/schema.sql). Il crée :
   - la table `profiles` (liée à `auth.users`)
   - un trigger qui crée automatiquement le profil à l'inscription
   - les policies RLS (chaque utilisateur ne voit/modifie que sa propre ligne)
3. Récupérez **Project URL** et la clé **anon/public** dans *Project Settings → API*.
4. Dans **Authentication → Email**, vérifiez que "Confirm email" correspond à ce que vous souhaitez pour le développement (le désactiver simplifie les tests manuels).

## Variables d'environnement

Aucune clé secrète n'est jamais écrite en dur dans le code. Les valeurs sont injectées au moment du build via `--dart-define`. Deux façons de les fournir :

**1. Directement en ligne de commande :**

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://xxxxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJxxxxx...
```

**2. Via un fichier local (recommandé pour le développement quotidien) :**

Copiez [`env.json.example`](env.json.example) en `env.json` à la racine du projet, puis remplissez-le avec vos vraies valeurs. `env.json` est exclu par `.gitignore` — il ne sera jamais commité.

```bash
cp env.json.example env.json
# éditez env.json avec vos vraies valeurs Supabase
flutter run --dart-define-from-file=env.json
```

Si ces valeurs manquent, l'application affiche un écran de configuration manquante clair plutôt que de planter silencieusement.

## Lancement local

```bash
flutter pub get
flutter run --dart-define-from-file=env.json
```

## Tests

```bash
flutter test
```

Couverture V1 :
- `test/core/errors/app_exception_test.dart` — traduction des erreurs en français
- `test/data/models/app_user_test.dart` — parsing du modèle `AppUser`
- `test/widgets/primary_button_test.dart` — widget bouton principal
- `test/features/auth/login_screen_test.dart` — validation de formulaire, appel réel au repository (via un double de test `FakeAuthRepository`), navigation après connexion, affichage des erreurs

## Icône de l'application

Le logo fourni est à `assets/icon/app_icon.png` (source pleine résolution) et `assets/icon/app_icon_foreground.png` (version recadrée pour les icônes adaptatives Android). `assets/images/readl_logo.png` est utilisé dans l'app (splash, écran de connexion).

```bash
dart run flutter_launcher_icons
```

Cette commande génère automatiquement toutes les résolutions Android (y compris l'icône adaptative, fond blanc) et iOS à partir de ces sources — configuration dans `pubspec.yaml` (clé `flutter_launcher_icons`).

## Feuille de route et limitations connues

Ordre de priorité repris du cahier des charges :

| # | Fonctionnalité | Statut |
|---|---|---|
| 1 | Projet Flutter compilable | ✅ V1 |
| 2 | UI READL (splash, onboarding, auth, accueil, navigation) | ✅ V1 |
| 3 | Import PDF | ⏳ à venir |
| 4 | Affichage PDF | ⏳ à venir |
| 5 | Extraction de texte | ⏳ à venir |
| 6 | Text-to-Speech | ⏳ à venir |
| 7 | Authentification Supabase | ✅ V1 |
| 8 | Bibliothèque complète (recherche, tri, dossiers) | ⏳ à venir |
| 9 | Historique / progression de lecture | ⏳ à venir |
| 10 | GitHub Actions Android | ⏳ à venir |
| 11 | GitHub Actions iOS | ⏳ à venir |
| 12 | Mode Étudiant / IA | ⏳ à venir (roadmap visible dans l'app) |
| 13 | OCR | ⏳ à venir |
| 14 | Premium | ⏳ à venir |

Autres limitations connues de cette V1 :
- Les dossiers `android/` et `ios/` ne sont pas fournis (voir [Installation](#installation)) — ils doivent être générés une fois localement avec `flutter create`.
- Aucun workflow GitHub Actions pour l'instant : rien à compiler côté PDF/TTS tant que ces fonctionnalités n'existent pas encore.
- Les compteurs "temps d'écoute", "PDF lus" etc. ne sont pas encore affichés : aucune donnée fictive n'est utilisée, ces sections apparaîtront avec la bibliothèque et l'historique réels.
- Les versions de dépendances dans `pubspec.yaml` (ex. `go_router: ^14.8.1`) sont volontairement fixées sur des versions dont l'API est vérifiée plutôt que sur la toute dernière version majeure disponible. Lancez `flutter pub outdated` si vous voulez évaluer une mise à jour majeure (ex. go_router 16/17, Riverpod 3).

## Checklist

- [x] Flutter (projet compilable)
- [ ] Android (dossier natif à générer, voir Installation)
- [ ] iOS (dossier natif à générer, voir Installation)
- [x] Supabase (auth + profils + RLS)
- [ ] PDF
- [ ] TTS
- [ ] OCR
- [ ] IA
- [x] Auth
- [ ] Library (V1 = état vide uniquement)
- [ ] History
- [ ] Premium
- [x] Tests (auth, modèles, widgets — à étendre avec chaque fonctionnalité)
- [ ] GitHub Actions
- [ ] Android Artifact
- [ ] iOS Artifact
