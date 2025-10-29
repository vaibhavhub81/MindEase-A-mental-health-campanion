import 'dart:convert';
import 'package:http/http.dart' as http;
import 'chatbot_memory.dart';
import 'chatbot_safety.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ChatbotService {
  final String baseUrl = "http://127.0.0.1:11434/api/generate";

  /// Returns a Map with keys: 'text' (String) and 'mood' (String)
  Future<Map<String, String>> getChatResponseWithMood(String userMessage) async {
    if (ChatbotSafety.detectCrisis(userMessage)) {
      return {
        'text': ChatbotSafety.crisisMessage,
        'mood': 'stressed',
      };
    }

    final profile = await ChatbotMemory.getUserProfile();
    final recentChats = await ChatbotMemory.getRecentChats();
    final recentMoods = await ChatbotMemory.getRecentMoods();
    final journals = await ChatbotMemory.getJournals();

    final box = Hive.box('userData');
    final bool firstTime = box.get('firstTime', defaultValue: true);

    // --- LIMIT HISTORY ---
    final int maxRecent = 5;
    final recentChatsTrimmed = recentChats.length > maxRecent
        ? recentChats.sublist(recentChats.length - maxRecent)
        : recentChats;
    final recentMoodsTrimmed = recentMoods.length > maxRecent
        ? recentMoods.sublist(recentMoods.length - maxRecent)
        : recentMoods;
    final recentJournalsTrimmed = journals.length > maxRecent
        ? journals.sublist(journals.length - maxRecent)
        : journals;

    // --- OPTIONAL: USE SUMMARY ---
    String chatSummary = box.get('chatSummary', defaultValue: '');
    if (chatSummary.isEmpty && recentChatsTrimmed.isNotEmpty) {
      chatSummary = recentChatsTrimmed.join(" | ");
      await box.put('chatSummary', chatSummary);
    }

    final context = '''
Summary of previous conversation: 
$chatSummary

Recent chats:
${recentChatsTrimmed.join("\n")}

Recent moods:
${recentMoodsTrimmed.join(", ")}

Recent journal entries:
${recentJournalsTrimmed.join("\n")}
''';

    final prompt = '''
You are MindEase, a ${profile.personality} mental health AI companion.
- Respond thoughtfully and empathetically.
- Keep your response concise (max 3 sentences) unless detail is required.
- Avoid repeating coping suggestions unnecessarily.
- Do not diagnose or prescribe medication.
- Only suggest helplines in crisis situations.
${firstTime ? "- This is the first interaction with the user. Respond briefly and do not introduce yourself." : ""}

Context:
$context

Respond to the following message from the user and also infer their current mood (happy, sad, anxious, stressed, lonely, excited, calm, neutral, frustrated). Return ONLY JSON with keys 'response' and 'mood':
"$userMessage"
''';

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "model": "phi",
          "prompt": prompt,
          "stream": false
        }),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        String text = jsonData['response']?.trim() ?? "";

        if (text.isEmpty) {
          print("[ChatbotService] Empty AI response. Raw body:\n${response.body}");
          text = "⚠️ Sorry, I couldn't process that.";
        }

        // Simple fallback mood detection if AI doesn't return mood
        String mood = "neutral";
        if (jsonData.containsKey('mood')) {
          mood = jsonData['mood'].toString();
        } else {
          mood = _detectMood(userMessage);
        }

        // Save chat
        await ChatbotMemory.saveChat(userMessage, text);

        // Update summary for next prompt (keep it concise)
        chatSummary += " | $userMessage -> $text";
        if (chatSummary.length > 500) chatSummary = chatSummary.substring(chatSummary.length - 500);
        await box.put('chatSummary', chatSummary);

        if (firstTime) {
          await box.put('firstTime', false);
        }

        return {'text': text, 'mood': mood};
      } else {
        print("[ChatbotService] Server error. Status code: ${response.statusCode}, body: ${response.body}");
        return {'text': "Error: Unable to connect to AI server.", 'mood': 'neutral'};
      }
    } catch (e, stack) {
      print("[ChatbotService] Exception:\n$e\nSTACK TRACE:\n$stack");
      return {'text': "⚠️ Error occurred while contacting AI.", 'mood': 'neutral'};
    }
  }

  // Fallback mood detectiona
  String _detectMood(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('happy') || lower.contains('joy') || lower.contains('good')) return "happy";
    if (lower.contains('sad') || lower.contains('unhappy') || lower.contains('depressed')) return "sad";
    if (lower.contains('anxious') || lower.contains('worried') || lower.contains('nervous')) return "anxious";
    if (lower.contains('stressed') || lower.contains('pressure') || lower.contains('overwhelmed')) return "stressed";
    if (lower.contains('lonely') || lower.contains('alone')) return "lonely";
    if (lower.contains('excited') || lower.contains('thrilled') || lower.contains('happy')) return "excited";
    if (lower.contains('calm') || lower.contains('relaxed') || lower.contains('peaceful')) return "calm";
    if (lower.contains('frustrated') || lower.contains('annoyed') || lower.contains('irritated')) return "frustrated";
    return "neutral";
  }
}
