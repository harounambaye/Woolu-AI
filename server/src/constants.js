export const INCIDENT_TYPES = {
  demande_code: "Message demandant un code confidentiel",
  transfert_non_recu: "Compte débité, transfert non reçu",
  paiement_conteste: "Paiement contesté par un commerçant",
  erreur_destinataire: "Transfert au mauvais destinataire",
  fausse_confirmation: "Confirmation de paiement incohérente",
  autre: "Autre incident",
};

export const RISK_LEVELS = ["low", "medium", "high"];

export const MAX_TEXT_LENGTH = 4000;

// Ajoutée à chaque analyse, quel que soit le contenu renvoyé par le modèle.
export const FIXED_LIMITATION =
  "Cette analyse est une aide à la compréhension. Ce n'est ni une preuve de fraude ni un avis juridique.";
