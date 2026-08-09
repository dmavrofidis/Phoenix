import 'dart:io';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:share_plus/share_plus.dart';

class LocalPickedFile {
  const LocalPickedFile({required this.name, required this.bytes});

  final String name;
  final Uint8List bytes;
}

Future<LocalPickedFile?> pickLocalFile({
  required List<String> extensions,
  int maxBytes = 25 * 1024 * 1024,
}) async {
  try {
    final file = await openFile(
      acceptedTypeGroups: Platform.isIOS
          ? const <XTypeGroup>[]
          : <XTypeGroup>[
              XTypeGroup(
                label: 'Phoenix file',
                extensions: extensions
                    .map((item) => item.toLowerCase())
                    .toList(),
              ),
            ],
    );
    if (file == null || !_hasAllowedExtension(file.name, extensions)) {
      return null;
    }
    final length = await file.length();
    if (length > maxBytes) return null;
    final bytes = await file.readAsBytes();
    if (bytes.length > maxBytes) return null;
    return LocalPickedFile(name: file.name, bytes: bytes);
  } catch (_) {
    return null;
  }
}

Future<bool> saveLocalBytes({
  required Uint8List bytes,
  required String filename,
  required String mimeType,
}) async {
  try {
    if (Platform.isAndroid || Platform.isIOS) {
      final result = await SharePlus.instance.share(
        ShareParams(
          files: <XFile>[
            XFile.fromData(bytes, mimeType: mimeType, name: filename),
          ],
          fileNameOverrides: <String>[filename],
          subject: 'Phoenix export',
        ),
      );
      return result.status == ShareResultStatus.success;
    }

    final extension = filename.contains('.')
        ? filename.split('.').last.toLowerCase()
        : '';
    final location = await getSaveLocation(
      suggestedName: filename,
      acceptedTypeGroups: extension.isEmpty
          ? const <XTypeGroup>[]
          : <XTypeGroup>[
              XTypeGroup(
                label: 'Phoenix export',
                extensions: <String>[extension],
              ),
            ],
    );
    if (location == null) return false;
    await XFile.fromData(
      bytes,
      mimeType: mimeType,
      name: filename,
    ).saveTo(location.path);
    return true;
  } catch (_) {
    return false;
  }
}

bool _hasAllowedExtension(String filename, List<String> extensions) {
  final lowerName = filename.toLowerCase();
  return extensions.any(
    (extension) => lowerName.endsWith('.${extension.toLowerCase()}'),
  );
}
