import 'package:flutter/foundation.dart';

List<String> _list(dynamic v) => v is List ? v.map((e) => e.toString()).toList() : <String>[];

class Analysis {
  Analysis(this.json);
  final Map<String, dynamic> json;

  String get incidentType => json['incidentType'] ?? 'autre';
  String get incidentLabel => json['incidentLabel'] ?? 'Incident';
  String get riskLevel => json['riskLevel'] ?? 'medium';
  String get summary => json['summary'] ?? '';
  List<String> get indicators => _list(json['indicators']);
  List<String> get recommendedActions => _list(json['recommendedActions']);
  List<String> get limitations => _list(json['limitations']);
  List<String> get missingInfo => _list(json['missingInfo']);
  List<String> get resolutionSteps => _list(json['resolutionSteps']);
  bool get demo => json['demo'] == true;
}

class Dossier {
  Dossier(this.json) : letter = json['letter'] ?? '';
  final Map<String, dynamic> json;
  String letter; // modifiable par l'utilisateur avant export

  DateTime get createdAt => DateTime.tryParse(json['createdAt'] ?? '')?.toLocal() ?? DateTime.now();
  String get incidentLabel => json['incidentLabel'] ?? 'Incident';
  String get riskLevel => json['riskLevel'] ?? 'medium';
  String get summary => json['summary'] ?? '';
  String get date => json['date'] ?? '';
  String get time => json['time'] ?? '';
  String get amount => json['amount'] ?? '';
  String get references => json['references'] ?? '';
  String get chronology => json['chronology'] ?? '';
  String get stepsTaken => json['stepsTaken'] ?? '';
  String get subject => json['subject'] ?? '';
  List<String> get evidenceChecklist => _list(json['evidenceChecklist']);
  bool get demo => json['demo'] == true;
}

class DossierInfo {
  String date = '', time = '', amount = '', references = '', chronology = '', stepsTaken = '';

  Map<String, String> toJson() => {
        'date': date,
        'time': time,
        'amount': amount,
        'references': references,
        'chronology': chronology,
        'stepsTaken': stepsTaken,
      };
}

enum InputSource { text, sms, screenshot }

class HistoryItem {
  HistoryItem({required this.input, required this.source, required this.analysis})
      : id = DateTime.now().microsecondsSinceEpoch.toString(),
        at = DateTime.now();

  final String id;
  final DateTime at;
  final String input;
  final InputSource source;
  final Analysis analysis;
  final Set<int> doneSteps = {};
  final DossierInfo info = DossierInfo();
  Dossier? dossier;
}

/// Historique de la session, en mémoire uniquement : rien n'est écrit sur l'appareil.
class Session extends ChangeNotifier {
  Session._();
  static final instance = Session._();

  final List<HistoryItem> items = [];

  void add(HistoryItem item) {
    items.insert(0, item);
    notifyListeners();
  }

  void touch() => notifyListeners();

  void clear() {
    items.clear();
    notifyListeners();
  }
}
