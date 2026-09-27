# PlayGarden

An educational mobile mini-games application for four-year-old children, built in Flutter.

PlayGarden is a small catalogue of short, picture-first, audio-supported learning games. A child can open the app, recognise every game by its picture alone, play without reading a single word, and receive immediate feedback (sound, speech, stars and confetti) for every correct action. The app carries no advertising, no in-app purchases and no third-party tracking; the only data it keeps is a small progress count held on the device and never uploaded.

This repository accompanies my CM3070 Final Project, which follows the **CM3050 Mobile Development** template (Project Idea 1).

## What is in this repository

| Folder | Contents |
|--------|----------|
| `flutter/` | The production Flutter application (Dart). This is the main deliverable. |
| `web_prototype/` | An early browser prototype (HTML/CSS/JS) used during design. |

## The core technical idea

The most important feature is a **data-driven game engine with a uniform feedback, speech and reward layer**. Every game is a small descriptor (`GameDescriptor`) that supplies a title, a home-grid card and a `build` method, and reaches the shared services through a single `EngineApi` contract. Adding a game means writing one descriptor, not a new screen. The prototype implements four games (Tap the Colour, Count the Friends, Animal Sounds and Pop the Bubbles) that between them exercise every engine subsystem: matching logic, numeric logic, audio-to-picture mapping and real-time timed scoring.

## Running the app

```bash
cd flutter
flutter pub get
flutter run          # on a connected device or emulator
flutter test         # runs the engine and registry tests
flutter analyze      # static analysis
flutter build apk    # Android build
flutter build web    # web build, for quick review
```

Verified on Flutter 3.47.4 (Dart 3.13.3): `flutter analyze` reports no issues, all unit tests pass, and `flutter build web` succeeds. `flutter run` and `flutter build apk` need the Android SDK (Android Studio) or, for iOS, a Mac with Xcode. See `flutter/HOW_TO_RUN.md` for details.

## Known limitations

- Four of the ten designed games are built in Flutter. All ten exist in the early web prototype.
- The parent-voice feature can play back recordings, but the recording step itself is not built yet.
- The app has been tested through the web build; it has not yet been installed on a range of physical phones.

## Privacy

No advertising, no in-app purchases, no third-party analytics SDKs, and no personal-data collection. Session state (a star count and round tallies) is stored on the device only.

## Licence

Released under the MIT Licence. See `LICENSE`.
