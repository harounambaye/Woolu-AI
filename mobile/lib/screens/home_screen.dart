import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../examples.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/brand.dart';
import '../widgets/history_tile.dart';
import 'analyze_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onOpenHistory});
  final VoidCallback onOpenHistory;

  void _open(BuildContext context, {InputSource source = InputSource.text, DemoExample? example}) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => AnalyzeScreen(initialSource: source, example: example)));
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _Hero(top: top, onStart: () => _open(context)),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const _SectionTitle('Comment voulez-vous commencer ?'),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _EntryTile(icon: PhosphorIconsDuotone.notePencil, label: 'Décrire\nle problème', onTap: () => _open(context))),
              const SizedBox(width: 10),
              Expanded(child: _EntryTile(icon: PhosphorIconsDuotone.chatCircleText, label: 'Coller\nun SMS', onTap: () => _open(context, source: InputSource.sms))),
              const SizedBox(width: 10),
              Expanded(child: _EntryTile(icon: PhosphorIconsDuotone.scan, label: 'Importer\nune capture', onTap: () => _open(context, source: InputSource.screenshot))),
            ]).animate().fadeIn(delay: 150.ms, duration: 400.ms).slideY(begin: 0.15),
            const SizedBox(height: 28),
            const _SectionTitle('Scénarios de démonstration'),
            const SizedBox(height: 4),
            const Text('Chargez un cas réaliste en un geste.', style: TextStyle(color: AppColors.muted, fontSize: 13.5)),
            const SizedBox(height: 12),
          ]),
        ),
        SizedBox(
          height: 150,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: demoExamples.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) => _DemoCard(
              example: demoExamples[i],
              onTap: () => _open(context, source: demoExamples[i].source, example: demoExamples[i]),
            ).animate().fadeIn(delay: (250 + i * 100).ms).slideX(begin: 0.2),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const _PillarsCard(),
            const SizedBox(height: 16),
            ListenableBuilder(
              listenable: Session.instance,
              builder: (context, _) {
                final items = Session.instance.items;
                if (items.isEmpty) return const SizedBox.shrink();
                return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const SizedBox(height: 12),
                  Row(children: [
                    const Expanded(child: _SectionTitle('Analyses récentes')),
                    TextButton(onPressed: onOpenHistory, child: const Text('Tout voir')),
                  ]),
                  const SizedBox(height: 6),
                  ...items.take(2).map((h) => HistoryTile(item: h)),
                ]);
              },
            ),
            const SizedBox(height: 8),
            const _SafetyNote(),
          ]),
        ),
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.top, required this.onStart});
  final double top;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(22, top + 18, 22, 28),
      decoration: const BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(34)),
      ),
      child: Stack(children: [
        Positioned(
          right: -40,
          top: 10,
          child: Icon(PhosphorIconsThin.shieldCheck, size: 210, color: Colors.white.withValues(alpha: 0.07)),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const BrandMark(light: true),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(20)),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(PhosphorIconsFill.sparkle, size: 13, color: AppColors.accent),
              SizedBox(width: 6),
              Text('Assistant de confiance mobile money',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
            ]),
          ),
          const SizedBox(height: 14),
          const Text.rich(
            TextSpan(children: [
              TextSpan(text: 'Comprendre.\nSécuriser.\n'),
              TextSpan(text: 'Résoudre.', style: TextStyle(color: AppColors.accent)),
            ]),
            style: TextStyle(color: Colors.white, fontSize: 36, height: 1.12, fontWeight: FontWeight.w800, letterSpacing: -0.5),
          ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),
          const SizedBox(height: 12),
          Text(
            'Un SMS suspect, un transfert disparu, un paiement contesté ? Obtenez une analyse claire, les bons réflexes et un dossier de réclamation prêt à envoyer.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.82), fontSize: 14.5, height: 1.5),
          ),
          const SizedBox(height: 22),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: onStart,
              child: const SizedBox(
                height: 56,
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(PhosphorIconsBold.magnifyingGlass, color: AppColors.primary, size: 20),
                  SizedBox(width: 10),
                  Text('Analyser un incident',
                      style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w800, fontSize: 16)),
                ]),
              ),
            ),
          ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.96, 0.96)),
        ]),
      ]),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) =>
      Text(text, style: const TextStyle(fontSize: 17.5, fontWeight: FontWeight.w800, letterSpacing: -0.2));
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.line),
          ),
          child: Column(children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(15)),
              child: Center(child: PhosphorIcon(icon, color: AppColors.primary, size: 26)),
            ),
            const SizedBox(height: 10),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, height: 1.25)),
          ]),
        ),
      ),
    );
  }
}

class _DemoCard extends StatelessWidget {
  const _DemoCard({required this.example, required this.onTap});
  final DemoExample example;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 210,
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.line),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(13)),
                  child: Center(child: PhosphorIcon(example.icon, color: const Color(0xFFB86E00), size: 23)),
                ),
                const Spacer(),
                const Icon(PhosphorIconsBold.arrowUpRight, size: 18, color: AppColors.muted),
              ]),
              const Spacer(),
              Text(example.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5)),
              const SizedBox(height: 3),
              Text(example.subtitle, style: const TextStyle(color: AppColors.muted, fontSize: 12.5)),
            ]),
          ),
        ),
      ),
    );
  }
}

class _PillarsCard extends StatelessWidget {
  const _PillarsCard();

  @override
  Widget build(BuildContext context) {
    const pillars = [
      (PhosphorIconsDuotone.magnifyingGlass, 'Comprendre', 'Indices et niveau de risque, expliqués simplement.'),
      (PhosphorIconsDuotone.shieldCheck, 'Sécuriser', 'Les bons réflexes immédiats, étape par étape.'),
      (PhosphorIconsDuotone.fileText, 'Résoudre', 'Un dossier et une lettre exportables en PDF.'),
    ];
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(24), boxShadow: AppShadows.soft),
      child: Column(children: [
        for (final (icon, title, desc) in pillars)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(14)),
                child: Center(child: PhosphorIcon(icon, color: AppColors.primary, size: 24)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(desc, style: const TextStyle(color: AppColors.muted, fontSize: 13, height: 1.35)),
                ]),
              ),
            ]),
          ),
      ]),
    );
  }
}

class _SafetyNote extends StatelessWidget {
  const _SafetyNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(PhosphorIconsFill.lockKey, color: AppColors.primary, size: 22),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            'Woolu AI ne vous demandera jamais votre code PIN, votre mot de passe ou un code OTP. Ne les communiquez à personne.',
            style: TextStyle(color: AppColors.primaryDark, fontSize: 13, height: 1.45, fontWeight: FontWeight.w600),
          ),
        ),
      ]),
    );
  }
}
