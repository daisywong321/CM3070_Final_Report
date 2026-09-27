import 'package:flutter/material.dart';
import '../engine/game.dart';
import '../engine/tokens.dart';
import '../engine/feedback_service.dart';
import '../engine/speech_service.dart';
import '../engine/session_state.dart';
import '../engine/reward_overlay.dart';

/// Hosts a single game and provides the concrete [EngineApi]. This is where the
/// shared services meet the game, so the uniform feedback and reward layer is
/// applied identically no matter which game is playing (report section 3.2).
class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    required this.descriptor,
    required this.feedback,
    required this.speech,
    required this.session,
  });

  final GameDescriptor descriptor;
  final FeedbackService feedback;
  final SpeechService speech;
  final SessionState session;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> implements EngineApi {
  bool _showReward = false;
  int _rewardStars = 0;
  String _rewardMessage = 'Great job!';
  Key _gameKey = UniqueKey();

  @override
  Future<void> say(String text) => widget.speech.say(text);

  @override
  void good() => widget.feedback.good();
  @override
  void win() => widget.feedback.win();
  @override
  void oops() => widget.feedback.oops();
  @override
  void tap() => widget.feedback.tap();

  @override
  void recordRound({required bool correct}) =>
      widget.session.recordRound(correct: correct);

  @override
  void reward(int earned, [String? message]) {
    widget.session.addStars(earned);
    widget.feedback.win();
    say(message ?? 'Great job!');
    setState(() {
      _rewardStars = earned;
      _rewardMessage = message ?? 'Great job!';
      _showReward = true;
    });
  }

  @override
  void goHome() {
    widget.speech.stop();
    Navigator.of(context).pop();
  }

  void _playAgain() {
    setState(() {
      _showReward = false;
      _gameKey = UniqueKey(); // rebuilds the game fresh
    });
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.descriptor;
    return Scaffold(
      backgroundColor: Tokens.cream,
      appBar: AppBar(
        backgroundColor: d.color,
        foregroundColor: Colors.white,
        leading: IconButton(
          iconSize: 32,
          icon: const Icon(Icons.chevron_left),
          onPressed: goHome,
        ),
        title: Text(d.title,
            style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: Stack(
        children: [
          KeyedSubtree(key: _gameKey, child: d.build(context, this)),
          if (_showReward)
            RewardOverlay(
              stars: _rewardStars,
              message: _rewardMessage,
              onPlayAgain: _playAgain,
              onHome: goHome,
            ),
        ],
      ),
    );
  }
}
