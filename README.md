# Woolu AI — Comprendre. Sécuriser. Résoudre.

> Hackathon NODE51 Dakar — 29 octobre 2026 · Thématique **AI for Africa**

## Pitch

Au Sénégal, des millions de personnes utilisent le mobile money au quotidien. Face à un SMS qui réclame un code, à un transfert débité mais jamais reçu ou à un commerçant qui conteste un paiement, elles restent souvent seules : elles ne savent ni quoi vérifier, ni qui contacter, ni comment formuler une réclamation.

**Woolu AI** est un assistant IA qui transforme un incident financier numérique en trois choses :
1. **une analyse compréhensible** : type d'incident, niveau de risque estimé, indices relevés et limites de l'analyse ;
2. **des actions concrètes**, à faire tout de suite, puis un parcours de résolution guidé ;
3. **un dossier de réclamation structuré**, avec une lettre en français exportable en PDF ou en .txt, que l'utilisateur envoie lui-même au service officiel.

Woolu AI ne demande jamais de code PIN, de mot de passe ni d'OTP, et ne conclut jamais avec certitude à une fraude.

## Stack

| Couche | Technologies |
|---|---|
| **Application principale** (`mobile/`) | Flutter 3.29 : web responsive, Android et iOS. Icônes Phosphor, police Plus Jakarta Sans, animations flutter_animate, PDF avec `pdf`, OCR local (Tesseract.js sur le web, ML Kit sur mobile) |
| Client web léger (`client/`) | React 18, Vite 6, Tailwind CSS 4, jsPDF |
| Backend | Node.js, Express 4, `groq-sdk` |
| IA | API Groq, modèle `llama-3.3-70b-versatile` (configurable), mode JSON |
| Stockage | Aucun : l'historique reste en mémoire dans le navigateur, le temps de la session |

Architecture : `React → /api (proxy Vite) → Express → règles déterministes + validation → Groq → validation du schéma → React`

## Installation

Prérequis : Node.js 18 ou plus récent (testé avec Node 24 sous Windows).

```bash
npm run install:all
```

Cette commande installe les dépendances de la racine, de `server/` et de `client/`.

## Configuration de `.env`

```bash
cp server/.env.example server/.env    # sous Windows : copy server\.env.example server\.env
```

| Variable | Rôle | Valeur par défaut |
|---|---|---|
| `GROQ_API_KEY` | Clé Groq (https://console.groq.com/keys). **Si elle est vide, le serveur passe en mode démo.** | vide |
| `GROQ_MODEL` | Modèle Groq utilisé | `llama-3.3-70b-versatile` |
| `PORT` | Port de l'API | `3001` |
| `CLIENT_ORIGIN` | Seule origine autorisée par CORS | `http://localhost:5173` |

La clé reste uniquement dans `server/.env`, qui est exclu de Git par `.gitignore`. Le client ne la voit jamais.

**Mode démo** : sans clé, `/api/analyze` renvoie des réponses préenregistrées pour les 3 scénarios. Le scénario est choisi d'après le type sélectionné, sinon d'après des mots-clés. Le dossier est alors construit à partir d'un modèle de lettre. Un bandeau gris l'indique dans l'interface. La démo ne dépend donc ni du réseau ni du quota Groq.

## Lancement

### Application Flutter (recommandée pour la démo)

```bash
npm run build:web   # compile l'app Flutter web (Flutter SDK requis), à refaire après chaque modification
npm run dev         # lance l'API et le client React
```

Ouvrez **http://localhost:3001**. Express y sert l'application Flutter et l'API à la même adresse.
- Sur téléphone, l'app occupe tout l'écran.
- Sur ordinateur, elle s'affiche dans une colonne centrée, avec un panneau de présentation à côté.
- Pour tester depuis un téléphone sur le même Wi-Fi, ouvrez `http://IP_DU_PC:3001`.

Pour développer avec rechargement à chaud : `cd mobile && flutter run -d chrome --web-port 5174`.
Pour Android : `cd mobile && flutter run` (voir [mobile/README.md](mobile/README.md)).

### Client React

- Client : http://localhost:5173
- API : http://localhost:3001 (`GET /api/health` indique le mode actif : `demo` ou `groq`)

### API

| Route | Entrée | Sortie |
|---|---|---|
| `POST /api/analyze` | `{ text, incidentType? }` (texte non vide, 4000 caractères max) | `{ incidentType, riskLevel, summary, indicators[], recommendedActions[], limitations[], missingInfo[], resolutionSteps[], incidentLabel, demo }` |
| `POST /api/dossier` | `{ analysis, info: { date, time, amount, references, chronology, stepsTaken } }` | Dossier structuré, avec `subject`, `letter` et `evidenceChecklist[]` |

Erreurs : 400 pour une entrée vide, trop longue ou un JSON invalide, 413 pour un body trop volumineux, 502 si Groq échoue ou renvoie une réponse hors schéma. Dans tous ces cas, l'API renvoie un message explicite et n'invente jamais de résultat.

## Déroulé de la démo (5 étapes, environ 2 minutes)

Le déroulé ci-dessous utilise l'application Flutter, sur http://localhost:3001.

1. **Accueil** : présenter « Comprendre. Sécuriser. Résoudre. » et les trois façons d'entrer un incident (décrire, coller un SMS, importer une capture).
2. **Analyse** : toucher le scénario *SMS demandant un code*, puis *Analyser*. Montrer l'en-tête rouge **Risque élevé**, les indices (dont les *règles de sécurité*, indépendantes de l'IA), les actions immédiates et l'encadré **Limites de l'analyse**.
3. **Capture** : dans *Importer une capture*, choisir une capture de confirmation. Le texte est lu dans le navigateur, puis analysé.
4. **Résolution** : toucher *Résoudre l'incident*, cocher les premières étapes (la barre de progression avance), puis renseigner la date, l'heure, le montant et la référence. Toucher *Générer le dossier*.
5. **Dossier** : montrer la synthèse, les justificatifs et la lettre, qu'on peut modifier. Toucher **Télécharger le PDF**, puis ouvrir *Mes incidents* pour retrouver les analyses de la session.

Le troisième scénario, *Paiement contesté*, est prêt pour les questions du jury.

## Sécurité et confidentialité

- Le prompt système interdit au modèle de demander un PIN, un mot de passe ou un OTP, de conclure avec certitude à une fraude ou à une culpabilité, de citer de vraies marques et d'inventer des faits. Il traite le texte de l'utilisateur comme une donnée, pas comme une instruction.
- Une limite fixe (« ni une preuve de fraude ni un avis juridique ») est ajoutée par le serveur à chaque analyse.
- Des règles déterministes (regex) détectent les demandes de code, l'urgence, les menaces de blocage et les promesses de gain. Ces indices s'affichent même si l'IA les omet.
- Les faits du dossier (date, montant, références) viennent de l'utilisateur. Le modèle ne rédige que la lettre.
- Les journaux contiennent uniquement des métadonnées (longueur, type, mode), jamais le texte des messages.
- CORS est limité à l'origine du client, et le body JSON est limité à 50 ko.
- Aucune base de données : rien n'est conservé côté serveur.

## Limites du MVP

- **OCR local imparfait** : la lecture des captures (Tesseract.js sur le web, ML Kit sur mobile) peut mal lire une image floue. L'utilisateur relit et corrige le texte avant l'analyse. Sur le web, Tesseract est téléchargé depuis un CDN au premier usage, il faut donc une connexion.
- **Aucune vérification réelle** : Woolu AI ne consulte pas les systèmes des opérateurs. Le niveau de risque est une estimation, pas une preuve.
- **Mode démo** : les réponses sont figées pour 3 scénarios. Tout autre texte reçoit un résultat générique, clairement signalé.
- **Historique éphémère** : il disparaît au rechargement de la page, et il n'y a pas de comptes.
- **Français uniquement** : le wolof et la voix sont prévus pour plus tard.
- **Qualité de l'IA non évaluée** : il n'existe pas encore de jeu de test annoté pour mesurer les faux positifs et les faux négatifs.
- **Export PDF** : les polices standard de jsPDF ne couvrent que le Latin-1, donc quelques caractères typographiques (tirets longs, « œ ») sont remplacés.

## Choix techniques simplificateurs

- Vite sert de proxy pour `/api` vers `:3001`. Le client appelle donc des URL relatives, et CORS sert surtout de protection si l'API est appelée directement.
- J'ai choisi Tailwind 4 avec le plugin `@tailwindcss/vite` : il n'y a aucun fichier de configuration Tailwind ni PostCSS.
- Un type d'incident inconnu renvoyé par le modèle est ramené à `autre` au lieu de rejeter toute l'analyse. En revanche, un `riskLevel` invalide ou un champ manquant entraîne un rejet (erreur 502).
- L'historique reste dans le state React, sans `localStorage`, pour qu'aucune donnée financière ne persiste sur l'appareil.
- La lettre reste modifiable dans l'aperçu. Les exports utilisent la version modifiée.

## Livrables du hackathon (d'après le livret NODE51)

Le livret impose **deux livrables à 15h30** : un **pitch deck** (problème, solution, impact, modèle) et une **démo** (ce dépôt). Le pitch oral dure **8 minutes, chrono strict**.

Critères du jury : problème et impact, exécution et design, originalité, faisabilité, modèle économique, équipe.

### Trame du pitch (8 min)

| Durée | Partie | Contenu Woolu AI |
|---|---|---|
| 1 min | Problème | Au Sénégal, les utilisateurs de mobile money victimes d'un message suspect, d'un transfert perdu ou d'un litige commerçant ne savent ni quoi vérifier ni comment réclamer. Il n'existe pas d'accompagnement accessible. |
| 2 min | Solution | Woolu AI analyse, conseille les bons réflexes et produit un dossier de réclamation prêt à envoyer. C'est un outil de résolution, pas seulement d'alerte. |
| 2 min | Démo | Les étapes 1 à 5 ci-dessus. *Montrez, ne racontez pas.* |
| 1 min | Modèle économique | B2B2C : gratuit pour les particuliers, avec des licences pour les institutions de microfinance, les associations de consommateurs, les structures d'accompagnement des commerçants et les services de réclamation. Hypothèses à valider par des pilotes. |
| 1 min | Impact en Afrique | Inclusion financière et confiance dans le numérique : moins de pertes liées aux arnaques au code, des réclamations plus rapides et mieux documentées. Extension prévue en Afrique de l'Ouest. |
| 1 min | Suite | OCR des captures, wolof et voix, procédures vérifiées avec les acteurs, statistiques anonymisées. Besoins : partenaires pilotes et données de test annotées. |

### Plan de deck suggéré (6 slides, selon le livret)

1. **Le problème** : « Au Sénégal, les utilisateurs de mobile money souffrent d'arnaques et d'incidents non résolus, car ils n'ont pas d'outil pour comprendre et documenter ce qui leur arrive. »
2. **La solution** : « Nous avons créé Woolu AI, un assistant qui analyse l'incident, guide la résolution et génère le dossier de réclamation. »
3. **La démo** : captures de l'analyse, du parcours de résolution et du PDF.
4. **L'impact** : bénéficiaires visés et bénéfice concret (temps gagné, pertes évitées).
5. **La faisabilité** : React, Node.js et Groq (LLM). Le parcours complet fonctionne déjà, avec des garde-fous (validation de schéma, règles déterministes, mode démo hors ligne).
6. **L'équipe et la suite** : prochaine étape, des pilotes avec une institution de microfinance ou une association de consommateurs.
