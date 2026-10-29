import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

Future<String> extractText(XFile file) async {
  final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
  try {
    final result = await recognizer.processImage(InputImage.fromFilePath(file.path));
    return result.blocks.map((b) => b.text.trim()).where((t) => t.isNotEmpty).join('\n');
  } finally {
    await recognizer.close();
  }
}
