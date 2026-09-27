import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../engine/game.dart';
import '../engine/tokens.dart';

/// Game 9: Pop the Bubbles (Fine motor and tap). Bubbles drift up; the child
/// pops them with single taps for points. Exercises the timed-scoring path of
/// the engine (report section 3.5).
class PopTheBubblesGame extends GameDescriptor {
  const PopTheBubblesGame();
  @override
  String get title => 'Pop the Bubbles';
  @override
  String get skillLabel => 'Tapping';
  @override
  Color get color => Tokens.teal;
  @override
  String get emoji => '🫧';
  @override
  Widget build(BuildContext context, EngineApi engine) =>
      _PopTheBubbles(engine: engine);
}

class _Bubble {
  _Bubble(this.id, this.x, this.color, this.size);
  final int id;
  double x;
  double y = 1.1; // starts below the visible area, 0..1 of height
  final Color color;
  final double size;
}

class _PopTheBubbles extends StatefulWidget {
  const _PopTheBubbles({required this.engine});
  final EngineApi engine;
  @override
  State<_PopTheBubbles> createState() => _PopTheBubblesState();
}

class _PopTheBubblesState extends State<_PopTheBubbles> {
  final _rng = Random();
  final List<_Bubble> _bubbles = [];
  Timer? _spawn;
  Timer? _tick;
  int _popped = 0;
  int _nextId = 0;
  static const _target = 8;

  @override
  void initState() {
    super.initState();
    widget.engine.say('Pop the bubbles!');
    _spawn = Timer.periodic(const Duration(milliseconds: 900), (_) => _add());
    _tick = Timer.periodic(const Duration(milliseconds: 40), (_) => _move());
  }

  void _add() {
    if (!mounted) return;
    setState(() {
      _bubbles.add(_Bubble(
        _nextId++,
        0.08 + _rng.nextDouble() * 0.84,
        Tokens.confettiColors[_rng.nextInt(Tokens.confettiColors.length)],
        60 + _rng.nextDouble() * 30,
      ));
    });
  }

  void _move() {
    if (!mounted) return;
    setState(() {
      for (final b in _bubbles) {
        b.y -= 0.012;
      }
      _bubbles.removeWhere((b) => b.y < -0.2);
    });
  }

  void _pop(_Bubble b) {
    widget.engine.good();
    widget.engine.recordRound(correct: true);
    setState(() => _bubbles.remove(b));
    _popped += 1;
    if (_popped >= _target) {
      _popped = 0;
      widget.engine.reward(4, 'Amazing!');
    }
  }

  @override
  void dispose() {
    _spawn?.cancel();
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final w = constraints.maxWidth;
      final h = constraints.maxHeight;
      return Stack(
        children: [
          const Positioned(
            top: 16,
            left: 0,
            right: 0,
            child: Center(
              child: Text('Pop the bubbles!',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Tokens.ink)),
            ),
          ),
          for (final b in _bubbles)
            Positioned(
              left: b.x * w - b.size / 2,
              top: b.y * h - b.size / 2,
              child: Semantics(
                label: 'bubble',
                button: true,
                child: GestureDetector(
                  onTap: () => _pop(b),
                  child: Container(
                    width: b.size,
                    height: b.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: b.color.withValues(alpha: 0.75),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.8),
                          width: 3),
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }
}
