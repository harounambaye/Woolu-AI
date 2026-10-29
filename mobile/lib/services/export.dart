import 'dart:convert';
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models.dart';
import '../widgets/risk.dart';
import 'file_saver.dart';

const _disclaimer =
    "Dossier préparé avec Woolu AI à partir des informations déclarées par l'utilisateur. "
    "L'analyse ne constitue ni une preuve de fraude ni un avis juridique.";

List<(String, String)> _sections(Dossier d) => [
      ("Type d'incident", d.incidentLabel),
      ('Niveau de risque estimé', riskOf(d.riskLevel).label),
      ('Date et heure déclarées', [d.date, d.time].where((s) => s.isNotEmpty).join(' à ').ifEmpty('Non précisées')),
      ('Montant indiqué', d.amount.isEmpty ? 'Non précisé' : '${d.amount} FCFA'),
      ('Références visibles', d.references.ifEmpty('Non précisées')),
      ("Résumé de l'analyse", d.summary),
      ('Chronologie des faits', d.chronology.ifEmpty('Non précisée')),
      ('Démarches déjà effectuées', d.stepsTaken.ifEmpty('Aucune')),
    ];

extension on String {
  String ifEmpty(String fallback) => trim().isEmpty ? fallback : this;
}

String _fileName(Dossier d, String ext) {
  final c = d.createdAt;
  String two(int n) => n.toString().padLeft(2, '0');
  return 'dossier-woolu-${c.year}${two(c.month)}${two(c.day)}-${two(c.hour)}${two(c.minute)}.$ext';
}

String dossierToText(Dossier d) {
  final b = StringBuffer()
    ..writeln('DOSSIER DE RÉCLAMATION — WOOLU AI')
    ..writeln('Créé le ${d.createdAt.day.toString().padLeft(2, '0')}/${d.createdAt.month.toString().padLeft(2, '0')}/${d.createdAt.year}')
    ..writeln();
  for (final (t, v) in _sections(d)) {
    b
      ..writeln(t.toUpperCase())
      ..writeln(v)
      ..writeln();
  }
  b.writeln('JUSTIFICATIFS À JOINDRE');
  for (final e in d.evidenceChecklist) {
    b.writeln('- $e');
  }
  b
    ..writeln()
    ..writeln('BROUILLON DE LETTRE')
    ..writeln('Objet : ${d.subject}')
    ..writeln()
    ..writeln(d.letter)
    ..writeln()
    ..writeln('---')
    ..writeln(_disclaimer);
  return b.toString();
}

Future<void> shareTxt(Dossier d) async {
  final bytes = Uint8List.fromList(utf8.encode(dossierToText(d)));
  await saveFile(bytes, _fileName(d, 'txt'), 'text/plain;charset=utf-8', subject: d.subject);
}

Future<void> sharePdf(Dossier d) async {
  await saveFile(await buildPdf(d), _fileName(d, 'pdf'), 'application/pdf', subject: d.subject);
}

Future<pw.ThemeData> _pdfTheme() async {
  try {
    return pw.ThemeData.withFont(
      base: await PdfGoogleFonts.plusJakartaSansRegular(),
      bold: await PdfGoogleFonts.plusJakartaSansBold(),
    );
  } catch (_) {
    // Hors connexion : police standard du PDF.
    return pw.ThemeData.base();
  }
}

Future<Uint8List> buildPdf(Dossier d) async {
  final theme = await _pdfTheme();
  const green = PdfColor.fromInt(0xFF0B7A63);
  const grey = PdfColor.fromInt(0xFF64748B);
  final risk = riskOf(d.riskLevel);
  final riskColor = PdfColor.fromInt(risk.color.toARGB32());

  final doc = pw.Document(theme: theme, title: d.subject, author: 'Woolu AI');
  doc.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.all(40),
    header: (ctx) => pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 10),
      decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: green, width: 2))),
      child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Text('WOOLU AI', style: pw.TextStyle(color: green, fontWeight: pw.FontWeight.bold, fontSize: 14, letterSpacing: 2)),
        pw.Text('Comprendre. Sécuriser. Résoudre.', style: const pw.TextStyle(color: grey, fontSize: 9)),
      ]),
    ),
    footer: (ctx) => pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
      pw.Expanded(child: pw.Text(_disclaimer, style: const pw.TextStyle(color: grey, fontSize: 7))),
      pw.SizedBox(width: 20),
      pw.Text('${ctx.pageNumber}/${ctx.pagesCount}', style: const pw.TextStyle(color: grey, fontSize: 8)),
    ]),
    build: (ctx) => [
      pw.SizedBox(height: 16),
      pw.Text('Dossier de réclamation', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 6),
      pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: pw.BoxDecoration(color: riskColor, borderRadius: pw.BorderRadius.circular(10)),
        child: pw.Text(risk.label, style: pw.TextStyle(color: PdfColors.white, fontSize: 9, fontWeight: pw.FontWeight.bold)),
      ),
      pw.SizedBox(height: 18),
      pw.Table(
        border: pw.TableBorder.symmetric(inside: const pw.BorderSide(color: PdfColor.fromInt(0xFFE6EAEE))),
        columnWidths: {0: const pw.FixedColumnWidth(150), 1: const pw.FlexColumnWidth()},
        children: [
          for (final (t, v) in _sections(d))
            pw.TableRow(children: [
              pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 7), child: pw.Text(t, style: pw.TextStyle(color: grey, fontSize: 10, fontWeight: pw.FontWeight.bold))),
              pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 7), child: pw.Text(v, style: const pw.TextStyle(fontSize: 10))),
            ]),
        ],
      ),
      pw.SizedBox(height: 18),
      pw.Text('Justificatifs à joindre', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: green)),
      pw.SizedBox(height: 6),
      ...d.evidenceChecklist.map((e) => pw.Bullet(text: e, style: const pw.TextStyle(fontSize: 10))),
      pw.NewPage(),
      pw.Text('Brouillon de lettre de réclamation', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: green)),
      pw.SizedBox(height: 10),
      pw.Text('Objet : ${d.subject}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
      pw.SizedBox(height: 12),
      ...d.letter.split('\n').map((l) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 2),
            child: pw.Text(l.isEmpty ? ' ' : l, style: const pw.TextStyle(fontSize: 11, lineSpacing: 2)),
          )),
    ],
  ));
  return doc.save();
}
