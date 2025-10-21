import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StartJournalScreen extends StatefulWidget {
  const StartJournalScreen({Key? key}) : super(key: key);

  @override
  State<StartJournalScreen> createState() => _StartJournalScreenState();
}

class _StartJournalScreenState extends State<StartJournalScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  String? _aiInsights;

  Future<void> _saveEntryAndAnalyze() async {
    final content = _controller.text.trim();
    if (content.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      // Save journal entry to Firestore
      await FirebaseFirestore.instance
          .collection('journal_entries')
          .doc(uid)
          .collection('entries')
          .add({
        'content': content,
        'created_at': FieldValue.serverTimestamp(),
      });

      // Analyze the content using OpenAI
      final insights = await _getAIInsights(content);

      setState(() {
        _aiInsights = insights;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Journal saved and analyzed!')),
      );
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save or analyze.')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<String> _getAIInsights(String content) async {
    const apiKey = 'KkL9cPI1bxjLSq30QecWONyhHkyXEbSxaw5Ecser';  // Replace with your actual Cohere API key
    const url = 'https://api.cohere.ai/v1/generate';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "model": "command", // Cohere's free model
          "prompt": "You are MindEase AI, a supportive mental health companion. Analyze the following journal entry and give empathetic feedback, insights, and possible coping exercises :\n\n$content",
          "max_tokens": 100,
          "temperature": 0.7,
          "stop_sequences": ["--"],  // Stops generating output after certain character
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['generations'][0]['text']?.trim() ?? 'No insights generated.';
      } else {
        print('Cohere API error: ${response.body}');
        return 'Failed to analyze journal entry.';
      }
    } catch (e) {
      print('Error calling Cohere API: $e');
      return 'Error during analysis.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C2C2E),
        title: const Text(
          'New Entry',
          style: TextStyle(color: Color(0xFF8ECAE6)),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(  // Add SingleChildScrollView here
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLines: 10,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Write your thoughts here...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: const Color(0xFF2C2C2E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _saveEntryAndAnalyze,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8ECAE6),
              ),
              child: const Text(
                'Save & Analyze',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            if (_aiInsights != null)
              Text(
                'AI Insights:\n$_aiInsights',
                style: const TextStyle(color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }
}
