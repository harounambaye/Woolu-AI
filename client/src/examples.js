// Scénarios de démonstration synthétiques : marques, noms et numéros sont fictifs.
export const EXAMPLES = [
  {
    id: "code",
    label: "Demande de code",
    incidentType: "demande_code",
    text: `SMS reçu le 28/10 à 21h47 du 77 000 00 00 :
"SERVICE CLIENT MOBILE MONEY : Bonjour, suite à une erreur système, un remboursement de 25 000 FCFA est en attente sur votre compte. Pour le débloquer, envoyez-nous IMMÉDIATEMENT le code à 6 chiffres que vous allez recevoir par SMS. Sans réponse sous 30 minutes, votre compte sera suspendu. Merci de votre confiance."`,
  },
  {
    id: "transfert",
    label: "Transfert non reçu",
    incidentType: "transfert_non_recu",
    text: `Hier, le 27/10 vers 14h10, j'ai envoyé 75 000 FCFA à ma sœur à Ziguinchor depuis mon compte mobile money. J'ai reçu le SMS : "Transfert de 75 000 FCFA effectué. Frais : 750 FCFA. Réf : TX-2610-48213. Nouveau solde : 12 340 FCFA." Mais ma sœur dit qu'elle n'a toujours rien reçu, ni SMS ni argent. Ça fait plus de 24 heures. Je ne sais pas qui contacter.`,
  },
  {
    id: "commercant",
    label: "Paiement contesté",
    incidentType: "paiement_conteste",
    text: `Je suis client d'une quincaillerie à Thiès. Samedi dernier, j'ai payé 42 500 FCFA par mobile money pour du matériel. J'ai eu un SMS de confirmation, mais je l'ai supprimé par erreur ; il me reste seulement une capture où l'on voit "Paiement marchand 42 500 FCFA" et une référence coupée qui commence par "PM-15...". Le commerçant dit qu'il n'a rien reçu et refuse de me donner le matériel sans un nouveau paiement. Il ne m'a pas donné de reçu.`,
  },
];

export const INCIDENT_OPTIONS = [
  { value: "", label: "Je ne sais pas (détection automatique)" },
  { value: "demande_code", label: "Message demandant un code confidentiel" },
  { value: "transfert_non_recu", label: "Compte débité, transfert non reçu" },
  { value: "paiement_conteste", label: "Paiement contesté par un commerçant" },
  { value: "erreur_destinataire", label: "Transfert au mauvais destinataire" },
  { value: "fausse_confirmation", label: "Confirmation de paiement incohérente" },
  { value: "autre", label: "Autre incident" },
];
