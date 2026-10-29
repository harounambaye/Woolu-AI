// Réponses du mode démo (pas de GROQ_API_KEY) : la démo fonctionne même sans réseau.

const MOCKS = {
  demande_code: {
    incidentType: "demande_code",
    riskLevel: "high",
    summary:
      "Le message se présente comme venant du service client et demande de communiquer le code reçu par SMS pour « débloquer » un remboursement. Un service officiel ne demande jamais ce code : ce type de demande correspond souvent à une tentative de prise de contrôle du compte.",
    indicators: [
      "Demande explicite du code reçu par SMS",
      "Menace de suspension du compte sous 30 minutes",
      "Numéro d'expéditeur personnel, et non un numéro court officiel",
      "Promesse d'un remboursement que l'utilisateur n'a pas demandé",
    ],
    recommendedActions: [
      "Ne communiquez aucun code (PIN, OTP, code reçu par SMS)",
      "Ne rappelez pas le numéro et ne cliquez sur aucun lien du message",
      "Contactez le service client de votre opérateur via le numéro officiel affiché dans l'application",
      "Faites une capture d'écran du message et conservez-la",
      "Si vous avez déjà donné un code, changez immédiatement votre code PIN et demandez le blocage du compte",
    ],
    limitations: [
      "Le message seul ne permet pas de confirmer l'identité réelle de l'expéditeur.",
      "L'analyse ne peut pas vérifier si votre compte a déjà été utilisé par un tiers.",
    ],
    missingInfo: [
      "Avez-vous communiqué un code ou effectué une opération ?",
      "Date et heure de réception du message",
      "Solde du compte avant et après la réception du message",
    ],
    resolutionSteps: [
      "Sécuriser le compte : ne rien communiquer et changer le PIN en cas de doute",
      "Vérifier l'historique des transactions dans l'application officielle",
      "Signaler le message au service client officiel",
      "Constituer le dossier : captures, date, numéro de l'expéditeur",
      "Envoyer la réclamation si une opération non autorisée apparaît",
    ],
  },
  transfert_non_recu: {
    incidentType: "transfert_non_recu",
    riskLevel: "medium",
    summary:
      "Votre compte a été débité de 75 000 FCFA, mais votre bénéficiaire affirme ne rien avoir reçu. Il peut s'agir d'un retard de traitement, d'une erreur de numéro ou d'un incident technique. La référence de transaction est l'élément clé de la réclamation.",
    indicators: [
      "SMS de débit reçu avec une référence de transaction",
      "Bénéficiaire qui déclare ne pas avoir été crédité",
      "Délai de plus de 24 heures depuis l'envoi",
    ],
    recommendedActions: [
      "Vérifiez que le numéro du bénéficiaire saisi est correct, chiffre par chiffre",
      "Demandez au bénéficiaire de vérifier son historique, et pas seulement ses SMS",
      "Contactez le service client officiel avec la référence de transaction",
      "Conservez le SMS de débit et une capture de l'historique",
    ],
    limitations: [
      "L'analyse ne peut pas consulter les systèmes de l'opérateur ni savoir où se trouvent les fonds.",
      "Une erreur de numéro de votre part ne peut pas être exclue à ce stade.",
    ],
    missingInfo: [
      "Numéro exact du bénéficiaire tel que saisi",
      "Capture de l'historique du bénéficiaire",
      "Numéro de ticket si une réclamation a déjà été ouverte",
    ],
    resolutionSteps: [
      "Vérifier le numéro saisi et le statut de la transaction dans l'application",
      "Recueillir la preuve de non-réception auprès du bénéficiaire",
      "Ouvrir une réclamation auprès du service client avec la référence",
      "Noter le numéro de ticket et le délai de traitement annoncé",
      "Relancer par écrit si aucune réponse n'arrive dans le délai annoncé",
    ],
  },
  paiement_conteste: {
    incidentType: "paiement_conteste",
    riskLevel: "medium",
    summary:
      "Un commerçant affirme ne pas avoir reçu un paiement de 42 500 FCFA que vous dites avoir effectué. Vous disposez d'un SMS de confirmation, mais pas de la référence complète ni du reçu du commerçant. Le dossier doit être complété avant toute réclamation.",
    indicators: [
      "Le paiement a été confirmé par SMS du côté de l'acheteur",
      "Le commerçant conteste la réception du paiement",
      "La référence de transaction est incomplète",
      "Aucun reçu n'a été remis par le commerçant",
    ],
    recommendedActions: [
      "Retrouvez la référence complète dans l'historique de l'application",
      "Demandez au commerçant de vérifier son compte marchand à la date et à l'heure indiquées",
      "Ne payez pas une seconde fois avant d'avoir obtenu une vérification",
      "Rassemblez tous les justificatifs : SMS, capture, facture ou bon de commande",
    ],
    limitations: [
      "L'analyse ne permet pas de déterminer qui, de l'acheteur ou du commerçant, a raison.",
      "Sans référence complète, le prestataire pourra difficilement retrouver l'opération.",
    ],
    missingInfo: [
      "Référence complète de la transaction",
      "Nom ou numéro marchand du commerçant",
      "Facture, ticket de caisse ou bon de commande",
    ],
    resolutionSteps: [
      "Compléter les justificatifs (référence, capture, facture)",
      "Chercher une solution à l'amiable avec le commerçant, preuves à l'appui",
      "Ouvrir une réclamation auprès du prestataire si le désaccord persiste",
      "Suivre la réclamation et conserver tous les échanges écrits",
    ],
  },
};

const GENERIC = {
  incidentType: "autre",
  riskLevel: "medium",
  summary:
    "Mode démo : aucune clé Groq n'est configurée, ce texte n'a donc pas été analysé par l'IA. Les recommandations ci-dessous sont des précautions générales.",
  indicators: ["Analyse IA indisponible en mode démo"],
  recommendedActions: [
    "Ne communiquez jamais votre code PIN, OTP ou mot de passe",
    "Vérifiez toute demande auprès du service client officiel",
    "Conservez les messages et les captures liés à l'incident",
  ],
  limitations: ["Résultat générique du mode démo : il ne s'agit pas d'une analyse de votre texte."],
  missingInfo: ["Date, montant et référence de l'opération concernée"],
  resolutionSteps: [
    "Rassembler les preuves",
    "Contacter le service client officiel",
    "Préparer une réclamation écrite",
  ],
};

function guessScenario(text, incidentType) {
  if (MOCKS[incidentType]) return incidentType;
  const t = text.toLowerCase();
  if (/(code|otp|pin|mot de passe)/.test(t)) return "demande_code";
  if (/(commer[çc]ant|boutique|marchand)/.test(t)) return "paiement_conteste";
  if (/(d[ée]bit|pas re[çc]u|non re[çc]u|rien re[çc]u|b[ée]n[ée]ficiaire)/.test(t)) return "transfert_non_recu";
  return null;
}

export function mockAnalysis(text, incidentType) {
  const key = guessScenario(text, incidentType);
  return structuredClone(key ? MOCKS[key] : GENERIC);
}

export function mockLetter(analysis, info) {
  const lines = [
    "[Nom et prénom]",
    "[Numéro de compte mobile money]",
    "",
    "À l'attention du service client",
    "",
    `Objet : Réclamation – ${analysis.summary.split(".")[0]}`,
    "",
    "Madame, Monsieur,",
    "",
    `Je vous signale un incident survenu le ${info.date || "[date]"} vers ${info.time || "[heure]"}${
      info.amount ? `, portant sur un montant de ${info.amount} FCFA` : ""
    }.`,
    info.references ? `Références visibles : ${info.references}.` : "Référence de transaction : [à compléter].",
    "",
    info.chronology ? `Déroulé des faits : ${info.chronology}` : "Déroulé des faits : [à compléter].",
    "",
    info.stepsTaken ? `Démarches déjà effectuées : ${info.stepsTaken}` : "",
    "",
    "Je vous demande de bien vouloir vérifier cette opération et de m'indiquer les suites données à ma demande, ainsi que le délai de traitement.",
    "Je tiens les justificatifs à votre disposition.",
    "",
    "Je vous prie d'agréer, Madame, Monsieur, l'expression de mes salutations distinguées.",
    "",
    "[Signature]",
  ];
  return {
    subject: `Réclamation – incident du ${info.date || "[date]"}`,
    letter: lines.filter((l, i, a) => !(l === "" && a[i - 1] === "")).join("\n"),
    evidenceChecklist: [
      "SMS ou notification de l'opération",
      "Capture de l'historique des transactions",
      "Échanges écrits avec le bénéficiaire ou le commerçant",
      "Numéro de ticket de réclamation, s'il existe",
    ],
  };
}
