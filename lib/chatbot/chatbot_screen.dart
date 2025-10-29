import 'package:flutter/material.dart';
import 'chatbot_service.dart';
import 'chatbot_safety.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final ChatbotService _service = ChatbotService();
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> messages = [];
  bool _isTyping = false;
  String _currentMood = "neutral";
  bool _isLoadingChats = true;

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  // 🔹 Load chat history from Firestore
  Future<void> _loadChatHistory() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('chat_history')
          .doc(uid)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .get();

      final loadedMessages = snapshot.docs.map((doc) {
        return {
          "sender": doc['sender'] ?? '',
          "text": doc['text'] ?? '',
        };
      }).toList();

      setState(() {
        messages.addAll(
          loadedMessages.map((m) => {
            "sender": m["sender"].toString(),
            "text": m["text"].toString(),
          }),
        );
        _isLoadingChats = false;
      });

    } catch (e) {
      setState(() => _isLoadingChats = false);
    }
  }

  // 🔹 Send message + Save chat
  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add({"sender": "user", "text": text});
      _controller.clear();
      _isTyping = true;
    });

    try {
      // Get AI response and mood
      final result = await _service.getChatResponseWithMood(text);
      final reply = result['text']!;
      final mood = result['mood'] ?? "neutral";

      setState(() {
        messages.add({"sender": "bot", "text": reply});
        _isTyping = false;
        _currentMood = mood;
      });

      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final batch = FirebaseFirestore.instance.batch();

        final userMsgRef = FirebaseFirestore.instance
            .collection('chat_history')
            .doc(uid)
            .collection('messages')
            .doc();
        batch.set(userMsgRef, {
          'sender': 'user',
          'text': text,
          'timestamp': FieldValue.serverTimestamp(),
        });

        final botMsgRef = FirebaseFirestore.instance
            .collection('chat_history')
            .doc(uid)
            .collection('messages')
            .doc();
        batch.set(botMsgRef, {
          'sender': 'bot',
          'text': reply,
          'timestamp': FieldValue.serverTimestamp(),
        });

        await batch.commit();
      }

      // Crisis popup if needed
      if (ChatbotSafety.detectCrisis(text)) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("⚠️ Crisis Detected"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(ChatbotSafety.crisisMessage),
                const SizedBox(height: 16),
                ...ChatbotSafety.helplines.map((h) => ElevatedButton.icon(
                  icon: const Icon(Icons.phone),
                  label: Text(
                      "${h.country}: ${h.number.replaceAll('tel:', '')}"),
                  onPressed: () => ChatbotSafety.callHelpline(h.number),
                )),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() {
        messages.add({"sender": "bot", "text": "⚠️ Error Occurred: $e"});
        _isTyping = false;
        _currentMood = "neutral";
      });
    }
  }

  // 🔹 Clear chat (local + Firestore)
  Future<void> _clearChatHistory() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("🧹 Clear Chat?"),
        content: const Text(
            "Are you sure you want to delete your entire chat history?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style:
            ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final collectionRef = FirebaseFirestore.instance
          .collection('chat_history')
          .doc(uid)
          .collection('messages');

      final snapshot = await collectionRef.get();
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }

      setState(() {
        messages.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Chat history cleared successfully.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error clearing chat: $e")),
      );
    }
  }

  Color _moodColor(String mood) {
    switch (mood) {
      case "happy":
        return Colors.green;
      case "sad":
        return Colors.blue;
      case "anxious":
        return Colors.orange;
      case "stressed":
        return Colors.red;
      case "lonely":
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("MindEase Chatbot"),
        backgroundColor: Colors.grey[900],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            decoration: BoxDecoration(
              color: _moodColor(_currentMood),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                "Mood: $_currentMood",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),

      // 🔹 Add a Drawer for actions
      drawer: Drawer(
        backgroundColor: Colors.grey[900],
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.grey),
              child: Center(
                child: Text(
                  'MindEase Menu',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.redAccent),
              title: const Text('Clear Chat', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context); // close drawer
                _clearChatHistory();
              },
            ),
            // You can add more menu items here later
          ],
        ),
      ),

      // 🔹 Chat Area
      body: _isLoadingChats
          ? const Center(
        child: CircularProgressIndicator(color: Colors.yellow),
      )
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isTyping && index == messages.length) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[850],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: SizedBox(
                        height: 50,
                        width: 50,
                        child: Lottie.asset(
                          'assets/animations/thinking.json',
                          repeat: true,
                        ),
                      ),
                    ),
                  );
                }

                final msg = messages[index];
                final isUser = msg["sender"] == "user";
                return Align(
                  alignment:
                  isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.yellow[700] : Colors.grey[850],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      msg["text"]!,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),

          // Input box
          Container(
            color: Colors.grey[900],
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "Type your thoughts...",
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.yellow),
                  onPressed: _isTyping ? null : _sendMessage,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

}
