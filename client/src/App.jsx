import { useState } from "react";
import { analyze, createDossier } from "./api.js";
import { EXAMPLES, INCIDENT_OPTIONS } from "./examples.js";
import { RISK, exportPdf, exportTxt } from "./exportDossier.js";

const MAX = 4000;

export default function App() {
  const [screen, setScreen] = useState("home");
  const [history, setHistory] = useState([]); // analyses de la session, en mémoire uniquement
  const [currentId, setCurrentId] = useState(null);
  const current = history.find((h) => h.id === currentId);

  const addAnalysis = (input, analysis) => {
    const id = crypto.randomUUID();
    setHistory((h) => [{ id, at: new Date(), input, analysis, dossier: null }, ...h]);
    setCurrentId(id);
    setScreen("result");
  };
  const setDossier = (dossier) => {
    setHistory((h) => h.map((x) => (x.id === currentId ? { ...x, dossier } : x)));
    setScreen("dossier");
  };
  const open = (id, target) => { setCurrentId(id); setScreen(target); };

  return (
    <div className="min-h-screen bg-slate-50 text-slate-800">
      <header className="sticky top-0 z-10 bg-teal-700 text-white shadow">
        <div className="mx-auto flex max-w-xl items-center justify-between px-4 py-3">
          <button onClick={() => setScreen("home")} className="text-lg font-bold tracking-tight">
            Woolu <span className="text-teal-200">AI</span>
          </button>
          <nav className="flex gap-2 text-sm">
            <button onClick={() => setScreen("form")} className="rounded-full bg-white/15 px-3 py-1 hover:bg-white/25">
              Analyser
            </button>
            <button onClick={() => setScreen("history")} className="rounded-full bg-white/15 px-3 py-1 hover:bg-white/25">
              Session ({history.length})
            </button>
          </nav>
        </div>
      </header>

      <main className="mx-auto max-w-xl px-4 pb-16 pt-5">
        {screen === "home" && <Home onStart={() => setScreen("form")} />}
        {screen === "form" && <AnalyzeForm onDone={addAnalysis} />}
        {screen === "result" && current && (
          <Result item={current} onResolve={() => setScreen("resolve")} onNew={() => setScreen("form")} />
        )}
        {screen === "resolve" && current && (
          <Resolve item={current} onDone={setDossier} onBack={() => setScreen("result")} />
        )}
        {screen === "dossier" && current?.dossier && (
          <Dossier dossier={current.dossier} onEdit={() => setScreen("resolve")} />
        )}
        {screen === "history" && <History items={history} onOpen={open} onNew={() => setScreen("form")} />}
      </main>
    </div>
  );
}

/* ---------- Petits composants ---------- */

function Card({ title, children, className = "" }) {
  return (
    <section className={`mb-4 rounded-2xl border border-slate-200 bg-white p-4 shadow-sm ${className}`}>
      {title && <h2 className="mb-2 font-semibold text-slate-900">{title}</h2>}
      {children}
    </section>
  );
}

function List({ items, ordered }) {
  if (!items?.length) return <p className="text-sm text-slate-500">Aucun élément.</p>;
  const Tag = ordered ? "ol" : "ul";
  return (
    <Tag className={`space-y-1.5 pl-5 text-sm ${ordered ? "list-decimal" : "list-disc"}`}>
      {items.map((it, i) => <li key={i}>{it}</li>)}
    </Tag>
  );
}

function Button({ children, variant = "primary", className = "", ...props }) {
  const styles = {
    primary: "bg-teal-700 text-white hover:bg-teal-800 disabled:bg-slate-400",
    secondary: "border border-teal-700 text-teal-800 bg-white hover:bg-teal-50",
  };
  return (
    <button className={`rounded-xl px-4 py-3 font-semibold transition ${styles[variant]} ${className}`} {...props}>
      {children}
    </button>
  );
}

function RiskBadge({ level }) {
  const r = RISK[level] || RISK.medium;
  return <span className={`inline-block rounded-full border px-3 py-1 text-sm font-bold ${r.cls}`}>{r.label}</span>;
}

function ErrorBox({ message }) {
  if (!message) return null;
  return <div className="mb-4 rounded-xl border border-red-300 bg-red-50 p-3 text-sm text-red-800">⚠️ {message}</div>;
}

function DemoNotice({ demo }) {
  if (!demo) return null;
  return (
    <p className="mb-4 rounded-xl bg-slate-200 px-3 py-2 text-xs text-slate-700">
      Mode démo : aucune clé Groq n'est configurée, la réponse est préenregistrée.
    </p>
  );
}

/* ---------- Écrans ---------- */

function Home({ onStart }) {
  return (
    <div className="pt-6 text-center">
      <p className="text-sm font-semibold uppercase tracking-widest text-teal-700">Assistant de confiance mobile money</p>
      <h1 className="mt-3 text-4xl font-extrabold leading-tight text-slate-900">
        Comprendre.<br />Sécuriser.<br /><span className="text-teal-700">Résoudre.</span>
      </h1>
      <p className="mx-auto mt-4 max-w-sm text-slate-600">
        Un message suspect, un transfert disparu ou un paiement contesté ? Woolu AI analyse la situation, vous dit
        quoi faire maintenant et prépare votre dossier de réclamation.
      </p>
      <Button onClick={onStart} className="mt-6 w-full max-w-xs text-lg">Analyser un incident</Button>
      <div className="mt-8 grid gap-3 text-left sm:grid-cols-3">
        {[
          ["🔍", "Comprendre", "Les indices et le niveau de risque, expliqués simplement."],
          ["🛡️", "Sécuriser", "Les bons réflexes immédiats, sans jamais vous demander de code."],
          ["📄", "Résoudre", "Un dossier et une lettre prêts à envoyer, en PDF ou en texte."],
        ].map(([icon, t, d]) => (
          <div key={t} className="rounded-2xl border border-slate-200 bg-white p-4">
            <div className="text-2xl">{icon}</div>
            <div className="mt-1 font-semibold">{t}</div>
            <div className="text-sm text-slate-600">{d}</div>
          </div>
        ))}
      </div>
      <p className="mt-8 text-xs text-slate-500">
        Woolu AI ne vous demandera jamais votre code PIN, votre mot de passe ni un code OTP. Ne les communiquez à personne.
      </p>
    </div>
  );
}

function AnalyzeForm({ onDone }) {
  const [text, setText] = useState("");
  const [incidentType, setIncidentType] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  const loadExample = (ex) => { setText(ex.text); setIncidentType(ex.incidentType); setError(""); };

  const submit = async (e) => {
    e.preventDefault();
    if (!text.trim()) return setError("Collez un message ou décrivez votre incident avant de lancer l'analyse.");
    setLoading(true);
    setError("");
    try {
      const analysis = await analyze(text, incidentType);
      onDone({ text, incidentType }, analysis);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <form onSubmit={submit}>
      <h1 className="mb-1 text-2xl font-bold">Décrivez votre incident</h1>
      <p className="mb-4 text-sm text-slate-600">
        Collez le message reçu ou racontez ce qui s'est passé. Retirez vos codes et mots de passe : nous n'en avons pas besoin.
      </p>

      <div className="mb-4">
        <p className="mb-2 text-xs font-semibold uppercase tracking-wide text-slate-500">Charger un exemple</p>
        <div className="flex flex-wrap gap-2">
          {EXAMPLES.map((ex) => (
            <button type="button" key={ex.id} onClick={() => loadExample(ex)}
              className="rounded-full border border-teal-300 bg-teal-50 px-3 py-1.5 text-sm text-teal-800 hover:bg-teal-100">
              {ex.label}
            </button>
          ))}
        </div>
      </div>

      <label className="mb-1 block text-sm font-medium" htmlFor="type">Type d'incident</label>
      <select id="type" value={incidentType} onChange={(e) => setIncidentType(e.target.value)}
        className="mb-4 w-full rounded-xl border border-slate-300 bg-white p-3">
        {INCIDENT_OPTIONS.map((o) => <option key={o.value} value={o.value}>{o.label}</option>)}
      </select>

      <label className="mb-1 block text-sm font-medium" htmlFor="text">Message ou description</label>
      <textarea id="text" value={text} onChange={(e) => setText(e.target.value)} maxLength={MAX} rows={9}
        placeholder="Ex. : J'ai reçu un SMS qui me demande le code que je vais recevoir…"
        className="w-full rounded-xl border border-slate-300 bg-white p-3 text-sm" />
      <p className={`mb-4 text-right text-xs ${text.length > MAX * 0.9 ? "text-red-600" : "text-slate-500"}`}>
        {text.length} / {MAX}
      </p>

      <ErrorBox message={error} />
      <Button type="submit" disabled={loading} className="w-full">
        {loading ? "Analyse en cours…" : "Analyser"}
      </Button>
    </form>
  );
}

function Result({ item, onResolve, onNew }) {
  const a = item.analysis;
  return (
    <div>
      <DemoNotice demo={a.demo} />
      <div className="mb-4 flex flex-wrap items-center gap-2">
        <RiskBadge level={a.riskLevel} />
        <span className="rounded-full bg-slate-200 px-3 py-1 text-sm">{a.incidentLabel}</span>
      </div>
      <Card title="Ce que nous comprenons"><p className="text-sm leading-relaxed">{a.summary}</p></Card>
      <Card title="✅ À faire maintenant" className="border-teal-300">
        <List items={a.recommendedActions} ordered />
      </Card>
      <Card title="🔎 Indices relevés"><List items={a.indicators} /></Card>
      <Card title="⚠️ Limites de l'analyse" className="border-2 border-amber-400 bg-amber-50">
        <List items={a.limitations} />
      </Card>
      {a.missingInfo.length > 0 && <Card title="❓ Informations manquantes"><List items={a.missingInfo} /></Card>}
      <div className="grid gap-2 sm:grid-cols-2">
        <Button onClick={onResolve}>Résoudre l'incident →</Button>
        <Button variant="secondary" onClick={onNew}>Nouvelle analyse</Button>
      </div>
    </div>
  );
}

const EMPTY_INFO = { date: "", time: "", amount: "", references: "", chronology: "", stepsTaken: "" };

function Resolve({ item, onDone, onBack }) {
  const a = item.analysis;
  const [done, setDone] = useState([]);
  const [info, setInfo] = useState(() => item.dossier ? pickInfo(item.dossier) : EMPTY_INFO);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const set = (k) => (e) => setInfo((i) => ({ ...i, [k]: e.target.value }));
  const toggle = (i) => setDone((d) => (d.includes(i) ? d.filter((x) => x !== i) : [...d, i]));

  const submit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError("");
    try {
      onDone(await createDossier(a, info));
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  const input = "w-full rounded-xl border border-slate-300 bg-white p-3 text-sm";
  return (
    <div>
      <button onClick={onBack} className="mb-3 text-sm text-teal-700">← Retour à l'analyse</button>
      <h1 className="mb-1 text-2xl font-bold">Parcours de résolution</h1>
      <p className="mb-4 text-sm text-slate-600">Cochez les étapes au fur et à mesure.</p>

      <Card title={`Étapes (${done.length}/${a.resolutionSteps.length})`}>
        <ol className="space-y-2">
          {a.resolutionSteps.map((s, i) => (
            <li key={i}>
              <label className="flex cursor-pointer items-start gap-3 rounded-xl p-2 hover:bg-slate-50">
                <input type="checkbox" checked={done.includes(i)} onChange={() => toggle(i)} className="mt-1 h-5 w-5 accent-teal-700" />
                <span className={`text-sm ${done.includes(i) ? "text-slate-400 line-through" : ""}`}>
                  <b>{i + 1}.</b> {s}
                </span>
              </label>
            </li>
          ))}
        </ol>
      </Card>

      <form onSubmit={submit}>
        <Card title="Compléter le dossier">
          <p className="mb-3 text-xs text-slate-500">
            Champs facultatifs. N'indiquez jamais de code PIN, de mot de passe ni d'OTP.
          </p>
          <div className="mb-3 grid grid-cols-2 gap-3">
            <label className="text-sm">Date<input type="date" value={info.date} onChange={set("date")} className={input} /></label>
            <label className="text-sm">Heure<input type="time" value={info.time} onChange={set("time")} className={input} /></label>
          </div>
          <label className="mb-3 block text-sm">Montant (FCFA)
            <input inputMode="numeric" value={info.amount} onChange={set("amount")} placeholder="75 000" className={input} />
          </label>
          <label className="mb-3 block text-sm">Références visibles (transaction, ticket…)
            <input value={info.references} onChange={set("references")} placeholder="TX-…" className={input} />
          </label>
          <label className="mb-3 block text-sm">Chronologie des faits
            <textarea rows={3} value={info.chronology} onChange={set("chronology")} className={input}
              placeholder="27/10 14h10 : envoi. 28/10 : le bénéficiaire confirme n'avoir rien reçu…" />
          </label>
          <label className="block text-sm">Démarches déjà effectuées
            <textarea rows={2} value={info.stepsTaken} onChange={set("stepsTaken")} className={input}
              placeholder="Appel au service client le 28/10, ticket n°…" />
          </label>
        </Card>
        <ErrorBox message={error} />
        <Button type="submit" disabled={loading} className="w-full">
          {loading ? "Rédaction du dossier…" : "Générer le dossier de réclamation"}
        </Button>
      </form>
    </div>
  );
}

const pickInfo = (d) => Object.fromEntries(Object.keys(EMPTY_INFO).map((k) => [k, d[k] || ""]));

function Dossier({ dossier: d, onEdit }) {
  const [letter, setLetter] = useState(d.letter);
  const edited = { ...d, letter };
  const rows = [
    ["Type d'incident", d.incidentLabel],
    ["Date et heure", [d.date, d.time].filter(Boolean).join(" à ") || "non précisées"],
    ["Montant", d.amount ? `${d.amount} FCFA` : "non précisé"],
    ["Références", d.references || "non précisées"],
    ["Chronologie", d.chronology || "non précisée"],
    ["Démarches effectuées", d.stepsTaken || "aucune"],
  ];
  return (
    <div>
      <DemoNotice demo={d.demo} />
      <div className="mb-4 flex items-center justify-between gap-2">
        <h1 className="text-2xl font-bold">Votre dossier</h1>
        <RiskBadge level={d.riskLevel} />
      </div>
      <Card title="Synthèse">
        <dl className="divide-y divide-slate-100 text-sm">
          {rows.map(([k, v]) => (
            <div key={k} className="grid grid-cols-3 gap-2 py-2">
              <dt className="text-slate-500">{k}</dt>
              <dd className="col-span-2 whitespace-pre-wrap">{v}</dd>
            </div>
          ))}
        </dl>
        <p className="mt-3 text-sm">{d.summary}</p>
      </Card>
      <Card title="Justificatifs à joindre"><List items={d.evidenceChecklist} /></Card>
      <Card title="Brouillon de lettre (modifiable)">
        <p className="mb-2 text-sm font-medium">Objet : {d.subject}</p>
        <textarea value={letter} onChange={(e) => setLetter(e.target.value)} rows={16}
          className="w-full rounded-xl border border-slate-300 p-3 font-mono text-xs leading-relaxed" />
        <p className="mt-2 text-xs text-slate-500">
          Remplacez les champs entre [crochets], relisez la lettre, puis envoyez-la vous-même au service client officiel.
        </p>
      </Card>
      <div className="grid gap-2 sm:grid-cols-3">
        <Button onClick={() => exportPdf(edited)}>Télécharger le PDF</Button>
        <Button variant="secondary" onClick={() => exportTxt(edited)}>Exporter en .txt</Button>
        <Button variant="secondary" onClick={onEdit}>Modifier les infos</Button>
      </div>
    </div>
  );
}

function History({ items, onOpen, onNew }) {
  return (
    <div>
      <h1 className="mb-1 text-2xl font-bold">Analyses de la session</h1>
      <p className="mb-4 text-sm text-slate-600">
        Rien n'est enregistré sur nos serveurs : cette liste disparaît quand vous fermez ou rechargez la page.
      </p>
      {items.length === 0 && (
        <Card><p className="mb-3 text-sm text-slate-500">Aucune analyse pour l'instant.</p><Button onClick={onNew}>Analyser un incident</Button></Card>
      )}
      {items.map((h) => (
        <Card key={h.id}>
          <div className="mb-2 flex flex-wrap items-center gap-2">
            <RiskBadge level={h.analysis.riskLevel} />
            <span className="text-sm font-medium">{h.analysis.incidentLabel}</span>
            <span className="ml-auto text-xs text-slate-500">{h.at.toLocaleTimeString("fr-FR", { hour: "2-digit", minute: "2-digit" })}</span>
          </div>
          <p className="mb-3 line-clamp-2 text-sm text-slate-600">{h.input.text}</p>
          <div className="flex flex-wrap gap-3 text-sm">
            <button className="font-semibold text-teal-700" onClick={() => onOpen(h.id, "result")}>Voir l'analyse</button>
            {h.dossier
              ? <button className="font-semibold text-teal-700" onClick={() => onOpen(h.id, "dossier")}>Voir le dossier ✓</button>
              : <button className="font-semibold text-teal-700" onClick={() => onOpen(h.id, "resolve")}>Créer le dossier</button>}
          </div>
        </Card>
      ))}
    </div>
  );
}
