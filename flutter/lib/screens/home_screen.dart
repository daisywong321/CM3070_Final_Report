import 'package:flutter/material.dart';
import '../engine/tokens.dart';
import '../engine/registry.dart';
import '../engine/game.dart';
import '../engine/feedback_service.dart';
import '../engine/speech_service.dart';
import '../engine/session_state.dart';
import 'game_screen.dart';
import 'parent_screen.dart';

/// The picture-first home grid. Each game is identified by a colour, an emoji
/// picture and a short label, supporting recognition over recall for a
/// pre-literate child (report section 3.4). The parent area is reached through a
/// small gated control in the top corner, not by the child's main path.
class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.feedback,
    required this.speech,
    required this.session,
  });

  final FeedbackService feedback;
  final SpeechService speech;
  final SessionState session;

  void _open(BuildContext context, GameDescriptor d) {
    feedback.tap();
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => GameScreen(
        descriptor: d,
        feedback: feedback,
        speech: speech,
        session: session,
      ),
    ));
  }

  Future<void> _openParent(BuildContext context) async {
    // A simple gate so a four-year-old does not wander in by accident.
    final ok = await _parentGate(context);
    if (ok && context.mounted) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ParentScreen(
          session: session,
          speech: speech,
          feedback: feedback,
        ),
      ));
    }
  }

  Future<bool> _parentGate(BuildContext context) async {
    // Ask a question a young child cannot answer, as recommended for
    // child-facing gates. Kept deliberately simple.
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('For grown-ups'),
            content: const Text('What is three plus four?'),
            actions: [
              for (final n in [5, 7, 9])
                TextButton(
                  onPressed: () => Navigator.pop(context, n == 7),
                  child: Text('$n', style: const TextStyle(fontSize: 20)),
                ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Tokens.cream,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                        color: Tokens.teal,
                        borderRadius: BorderRadius.circular(16)),
                    child: const Icon(Icons.favorite,
                        color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('PlayGarden',
                            style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: Tokens.ink)),
                        Text('Play & learn · ages 3–5',
                            style: TextStyle(
                                fontSize: 15, color: Tokens.inkSoft)),
                      ],
                    ),
                  ),
                  AnimatedBuilder(
                    animation: session,
                    builder: (context, _) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20)),
                      child: Row(children: [
                        const Text('⭐', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 6),
                        Text('${session.stars}',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w700)),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: Text('Pick a game!',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Tokens.ink)),
            ),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                padding: const EdgeInsets.all(16),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  for (final d in kGameRegistry)
                    _GameCard(descriptor: d, onTap: () => _open(context, d)),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 12, 8),
                child: TextButton.icon(
                  onPressed: () => _openParent(context),
                  icon: const Icon(Icons.lock_outline, size: 20),
                  label: const Text('For grown-ups'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({required this.descriptor, required this.onTap});
  final GameDescriptor descriptor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: descriptor.title,
      button: true,
      child: Material(
        color: descriptor.color,
        borderRadius: BorderRadius.circular(Tokens.radius),
        elevation: 3,
        child: InkWell(
          borderRadius: BorderRadius.circular(Tokens.radius),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(14)),
                  child: Text(descriptor.skillLabel,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600)),
                ),
                const Spacer(),
                Text(descriptor.emoji, style: const TextStyle(fontSize: 56)),
                const Spacer(),
                Text(descriptor.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
