# How to run and check PlayGarden (Flutter)

## Requirements

- Flutter 3.27 or newer (developed and checked on Flutter 3.47.4, Dart 3.13.3)
- For a phone build: Android Studio with the Android SDK and an Android phone or
  emulator, or a Mac with Xcode for iOS
- For a quick browser preview: Chrome

## Steps

From the root of this repository:

```bash
cd flutter
flutter pub get          # fetch dependencies
flutter analyze          # static analysis
flutter test             # run the engine and registry unit tests
flutter run              # run on a connected phone or emulator
```

To produce builds:

```bash
flutter build apk        # Android (needs the Android SDK)
flutter build web        # web, for a quick browser preview
flutter run -d chrome    # or run straight in Chrome
```

## Checks carried out for this submission

On Flutter 3.47.4 (Dart 3.13.3), using a fresh copy cloned from this repository:

- `flutter pub get`: dependencies resolved.
- `flutter analyze`: "No issues found!".
- `flutter test`: all four tests passed (RoundRunner completion, the registry
  holds four unique games each with a skill label and emoji, and the content
  pools are large enough for four options).
- `flutter build web`: "Built build/web".

The `android/` and `ios/` folders are the standard Flutter platform projects.
The Android build has not been produced on this machine because it has no
Android SDK; run `flutter build apk` on a computer with Android Studio.

## Project layout

```
lib/
  engine/    game.dart, feedback_service.dart, speech_service.dart,
             session_state.dart, reward_overlay.dart, content.dart,
             registry.dart, tokens.dart
  games/     tap_the_colour.dart, count_the_friends.dart,
             animal_sounds.dart, pop_the_bubbles.dart
  screens/   home_screen.dart, game_screen.dart, parent_screen.dart
  main.dart
test/        engine_test.dart
assets/sfx/  four short feedback tones (tap, good, oops, win)
android/     Android platform project
ios/         iOS platform project
```

## Privacy

No advertising, no in-app purchases, no third-party analytics and no personal
data collection. Session progress is stored on the device only, using
`SharedPreferences`, and is never uploaded.
