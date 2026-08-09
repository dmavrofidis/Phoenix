import 'dart:typed_data';

class LocalPickedFile {
  const LocalPickedFile({required this.name, required this.bytes});

  final String name;
  final Uint8List bytes;
}

Future<LocalPickedFile?> pickLocalFile({
  required List<String> extensions,
}) async => null;

Future<bool> saveLocalBytes({
  required Uint8List bytes,
  required String filename,
  required String mimeType,
}) async => false;
