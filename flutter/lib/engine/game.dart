import 'package:flutter/material.dart';

/// The Game abstraction: the heart of the data-driven engine.
///
/// This mirrors the web prototype's descriptor object exactly. Rather than
/// coding each game as its own screen stack, every game is a small descriptor
/// that exposes a [title], the metadata needed to draw its home-grid card, and
/// a [build] method that returns the game's widget. The widget is handed an
/// [EngineApi] so it can call back into the shared feedback, speech and reward
/// helpers. Adding a new game means writing one descriptor, not a new screen.
abstract class GameDescriptor {
  const GameDescriptor();

  /// Short spoken/label title, for example "Tap the Colour".
  String get title;

  /// One-word skill label shown on the card, for example "Colours".
  String get skillLabel;

  /// Card colour on the picture-first home grid.
  Color get color;

  /// Emoji used as the picture on the card and in-game.
  String get emoji;

  /// Builds the playable game widget, wired to the shared engine helpers.
  Widget build(BuildContext context, EngineApi engine);
}

/// The contract a game uses to reach the shared services. The engine passes a
/// concrete implementation into every game, so the uniform feedback, speech and
/// reward layer is applied identically across all content (report section 3.2).
abstract class EngineApi {
  /// Speaks [text] aloud, using the parent-recorded voice when one is set,
  /// otherwise the built-in text-to-speech voice.
  Future<void> say(String text);

  /// Plays the short "good", "win" or "oops" tone.
  void good();
  void win();
  void oops();
  void tap();

  /// Awards [earned] stars, speaks praise, and shows the celebration overlay
  /// with confetti. This is the single success path shared by every game.
  void reward(int earned, [String? message]);

  /// Records the result of one round for the parent progress view. No personal
  /// data is stored: only counts, and only on the device.
  void recordRound({required bool correct});

  /// Returns to the home grid.
  void goHome();
}
