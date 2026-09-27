import 'dart:math';
import 'package:flutter/material.dart';
import '../engine/game.dart';
import '../engine/content.dart';
import '../engine/tokens.dart';

/// Game 2: Count the Friends (Counting and number). Count the objects on the
/// stage, then tap the matching numeral. Exercises the numeric-logic path of
/// the engine (report section 3.5).
class CountTheFriendsGame extends GameDescriptor {
  const CountTheFriendsGame();
  @override
  String get title => 'Count the Friends';
  @override
  String get skillLabel => 'Counting';
  @override
  Color get color => Tokens.blue;
  @override
  String get emoji => '🔢';
  @override
  Widget build(BuildContext context, EngineApi engine) =>
      _CountTheFriends(engine: engine);
}

class _CountTheFriends extends StatefulWidget {
  const _CountTheFriends({required this.engine});
  final EngineApi engine;
  @override
  State<_CountTheFriends> createState() => _CountTheFriendsState();
}

class _CountTheFriendsState extends State<_CountTheFriends> {
  final _rng = Random();
  final _runner = RoundRunner(5);
  late int _count;
  late String _friend;
  late List<int> _choices;

  @override
  void initState() {
    super.initState();
    _newRound();
  }

  void _newRound() {
    _count = 1 + _rng.nextInt(5); // 1..5
    _friend = kAnimals[_rng.nextInt(kAnimals.length)].emoji;
    final set = <int>{_count};
    while (set.length < 3) {
      set.add(1 + _rng.nextInt(5));
    }
    _choices = set.toList()..shuffle(_rng);
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.engine.say('How many?');
    });
  }

  void _choose(int n) {
    final correct = n == _count;
    widget.engine.recordRound(correct: correct);
    if (!correct) {
      widget.engine.oops();
      return;
    }
    widget.engine.good();
    if (_runner.next()) {
      widget.engine.reward(3, 'Great counting!');
      _runner.reset();
    }
    _newRound();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(20),
          child: Text('How many?',
              style: TextStyle(
                  fontSize: 26, fontWeight: FontWeight.w800, color: Tokens.ink)),
        ),
        Expanded(
          child: Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < _count; i++)
                  Text(_friend, style: const TextStyle(fontSize: 56)),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final n in _choices)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _NumberTile(value: n, onTap: () => _choose(n)),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NumberTile extends StatelessWidget {
  const _NumberTile({required this.value, required this.onTap});
  final int value;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$value',
      button: true,
      child: Material(
        color: Tokens.blue,
        borderRadius: BorderRadius.circular(Tokens.radius),
        child: InkWell(
          borderRadius: BorderRadius.circular(Tokens.radius),
          onTap: onTap,
          child: SizedBox(
            height: Tokens.minTapTarget,
            width: Tokens.minTapTarget,
            child: Center(
              child: Text('$value',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.w800)),
            ),
          ),
        ),
      ),
    );
  }
}
