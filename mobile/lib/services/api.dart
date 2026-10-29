import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models.dart';

/// Adresse du serveur, surchargeable avec --dart-define=API_URL=http://IP_DU_PC:3001
/// Web : même origine si l'app est servie par le serveur (port 3001), sinon port 3001 du même hôte.
/// Émulateur Android : 10.0.2.2 désigne le PC hôte.
const _envUrl = String.fromEnvironment('API_URL');

String get apiBaseUrl {
  if (_envUrl.isNotEmpty) return _envUrl;
  if (kIsWeb) return Uri.base.port == 3001 ? '' : '${Uri.base.scheme}://${Uri.base.host}:3001';
  return defaultTargetPlatform == TargetPlatform.android ? 'http://10.0.2.2:3001' : 'http://localhost:3001';
}

class ApiException implements Exception {
  ApiException(this.message);
  final String message;
  @override
  String toString() => message;
}

class Api {
  static Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body) async {
    final http.Response res;
    try {
      res = await http
          .post(
            Uri.parse('$apiBaseUrl/api/$path'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 45));
    } on TimeoutException {
      throw ApiException("Le serveur met trop de temps à répondre. Réessayez.");
    } catch (_) {
      throw ApiException("Impossible de joindre le serveur Woolu. Vérifiez votre connexion.");
    }
    Map<String, dynamic> data = {};
    try {
      data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    } catch (_) {}
    if (res.statusCode >= 400) throw ApiException(data['error']?.toString() ?? 'Erreur ${res.statusCode}');
    return data;
  }

  static Future<Analysis> analyze(String text, String? incidentType) async =>
      Analysis(await _post('analyze', {'text': text, 'incidentType': incidentType ?? ''}));

  static Future<Dossier> dossier(Analysis analysis, DossierInfo info) async =>
      Dossier(await _post('dossier', {'analysis': analysis.json, 'info': info.toJson()}));
}
