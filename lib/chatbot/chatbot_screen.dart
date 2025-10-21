import 'package:flutter/material.dart';
import 'chatbot_service.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/send_message_bar.dart';
import 'widgets/avatar_widget.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final ChatbotService _service = ChatbotService(useEmulator: false); // set true if using Android emulator
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> messages = [];
  String currentEmotion = 'neutral';

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => messages.add({"sender": "user", "text": text}));
    _controller.clear();

    // Optimistic UI: show thinking indicator as bot message
    setState(() => messages.add({"sender": "bot", "text": "…"}));

    final result = await _service.getChatResponse(text);

    // remove the thinking placeholder
    setState(() {
      messages.removeWhere((m) => m['text'] == '…');
      messages.add({"sender": "bot", "text": result['text'] ?? '...'});
      currentEmotion = result['emotion'] ?? 'neutral';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MindEase'),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/avatar-creation'),
            icon: const Icon(Icons.person),
            tooltip: 'Create Avatar',
          )
        ],
      ),
      body: Column(
        children: [
          // Avatar at top
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: AvatarWidget(emotion: currentEmotion),
          ),

          const Divider(height: 1),

          // Messages
          Expanded(
            child: ListView.builder(
              reverse: false,
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, i) {
                final m = messages[i];
                final isUser = m['sender'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: ChatBubble(
                    text: m['text'] ?? '',
                    isUser: isUser,
                  ),
                );
              },
            ),
          ),

          // Send bar
          SendMessageBar(
            controller: _controller,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }
}
