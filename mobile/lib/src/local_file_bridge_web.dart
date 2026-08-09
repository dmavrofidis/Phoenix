// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:html';
import 'dart:typed_data';

class LocalPickedFile {
  const LocalPickedFile({required this.name, required this.bytes});

  final String name;
  final Uint8List bytes;
}

Future<LocalPickedFile?> pickLocalFile({
  required List<String> extensions,
  int maxBytes = 25 * 1024 * 1024,
}) async {
  final input = FileUploadInputElement()
    ..accept = extensions.map((item) => '.$item').join(',')
    ..multiple = false;
  input.click();
  final change = await input.onChange.first;
  if (change.type != 'change' || input.files == null || input.files!.isEmpty) {
    return null;
  }
  final file = input.files!.first;
  if (file.size > maxBytes || !_hasAllowedExtension(file.name, extensions)) {
    return null;
  }
  final reader = FileReader()..readAsArrayBuffer(file);
  await reader.onLoad.first;
  final result = reader.result;
  final bytes = switch (result) {
    ByteBuffer value => value.asUint8List(),
    Uint8List value => value,
    _ => null,
  };
  if (bytes == null) return null;
  return LocalPickedFile(name: file.name, bytes: bytes);
}

bool _hasAllowedExtension(String filename, List<String> extensions) {
  final lowerName = filename.toLowerCase();
  return extensions.any(
    (extension) => lowerName.endsWith('.${extension.toLowerCase()}'),
  );
}

Future<bool> saveLocalBytes({
  required Uint8List bytes,
  required String filename,
  required String mimeType,
}) async {
  final blob = Blob([bytes], mimeType);
  final url = Url.createObjectUrlFromBlob(blob);
  final anchor = AnchorElement(href: url)
    ..download = filename
    ..style.display = 'none';
  document.body?.children.add(anchor);
  anchor.click();
  anchor.remove();
  Url.revokeObjectUrl(url);
  return true;
}
