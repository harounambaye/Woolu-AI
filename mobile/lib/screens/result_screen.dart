import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../models.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/risk.dart';
import 'resolve_screen.dart';

const _rulePrefix = '[Règle automatique] ';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.item});
  final HistoryItem item;

  @override
  Widget build(BuildContext context) {
    final a = item.analysis;
    final r = riskOf(a.riskLevel);
    final cards = <Widget>[
      DemoBanner(visible: a.demo),
      SectionCard(
        title: 'Ce que nous comprenons',
        icon: PhosphorIconsBold.lightbulbFilament,
        child: Text(a.summary, style: const TextStyle(fontSize: 15, height: 1.55)),
      ),
      SectionCard(
        title: 'À faire maintenant',
        icon: PhosphorIconsBold.listChecks,
        borderColor: AppColors.primary.withValues(alpha: 0.35),
        child: BulletList(a.recommendedActions, numbered: true),
      ),
      SectionCard(
        title: 'Indices relevés',
        icon: PhosphorIconsBold.magnifyingGlass,
        color: r.color,
        child: _Indicators(a.indicators, color: r.color),
      ),
      SectionCard(
        title: "Limites de l'analyse",
        icon: PhosphorIconsBold.info,
        color: const Color(0xFFB86E00),
        background: const Color(0xFFFFF7E8),
        borderColor: AppColors.accent.withValues(alpha: 0.6),
        child: BulletList(a.limitations, color: const Color(0xFFB86E00), icon: PhosphorIconsBold.warning),
      ),
      if (a.missingInfo.isNotEmpty)
        SectionCard(
          title: 'Informations manquantes',
          icon: PhosphorIconsBold.question,
          color: AppColors.muted,
          child: BulletList(a.missingInfo, color: AppColors.muted, icon: PhosphorIconsBold.circle),
        ),
    ];

    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverToBoxAdapter(child: _RiskHeader(item: item)),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          sliver: SliverList.list(children: [
            for (final (i, c) in cards.indexed) c.animate().fadeIn(delay: (80 * i).ms, duration: 350.ms).slideY(begin: 0.08),
          ]),
        ),
      ]),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: PrimaryButton(
          label: "Résoudre l'incident",
          icon: PhosphorIconsBold.arrowRight,
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ResolveScreen(item: item))),
        ),
      ),
    );
  }
}

class _RiskHeader extends StatelessWidget {
  const _RiskHeader({required this.item});
  final HistoryItem item;

  @override
  Widget build(BuildContext context) {
    final a = item.analysis;
    final r = riskOf(a.riskLevel);
    final dark = Color.lerp(r.color, Colors.black, 0.35)!;
    return Container(
      padding: EdgeInsets.fromLTRB(12, MediaQuery.of(context).padding.top + 6, 22, 26),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [r.color, dark]),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          IconButton(
            icon: const Icon(PhosphorIconsBold.arrowLeft, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Text('Résultat de l\'analyse',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
        ]),
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 14),
            Row(children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(20)),
                child: Icon(r.icon, color: Colors.white, size: 34),
              ).animate().scale(begin: const Offset(0.6, 0.6), curve: Curves.easeOutBack, duration: 500.ms),
              const SizedBox(width: 16),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('NIVEAU DE RISQUE ESTIMÉ',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(r.short, style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800, height: 1.1)),
                ]),
              ),
            ]),
            const SizedBox(height: 18),
            RiskGauge(a.riskLevel),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(20)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(PhosphorIconsBold.tag, size: 14, color: Colors.white),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(a.incidentLabel,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                ),
              ]),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _Indicators extends StatelessWidget {
  const _Indicators(this.items, {required this.color});
  final List<String> items;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      for (final raw in items)
        Builder(builder: (context) {
          final isRule = raw.startsWith(_rulePrefix);
          final text = isRule ? raw.substring(_rulePrefix.length) : raw;
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(isRule ? PhosphorIconsFill.sealWarning : PhosphorIconsBold.eye, size: 18, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  if (isRule)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text('RÈGLE DE SÉCURITÉ',
                          style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.w800, letterSpacing: 0.8)),
                    ),
                  Text(text, style: const TextStyle(fontSize: 14, height: 1.4)),
                ]),
              ),
            ]),
          );
        }),
    ]);
  }
}
