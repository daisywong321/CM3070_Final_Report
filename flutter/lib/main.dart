import 'package:flutter/material.dart';
import 'engine/tokens.dart';
import 'engine/feedback_service.dart';
import 'engine/speech_service.dart';
import 'engine/session_state.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final session = SessionState();
  await session.load();
  runApp(PlayGardenApp(session: session));
}

/// PlayGarden: an educational mobile mini-games application for four-year-old
/// children. Built on one data-driven engine with a shared feedback, speech and
/// reward layer (see the engine/ directory and the report, Chapter 3).
class PlayGardenApp extends StatefulWidget {
  const PlayGardenApp({super.key, required this.session});
  final SessionState session;

  @override
  State<PlayGardenApp> createState() => _PlayGardenAppState();
}

class _PlayGardenAppState extends State<PlayGardenApp> {
  final FeedbackService _feedback = FeedbackService();
  final SpeechService _speech = SpeechService();

  @override
  void dispose() {
    _feedback.dispose();
    _speech.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PlayGarden',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Tokens.cream,
        colorScheme: ColorScheme.fromSeed(seedColor: Tokens.teal),
        fontFamily: 'Roboto',
      ),
      home: HomeScreen(
        feedback: _feedback,
        speech: _speech,
        session: widget.session,
      ),
    );
  }
}
