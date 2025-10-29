import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

class MoodForecastScreen extends StatefulWidget {
  const MoodForecastScreen({Key? key}) : super(key: key);

  @override
  State<MoodForecastScreen> createState() => _MoodForecastScreenState();
}

class _MoodForecastScreenState extends State<MoodForecastScreen> {
  bool isLoading = true;
  bool isPositiveMood = true;
  String forecastText = "Fetching your mood forecast...";
  String dominantMood = "Unknown";
  double moodScore = 0.0;
  List<Map<String, dynamic>> moodTrend = [];

  @override
  void initState() {
    super.initState();
    _generateMoodForecast();
  }

  Future<void> _generateMoodForecast() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('chat_analytics')
          .doc(uid)
          .collection('entries')
          .orderBy('timestamp', descending: true)
          .limit(15)
          .get();

      if (querySnapshot.docs.isEmpty) {
        setState(() {
          forecastText =
          "No mood data found yet. Start chatting with MindEase to receive your first forecast!";
          isLoading = false;
        });
        return;
      }

      int positive = 0, negative = 0, neutral = 0;
      final List<Map<String, dynamic>> moodEntries = [];

      for (var doc in querySnapshot.docs.reversed) {
        final mood = (doc['detected_mood'] ?? '').toString().toLowerCase();
        int score = 0;

        if (mood.contains('happy') ||
            mood.contains('calm') ||
            mood.contains('positive') ||
            mood.contains('relaxed')) {
          positive++;
          score = 3;
        } else if (mood.contains('sad') ||
            mood.contains('angry') ||
            mood.contains('anxious') ||
            mood.contains('depressed')) {
          negative++;
          score = 1;
        } else {
          neutral++;
          score = 2;
        }

        moodEntries.add({
          'mood': mood,
          'score': score,
          'time': (doc['timestamp'] as Timestamp?)?.toDate() ??
              DateTime.now().subtract(Duration(minutes: moodEntries.length * 5)),
        });
      }

      // Determine mood stats
      moodTrend = moodEntries;
      double avgScore = moodEntries.map((e) => e['score']).reduce((a, b) => a + b) / moodEntries.length;

      String resultText;
      bool isPositive;
      String mainMood;

      if (positive >= negative && positive >= neutral) {
        resultText =
        "You’re in a great mental space. Maintain this positivity with gratitude or short mindful breaks.";
        isPositive = true;
        mainMood = "Positive";
      } else if (negative > positive && negative >= neutral) {
        resultText =
        "You seem emotionally drained lately. Take a walk, meditate, or talk to someone you trust.";
        isPositive = false;
        mainMood = "Negative";
      } else {
        resultText =
        "You have a balanced emotional trend. Stay mindful and maintain your self-awareness.";
        isPositive = true;
        mainMood = "Neutral";
      }

      setState(() {
        forecastText = resultText;
        isPositiveMood = isPositive;
        dominantMood = mainMood;
        moodScore = avgScore;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        forecastText = "Error fetching mood data. Please try again later.";
        isLoading = false;
      });
    }
  }

  String _motivationalQuote() {
    final positiveQuotes = [
      "Every day may not be good, but there’s something good in every day.",
      "Your mind is a powerful thing. Keep it positive.",
      "Breathe. You are capable, you are strong, and you are enough."
    ];
    final negativeQuotes = [
      "It’s okay to not be okay sometimes.",
      "Storms make trees take deeper roots.",
      "Healing takes time. Be gentle with yourself."
    ];
    final random = Random();
    return isPositiveMood
        ? positiveQuotes[random.nextInt(positiveQuotes.length)]
        : negativeQuotes[random.nextInt(negativeQuotes.length)];
  }

  Future<void> _addReflection() async {
    final TextEditingController _controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          "Reflect on Your Day",
          style: TextStyle(color: Color(0xFF8ECAE6), fontFamily: 'Poppins'),
        ),
        content: TextField(
          controller: _controller,
          style: const TextStyle(color: Colors.white),
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: "Write your thoughts here...",
            hintStyle: TextStyle(color: Colors.grey),
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              // You can store this reflection later in Firestore if needed
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text("Reflection saved!", style: TextStyle(fontFamily: 'Poppins'))),
              );
            },
            child: const Text("Save", style: TextStyle(color: Color(0xFF8ECAE6))),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodChart() {
    return moodTrend.isEmpty
        ? const Center(child: Text("No mood data", style: TextStyle(color: Colors.white70)))
        : LineChart(
      LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: moodTrend
                .asMap()
                .entries
                .map((e) => FlSpot(e.key.toDouble(), e.value['score'].toDouble()))
                .toList(),
            isCurved: true,
            color: isPositiveMood ? Colors.greenAccent : Colors.redAccent,
            barWidth: 3,
            dotData: FlDotData(show: true),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C2C2E),
        title: const Text(
          'Mood Forecast',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 24,
            color: Color(0xFF8ECAE6),
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF8ECAE6)))
          : RefreshIndicator(
        onRefresh: _generateMoodForecast,
        color: const Color(0xFF8ECAE6),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Emotional Overview:',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8ECAE6),
                ),
              ),
              const SizedBox(height: 15),

              // Mood trend chart
              Container(
                height: 220,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2E),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: _buildMoodChart(),
              ),
              const SizedBox(height: 20),

              // Summary info card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2E),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      "Dominant Mood: $dominantMood",
                      style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Emotional Score: ${moodScore.toStringAsFixed(2)} / 3.0",
                      style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          color: Colors.white70),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Forecast text
              Text(
                forecastText,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  color:
                  isPositiveMood ? Colors.greenAccent : Colors.redAccent,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),

              // Motivational quote
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _motivationalQuote(),
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      color: Colors.white70,
                      fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 30),

              // Reflect button
              ElevatedButton.icon(
                onPressed: _addReflection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8ECAE6),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.edit_note_rounded, color: Colors.white),
                label: const Text(
                  'Reflect & Improve',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
