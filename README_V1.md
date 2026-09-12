# READL V1 — PDF + extraction + lecture vocale

Cette version ajoute le cœur fonctionnel de READL :

- Import de fichiers PDF depuis Android/iOS via le sélecteur natif.
- Copie locale du PDF dans l'espace privé de l'application.
- Extraction du texte avec Syncfusion Flutter PDF.
- Lecteur PDF avec zoom, recherche et navigation via Syncfusion PDF Viewer.
- Lecture vocale française avec Flutter TTS.
- Play / pause / reprise / stop.
- Vitesse réglable.
- Bibliothèque locale persistante.
- Suppression et favoris.
- Sauvegarde de la dernière page.
- Détection des PDF sans texte extractible (scans/OCR non inclus dans cette V1).
- Workflows GitHub Actions Android et iOS.

## Compilation

Le dépôt d'origine ne contenait pas les dossiers `android/` et `ios/`. Les workflows les génèrent avec `flutter create` avant compilation.

### Android
Actions → **READL Android** → Run workflow.

L'APK est publié dans l'artifact `readl-android-apk`.

### iOS
Actions → **READL iOS** → Run workflow.

La compilation iOS est faite sans signature. L'artifact contient `Runner.app`; il faudra ensuite une signature Apple pour une installation/distribution réelle.

## Supabase
La connexion reste celle de la V1 d'origine. Le stockage des PDF de cette V1 est local pour éviter d'envoyer automatiquement des documents privés vers le cloud. Le schéma Supabase contient aussi une table `documents` préparée pour une future synchronisation.

## Licence Syncfusion
`syncfusion_flutter_pdf` et `syncfusion_flutter_pdfviewer` sont soumis à leur licence Syncfusion. Une licence commerciale ou la Community License éligible est nécessaire selon les conditions du projet.
