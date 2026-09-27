import 'dart:math';
import 'package:flutter/material.dart';
import '../engine/game.dart';
import '../engine/content.dart';
import '../engine/tokens.dart';

/// Game 4: Animal Sounds (Animals and vocabulary). The engine names an animal
/// aloud; the child taps the matching animal. Exercises the audio-mapping path
/// of the engine (report section 3.5).
class AnimalSoundsGame extends GameDescriptor {
  const AnimalSoundsGame();
  @override
  String get title => 'Animal Sounds';
  @override
  String get skillLabel => 'Animals';
  @override
  Color get color => Tokens.green;
  @override
  String get emoji => '🐮';
  @override
  Widget build(BuildContext context, EngineApi engine) =>
      _AnimalSounds(engine: engine);
}

class _AnimalSounds extends StatefulWidget {
  const _AnimalSounds({required this.engine});
  final EngineApi engine;
  @override
  State<_AnimalSounds> createState() => _AnimalSoundsState();
}

class _AnimalSoundsState extends State<_AnimalSounds> {
  final _rng = Random();
  final _runner = RoundRunner(5);
  late List<AnimalItem> _options;
  late AnimalItem _target;

  @override
  void initState() {
    super.initState();
    _newRound();
  }

  void _newRound() {
    final pool = List<AnimalItem>.from(kAnimals)..shuffle(_rng);
    _options = pool.take(4).toList();
    _target = _options[_rng.nextInt(_options.length)];
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.engine.say('Find the ${_target.name}');
    });
  }

  void _choose(AnimalItem a) {
    final correct = a.name == _target.name;
    widget.engine.recordRound(correct: correct);
    if (!correct) {
      widget.engine.oops();
      return;
    }
    widget.engine.good();
    if (_runner.next()) {
      widget.engine.reward(3, 'Wonderful!');
      _runner.reset();
    }
    _newRound();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text('Find the ${_target.name}',
                  style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Tokens.ink)),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => widget.engine.say('Find the ${_target.name}'),
                icon: const Icon(Icons.volume_up, size: 28),
                label: const Text('Say again',
                    style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            padding: const EdgeInsets.all(16),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              for (final a in _options)
                _AnimalTile(item: a, onTap: () => _choose(a)),
            ],
          ),
        ),
      ],
    );
  }
}

class _AnimalTile extends StatelessWidget {
  const _AnimalTile({required this.item, required this.onTap});
  final AnimalItem item;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: item.name,
      button: true,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Tokens.radius),
        elevation: 2,
        child: InkWell(
          borderRadius: BorderRadius.circular(Tokens.radius),
          onTap: onTap,
          child: Center(
            child: Text(item.emoji, style: const TextStyle(fontSize: 64)),
          ),
        ),
      ),
    );
  }
}
