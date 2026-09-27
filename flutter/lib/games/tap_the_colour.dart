import 'dart:math';
import 'package:flutter/material.dart';
import '../engine/game.dart';
import '../engine/content.dart';
import '../engine/tokens.dart';

/// Game 1: Tap the Colour (Colours). Hear and see a colour, tap the match.
/// A single-tap matching game that exercises the matching-logic path of the
/// engine (report section 3.5).
class TapTheColourGame extends GameDescriptor {
  const TapTheColourGame();
  @override
  String get title => 'Tap the Colour';
  @override
  String get skillLabel => 'Colours';
  @override
  Color get color => Tokens.red;
  @override
  String get emoji => '🎨';
  @override
  Widget build(BuildContext context, EngineApi engine) =>
      _TapTheColour(engine: engine);
}

class _TapTheColour extends StatefulWidget {
  const _TapTheColour({required this.engine});
  final EngineApi engine;
  @override
  State<_TapTheColour> createState() => _TapTheColourState();
}

class _TapTheColourState extends State<_TapTheColour> {
  final _rng = Random();
  final _runner = RoundRunner(5);
  late List<ColourItem> _options;
  late ColourItem _target;

  @override
  void initState() {
    super.initState();
    _newRound();
  }

  void _newRound() {
    final pool = List<ColourItem>.from(kColours)..shuffle(_rng);
    _options = pool.take(4).toList();
    _target = _options[_rng.nextInt(_options.length)];
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.engine.say('Tap ${_target.name}');
    });
  }

  void _choose(ColourItem c) {
    final correct = c.name == _target.name;
    widget.engine.recordRound(correct: correct);
    if (!correct) {
      widget.engine.oops();
      return;
    }
    widget.engine.good();
    if (_runner.next()) {
      widget.engine.reward(3, 'You did it!');
      _runner.reset();
      _newRound();
    } else {
      _newRound();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('Tap  ${_target.name}',
              style: const TextStyle(
                  fontSize: 26, fontWeight: FontWeight.w800, color: Tokens.ink)),
        ),
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            padding: const EdgeInsets.all(16),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              for (final c in _options)
                _ColourTile(item: c, onTap: () => _choose(c)),
            ],
          ),
        ),
      ],
    );
  }
}

class _ColourTile extends StatelessWidget {
  const _ColourTile({required this.item, required this.onTap});
  final ColourItem item;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: item.name,
      button: true,
      child: Material(
        color: item.color,
        borderRadius: BorderRadius.circular(Tokens.radius),
        child: InkWell(
          borderRadius: BorderRadius.circular(Tokens.radius),
          onTap: onTap,
          child: const SizedBox(
              height: Tokens.minTapTarget, width: Tokens.minTapTarget),
        ),
      ),
    );
  }
}
