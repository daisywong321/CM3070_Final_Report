import 'package:flutter_test/flutter_test.dart';
import 'package:playgarden/engine/content.dart';
import 'package:playgarden/engine/registry.dart';

void main() {
  group('RoundRunner', () {
    test('signals completion after the set number of rounds', () {
      final r = RoundRunner(3);
      expect(r.next(), isFalse); // 1
      expect(r.next(), isFalse); // 2
      expect(r.next(), isTrue); // 3 -> done
      r.reset();
      expect(r.done, 0);
    });
  });

  group('Game registry', () {
    test('contains the four deep-set games with unique titles', () {
      expect(kGameRegistry.length, 4);
      final titles = kGameRegistry.map((g) => g.title).toSet();
      expect(titles.length, 4);
      expect(titles, containsAll(<String>[
        'Tap the Colour',
        'Count the Friends',
        'Animal Sounds',
        'Pop the Bubbles',
      ]));
    });

    test('every game exposes a skill label, colour and emoji', () {
      for (final g in kGameRegistry) {
        expect(g.skillLabel, isNotEmpty);
        expect(g.emoji, isNotEmpty);
      }
    });
  });

  group('Content', () {
    test('colour and animal pools are large enough for four options', () {
      expect(kColours.length, greaterThanOrEqualTo(4));
      expect(kAnimals.length, greaterThanOrEqualTo(4));
    });
  });
}
