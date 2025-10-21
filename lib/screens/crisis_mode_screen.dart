import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class CrisisModeScreen extends StatefulWidget {
  const CrisisModeScreen({Key? key}) : super(key: key);

  @override
  State<CrisisModeScreen> createState() => _CrisisModeScreenState();
}

class _CrisisModeScreenState extends State<CrisisModeScreen> {
  bool isSosActive = false;

  // Get user's location
  Future<Position> _getUserLocation() async {
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  // Toggle SOS button action
  void _toggleSOS() async {
    setState(() {
      isSosActive = !isSosActive;
    });

    if (isSosActive) {
      // Activate SOS, get location and send alert
      Position position = await _getUserLocation();
      print("SOS ACTIVATED at ${position.latitude}, ${position.longitude}");
    } else {
      // Deactivate SOS
      print("SOS STOPPED");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Set the theme colors based on SOS state
    final backgroundColor = isSosActive ? Colors.red.shade900 : const Color(0xFF1C1C1E);
    final appBarColor = isSosActive ? Colors.red.shade800 : const Color(0xFF2C2C2E);
    final headingColor = isSosActive ? Colors.white : const Color(0xFF8ECAE6);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        title: Text(
          isSosActive ? '🚨 SOS ACTIVE' : 'Crisis Mode',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              isSosActive
                  ? 'Emergency Alert is ACTIVE.\nHelp is on the way!'
                  : 'In times of crisis, we are here to help.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: headingColor,
              ),
            ),
            const SizedBox(height: 40),

            // Circular SOS Button
            Center(
              child: GestureDetector(
                onTap: _toggleSOS,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: isSosActive ? Colors.red.shade700 : Colors.red,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      isSosActive ? 'STOP\nSOS' : 'SEND\nSOS',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            if (!isSosActive) ...[
              Text(
                'Feeling overwhelmed? Try a short breathing exercise.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/breathing');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8ECAE6),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Start Breathing Exercise',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
