import 'dart:typed_data';

import 'package:share_plus/share_plus.dart';

/// Mobile : ouvre la feuille de partage (WhatsApp, e-mail, Fichiers…).
Future<void> saveFile(Uint8List bytes, String name, String mimeType, {String? subject}) async {
  await SharePlus.instance.share(ShareParams(
    files: [XFile.fromData(bytes, name: name, mimeType: mimeType)],
    fileNameOverrides: [name],
    subject: subject,
  ));
}
