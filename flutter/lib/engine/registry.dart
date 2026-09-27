import 'game.dart';
import '../games/tap_the_colour.dart';
import '../games/count_the_friends.dart';
import '../games/animal_sounds.dart';
import '../games/pop_the_bubbles.dart';

/// The Game Registry: a plain list of descriptors that drives the picture-first
/// home grid. Adding a game means adding one entry here (report section 3.2).
///
/// The four deep-set games from the report (Tap the Colour, Count the Friends,
/// Animal Sounds and Pop the Bubbles) are implemented in full because together
/// they exercise every engine subsystem: matching logic, numeric logic, audio
/// mapping and timed scoring (report section 3.5).
const List<GameDescriptor> kGameRegistry = [
  TapTheColourGame(),
  CountTheFriendsGame(),
  AnimalSoundsGame(),
  PopTheBubblesGame(),
];
