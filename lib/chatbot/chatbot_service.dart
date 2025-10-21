import 'dart:convert';
import 'package:http/http.dart' as http;
import 'chatbot_memory.dart';
import 'chatbot_safety.dart';
import 'dart:io';

class ChatbotService {
  final bool useEmulator;
  ChatbotService({this.useEmulator = false});

  String get baseUrl {
    final host = useEmulator ? '10.0.2.2' : '127.0.0.1';
    return "http://192.168.1.7:5000/generate";
  }

  Future<Map<String, String>> getChatResponse(String userMessage) async {
    print("🧠 Sending message to AI: $userMessage");

    if (ChatbotSafety.detectCrisis(userMessage)) {
      print("⚠️ Crisis detected in user message.");
      return {'text': ChatbotSafety.crisisMessage, 'emotion': 'concerned'};
    }

    try {
      final recentChats = await ChatbotMemory.getRecentChats();
      final context = recentChats.join("\n");

      final prompt = '''
You are MindEase, an empathetic mental health companion.
Context:
$context

User says:
$userMessage
Respond concisely and include an emotion tag in the response metadata (emotion: neutral/positive/concerned/encouraging).
''';

      print("📡 Sending request to $baseUrl ...");
      final response = await http
          .post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"model": "phi", "prompt": prompt}),
      )
          .timeout(const Duration(seconds: 60));

      print("✅ Response received with status: ${response.statusCode}");

      if (response.statusCode == 200) {
        try {
          final map = jsonDecode(response.body);
          String text = '';
          String emotion = 'neutral';

          if (map is Map && map.containsKey('response')) {
            text = (map['response'] ?? '').toString().trim();
          } else if (map is Map && map.containsKey('text')) {
            text = (map['text'] ?? '').toString().trim();
            emotion = (map['emotion'] ?? 'neutral').toString();
          } else {
            text = response.body.toString();
          }

          if (text.isEmpty) text = "⚠️ Sorry, I couldn't process that.";
          await ChatbotMemory.saveChat(userMessage, text);

          print("💬 AI Response: $text");
          print("😌 Emotion Detected: $emotion");

          return {'text': text, 'emotion': emotion};
        } catch (e) {
          print("❌ JSON parsing failed: $e");
          final raw = response.body.trim();
          await ChatbotMemory.saveChat(userMessage, raw);
          return {'text': raw, 'emotion': 'neutral'};
        }
      } else {
        print("🚨 Server returned error code: ${response.statusCode}");
        return {
          'text': 'Error: AI server returned ${response.statusCode}',
          'emotion': 'neutral'
        };
      }
    } catch (e, stack) {
      print("🔥 Exception during chat request: $e");
      print("📄 Stacktrace: $stack");
      return {'text': '⚠️ Error communicating with AI: $e', 'emotion': 'neutral'};
    }
  }
}
