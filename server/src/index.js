import "dotenv/config";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import express from "express";
import cors from "cors";
import Groq from "groq-sdk";
import { INCIDENT_TYPES, MAX_TEXT_LENGTH } from "./constants.js";
import { ANALYZE_SYSTEM_PROMPT, DOSSIER_SYSTEM_PROMPT } from "./prompts.js";
import { validateAnalysis, validateLetter, mergeRuleIndicators } from "./validate.js";
import { mockAnalysis, mockLetter } from "./mock.js";

const PORT = process.env.PORT || 3001;
const MODEL = process.env.GROQ_MODEL || "openai/gpt-oss-120b";
const DEMO_MODE = !process.env.GROQ_API_KEY;
const groq = DEMO_MODE ? null : new Groq({ apiKey: process.env.GROQ_API_KEY });

// Origines autorisées, séparées par des virgules (client React et app Flutter web en développement).
const ALLOWED_ORIGINS = (process.env.CLIENT_ORIGIN || "http://localhost:5173,http://localhost:5174")
  .split(",")
  .map((o) => o.trim())
  .filter(Boolean);
// Build Flutter web servi sur la même origine que l'API (flutter build web dans mobile/).
const WEB_DIR = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "../../mobile/build/web");

const app = express();
app.use(cors({ origin: ALLOWED_ORIGINS }));
app.use(express.json({ limit: "50kb" }));

class HttpError extends Error {
  constructor(status, message) {
    super(message);
    this.status = status;
  }
}

async function askGroq(systemPrompt, userContent, temperature) {
  let completion;
  try {
    completion = await groq.chat.completions.create({
      model: MODEL,
      temperature,
      response_format: { type: "json_object" },
      messages: [
        { role: "system", content: systemPrompt },
        { role: "user", content: userContent },
      ],
    });
  } catch (err) {
    console.error(`[groq] échec de l'appel : ${err.status || ""} ${err.message}`);
    throw new HttpError(502, "Le service d'IA est momentanément indisponible. Réessayez dans un instant.");
  }
  try {
    return JSON.parse(completion.choices[0]?.message?.content || "");
  } catch {
    throw new HttpError(502, "L'IA a renvoyé une réponse illisible. Aucun résultat n'a été inventé : réessayez.");
  }
}

const str = (v, max) => (typeof v === "string" ? v.trim().slice(0, max) : "");

app.get("/api/health", (req, res) => {
  res.json({ ok: true, mode: DEMO_MODE ? "demo" : "groq", model: DEMO_MODE ? null : MODEL });
});

app.post("/api/analyze", async (req, res, next) => {
  try {
    const text = str(req.body?.text, MAX_TEXT_LENGTH + 1);
    const incidentType = INCIDENT_TYPES[req.body?.incidentType] ? req.body.incidentType : "";
    if (!text) throw new HttpError(400, "Le texte à analyser est vide.");
    if (text.length > MAX_TEXT_LENGTH)
      throw new HttpError(400, `Le texte dépasse ${MAX_TEXT_LENGTH} caractères.`);

    // On journalise des métadonnées uniquement, jamais le contenu du message.
    console.log(`[analyze] ${text.length} caractères, type=${incidentType || "non précisé"}, mode=${DEMO_MODE ? "demo" : "groq"}`);

    let result;
    if (DEMO_MODE) {
      result = mockAnalysis(text, incidentType);
    } else {
      const hint = incidentType ? `Type d'incident indiqué par l'utilisateur : ${INCIDENT_TYPES[incidentType]}\n\n` : "";
      const raw = await askGroq(ANALYZE_SYSTEM_PROMPT, `${hint}Texte à analyser :\n"""\n${text}\n"""`, 0.2);
      try {
        result = validateAnalysis(raw);
      } catch (err) {
        console.error(`[analyze] réponse IA invalide : ${err.message}`);
        throw new HttpError(502, "L'IA a renvoyé une analyse incomplète. Aucun résultat n'a été inventé : réessayez.");
      }
    }
    result = mergeRuleIndicators(result, text);
    res.json({ ...result, incidentLabel: INCIDENT_TYPES[result.incidentType], demo: DEMO_MODE });
  } catch (err) {
    next(err);
  }
});

app.post("/api/dossier", async (req, res, next) => {
  try {
    const analysis = req.body?.analysis;
    const i = req.body?.info || {};
    if (!analysis || typeof analysis.summary !== "string")
      throw new HttpError(400, "Le résultat d'analyse est manquant.");

    const isoDate = str(i.date, 20).match(/^(\d{4})-(\d{2})-(\d{2})$/);
    const info = {
      date: isoDate ? `${isoDate[3]}/${isoDate[2]}/${isoDate[1]}` : str(i.date, 20),
      time: str(i.time, 10),
      amount: str(i.amount, 30),
      references: str(i.references, 300),
      chronology: str(i.chronology, 2000),
      stepsTaken: str(i.stepsTaken, 1000),
    };
    const incidentType = INCIDENT_TYPES[analysis.incidentType] ? analysis.incidentType : "autre";
    console.log(`[dossier] type=${incidentType}, mode=${DEMO_MODE ? "demo" : "groq"}`);

    let letter;
    if (DEMO_MODE) {
      letter = mockLetter(analysis, info);
    } else {
      const content = JSON.stringify({
        typeIncident: INCIDENT_TYPES[incidentType],
        resumeAnalyse: str(analysis.summary, 1000),
        indices: Array.isArray(analysis.indicators) ? analysis.indicators.slice(0, 8) : [],
        dateDeclaree: info.date || "non précisée",
        heureDeclaree: info.time || "non précisée",
        montantFCFA: info.amount || "non précisé",
        references: info.references || "non précisées",
        chronologie: info.chronology || "non précisée",
        demarchesEffectuees: info.stepsTaken || "aucune",
      });
      const raw = await askGroq(DOSSIER_SYSTEM_PROMPT, `Informations déclarées par l'utilisateur :\n${content}`, 0.4);
      try {
        letter = validateLetter(raw);
      } catch (err) {
        console.error(`[dossier] réponse IA invalide : ${err.message}`);
        throw new HttpError(502, "L'IA n'a pas pu rédiger la lettre. Réessayez.");
      }
    }

    // Les faits du dossier viennent de l'utilisateur, pas du modèle.
    res.json({
      createdAt: new Date().toISOString(),
      incidentType,
      incidentLabel: INCIDENT_TYPES[incidentType],
      riskLevel: analysis.riskLevel,
      summary: str(analysis.summary, 1000),
      ...info,
      ...letter,
      demo: DEMO_MODE,
    });
  } catch (err) {
    next(err);
  }
});

app.use("/api", (req, res) => res.status(404).json({ error: "Route inconnue." }));

if (fs.existsSync(WEB_DIR)) {
  app.use(express.static(WEB_DIR));
  app.get("*", (req, res) => res.sendFile(path.join(WEB_DIR, "index.html")));
}

app.use((err, req, res, next) => {
  if (err.type === "entity.too.large") return res.status(413).json({ error: "Requête trop volumineuse." });
  if (err.type === "entity.parse.failed") return res.status(400).json({ error: "JSON invalide." });
  const status = err.status || 500;
  if (status === 500) console.error(`[erreur] ${err.message}`);
  res.status(status).json({ error: status === 500 ? "Erreur interne du serveur." : err.message });
});

app.listen(PORT, () => {
  console.log(`Woolu AI API sur http://localhost:${PORT} — mode ${DEMO_MODE ? "DÉMO (réponses mockées)" : `Groq (${MODEL})`}`);
  if (fs.existsSync(WEB_DIR)) console.log(`Application web servie sur http://localhost:${PORT}`);
});
