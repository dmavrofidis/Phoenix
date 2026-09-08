import 'package:flutter_tts/flutter_tts.dart';

/// Uses only the speech engine already available on the device.
class VoiceCoach {
  VoiceCoach({FlutterTts? engine}) : _engine = engine ?? FlutterTts();

  final FlutterTts _engine;

  Future<void> speak({
    required String text,
    required String languageCode,
  }) async {
    try {
      await _engine.stop();
      await _engine.setLanguage(languageCode == 'el' ? 'el-GR' : 'en-US');
      await _engine.setSpeechRate(.45);
      await _engine.setVolume(1);
      await _engine.setPitch(1);
      await _engine.speak(text);
    } catch (_) {
      // Speech is a convenience. A missing device voice must never interrupt
      // the workout or make the local timer unusable.
    }
  }

  Future<void> stop() async {
    try {
      await _engine.stop();
    } catch (_) {
      // Some web/device engines may disappear when the app is backgrounded.
    }
  }
}
