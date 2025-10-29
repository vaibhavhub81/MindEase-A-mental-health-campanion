import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatbotMemory {
  static bool _initialized = false;

  // Ensure Hive is initialized only once
  static Future<void> init() async {
    if (_initialized) return;

    await Hive.initFlutter();

    await Future.wait([
      Hive.openBox('chatMemory'),
      Hive.openBox('userData'),
    ]);

    _initialized = true;
  }

  static Future<Box> _safeBox(String name) async {
    if (!_initialized || !Hive.isBoxOpen(name)) {
      await init();
    }
    return Hive.box(name);
  }

  // --------------------------
  // 🔹 Save Chat (local + cloud)
  // --------------------------
  static Future<void> saveChat(String userMsg, String botMsg,
      {String mood = "neutral"}) async {
    final box = await _safeBox('chatMemory');

    // Local Hive storage (unchanged)
    final chats =
    List<String>.from(box.get('recentChats', defaultValue: <String>[]));
    chats.add('You: $userMsg\nBot: $botMsg');
    if (chats.length > 20) chats.removeAt(0);
    await box.put('recentChats', chats);

    // 🔹 Firestore sync for analytics
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final analyticsRef = FirebaseFirestore.instance
          .collection('chat_analytics') // ✅ new collection
          .doc(uid)
          .collection('entries')
          .doc();

      await analyticsRef.set({
        'user_message': userMsg,
        'bot_reply': botMsg,
        'detected_mood': mood,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  static Future<List<String>> getRecentChats() async {
    final box = await _safeBox('chatMemory');
    return List<String>.from(box.get('recentChats', defaultValue: <String>[]));
  }

  // --------------------------
  // 🔹 Save Mood (local + cloud)
  // --------------------------
  static Future<void> saveMood(String mood) async {
    final box = await _safeBox('userData');

    // Local Hive storage (unchanged)
    final moods =
    List<String>.from(box.get('moods', defaultValue: <String>[]));
    moods.add(mood);
    if (moods.length > 30) moods.removeAt(0);
    await box.put('moods', moods);

    // 🔹 Firestore sync for trend analysis
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final moodTrendsRef = FirebaseFirestore.instance
          .collection('mood_trends') // ✅ new collection
          .doc(uid)
          .collection('entries')
          .doc();

      await moodTrendsRef.set({
        'mood': mood,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  static Future<List<String>> getRecentMoods() async {
    final box = await _safeBox('userData');
    return List<String>.from(box.get('moods', defaultValue: <String>[]));
  }

  static Future<void> saveJournal(String entry) async {
    final box = await _safeBox('userData');
    final journals =
    List<String>.from(box.get('journals', defaultValue: <String>[]));
    journals.add(entry);
    if (journals.length > 50) journals.removeAt(0);
    await box.put('journals', journals);
  }

  static Future<List<String>> getJournals() async {
    final box = await _safeBox('userData');
    return List<String>.from(box.get('journals', defaultValue: <String>[]));
  }

  static Future<UserProfile> getUserProfile() async {
    final box = await _safeBox('userData');
    return UserProfile(
      name: box.get('name', defaultValue: 'User'),
      age: box.get('age', defaultValue: 21),
      personality:
      box.get('personality', defaultValue: 'supportive and empathetic'),
    );
  }

  static Future<void> saveUserProfile(UserProfile profile) async {
    final box = await _safeBox('userData');
    await box.put('name', profile.name);
    await box.put('age', profile.age);
    await box.put('personality', profile.personality);
  }
}

class UserProfile {
  final String name;
  final int age;
  final String personality;

  UserProfile({
    required this.name,
    required this.age,
    required this.personality,
  });
}
