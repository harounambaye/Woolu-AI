import 'dart:js_interop';

import 'package:image_picker/image_picker.dart';

@JS('wooluOcr')
external JSPromise<JSString> _wooluOcr(JSUint8Array bytes);

Future<String> extractText(XFile file) async {
  final bytes = await file.readAsBytes();
  final text = await _wooluOcr(bytes.toJS).toDart;
  return text.toDart.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).join('\n');
}
