# WOD TRACKER – première version

## Contenu
- Application web mobile (PWA) adaptée à iPhone
- Ajout de WOD avec exercices, répétitions, charges et unités
- Formats For Time, AMRAP, EMOM
- Bibliothèque de benchmarks
- Historique, statistiques simples et comparaison de WOD
- Export/import JSON de sauvegarde

## Lancer
Ouvrir `index.html` dans un navigateur pour tester. Pour l'installation PWA sur iPhone, publier le dossier sur un hébergement HTTPS, ouvrir l'URL dans Safari puis Partager > Sur l'écran d'accueil.

## Données
Version 1 : stockage local dans le navigateur (localStorage). Les données restent sur cet appareil et ne sont pas synchronisées. Exporter régulièrement une sauvegarde JSON. La synchronisation cloud / compte personnel sera une étape ultérieure (ex. Supabase).

## Note
Les mouvements et charges des benchmarks sont des valeurs de référence indicatives, à adapter à ton niveau et à la version pratiquée.
