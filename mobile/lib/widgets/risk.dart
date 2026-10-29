import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../theme.dart';

class RiskInfo {
  const RiskInfo(this.label, this.short, this.color, this.icon, this.level);
  final String label;
  final String short;
  final Color color;
  final IconData icon;
  final int level; // 1 à 3, pour la jauge
}

RiskInfo riskOf(String level) => switch (level) {
      'low' => const RiskInfo('Risque faible', 'Faible', AppColors.low, PhosphorIconsFill.shieldCheck, 1),
      'high' => const RiskInfo('Risque élevé', 'Élevé', AppColors.high, PhosphorIconsFill.warningOctagon, 3),
      _ => const RiskInfo('Risque modéré', 'Modéré', AppColors.medium, PhosphorIconsFill.shieldWarning, 2),
    };

class RiskPill extends StatelessWidget {
  const RiskPill(this.level, {super.key, this.compact = false});
  final String level;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final r = riskOf(level);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 12, vertical: compact ? 4 : 6),
      decoration: BoxDecoration(color: r.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(30)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(r.icon, size: compact ? 13 : 16, color: r.color),
        const SizedBox(width: 5),
        Text(compact ? r.short : r.label,
            style: TextStyle(color: r.color, fontWeight: FontWeight.w700, fontSize: compact ? 11.5 : 13)),
      ]),
    );
  }
}

/// Jauge à trois segments affichée en tête du résultat.
class RiskGauge extends StatelessWidget {
  const RiskGauge(this.level, {super.key});
  final String level;

  @override
  Widget build(BuildContext context) {
    final r = riskOf(level);
    return Row(
      children: List.generate(3, (i) {
        final on = i < r.level;
        return Expanded(
          child: AnimatedContainer(
            duration: Duration(milliseconds: 400 + i * 150),
            height: 6,
            margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
            decoration: BoxDecoration(
              color: on ? Colors.white : Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        );
      }),
    );
  }
}
