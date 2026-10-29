import { INCIDENT_TYPES, RISK_LEVELS, FIXED_LIMITATION } from "./constants.js";

const cleanString = (v, max = 600) => (typeof v === "string" ? v.trim().slice(0, max) : "");

function cleanList(v, field) {
  if (!Array.isArray(v)) throw new Error(`champ "${field}" absent ou invalide`);
  return v.map((s) => cleanString(s, 400)).filter(Boolean).slice(0, 8);
}

// Valide et normalise la réponse d'analyse. Lève une erreur si le schéma n'est pas respecté.
export function validateAnalysis(raw) {
  if (!raw || typeof raw !== "object") throw new Error("réponse non JSON");
  if (!RISK_LEVELS.includes(raw.riskLevel)) throw new Error(`riskLevel invalide`);
  const summary = cleanString(raw.summary, 1000);
  if (!summary) throw new Error(`summary manquant`);

  const result = {
    incidentType: INCIDENT_TYPES[raw.incidentType] ? raw.incidentType : "autre",
    riskLevel: raw.riskLevel,
    summary,
    indicators: cleanList(raw.indicators, "indicators"),
    recommendedActions: cleanList(raw.recommendedActions, "recommendedActions"),
    limitations: cleanList(raw.limitations, "limitations"),
    missingInfo: cleanList(raw.missingInfo, "missingInfo"),
    resolutionSteps: cleanList(raw.resolutionSteps, "resolutionSteps"),
  };
  if (!result.recommendedActions.length) throw new Error("aucune action recommandée");
  if (!result.limitations.includes(FIXED_LIMITATION)) result.limitations.unshift(FIXED_LIMITATION);
  return result;
}

export function validateLetter(raw) {
  if (!raw || typeof raw !== "object") throw new Error("réponse non JSON");
  const subject = cleanString(raw.subject, 300);
  const letter = cleanString(raw.letter, 6000);
  if (!subject || !letter) throw new Error("lettre incomplète");
  const evidenceChecklist = Array.isArray(raw.evidenceChecklist)
    ? raw.evidenceChecklist.map((s) => cleanString(s, 300)).filter(Boolean).slice(0, 10)
    : [];
  return { subject, letter, evidenceChecklist };
}

// Règles déterministes appliquées avant le modèle : elles ne dépendent pas de l'IA.
const RULES = [
  { re: /\b(codes?|pin|otp|mot de passe)\b/i, label: "Le message mentionne un code confidentiel (PIN, OTP ou mot de passe)." },
  { re: /\b(urgent|imm[ée]diatement|vite|sinon|(sous|dans|valable|expire\w*)\s+(les\s+)?\d+\s*(min|minutes|heures?|h)\b)/i, label: "Le message pousse à agir dans l'urgence." },
  { re: /\b(bloqu[ée]|suspendu|d[ée]sactiv[ée])\b/i, label: "Le message menace de bloquer ou de suspendre le compte." },
  { re: /\b(gagn\w*|bonus|cadeau|lot|tir[ée] au sort|f[ée]licitations)\b/i, label: "Le message promet un gain ou un cadeau." },
  { re: /\bfrais de (dossier|d[ée]blocage|retrait)\b/i, label: "Le message réclame des frais avant de verser un gain ou un remboursement." },
];

export function ruleIndicators(text) {
  return RULES.filter((r) => r.re.test(text)).map((r) => `[Règle automatique] ${r.label}`);
}

export function mergeRuleIndicators(result, text) {
  const rules = ruleIndicators(text);
  return { ...result, indicators: [...rules, ...result.indicators].slice(0, 10) };
}
