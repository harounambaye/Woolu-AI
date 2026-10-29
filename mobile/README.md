# Woolu AI — application Flutter (web responsive et mobile)

Interface principale de Woolu AI. Le même code tourne dans le navigateur (responsive, du téléphone à l'ordinateur) et sur Android ou iOS.

## Lancer en version web

```bash
flutter pub get
flutter build web          # puis, à la racine du dépôt : npm run dev
```

Le serveur Express sert alors l'application sur http://localhost:3001, à la même adresse que l'API.

Mode développement avec rechargement à chaud (le serveur doit tourner sur le port 3001) :

```bash
flutter run -d chrome --web-port 5174
```

## Lancer sur Android

```bash
flutter run                                         # émulateur : l'API est jointe via 10.0.2.2:3001
flutter run --dart-define=API_URL=http://IP_DU_PC:3001   # vrai téléphone sur le même Wi-Fi
```

## Saisie

- **Décrire** le problème, **coller un SMS**, ou **importer une capture** de confirmation.
- Le texte de la capture est lu sur l'appareil : Tesseract.js dans le navigateur, ML Kit sur mobile. L'image n'est jamais envoyée au serveur.
