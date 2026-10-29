import 'package:image_picker/image_picker.dart';

import 'ocr_mlkit.dart' if (dart.library.js_interop) 'ocr_web.dart' as engine;

/// Lecture du texte d'une capture, directement sur l'appareil : l'image n'est jamais envoyée au serveur.
/// Mobile : ML Kit. Web : Tesseract.js, chargé à la demande par web/index.html.
class Ocr {
  static final _picker = ImagePicker();

  static Future<XFile?> pick(ImageSource source) =>
      _picker.pickImage(source: source, imageQuality: 90, maxWidth: 2000);

  static Future<String> extract(XFile file) => engine.extractText(file);
}
