async function post(path, body) {
  let res;
  try {
    res = await fetch(`/api/${path}`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(body),
    });
  } catch {
    throw new Error("Impossible de joindre le serveur. Vérifiez qu'il est bien lancé.");
  }
  const data = await res.json().catch(() => ({}));
  if (!res.ok) throw new Error(data.error || `Erreur ${res.status}`);
  return data;
}

export const analyze = (text, incidentType) => post("analyze", { text, incidentType });
export const createDossier = (analysis, info) => post("dossier", { analysis, info });
