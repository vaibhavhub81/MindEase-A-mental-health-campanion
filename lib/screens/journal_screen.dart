import 'package:flutter/material.dart';

class JournalScreen extends StatelessWidget {
  const JournalScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),  // Rich Dark Gray
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C2C2E), // Dark Gray Surface
        title: const Text(
          'Journaling',
          style: TextStyle(
            fontFamily: 'Poppins', // Rounded typography
            fontSize: 24,
            color: Color(0xFF8ECAE6), // Soft Sky Blue
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Instructions or information
            Text(
              'Record your thoughts, reflect, and gain insights!',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // Voice recording button
            _buildActionButton(
              context,
              'Start Journal',
              '/start-journal',

              const Color(0xFF8ECAE6), // Soft Sky Blue
            ),
            const SizedBox(height: 20),

            // Previous entries button
            _buildActionButton(
              context,
              'View Previous Entries',
              '/previous-entries',
              const Color(0xFFFFB703), // Warm Yellow Accent Color
            ),
          ],
        ),
      ),
    );
  }

  // Reusable button for the journal actions
  Widget _buildActionButton(BuildContext context, String label, String route, Color color) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color, // Replaced 'primary' with 'backgroundColor'
        minimumSize: const Size(double.infinity, 50), // Full width button
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: () {
        Navigator.pushNamed(context, route);
      },
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 18,
          color: Colors.white,
        ),
      ),
    );
  }
}
