import 'package:flutter/material.dart';
import 'tokens.dart';

/// Content the games draw from: colours, animals and so on. Kept separate from
/// game logic so content can grow without touching the engine.
class ColourItem {
  const ColourItem(this.name, this.color);
  final String name;
  final Color color;
}

const List<ColourItem> kColours = [
  ColourItem('red', Tokens.red),
  ColourItem('orange', Tokens.orange),
  ColourItem('yellow', Tokens.yellow),
  ColourItem('green', Tokens.green),
  ColourItem('blue', Tokens.blue),
  ColourItem('purple', Tokens.purple),
  ColourItem('pink', Tokens.pink),
  ColourItem('teal', Tokens.teal),
];

class AnimalItem {
  const AnimalItem(this.emoji, this.name);
  final String emoji;
  final String name;
}

const List<AnimalItem> kAnimals = [
  AnimalItem('🐶', 'dog'),
  AnimalItem('🐱', 'cat'),
  AnimalItem('🐮', 'cow'),
  AnimalItem('🐷', 'pig'),
  AnimalItem('🐸', 'frog'),
  AnimalItem('🦆', 'duck'),
  AnimalItem('🐑', 'sheep'),
  AnimalItem('🐴', 'horse'),
];

/// A tiny round counter shared by the games. Play [rounds] rounds, then the
/// game asks the engine to reward the child. Mirrors makeRunner() in the web
/// prototype (report section 3.2).
class RoundRunner {
  RoundRunner(this.rounds);
  final int rounds;
  int done = 0;

  bool next() {
    done += 1;
    return done >= rounds;
  }

  void reset() => done = 0;
}
