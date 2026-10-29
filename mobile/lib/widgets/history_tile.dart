import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../models.dart';
import '../screens/dossier_screen.dart';
import '../screens/result_screen.dart';
import '../theme.dart';
import 'risk.dart';

IconData sourceIcon(InputSource s) => switch (s) {
      InputSource.sms => PhosphorIconsBold.chatCircleText,
      InputSource.screenshot => PhosphorIconsBold.imageSquare,
      InputSource.text => PhosphorIconsBold.notePencil,
    };

class HistoryTile extends StatelessWidget {
  const HistoryTile({super.key, required this.item});
  final HistoryItem item;

  @override
  Widget build(BuildContext context) {
    final r = riskOf(item.analysis.riskLevel);
    final t = item.at;
    final time = '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(20), boxShadow: AppShadows.soft),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => item.dossier != null ? DossierScreen(item: item) : ResultScreen(item: item),
          )),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: r.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(15)),
                child: Icon(r.icon, color: r.color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(item.analysis.incidentLabel,
                      maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5)),
                  const SizedBox(height: 3),
                  Text(item.input.replaceAll('\n', ' '),
                      maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.muted, fontSize: 12.5)),
                  const SizedBox(height: 6),
                  Row(children: [
                    RiskPill(item.analysis.riskLevel, compact: true),
                    const SizedBox(width: 8),
                    Icon(sourceIcon(item.source), size: 13, color: AppColors.muted),
                    const SizedBox(width: 4),
                    Text(time, style: const TextStyle(color: AppColors.muted, fontSize: 11.5)),
                    const Spacer(),
                    if (item.dossier != null)
                      const Row(children: [
                        Icon(PhosphorIconsFill.fileText, size: 14, color: AppColors.primary),
                        SizedBox(width: 3),
                        Text('Dossier', style: TextStyle(color: AppColors.primary, fontSize: 11.5, fontWeight: FontWeight.w700)),
                      ]),
                  ]),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
