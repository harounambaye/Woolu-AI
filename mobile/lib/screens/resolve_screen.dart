import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../models.dart';
import '../services/api.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'dossier_screen.dart';

class ResolveScreen extends StatefulWidget {
  const ResolveScreen({super.key, required this.item});
  final HistoryItem item;

  @override
  State<ResolveScreen> createState() => _ResolveScreenState();
}

class _ResolveScreenState extends State<ResolveScreen> {
  late final DossierInfo _info = widget.item.info;
  late final _amount = TextEditingController(text: _info.amount);
  late final _refs = TextEditingController(text: _info.references);
  late final _chrono = TextEditingController(text: _info.chronology);
  late final _steps = TextEditingController(text: _info.stepsTaken);
  bool _loading = false;

  @override
  void dispose() {
    for (final c in [_amount, _refs, _chrono, _steps]) {
      c.dispose();
    }
    super.dispose();
  }

  String _two(int n) => n.toString().padLeft(2, '0');

  String get _dateLabel {
    final p = _info.date.split('-');
    return p.length == 3 ? '${p[2]}/${p[1]}/${p[0]}' : 'Choisir';
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_info.date) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (d != null) setState(() => _info.date = '${d.year}-${_two(d.month)}-${_two(d.day)}');
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (t != null) setState(() => _info.time = '${_two(t.hour)}:${_two(t.minute)}');
  }

  void _toggle(int i) {
    final done = widget.item.doneSteps;
    setState(() => done.contains(i) ? done.remove(i) : done.add(i));
  }

  Future<void> _generate() async {
    FocusScope.of(context).unfocus();
    _info
      ..amount = _amount.text.trim()
      ..references = _refs.text.trim()
      ..chronology = _chrono.text.trim()
      ..stepsTaken = _steps.text.trim();
    setState(() => _loading = true);
    try {
      widget.item.dossier = await Api.dossier(widget.item.analysis, _info);
      Session.instance.touch();
      if (!mounted) return;
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => DossierScreen(item: widget.item)));
    } on ApiException catch (e) {
      if (mounted) showError(context, e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final steps = widget.item.analysis.resolutionSteps;
    final done = widget.item.doneSteps;
    final progress = steps.isEmpty ? 0.0 : done.length / steps.length;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(PhosphorIconsBold.arrowLeft), onPressed: () => Navigator.pop(context)),
        title: const Text('Parcours de résolution'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(gradient: AppColors.heroGradient, borderRadius: BorderRadius.circular(22)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(PhosphorIconsFill.flagCheckered, color: AppColors.accent, size: 22),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text('Votre progression',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                ),
                Text('${done.length}/${steps.length}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
              ]),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(end: progress),
                  duration: const Duration(milliseconds: 400),
                  builder: (_, v, __) => LinearProgressIndicator(
                    value: v,
                    minHeight: 8,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                  ),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < steps.length; i++)
            _StepTile(index: i, text: steps[i], done: done.contains(i), last: i == steps.length - 1, onTap: () => _toggle(i)),
          const SizedBox(height: 18),
          SectionCard(
            title: 'Compléter le dossier',
            icon: PhosphorIconsBold.folderOpen,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const Text('Champs facultatifs. Ne saisissez jamais de code PIN, de mot de passe ni d\'OTP.',
                  style: TextStyle(color: AppColors.muted, fontSize: 12.5, height: 1.4)),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: _PickerField(icon: PhosphorIconsBold.calendarBlank, label: 'Date', value: _dateLabel, onTap: _pickDate)),
                const SizedBox(width: 10),
                Expanded(
                  child: _PickerField(
                      icon: PhosphorIconsBold.clock, label: 'Heure', value: _info.time.isEmpty ? 'Choisir' : _info.time, onTap: _pickTime),
                ),
              ]),
              const SizedBox(height: 12),
              _Field(controller: _amount, icon: PhosphorIconsBold.coins, label: 'Montant (FCFA)', hint: '75 000', keyboard: TextInputType.number),
              _Field(controller: _refs, icon: PhosphorIconsBold.hash, label: 'Références visibles', hint: 'TX-2610-48213, ticket n°…'),
              _Field(
                controller: _chrono,
                icon: PhosphorIconsBold.clockCounterClockwise,
                label: 'Chronologie des faits',
                hint: "27/10 14h10 : envoi. 28/10 : le bénéficiaire confirme n'avoir rien reçu…",
                lines: 3,
              ),
              _Field(
                controller: _steps,
                icon: PhosphorIconsBold.headset,
                label: 'Démarches déjà effectuées',
                hint: 'Appel au service client le 28/10…',
                lines: 2,
              ),
            ]),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: PrimaryButton(
          label: 'Générer le dossier',
          icon: PhosphorIconsBold.fileText,
          loading: _loading,
          onPressed: _generate,
        ),
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({required this.index, required this.text, required this.done, required this.last, required this.onTap});
  final int index;
  final String text;
  final bool done;
  final bool last;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SizedBox(
          width: 34,
          child: Column(children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: done ? AppColors.primary : AppColors.white,
                shape: BoxShape.circle,
                border: Border.all(color: done ? AppColors.primary : AppColors.line, width: 2),
              ),
              child: Center(
                child: done
                    ? const Icon(PhosphorIconsBold.check, size: 16, color: Colors.white)
                    : Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.muted)),
              ),
            ),
            if (!last) Expanded(child: Container(width: 2, color: done ? AppColors.primary : AppColors.line)),
          ]),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Material(
              color: done ? AppColors.primarySoft : AppColors.white,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: onTap,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: done ? Colors.transparent : AppColors.line),
                  ),
                  child: Text(text,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                        color: done ? AppColors.primaryDark : AppColors.ink,
                        decoration: done ? TextDecoration.lineThrough : null,
                        decorationColor: AppColors.primary,
                      )),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class _PickerField extends StatelessWidget {
  const _PickerField({required this.icon, required this.label, required this.value, required this.onTap});
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final empty = value == 'Choisir';
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 11.5, fontWeight: FontWeight.w600)),
              Text(value,
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: empty ? AppColors.muted : AppColors.ink)),
            ]),
          ]),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.icon,
    required this.label,
    required this.hint,
    this.lines = 1,
    this.keyboard,
  });
  final TextEditingController controller;
  final IconData icon;
  final String label;
  final String hint;
  final int lines;
  final TextInputType? keyboard;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: lines,
        keyboardType: keyboard,
        style: const TextStyle(fontSize: 14.5),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          alignLabelWithHint: lines > 1,
          prefixIcon: lines == 1 ? Icon(icon, size: 20, color: AppColors.primary) : null,
        ),
      ),
    );
  }
}
