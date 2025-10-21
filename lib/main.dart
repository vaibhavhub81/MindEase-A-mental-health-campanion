import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mindease/chatbot/chatbot_screen.dart';
import 'package:mindease/chatbot/chatbot_memory.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/journal_screen.dart';  // Make sure this is imported
import 'screens/breathing_coach_screen.dart';  // Make sure this is imported
import 'screens/mood_forecast_screen.dart';  // Make sure this is imported
import 'screens/crisis_mode_screen.dart';  // Make sure this is imported
import 'screens/thoughts_room_screen.dart';
import 'screens/start_journal_screen.dart';
import 'screens/previous_entries_screen.dart';
import 'screens/journal_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Initialize Hive
  await Hive.initFlutter();
  await ChatbotMemory.init();
  // Open required boxes before runApp
  await Hive.openBox('userProfile');
  await Hive.openBox('chatHistory'); // or any others you use

  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mindease',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true), // dark theme
      initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/onboarding': (context) => const OnboardingScreen(),
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/home': (context) => const HomeScreen(),
          '/journal': (context) => const JournalScreen(),
          '/breathing': (context) => const BreathingCoachScreen(),
          '/thoughts': (context) => ThoughtRoomScreen(),
          '/mood-forecast': (context) => const MoodForecastScreen(),
          '/crisis-mode': (context) => const CrisisModeScreen(),
          '/chatbot': (context) => const ChatbotScreen(),
          '/start-journal': (context) => const StartJournalScreen(),
          '/previous-entries': (context) => const PreviousEntriesScreen(),

        },

    );
  }
}
