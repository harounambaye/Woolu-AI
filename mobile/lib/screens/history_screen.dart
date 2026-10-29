import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../models.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/history_tile.dart';
import 'analyze_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  Future<void> _confirmClear(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Effacer la session ?'),
        content: const Text('Les analyses et dossiers de cette session seront supprimés de l\'appareil.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Effacer')),
        ],
      ),
    );
    if (ok == true) Session.instance.clear();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Session.instance,
      builder: (context, _) {
        final items = Session.instance.items;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Mes incidents'),
            actions: [
              if (items.isNotEmpty)
                IconButton(
                  tooltip: 'Effacer la session',
                  icon: const Icon(PhosphorIconsBold.trash),
                  onPressed: () => _confirmClear(context),
                ),
            ],
          ),
          body: items.isEmpty
              ? _Empty(onStart: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AnalyzeScreen())))
              : ListView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(16)),
                      child: const Row(children: [
                        Icon(PhosphorIconsFill.lockKey, size: 18, color: AppColors.primary),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text('Historique de session uniquement : rien n\'est conservé après la fermeture de l\'app.',
                              style: TextStyle(color: AppColors.primaryDark, fontSize: 12.5, fontWeight: FontWeight.w600)),
                        ),
                      ]),
                    ),
                    ...items.map((h) => HistoryTile(item: h)),
                  ],
                ),
        );
      },
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.onStart});
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle),
            child: const Center(child: PhosphorIcon(PhosphorIconsDuotone.folderOpen, size: 46, color: AppColors.primary)),
          ),
          const SizedBox(height: 18),
          const Text('Aucun incident pour le moment', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          const SizedBox(height: 6),
          const Text('Vos analyses et dossiers de la session apparaîtront ici.',
              textAlign: TextAlign.center, style: TextStyle(color: AppColors.muted, height: 1.4)),
          const SizedBox(height: 22),
          SizedBox(width: 240, child: PrimaryButton(label: 'Analyser un incident', icon: PhosphorIconsBold.arrowRight, onPressed: onStart)),
        ]),
      ),
    );
  }
}
