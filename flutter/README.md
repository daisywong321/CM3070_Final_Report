# PlayGarden (Flutter)

An educational mobile mini-games application for four-year-old children, built
in Flutter. This is the production-target implementation of the architecture
described in the project report (Chapter 3).

## What this demonstrates

The most important technical feature is a **data-driven game engine with a
uniform feedback, speech and reward layer**. Every game is a small descriptor
(`GameDescriptor`) that supplies a title, a home-grid card and a `build` method;
each game reaches the shared services through a single `EngineApi` contract.
Adding a game means writing one descriptor, not a new screen stack.

- `lib/engine/game.dart`: the `GameDescriptor` and `EngineApi` abstractions.
- `lib/engine/feedback_service.dart`: shared audio tones and haptics.
- `lib/engine/speech_service.dart`: text-to-speech, plus playback of
  parent-recorded clips (the recording step is not built yet).
- `lib/engine/session_state.dart`: on-device star and progress counts
  (no personal data, nothing uploaded).
- `lib/engine/reward_overlay.dart`: the shared celebration (stars + confetti).
- `lib/engine/registry.dart`: the list that drives the picture-first home grid.
- `lib/games/`: the four deep-set games, Tap the Colour, Count the Friends,
  Animal Sounds and Pop the Bubbles. Together they exercise every engine
  subsystem: matching logic, numeric logic, audio mapping and timed scoring.

## Run

```bash
flutter pub get
flutter run                 # on a connected device or emulator
flutter test                # runs the engine and registry tests
flutter analyze             # static analysis
flutter build apk           # Android build (needs the Android SDK)
flutter build web           # web build (for quick review)
```

## Design tokens

Bright saturated primaries, large rounded shapes and a minimum tap target of
88 logical pixels (`lib/engine/tokens.dart`), reflecting the coarse motor
control of four-year-olds (report section 3.4).

## Privacy

No advertising, no in-app purchases, no third-party analytics SDKs, and no
personal-data collection. Session state is stored on the device only.
