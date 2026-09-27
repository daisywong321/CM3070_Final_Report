import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// On-device session and progress state.
///
/// Holds the star count and a simple tally of correct and total rounds, so the
/// parent area can show progress across sessions rather than resetting on every
/// launch. Everything is stored on
/// the device with [SharedPreferences] and nothing is ever sent off it, which
/// satisfies privacy by design (report section 2.8). No name, no identifier and
/// no behavioural profile is kept: only anonymous counts.
class SessionState extends ChangeNotifier {
  SessionState();

  static const _kStars = 'pg_stars';
  static const _kCorrect = 'pg_correct';
  static const _kTotal = 'pg_total';

  int stars = 0;
  int correctRounds = 0;
  int totalRounds = 0;

  SharedPreferences? _prefs;

  Future<void> load() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      stars = _prefs?.getInt(_kStars) ?? 0;
      correctRounds = _prefs?.getInt(_kCorrect) ?? 0;
      totalRounds = _prefs?.getInt(_kTotal) ?? 0;
      notifyListeners();
    } catch (_) {
      // If storage is unavailable the app still runs; stars just reset.
    }
  }

  void addStars(int n) {
    stars += n;
    _prefs?.setInt(_kStars, stars);
    notifyListeners();
  }

  void recordRound({required bool correct}) {
    totalRounds += 1;
    if (correct) correctRounds += 1;
    _prefs?.setInt(_kTotal, totalRounds);
    _prefs?.setInt(_kCorrect, correctRounds);
    notifyListeners();
  }

  /// Percentage of correct rounds, for the parent progress summary.
  int get accuracyPercent =>
      totalRounds == 0 ? 0 : ((correctRounds / totalRounds) * 100).round();

  Future<void> reset() async {
    stars = 0;
    correctRounds = 0;
    totalRounds = 0;
    await _prefs?.remove(_kStars);
    await _prefs?.remove(_kCorrect);
    await _prefs?.remove(_kTotal);
    notifyListeners();
  }
}
