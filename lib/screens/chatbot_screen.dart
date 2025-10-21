// Firebase integration + dataset matching + UI updates for ChatbotPage
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({Key? key}) : super(key: key);

  @override
  _ChatbotPageState createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  Map<String, dynamic> intents = {};
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _loadIntents();
  }

  Future<void> _loadIntents() async {
    try {
      final String data = await rootBundle.loadString('assets/intents.json');
      final Map<String, dynamic> parsed = json.decode(data);

      if (parsed['intents'] == null || parsed['intents'].isEmpty) {
        print('❌ intents.json loaded but "intents" is empty or missing.');
      } else {
        print('✅ intents.json loaded with ${parsed['intents'].length} intents.');
      }

      setState(() {
        intents = parsed;
      });
    } catch (e) {
      print('❌ Failed to load intents.json: $e');
    }
  }


  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'text': text, 'sender': 'user'});
    });

    _controller.clear();
    _scrollToBottom();

    // Save to Firestore
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance
          .collection('chat_history')
          .doc(uid)
          .collection('messages')
          .add({
        'sender': 'user',
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    Future.delayed(const Duration(milliseconds: 600), () async {
      final botReply = _getResponse(text);

      setState(() {
        _messages.add({'text': botReply, 'sender': 'bot'});
      });

      if (uid != null) {
        await FirebaseFirestore.instance
            .collection('chat_history')
            .doc(uid)
            .collection('messages')
            .add({
          'sender': 'bot',
          'text': botReply,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      _scrollToBottom();
    });
  }

  String _getResponse(String input) {
    input = input.toLowerCase();
    final inputWords = input.split(RegExp(r'\s+'));
    int bestScore = 0;
    Map<String, dynamic>? bestMatch;

    for (var intent in intents['intents']) {
      int score = 0;

      // Boost score if user input has words in the tag itself
      final tag = intent['tag'].toString().toLowerCase();
      for (var word in inputWords) {
        if (tag.contains(word)) score += 2;
      }

      // Match with pattern tokens
      for (var pattern in intent['patterns']) {
        final patternLower = pattern.toLowerCase();
        final patternWords = patternLower.split(RegExp(r'\s+'));

        for (var word in inputWords) {
          if (patternWords.contains(word)) {
            score += 1;
          }
          if (patternLower.contains(word)) {
            score += 2;
          }
        }
      }

      if (score > bestScore) {
        bestScore = score;
        bestMatch = intent;
      }
    }

    // Use best matched intent if found and above threshold
    if (bestMatch != null && bestScore > 0) {
      final responses = List<String>.from(bestMatch['responses']);
      return responses[_random.nextInt(responses.length)];
    }

    // Fallback
    final fallback = intents['intents'].firstWhere(
          (i) => i['tag'] == 'no-response',
      orElse: () => null,
    );

    if (fallback != null) {
      final responses = List<String>.from(fallback['responses']);
      return responses[_random.nextInt(responses.length)];
    }

    return "Hmm, I’m not sure how to respond to that.";
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(
        title: const Text('Chat with MindEase'),
        backgroundColor: const Color(0xFF2C2C2E),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['sender'] == 'user';
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      decoration: BoxDecoration(
                        color: isUser ? const Color(0xFF8ECAE6) : const Color(0xFF2C2C2E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        message['text']!,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          color: isUser ? Colors.white : Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _controller,
                    maxLines: 5,
                    minLines: 1,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                      filled: true,
                      fillColor: const Color(0xFF3A3A3A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF8ECAE6)),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
