import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../examples.dart';
import '../models.dart';
import '../services/api.dart';
import '../services/ocr.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'result_screen.dart';

const _maxLength = 4000;

class AnalyzeScreen extends StatefulWidget {
  const AnalyzeScreen({super.key, this.initialSource = InputSource.text, this.example});
  final InputSource initialSource;
  final DemoExample? example;

  @override
  State<AnalyzeScreen> createState() => _AnalyzeScreenState();
}

class _AnalyzeScreenState extends State<AnalyzeScreen> {
  final _text = TextEditingController();
  late InputSource _source = widget.initialSource;
  String? _incidentType;
  Uint8List? _image;
  bool _reading = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.example != null) _loadExample(widget.example!);
    _text.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _loadExample(DemoExample e) {
    _text.text = e.text;
    _incidentType = e.incidentType;
    _source = e.source;
    _image = null;
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final value = data?.text?.trim() ?? '';
    if (!mounted) return;
    if (value.isEmpty) return showError(context, 'Le presse-papiers est vide.');
    _text.text = value.length > _maxLength ? value.substring(0, _maxLength) : value;
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final file = await Ocr.pick(source);
      if (file == null) return;
      final bytes = await file.readAsBytes();
      setState(() {
        _image = bytes;
        _reading = true;
      });
      final text = await Ocr.extract(file);
      if (!mounted) return;
      if (text.isEmpty) {
        showError(context, "Aucun texte détecté sur l'image. Essayez une capture plus nette.");
      } else {
        _text.text = text.length > _maxLength ? text.substring(0, _maxLength) : text;
        showInfo(context, 'Texte extrait : relisez-le et masquez vos informations sensibles.');
      }
    } catch (_) {
      if (mounted) showError(context, "Impossible de lire cette image sur cet appareil.");
    } finally {
      if (mounted) setState(() => _reading = false);
    }
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final text = _text.text.trim();
    if (text.isEmpty) return showError(context, 'Décrivez votre incident ou collez le message reçu.');
    setState(() => _loading = true);
    try {
      final analysis = await Api.analyze(text, _incidentType);
      final item = HistoryItem(input: text, source: _source, analysis: analysis);
      Session.instance.add(item);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => ResultScreen(item: item)));
    } on ApiException catch (e) {
      if (mounted) showError(context, e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Scaffold(
        appBar: AppBar(
          leading: IconButton(icon: const Icon(PhosphorIconsBold.arrowLeft), onPressed: () => Navigator.pop(context)),
          title: const Text('Nouvelle analyse'),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          children: [
            _SourceSelector(value: _source, onChanged: (s) => setState(() => _source = s)),
            const SizedBox(height: 18),
            AnimatedSwitcher(
              duration: 250.ms,
              child: KeyedSubtree(key: ValueKey(_source), child: _buildInput()),
            ),
            const SizedBox(height: 22),
            const Text("Type d'incident", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15.5)),
            const SizedBox(height: 4),
            const Text('Facultatif : Woolu le détecte automatiquement.', style: TextStyle(color: AppColors.muted, fontSize: 12.5)),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final o in incidentOptions)
                _TypeChip(
                  option: o,
                  selected: _incidentType == o.value,
                  onTap: () => setState(() => _incidentType = _incidentType == o.value ? null : o.value),
                ),
            ]),
            const SizedBox(height: 22),
            _ExamplesRow(onPick: (e) => setState(() => _loadExample(e))),
            const SizedBox(height: 18),
            const Row(children: [
              Icon(PhosphorIconsFill.lockKey, size: 15, color: AppColors.primary),
              SizedBox(width: 8),
              Expanded(
                child: Text('Retirez vos codes et mots de passe : Woolu n\'en a jamais besoin.',
                    style: TextStyle(color: AppColors.muted, fontSize: 12.5)),
              ),
            ]),
          ],
        ),
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: PrimaryButton(
            label: 'Analyser',
            icon: PhosphorIconsBold.sparkle,
            loading: _loading,
            onPressed: _text.text.trim().isEmpty || _reading ? null : _submit,
          ),
        ),
      ),
      if (_loading) const _AnalyzingOverlay(),
    ]);
  }

  Widget _buildInput() {
    final field = TextField(
      controller: _text,
      maxLines: _source == InputSource.screenshot ? 7 : 9,
      minLines: 6,
      maxLength: _maxLength,
      style: const TextStyle(fontSize: 14.5, height: 1.45),
      decoration: InputDecoration(
        hintText: switch (_source) {
          InputSource.sms => 'Collez ici le SMS reçu…',
          InputSource.screenshot => 'Le texte lu sur la capture apparaîtra ici…',
          InputSource.text => "Racontez ce qui s'est passé : date, montant, ce que vous avez vu…",
        },
      ),
    );

    return switch (_source) {
      InputSource.sms => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          field,
          const SizedBox(height: 4),
          SecondaryButton(label: 'Coller depuis le presse-papiers', icon: PhosphorIconsBold.clipboardText, onPressed: _paste),
        ]),
      InputSource.screenshot => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _ImageDropZone(
            image: _image,
            reading: _reading,
            onGallery: () => _pickImage(ImageSource.gallery),
            onCamera: () => _pickImage(ImageSource.camera),
            onClear: () => setState(() => _image = null),
          ),
          const SizedBox(height: 14),
          field,
        ]),
      InputSource.text => field,
    };
  }
}

class _SourceSelector extends StatelessWidget {
  const _SourceSelector({required this.value, required this.onChanged});
  final InputSource value;
  final ValueChanged<InputSource> onChanged;

  @override
  Widget build(BuildContext context) {
    const items = [
      (InputSource.text, PhosphorIconsBold.notePencil, 'Décrire'),
      (InputSource.sms, PhosphorIconsBold.chatCircleText, 'SMS'),
      (InputSource.screenshot, PhosphorIconsBold.scan, 'Capture'),
    ];
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(color: const Color(0xFFE9EEEC), borderRadius: BorderRadius.circular(18)),
      child: Row(children: [
        for (final (source, icon, label) in items)
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(source),
              child: AnimatedContainer(
                duration: 220.ms,
                curve: Curves.easeOut,
                height: 46,
                decoration: BoxDecoration(
                  color: value == source ? AppColors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: value == source ? AppShadows.soft : null,
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(icon, size: 18, color: value == source ? AppColors.primary : AppColors.muted),
                  const SizedBox(width: 7),
                  Text(label,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                        color: value == source ? AppColors.ink : AppColors.muted,
                      )),
                ]),
              ),
            ),
          ),
      ]),
    );
  }
}

class _ImageDropZone extends StatelessWidget {
  const _ImageDropZone({
    required this.image,
    required this.reading,
    required this.onGallery,
    required this.onCamera,
    required this.onClear,
  });
  final Uint8List? image;
  final bool reading;
  final VoidCallback onGallery;
  final VoidCallback onCamera;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    if (image != null) {
      return Container(
        height: 190,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), boxShadow: AppShadows.soft),
        child: Stack(fit: StackFit.expand, children: [
          Image.memory(image!, fit: BoxFit.cover),
          Container(color: Colors.black.withValues(alpha: reading ? 0.55 : 0.15)),
          if (reading)
            const Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                CircularProgressIndicator(color: Colors.white, strokeWidth: 2.6),
                SizedBox(height: 12),
                Text('Lecture du texte…', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              ]),
            ),
          Positioned(
            top: 10,
            right: 10,
            child: Material(
              color: Colors.white,
              shape: const CircleBorder(),
              child: IconButton(icon: const Icon(PhosphorIconsBold.x, size: 18), onPressed: onClear),
            ),
          ),
          if (!reading)
            Positioned(
              left: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: const Row(children: [
                  Icon(PhosphorIconsFill.checkCircle, size: 15, color: AppColors.low),
                  SizedBox(width: 6),
                  Text('Texte lu sur votre appareil', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                ]),
              ),
            ),
        ]),
      );
    }
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primarySoft.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25), width: 1.4),
      ),
      child: Column(children: [
        const PhosphorIcon(PhosphorIconsDuotone.scan, size: 46, color: AppColors.primary),
        const SizedBox(height: 10),
        const Text('Importez une capture de confirmation', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
        const SizedBox(height: 4),
        const Text("Le texte est lu directement sur votre appareil : l'image n'est jamais envoyée.",
            textAlign: TextAlign.center, style: TextStyle(color: AppColors.muted, fontSize: 12.5, height: 1.4)),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: SecondaryButton(label: 'Galerie', icon: PhosphorIconsBold.images, onPressed: onGallery)),
          const SizedBox(width: 10),
          Expanded(child: SecondaryButton(label: 'Photo', icon: PhosphorIconsBold.camera, onPressed: onCamera)),
        ]),
      ]),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.option, required this.selected, required this.onTap});
  final IncidentOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: 200.ms,
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: selected ? AppColors.primary : AppColors.line),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(option.icon, size: 16, color: selected ? Colors.white : AppColors.primary),
          const SizedBox(width: 7),
          Text(option.label,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: selected ? Colors.white : AppColors.ink)),
        ]),
      ),
    );
  }
}

class _ExamplesRow extends StatelessWidget {
  const _ExamplesRow({required this.onPick});
  final ValueChanged<DemoExample> onPick;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(PhosphorIconsFill.lightning, size: 16, color: Color(0xFFB86E00)),
          SizedBox(width: 6),
          Text('Charger un exemple', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
        ]),
        const SizedBox(height: 10),
        for (final e in demoExamples)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Material(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => onPick(e),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                  child: Row(children: [
                    PhosphorIcon(e.icon, size: 20, color: const Color(0xFFB86E00)),
                    const SizedBox(width: 10),
                    Expanded(child: Text(e.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5))),
                    const Icon(PhosphorIconsBold.arrowRight, size: 16, color: AppColors.muted),
                  ]),
                ),
              ),
            ),
          ),
      ]),
    );
  }
}

class _AnalyzingOverlay extends StatelessWidget {
  const _AnalyzingOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        decoration: const BoxDecoration(gradient: AppColors.heroGradient),
        child: Material(
          color: Colors.transparent,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), shape: BoxShape.circle),
              child: const Icon(PhosphorIconsFill.shieldCheck, color: Colors.white, size: 54),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(begin: const Offset(0.92, 0.92), end: const Offset(1.06, 1.06), duration: 900.ms, curve: Curves.easeInOut),
            const SizedBox(height: 28),
            const Text('Analyse en cours',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 18),
            for (final (i, label) in const ['Lecture du message', 'Recherche des indices', 'Préparation des recommandations'].indexed)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(PhosphorIconsFill.checkCircle, color: AppColors.accent.withValues(alpha: 0.95), size: 18),
                  const SizedBox(width: 8),
                  Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14.5)),
                ]).animate().fadeIn(delay: (300 + i * 600).ms, duration: 400.ms).slideX(begin: -0.1),
              ),
          ]),
        ),
      ),
    );
  }
}
