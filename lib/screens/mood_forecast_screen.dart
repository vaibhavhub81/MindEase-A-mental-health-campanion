import 'package:flutter/material.dart';

class MoodForecastScreen extends StatelessWidget {
  const MoodForecastScreen({Key? key}) : super(key: key);

  // Sample mood data (replace with dynamic analysis in future)
  final String moodResult =
      'Based on your activity and past mood logs, it seems that you may experience calm and positivity today. Keep up the good work!';
  final bool isPositiveMood = true; // change to false to simulate negative mood

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E), // Rich Dark Gray
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C2C2E), // Dark Gray Surface
        title: const Text(
          'Mood Forecast',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 24,
            color: Color(0xFF8ECAE6), // Soft Sky Blue
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Forecast heading
            Text(
              'Your mood prediction for today:',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF8ECAE6),
              ),
            ),
            const SizedBox(height: 20),

            // Placeholder for mood chart
            Container(
              height: 250,
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2E),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  'Mood Chart Placeholder',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Mood Insight based on activity
            Text(
              moodResult,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                color: isPositiveMood ? Colors.greenAccent : Colors.redAccent,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // Button to refresh mood
            ElevatedButton(
              onPressed: () {
                // TODO: Implement refresh logic
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8ECAE6),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Get Latest Mood Forecast',
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
    );
  }
}
