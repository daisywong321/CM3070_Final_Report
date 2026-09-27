import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Shared speech service. Every prompt is read aloud so a non-reader is never
/// blocked by text (report sections 3.4 and 2.1).
///
/// Two voice sources are supported. By default the built-in device
/// text-to-speech voice speaks each prompt. If a parent has recorded their own
/// voice for a given phrase, that
/// on-device recording is played instead, so the prompts a child hears are
/// spoken by a familiar carer. Recordings live only on the device and are never
/// uploaded, in keeping with the privacy stance in section 2.8.
class SpeechService {
  SpeechService();

  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _voicePlayer = AudioPlayer(playerId: 'playgarden-voice');
  bool soundOn = true;

  /// Maps a spoken phrase to a parent-recorded audio file path on the device.
  final Map<String, String> _parentClips = {};

  bool _configured = false;

  Future<void> _configure() async {
    if (_configured) return;
    try {
      await _tts.setLanguage('en-GB');
      await _tts.setSpeechRate(0.9);
      await _tts.setPitch(1.2);
      _configured = true;
    } catch (_) {
      // Speech is an enhancement; a missing engine must never crash a game.
    }
  }

  /// Registers a parent recording for [phrase]. Called from the parent area.
  void setParentClip(String phrase, String filePath) {
    _parentClips[phrase] = filePath;
  }

  void clearParentClips() => _parentClips.clear();

  bool get hasParentVoice => _parentClips.isNotEmpty;

  Future<void> say(String text) async {
    if (!soundOn) return;
    final clip = _parentClips[text];
    if (clip != null) {
      try {
        await _voicePlayer.stop();
        await _voicePlayer.play(DeviceFileSource(clip));
        return;
      } catch (_) {
        // Fall back to text-to-speech if the recording cannot be played.
      }
    }
    await _configure();
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {}
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
    try {
      await _voicePlayer.stop();
    } catch (_) {}
  }

  void dispose() => _voicePlayer.dispose();
}
