import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../models.dart';
import '../services/export.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/risk.dart';
import 'resolve_screen.dart';

class DossierScreen extends StatefulWidget {
  const DossierScreen({super.key, required this.item});
  final HistoryItem item;

  @override
  State<DossierScreen> createState() => _DossierScreenState();
}

class _DossierScreenState extends State<DossierScreen> {
  late final Dossier _d = widget.item.dossier!;
  late final _letter = TextEditingController(text: _d.letter);
  bool _exporting = false;

  @override
  void initState() {
    super.initState();
    _letter.addListener(() => _d.letter = _letter.text);
  }

  @override
  void dispose() {
    _letter.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function(Dossier) action) async {
    setState(() => _exporting = true);
    try {
      await action(_d);
    } catch (_) {
      if (mounted) showError(context, "L'export a échoué. Réessayez.");
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: 'Objet : ${_d.subject}\n\n${_letter.text}'));
    if (mounted) showInfo(context, 'Lettre copiée dans le presse-papiers.');
  }

  @override
  Widget build(BuildContext context) {
    final rows = [
      (PhosphorIconsBold.tag, "Type d'incident", _d.incidentLabel),
      (PhosphorIconsBold.calendarBlank, 'Date et heure', [_d.date, _d.time].where((s) => s.isNotEmpty).join(' à ')),
      (PhosphorIconsBold.coins, 'Montant', _d.amount.isEmpty ? '' : '${_d.amount} FCFA'),
      (PhosphorIconsBold.hash, 'Références', _d.references),
      (PhosphorIconsBold.clockCounterClockwise, 'Chronologie', _d.chronology),
      (PhosphorIconsBold.headset, 'Démarches effectuées', _d.stepsTaken),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(PhosphorIconsBold.arrowLeft), onPressed: () => Navigator.pop(context)),
        title: const Text('Dossier de réclamation'),
        actions: [
          IconButton(
            tooltip: 'Modifier les informations',
            icon: const Icon(PhosphorIconsBold.pencilSimpleLine),
            onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => ResolveScreen(item: widget.item))),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          DemoBanner(visible: _d.demo),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(gradient: AppColors.heroGradient, borderRadius: BorderRadius.circular(24), boxShadow: AppShadows.glow),
            child: Row(children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(18)),
                child: const Icon(PhosphorIconsFill.sealCheck, color: AppColors.accent, size: 32),
              ).animate().scale(begin: const Offset(0.5, 0.5), curve: Curves.easeOutBack, duration: 500.ms),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Votre dossier est prêt', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                  SizedBox(height: 3),
                  Text('Relisez la lettre, puis envoyez-la au service client officiel.',
                      style: TextStyle(color: Color(0xFFD5EDE5), fontSize: 13, height: 1.35)),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Synthèse',
            icon: PhosphorIconsBold.clipboardText,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              RiskPill(_d.riskLevel),
              const SizedBox(height: 12),
              for (final (icon, label, value) in rows)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Icon(icon, size: 17, color: AppColors.muted),
                    const SizedBox(width: 10),
                    SizedBox(width: 105, child: Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 13))),
                    Expanded(
                      child: Text(value.isEmpty ? 'Non précisé' : value,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: value.isEmpty ? const Color(0xFFA0AAB6) : AppColors.ink,
                          )),
                    ),
                  ]),
                ),
              const Divider(height: 24, color: AppColors.line),
              Text(_d.summary, style: const TextStyle(fontSize: 14, height: 1.5)),
            ]),
          ),
          SectionCard(
            title: 'Justificatifs à joindre',
            icon: PhosphorIconsBold.paperclip,
            child: BulletList(_d.evidenceChecklist, icon: PhosphorIconsBold.checkSquare),
          ),
          SectionCard(
            title: 'Brouillon de lettre',
            icon: PhosphorIconsBold.envelopeSimple,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text('Objet : ${_d.subject}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
              const SizedBox(height: 10),
              TextField(
                controller: _letter,
                maxLines: null,
                minLines: 12,
                style: const TextStyle(fontSize: 13.5, height: 1.55),
                decoration: const InputDecoration(fillColor: AppColors.surface),
              ),
              const SizedBox(height: 8),
              const Text('Remplacez les champs entre [crochets] avant envoi. La lettre est modifiable.',
                  style: TextStyle(color: AppColors.muted, fontSize: 12)),
            ]),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: Row(children: [
          Expanded(
            flex: 3,
            child: PrimaryButton(
              label: kIsWeb ? 'Télécharger le PDF' : 'Partager en PDF',
              icon: PhosphorIconsBold.filePdf,
              loading: _exporting,
              onPressed: () => _run(sharePdf),
            ),
          ),
          const SizedBox(width: 10),
          _SquareAction(icon: PhosphorIconsBold.fileTxt, tooltip: 'Exporter en .txt', onTap: () => _run(shareTxt)),
          const SizedBox(width: 10),
          _SquareAction(icon: PhosphorIconsBold.copy, tooltip: 'Copier la lettre', onTap: _copy),
        ]),
      ),
    );
  }
}

class _SquareAction extends StatelessWidget {
  const _SquareAction({required this.icon, required this.tooltip, required this.onTap});
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.line, width: 1.4)),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
        ),
      ),
    );
  }
}
