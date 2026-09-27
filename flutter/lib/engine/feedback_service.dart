import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

/// Shared audio-and-haptic feedback, used identically by every game.
///
/// In the web prototype these tones were synthesised with the Web Audio API.
/// In the Flutter production target they are short bundled sound assets played
/// through the audio plugin, plus light haptic taps. Sound is treated as an
/// enhancement, never a dependency, so a game still works with sound off.
class FeedbackService {
  FeedbackService();

  final AudioPlayer _player = AudioPlayer(playerId: 'playgarden-sfx');
  bool soundOn = true;

  Future<void> _play(String asset) async {
    if (!soundOn) return;
    try {
      await _player.stop();
      await _player.play(AssetSource(asset));
    } catch (_) {
      // Audio is an enhancement, never a dependency.
    }
  }

  Future<void> good() async {
    HapticFeedback.lightImpact();
    await _play('sfx/good.mp3');
  }

  Future<void> win() async {
    HapticFeedback.mediumImpact();
    await _play('sfx/win.mp3');
  }

  Future<void> oops() async {
    HapticFeedback.selectionClick();
    await _play('sfx/oops.mp3');
  }

  Future<void> tap() async {
    HapticFeedback.selectionClick();
    await _play('sfx/tap.mp3');
  }

  void dispose() => _player.dispose();
}
