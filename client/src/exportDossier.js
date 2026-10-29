import { jsPDF } from "jspdf";

export const RISK = {
  low: { label: "Risque faible", cls: "bg-emerald-100 text-emerald-800 border-emerald-300" },
  medium: { label: "Risque modéré", cls: "bg-amber-100 text-amber-800 border-amber-300" },
  high: { label: "Risque élevé", cls: "bg-red-100 text-red-800 border-red-300" },
};

const DISCLAIMER =
  "Dossier préparé avec l'aide de Woolu AI à partir des informations déclarées par l'utilisateur. L'analyse ne constitue ni une preuve de fraude ni un avis juridique.";

function sections(d) {
  return [
    ["Type d'incident", d.incidentLabel],
    ["Niveau de risque estimé", RISK[d.riskLevel]?.label || "-"],
    ["Date et heure déclarées", `${d.date || "non précisée"} ${d.time ? "à " + d.time : ""}`],
    ["Montant indiqué", d.amount ? `${d.amount} FCFA` : "non précisé"],
    ["Références visibles", d.references || "non précisées"],
    ["Résumé de l'analyse", d.summary],
    ["Chronologie des faits", d.chronology || "non précisée"],
    ["Démarches déjà effectuées", d.stepsTaken || "aucune"],
    ["Justificatifs à joindre", d.evidenceChecklist.map((e) => `- ${e}`).join("\n")],
  ];
}

export function dossierToText(d) {
  const parts = [
    "DOSSIER DE RÉCLAMATION - WOOLU AI",
    `Créé le ${new Date(d.createdAt).toLocaleString("fr-FR")}`,
    "",
    ...sections(d).flatMap(([t, v]) => [t.toUpperCase(), v, ""]),
    "BROUILLON DE LETTRE",
    `Objet : ${d.subject}`,
    "",
    d.letter,
    "",
    "---",
    DISCLAIMER,
  ];
  return parts.join("\n");
}

function download(blob, name) {
  const url = URL.createObjectURL(blob);
  const a = Object.assign(document.createElement("a"), { href: url, download: name });
  a.click();
  URL.revokeObjectURL(url);
}

const fileName = (d, ext) => `dossier-woolu-${d.createdAt.slice(0, 10)}.${ext}`;

export function exportTxt(d) {
  download(new Blob([dossierToText(d)], { type: "text/plain;charset=utf-8" }), fileName(d, "txt"));
}

// Les polices standard de jsPDF ne couvrent que le Latin-1 : on remplace les rares caractères hors jeu.
const latin1 = (s) =>
  String(s ?? "")
    .replace(/[–—]/g, "-")
    .replace(/[’‘]/g, "'")
    .replace(/[“”]/g, '"')
    .replace(/œ/g, "oe")
    .replace(/…/g, "...")
    .replace(/[  ]/g, " ")
    .replace(/[^\x00-\xff\n]/g, "");

export function exportPdf(d) {
  const doc = new jsPDF({ unit: "mm", format: "a4" });
  const W = 210, M = 18, maxW = W - 2 * M;
  let y = 20;

  const write = (text, { size = 10, bold = false, color = [30, 41, 59], gap = 5 } = {}) => {
    doc.setFont("helvetica", bold ? "bold" : "normal");
    doc.setFontSize(size);
    doc.setTextColor(...color);
    for (const line of doc.splitTextToSize(latin1(text), maxW)) {
      if (y > 280) { doc.addPage(); y = 20; }
      doc.text(line, M, y);
      y += size * 0.45;
    }
    y += gap - size * 0.45 + 2;
  };

  write("Dossier de réclamation", { size: 18, bold: true, color: [15, 118, 110], gap: 2 });
  write(`Woolu AI - créé le ${new Date(d.createdAt).toLocaleString("fr-FR")}`, { size: 9, color: [100, 116, 139] });
  for (const [title, value] of sections(d)) {
    write(title, { size: 11, bold: true, gap: 1 });
    write(value);
  }
  doc.addPage(); y = 20;
  write("Brouillon de lettre de réclamation", { size: 14, bold: true, color: [15, 118, 110] });
  write(`Objet : ${d.subject}`, { bold: true });
  write(d.letter);
  write(DISCLAIMER, { size: 8, color: [100, 116, 139] });
  doc.save(fileName(d, "pdf"));
}
