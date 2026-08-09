import 'dart:async';

import 'package:flutter/services.dart';

Future<void> setSecureClipboard(
  String text, {
  Duration timeout = const Duration(minutes: 2),
}) async {
  await Clipboard.setData(ClipboardData(text: text));
  Timer(timeout, () async {
    final current = await Clipboard.getData(Clipboard.kTextPlain);
    if (current?.text == text) {
      await Clipboard.setData(const ClipboardData(text: ''));
    }
  });
}
