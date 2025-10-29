import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'EmergencyContactsScreen.dart';

class SmsService {
  static const MethodChannel _channel = MethodChannel('com.example.mindease/sms');

  static Future<void> sendSms(String phone, String message) async {
    try {
      await _channel.invokeMethod('sendSms', {
        'phone': phone,
        'message': message,
      });
    } on PlatformException catch (e) {
      print("Failed to send SMS: ${e.message}");
    }
  }
}

class CrisisModeScreen extends StatefulWidget {
  const CrisisModeScreen({Key? key}) : super(key: key);

  @override
  State<CrisisModeScreen> createState() => _CrisisModeScreenState();
}

class _CrisisModeScreenState extends State<CrisisModeScreen>
    with SingleTickerProviderStateMixin {
  bool isSosActive = false;
  Position? _currentPosition;
  StreamSubscription<Position>? _positionStream;
  Timer? _smsTimer;
  late AnimationController _pulseController;

  List<Map<String, dynamic>> emergencyContacts = [];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
      lowerBound: 0.9,
      upperBound: 1.1,
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _pulseController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _pulseController.forward();
      }
    });
    _pulseController.forward();
    _loadEmergencyContacts();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _positionStream?.cancel();
    _smsTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadEmergencyContacts() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('emergency_contacts')
        .get();

    setState(() {
      emergencyContacts = snapshot.docs.map((doc) {
        return {
          'name': doc['name'] ?? '',
          'phone': doc['phone'] ?? '',
        };
      }).toList();
    });
  }

  Future<Position?> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) return null;
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  void _toggleSOS() async {
    setState(() => isSosActive = !isSosActive);

    if (isSosActive) {
      _pulseController.forward();
      _currentPosition = await _getUserLocation();

      // Start continuous location updates
      _positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).listen((Position position) {
        _currentPosition = position;
        _sendSosToFirestore(position);
      });

      if (_currentPosition != null) {
        _sendSosToFirestore(_currentPosition!);
        _sendSmsToContacts(_currentPosition!, emergencyContacts);
      }

      // Periodic SMS every 2 minutes
      _smsTimer = Timer.periodic(const Duration(seconds: 120), (_) {
        if (_currentPosition != null) {
          _sendSmsToContacts(_currentPosition!, emergencyContacts);
        }
      });
    } else {
      _pulseController.stop();
      _positionStream?.cancel();
      _smsTimer?.cancel();
    }
  }

  Future<void> _sendSosToFirestore(Position position) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final sosRef = FirebaseFirestore.instance
        .collection('sos_alerts')
        .doc(uid)
        .collection('history')
        .doc();

    await sosRef.set({
      'latitude': position.latitude,
      'longitude': position.longitude,
      'timestamp': FieldValue.serverTimestamp(),
      'active': isSosActive,
      'contacts': emergencyContacts,
    });

    print("SOS sent: ${position.latitude}, ${position.longitude}");
  }

  Future<void> _sendSmsToContacts(Position position, List<Map<String, dynamic>> contacts) async {
    if (contacts.isEmpty) return;

    String locationUrl =
        "https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}";
    String message = "🚨 SOS Alert! I need help. My current location: $locationUrl";

    for (var contact in contacts) {
      String phone = contact['phone'].toString();
      await SmsService.sendSms(phone, message);
    }
  }

  Color _headingColor() => isSosActive ? Colors.white : const Color(0xFF8ECAE6);
  Color _backgroundColor() => isSosActive ? Colors.red.shade900 : const Color(0xFF1C1C1E);
  Color _appBarColor() => isSosActive ? Colors.red.shade800 : const Color(0xFF2C2C2E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor(),
      appBar: AppBar(
        backgroundColor: _appBarColor(),
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
                color: _headingColor(),
              ),
            ),
            const SizedBox(height: 40),

            Center(
              child: ScaleTransition(
                scale: _pulseController,
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
                          color: Colors.black.withAlpha(102),
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
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => print('Call 24/7 Helpline'),
                icon: const Icon(Icons.phone),
                label: const Text('Call Mental Health Helpline'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EmergencyContactsScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.contacts),
                label: const Text('Manage Emergency Contacts'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
