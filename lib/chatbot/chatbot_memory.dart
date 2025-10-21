import 'package:hive_flutter/hive_flutter.dart';

class ChatbotMemory {
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox('chatMemory');
    await Hive.openBox('userData');
  }

  // Chat history
  static Future<void> saveChat(String userMsg, String botMsg) async {
    final box = Hive.box('chatMemory');
    final chats = List<String>.from(box.get('recentChats', defaultValue: <String>[]));
    chats.add('You: $userMsg\nBot: $botMsg');
    if (chats.length > 50) chats.removeAt(0);
    await box.put('recentChats', chats);
  }

  static Future<List<String>> getRecentChats() async {
    final box = Hive.box('chatMemory');
    return List<String>.from(box.get('recentChats', defaultValue: <String>[]));
  }

  // Avatar / profile storage
  static Future<void> saveAvatar(Map<String, dynamic> avatar) async {
    final box = Hive.box('userData');
    final avatars = Map<String, dynamic>.from(box.get('avatars', defaultValue: <String, dynamic>{}));
    avatars[avatar['name'] ?? 'default'] = avatar;
    await box.put('avatars', avatars);
    await box.put('activeAvatar', avatar['name'] ?? 'default');
  }

  static Future<Map<String, dynamic>?> getAvatar(String name) async {
    final box = Hive.box('userData');
    final avatars = Map<String, dynamic>.from(box.get('avatars', defaultValue: <String, dynamic>{}));
    if (avatars.containsKey(name)) return Map<String, dynamic>.from(avatars[name]);
    return null;
  }

  static Future<Map<String, dynamic>?> getActiveAvatar() async {
    final box = Hive.box('userData');
    final active = box.get('activeAvatar', defaultValue: null);
    if (active == null) return null;
    return getAvatar(active);
  }
}
