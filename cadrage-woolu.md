# WOOLU AI
## Assistant intelligent de confiance et de résolution des incidents financiers numériques en Afrique

**Document de cadrage du projet — Version 1.0**

**Contexte :** Hackathon et innovation technologique  
**Domaine :** Intelligence artificielle, FinTech, cybersécurité et inclusion financière  
**Marché initial :** Sénégal, avec une perspective d'expansion en Afrique  
**Technologies principales :** JavaScript, Node.js, React et API Groq

---

## 1. Présentation du projet

Woolu AI est une solution d'intelligence artificielle conçue pour aider les utilisateurs à comprendre, prévenir, documenter et résoudre les problèmes rencontrés lors de leurs opérations financières numériques.

La solution cible notamment les utilisateurs de mobile money, les particuliers, les commerçants et les petites entreprises confrontés à des messages suspects, des erreurs de transfert, des paiements contestés ou des difficultés à effectuer une réclamation.

Contrairement à un simple détecteur d'arnaques, Woolu AI accompagne l'utilisateur tout au long du processus : compréhension du problème, analyse des informations disponibles, identification des vérifications nécessaires, constitution d'un dossier et préparation des démarches à effectuer.

L'ambition est de proposer une solution accessible, adaptée aux usages africains et capable d'évoluer vers un service de confiance numérique à l'échelle régionale.

## 2. Problématique

Le développement du mobile money et des services financiers numériques facilite les transactions, mais expose également les utilisateurs à plusieurs difficultés :

- Tentatives d'arnaque et usurpation d'identité.
- Erreurs de destinataire ou de montant.
- Débit d'un compte sans réception apparente par le bénéficiaire.
- Fausses confirmations de paiement.
- Mauvaise compréhension des frais et des messages transactionnels.
- Difficultés à identifier le bon interlocuteur en cas de litige.
- Absence de dossier organisé pour documenter un incident.

Les utilisateurs ont besoin de plus qu'une alerte. Ils ont besoin de comprendre ce qui s'est passé, de savoir quelles informations vérifier et de disposer d'une procédure claire pour agir.

**Problème central :** les utilisateurs ne disposent pas toujours d'un assistant accessible qui les aide à transformer un incident financier numérique en une démarche structurée et exploitable.

## 3. Vision et objectifs

### Vision

Devenir une plateforme africaine de confiance numérique qui facilite la prévention, la compréhension et la résolution des incidents financiers.

### Objectif général

Développer une application utilisant l'intelligence artificielle pour accompagner les utilisateurs avant, pendant et après un incident financier numérique.

### Objectifs spécifiques

1. Analyser les messages et documents transmis volontairement par les utilisateurs.
2. Expliquer les signaux de risque dans un langage accessible.
3. Identifier les informations manquantes ou incohérentes.
4. Proposer des actions adaptées à chaque type d'incident.
5. Générer un dossier de réclamation organisé et exportable.
6. Construire progressivement une connaissance anonymisée des incidents récurrents.
7. Préparer une adaptation aux langues locales et aux contraintes de connectivité.

## 4. Fonctionnalités du produit

### 4.1. Analyse intelligente des messages

L'utilisateur peut copier un message ou importer une capture d'écran.

Woolu AI analyse le contenu et fournit :
- Une catégorie de problème.
- Un niveau de risque estimé.
- Les indices ayant motivé l'analyse.
- Les vérifications recommandées.
- Les prochaines actions à entreprendre.

Le résultat doit distinguer les éléments observés des hypothèses du modèle. Une analyse ne constitue pas une preuve définitive de fraude.

### 4.2. Assistant de résolution des incidents

L'utilisateur sélectionne ou décrit son problème, par exemple :
- Transfert envoyé au mauvais destinataire.
- Compte débité, mais transfert non reçu.
- Paiement contesté par un commerçant.
- Message demandant des informations confidentielles.
- Confirmation de paiement présentant des incohérences.

L'assistant propose une procédure adaptée, les éléments à conserver et les démarches à envisager auprès du prestataire concerné.

### 4.3. Génération d'un dossier de réclamation

À partir des informations fournies, Woolu AI organise :
- Le type d'incident.
- La date et l'heure déclarées.
- Le montant indiqué, le cas échéant.
- Les références visibles.
- Les justificatifs disponibles.
- La chronologie des événements.
- Les démarches déjà effectuées.
- Un brouillon de réclamation.

Le dossier peut être exporté en PDF ou en texte afin que l'utilisateur puisse le transmettre lui-même au service compétent.

### 4.4. Tableau de bord des incidents

Une interface permet de consulter les analyses réalisées et les dossiers créés pendant la session.

Dans une version ultérieure, les signalements consentis et correctement anonymisés pourront alimenter des statistiques agrégées sur les problèmes récurrents, sous réserve d'un contrôle de qualité et de mesures de protection des données.

### 4.5. Accessibilité linguistique

À terme, Woolu AI pourra proposer une interaction vocale en français et dans des langues locales, notamment le wolof, après évaluation de la qualité de compréhension et de génération.

Cette fonctionnalité vise les personnes qui préfèrent parler plutôt que rédiger ou qui maîtrisent difficilement les interfaces numériques.

## 5. Périmètre du MVP du hackathon

Le MVP doit démontrer un parcours complet et fonctionnel, et non simplement présenter des écrans statiques.

### Fonctionnalités indispensables

1. Page d'accueil présentant clairement Woolu AI.
2. Formulaire de saisie d'un message ou d'une description d'incident.
3. Import facultatif d'une capture d'écran si le temps permet l'intégration de l'OCR.
4. Analyse par l'API Groq à travers le backend.
5. Affichage d'un résultat structuré : catégorie, risque estimé, indices, limites et recommandations.
6. Parcours guidé de résolution.
7. Génération d'un dossier de réclamation.
8. Trois scénarios de démonstration préparés et reproductibles.

### Fonctionnalités reportées après le hackathon

- Intégration directe aux API de Wave ou d'Orange Money.
- Accès automatique à l'historique bancaire.
- Reconnaissance vocale complète en wolof.
- Détection collective à grande échelle.
- Comptes utilisateurs et gestion avancée des rôles.
- Système de suivi connecté aux prestataires financiers.

Ces éléments nécessitent des validations techniques, commerciales ou réglementaires supplémentaires.

## 6. Stack technique

### Frontend

**React + JavaScript + Vite**

Responsabilités :
- Affichage des pages et des formulaires.
- Gestion de l'état de l'interface.
- Import et prévisualisation des captures.
- Affichage des résultats d'analyse.
- Consultation des incidents de la session.
- Téléchargement du dossier de réclamation.

**Tailwind CSS** peut être utilisé pour accélérer la réalisation du design responsive. Une bibliothèque de composants React peut compléter l'interface.

### Backend

**Node.js + Express.js + JavaScript**

Le backend assure :
- La réception et la validation des requêtes.
- La communication avec l'API Groq.
- L'application des règles de sécurité.
- La normalisation des réponses de l'IA.
- La génération des dossiers de réclamation.
- La gestion des fichiers transmis.
- La protection des clés et des données sensibles.

Le choix de Node.js permet de conserver JavaScript sur le frontend et le backend, ce qui simplifie le développement pour une petite équipe.

### Intelligence artificielle

**API Groq**

Le backend envoie au modèle un prompt encadré et les informations nécessaires à l'analyse. Le modèle retourne une réponse structurée destinée à l'interface.

Les responsabilités de l'IA sont :
- Comprendre le contexte décrit.
- Catégoriser l'incident.
- Expliquer les signaux suspects.
- Proposer des vérifications et des démarches.
- Préparer une synthèse pour le dossier.

Le modèle ne doit pas décider seul qu'une transaction est authentique ou qu'une personne est coupable. Les règles déterministes, les sources officielles et les vérifications humaines restent nécessaires.

Le modèle précis sera choisi selon sa disponibilité sur Groq, son coût, ses capacités de sortie structurée et ses performances sur les cas testés.

### OCR facultatif

Pour lire les captures d'écran, une bibliothèque OCR telle que Tesseract peut extraire le texte avant son analyse.

Cette fonctionnalité peut être ajoutée après validation du parcours principal, car les captures peuvent contenir des informations personnelles et produire des extractions imparfaites.

### Stockage

Pour le premier prototype, un historique temporaire côté client peut suffire.

Si une persistance est nécessaire, une base de données pourra être ajoutée pour stocker les dossiers avec des contrôles d'accès, une politique de conservation et des mécanismes de suppression. Une base persistante n'est pas indispensable à la première démonstration.

## 7. Architecture technique

Le système suit le flux suivant :

**Utilisateur → React → API Node.js/Express → règles de sécurité → API Groq → validation de la réponse → interface React.**

Pour l'import d'une capture :

**Image → validation du fichier → OCR → texte extrait → analyse → recommandations.**

Pour la résolution d'un incident :

**Description du problème → collecte des informations utiles → procédure proposée → génération du dossier → export par l'utilisateur.**

Le backend doit vérifier et normaliser les sorties de l'IA avant leur affichage. Les recommandations ne doivent pas être exécutées automatiquement auprès d'un service financier.

## 8. Exemple de réponse structurée de l'IA

Le backend peut demander une réponse JSON conforme à un schéma défini :

```json
{
  "incidentType": "message_suspect",
  "riskLevel": "high",
  "summary": "Le message demande une information confidentielle.",
  "indicators": [
    "Demande de code secret",
    "Incitation à agir rapidement"
  ],
  "recommendedActions": [
    "Ne pas communiquer le code",
    "Vérifier la demande auprès du canal officiel"
  ],
  "limitations": [
    "Le message seul ne permet pas de confirmer l'identité de l'expéditeur."
  ]
}
```

Cet exemple illustre le format attendu ; il ne constitue pas une analyse réelle.

Les valeurs reçues doivent être validées côté serveur. Si le modèle renvoie une réponse invalide ou indisponible, l'application doit afficher un message d'erreur explicite plutôt qu'inventer un résultat.

## 9. Sécurité et confidentialité

Woolu AI traite potentiellement des informations financières sensibles. La protection des utilisateurs doit être intégrée dès le MVP.

Principes essentiels :

- Ne jamais demander de PIN, de mot de passe ou de code OTP.
- Conserver la clé Groq exclusivement dans les variables d'environnement du backend.
- Ne jamais exposer la clé dans le code React ou dans le dépôt Git.
- Limiter la taille et les types de fichiers acceptés.
- Éviter de journaliser les messages financiers complets.
- Demander le consentement avant toute conservation ou contribution à des statistiques.
- Réduire les données transmises au modèle au strict nécessaire.
- Prévoir la suppression des données conservées.
- Ne pas présenter un niveau de risque comme une certitude juridique.
- Ne pas publier d'accusations fondées sur des signalements non vérifiés.

Le traitement par un fournisseur externe doit également être évalué au regard de ses conditions de service, de ses politiques de conservation et des exigences applicables à la protection des données.

## 10. Différenciation et originalité

La valeur de Woolu AI ne doit pas reposer uniquement sur la détection de messages frauduleux.

Sa différenciation recherchée repose sur quatre axes complémentaires :

**1. La résolution, pas seulement l'alerte.** L'application accompagne l'utilisateur jusqu'à la préparation d'une démarche concrète.

**2. La preuve structurée.** Les informations éparpillées dans des messages, captures et reçus sont organisées dans un dossier exploitable.

**3. La connaissance des risques locaux.** Les incidents consentis et contrôlés peuvent, à terme, permettre de comprendre les scénarios récurrents propres aux usages locaux.

**4. L'accessibilité.** Le produit est conçu pour les téléphones, les connexions limitées et, progressivement, les langues locales.

Cette combinaison représente une hypothèse de différenciation à tester. Une analyse concurrentielle plus approfondie et des entretiens avec des utilisateurs seront nécessaires avant de revendiquer une originalité exclusive.

## 11. Modèle économique

Le modèle envisagé est principalement B2B2C.

### Pour les particuliers

L'accès aux fonctions essentielles pourrait rester gratuit afin de favoriser l'adoption et l'inclusion financière.

### Pour les organisations

Des licences ou contrats pourraient être proposés à :
- Des institutions de microfinance.
- Des associations de consommateurs.
- Des structures d'accompagnement des commerçants.
- Des organismes qui gèrent des réclamations.
- Des acteurs financiers intéressés par des outils d'assistance et des indicateurs agrégés.

Les revenus pourraient provenir de licences professionnelles, de frais d'intégration et de contrats de service.

Ces pistes restent à valider auprès de partenaires potentiels. Aucun revenu récurrent ne doit être considéré comme acquis avant des entretiens, des pilotes et des engagements commerciaux concrets.

## 12. Plan de réalisation pour le hackathon

### Étape 1 — Interface

Créer une interface mobile avec :
- Une page d'accueil.
- Un formulaire d'analyse.
- Une page de résultat.
- Un parcours de résolution.
- Un aperçu du dossier généré.

### Étape 2 — Backend

Mettre en place l'API Express, la validation des entrées, les règles de sécurité et la communication avec Groq.

### Étape 3 — Parcours complet

Relier le formulaire au backend, afficher les résultats structurés et générer un dossier téléchargeable.

### Étape 4 — Tests

Préparer trois cas synthétiques :
- Message demandant un code confidentiel.
- Transfert débité mais non reçu.
- Paiement contesté avec justificatifs incomplets.

Tester également les erreurs d'API, les entrées vides, les réponses invalides et les fichiers trop volumineux.

### Étape 5 — Démonstration

Présenter le problème, exécuter un scénario réel de bout en bout, montrer la procédure proposée et télécharger le dossier de réclamation.

La priorité est de garantir la fiabilité du parcours principal avant d'ajouter des fonctionnalités secondaires.

## 13. Indicateurs de réussite

Pour évaluer le MVP, il faudra mesurer :
- Le taux de réponses correctement structurées.
- La pertinence des catégories et recommandations sur un jeu de tests annoté.
- Les faux positifs et les faux négatifs.
- Le temps nécessaire pour obtenir un dossier exploitable.
- La compréhension des recommandations par les utilisateurs.
- La proportion d'utilisateurs qui jugent le parcours utile.
- L'intérêt exprimé par des partenaires professionnels.

Ces mesures permettront de distinguer une démonstration convaincante d'un produit réellement utile.

## 14. Vision à long terme

Woolu AI pourrait évoluer en plusieurs étapes :

**Court terme :** assistant de compréhension et de résolution des incidents, avec génération de dossiers.

**Moyen terme :** tableau de bord professionnel, procédures vérifiées, assistance multilingue et analyses agrégées.

**Long terme :** plateforme de confiance numérique interopérable avec plusieurs acteurs, pays et services financiers, si les partenariats, les exigences réglementaires et la viabilité économique le permettent.

La pérennité du projet devra reposer sur la qualité des procédures, la confiance des utilisateurs, les partenariats, la protection des données et l'efficacité opérationnelle, plutôt que sur un modèle d'IA particulier.

## Conclusion

Woolu AI ambitionne de rendre les services financiers numériques plus compréhensibles et plus sûrs pour les utilisateurs africains.

Le MVP du hackathon doit démontrer une promesse précise : **transformer un problème financier numérique en une analyse compréhensible, des actions concrètes et un dossier de résolution structuré.**

La priorité immédiate est de développer cette expérience de bout en bout avec React, Node.js, Express et Groq, puis de la confronter à des utilisateurs réels. L'expansion, les partenariats et la monétisation devront être construits à partir des résultats observés.

**Woolu AI — Comprendre. Sécuriser. Résoudre.**
