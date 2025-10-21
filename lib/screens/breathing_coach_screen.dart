import 'dart:async';
import 'package:flutter/material.dart';

class BreathingCoachScreen extends StatefulWidget {
  const BreathingCoachScreen({Key? key}) : super(key: key);

  @override
  _BreathingCoachScreenState createState() => _BreathingCoachScreenState();
}

class _BreathingCoachScreenState extends State<BreathingCoachScreen> {
  bool _isBreathingExerciseActive = false;
  String _currentPhase = '';
  IconData _currentIcon = Icons.air;
  Timer? _timer;

  void _startBreathingCycle() {
    const duration = Duration(seconds: 4);
    int step = 0;

    _setPhase('Inhale', Icons.air); // Start with inhale

    _timer = Timer.periodic(duration, (Timer timer) {
      setState(() {
        step = (step + 1) % 3;
        switch (step) {
          case 0:
            _setPhase('Inhale', Icons.air);
            break;
          case 1:
            _setPhase('Hold', Icons.pause_circle_filled);
            break;
          case 2:
            _setPhase('Exhale', Icons.south); // Use a down arrow or wind icon
            break;
        }
      });
    });
  }

  void _setPhase(String phase, IconData icon) {
    _currentPhase = phase;
    _currentIcon = icon;
  }

  void _toggleBreathingExercise() {
    setState(() {
      _isBreathingExerciseActive = !_isBreathingExerciseActive;
      if (_isBreathingExerciseActive) {
        _startBreathingCycle();
      } else {
        _timer?.cancel();
        _currentPhase = '';
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C2C2E),
        title: const Text(
          'Breathing Coach',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 24,
            color: Color(0xFF8ECAE6),
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Follow the instructions below and breathe deeply to relax.',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // Breathing Circle with Icon
            AnimatedContainer(
              duration: const Duration(seconds: 4),
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2C2C2E),
                border: Border.all(
                  color: const Color(0xFF8ECAE6),
                  width: 5,
                ),
              ),
              child: Center(
                child: Icon(
                  _currentIcon,
                  color: const Color(0xFFFFB703),
                  size: 80,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Breathing Phase Label
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: Text(
                _currentPhase.isNotEmpty ? _currentPhase : 'Ready?',
                key: ValueKey(_currentPhase),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 24,
                  color: Color(0xFFFFB703),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Start/Stop Button
            ElevatedButton(
              onPressed: _toggleBreathingExercise,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8ECAE6),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _isBreathingExerciseActive ? 'Stop Exercise' : 'Start Exercise',
                style: const TextStyle(
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
