import 'package:flutter/material.dart';
import '../engine/tokens.dart';
import '../engine/feedback_service.dart';
import '../engine/speech_service.dart';
import '../engine/session_state.dart';

/// The parent area. It carries co-play guidance in line with WHO and AAP
/// screen-time advice, shows a simple non-identifying progress summary drawn
/// from on-device counts, and explains the parent-voice option. No data ever
/// leaves the device.
class ParentScreen extends StatefulWidget {
  const ParentScreen({
    super.key,
    required this.session,
    required this.speech,
    required this.feedback,
  });

  final SessionState session;
  final SpeechService speech;
  final FeedbackService feedback;

  @override
  State<ParentScreen> createState() => _ParentScreenState();
}

class _ParentScreenState extends State<ParentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Tokens.cream,
      appBar: AppBar(
        title: const Text('For grown-ups'),
        backgroundColor: Tokens.teal,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _card(
            colour: Tokens.orange.withValues(alpha: 0.12),
            title: 'How to play together',
            body:
                'Keep sessions short and playful, ideally under an hour a day, '
                'and play alongside your child when you can. Short, interactive, '
                'co-viewed play supports learning far better than long passive '
                'watching.',
          ),
          AnimatedBuilder(
            animation: widget.session,
            builder: (context, _) => _card(
              colour: Tokens.blue.withValues(alpha: 0.10),
              title: 'Progress',
              body:
                  'Stars earned: ${widget.session.stars}\n'
                  'Rounds played: ${widget.session.totalRounds}\n'
                  'Correct: ${widget.session.correctRounds} '
                  '(${widget.session.accuracyPercent}%)\n\n'
                  'These counts are kept on this device only and are never '
                  'uploaded.',
            ),
          ),
          _card(
            colour: Tokens.green.withValues(alpha: 0.12),
            title: 'Record your own voice',
            body:
                'You can replace the built-in voice with your own, so the '
                'prompts your child hears are spoken by a familiar person. '
                'Recordings are saved on this device only.',
            action: FilledButton.icon(
              style: FilledButton.styleFrom(
                  backgroundColor: Tokens.green,
                  minimumSize: const Size.fromHeight(Tokens.minTapTarget)),
              onPressed: _recordVoice,
              icon: const Icon(Icons.mic),
              label: Text(widget.speech.hasParentVoice
                  ? 'Re-record prompts'
                  : 'Record prompts'),
            ),
          ),
          _card(
            colour: Colors.black.withValues(alpha: 0.04),
            title: 'Settings',
            body: '',
            action: Column(
              children: [
                SwitchListTile(
                  title: const Text('Sound'),
                  value: widget.feedback.soundOn,
                  onChanged: (v) => setState(() {
                    widget.feedback.soundOn = v;
                    widget.speech.soundOn = v;
                  }),
                ),
                OutlinedButton(
                  onPressed: () => widget.session.reset(),
                  child: const Text('Reset progress'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _recordVoice() {
    // Playback of parent clips is implemented in SpeechService. Capturing audio
    // with the microphone is not built yet, so this button only explains the
    // feature. Next step: add a recorder package and save each clip with
    // SpeechService.setParentClip.
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Record your voice'),
        content: const Text(
            'Voice recording is coming in a later version. Each prompt will '
            'be saved on this device and will replace the built-in voice.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _card({
    required Color colour,
    required String title,
    required String body,
    Widget? action,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: colour, borderRadius: BorderRadius.circular(Tokens.radius)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: Tokens.ink)),
          if (body.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(body,
                style: const TextStyle(fontSize: 15, color: Tokens.ink)),
          ],
          if (action != null) ...[const SizedBox(height: 12), action],
        ],
      ),
    );
  }
}
