import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../theme.dart';
import 'brand.dart';

const _appWidth = 460.0;

/// Sur téléphone, l'app occupe tout l'écran. Sur tablette et ordinateur, elle s'affiche
/// dans une colonne centrée, accompagnée d'un panneau de présentation sur les grands écrans.
class ResponsiveFrame extends StatelessWidget {
  const ResponsiveFrame({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final width = mq.size.width;
    if (width < 700) return child;

    final wide = width >= 1100;
    final height = (mq.size.height - 48).clamp(560.0, 940.0);
    final app = Container(
      width: _appWidth,
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(34),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.28), blurRadius: 60, offset: const Offset(0, 24)),
        ],
      ),
      child: MediaQuery(
        data: mq.copyWith(size: Size(_appWidth, height), padding: EdgeInsets.zero, viewPadding: EdgeInsets.zero),
        child: child,
      ),
    );

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A5E4D), Color(0xFF052F27)],
        ),
      ),
      child: Stack(children: [
        Positioned(
          left: -120,
          bottom: -140,
          child: Icon(PhosphorIconsThin.shieldCheck, size: 520, color: Colors.white.withValues(alpha: 0.04)),
        ),
        Center(
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (wide) ...[const _Pitch(), const SizedBox(width: 72)],
            app,
          ]),
        ),
      ]),
    );
  }
}

class _Pitch extends StatelessWidget {
  const _Pitch();

  @override
  Widget build(BuildContext context) {
    const features = [
      (PhosphorIconsFill.magnifyingGlass, 'Analyse claire', 'Type d\'incident, niveau de risque et indices expliqués simplement.'),
      (PhosphorIconsFill.listChecks, 'Résolution guidée', 'Les bons réflexes immédiats, puis un parcours étape par étape.'),
      (PhosphorIconsFill.fileText, 'Dossier prêt à envoyer', 'Synthèse et lettre de réclamation, exportables en PDF.'),
      (PhosphorIconsFill.lockKey, 'Confidentiel par conception', 'Aucun code demandé, aucun compte, rien conservé sur nos serveurs.'),
    ];
    return SizedBox(
      width: 420,
      child: Material(
        color: Colors.transparent,
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const BrandMark(light: true),
          const SizedBox(height: 36),
          const Text.rich(
            TextSpan(children: [
              TextSpan(text: 'Vos incidents de mobile money, '),
              TextSpan(text: 'enfin résolus.', style: TextStyle(color: AppColors.accent)),
            ]),
            style: TextStyle(color: Colors.white, fontSize: 40, height: 1.12, fontWeight: FontWeight.w800, letterSpacing: -0.8),
          ),
          const SizedBox(height: 16),
          Text(
            'Un SMS suspect, un transfert disparu, un paiement contesté : Woolu AI transforme le problème en actions concrètes et en dossier de réclamation structuré.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.78), fontSize: 16, height: 1.55),
          ),
          const SizedBox(height: 32),
          for (final (icon, title, desc) in features)
            Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(13)),
                  child: Icon(icon, color: AppColors.accent, size: 21),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15.5)),
                    const SizedBox(height: 3),
                    Text(desc, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13.5, height: 1.45)),
                  ]),
                ),
              ]),
            ),
        ]),
      ),
    );
  }
}
