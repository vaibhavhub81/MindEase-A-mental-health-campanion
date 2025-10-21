import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.light(
          primary: Colors.lightBlue.shade600,
          secondary: Colors.amber.shade600,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          background: Colors.white,
          surface: Colors.blueGrey.shade50,
        ),
        textTheme: TextTheme(
          titleLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(fontSize: 16),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.blueGrey.shade50,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          hintStyle: TextStyle(color: Colors.blueGrey.shade500),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightBlue.shade600,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          ),
        ),
      ),
      home: ThoughtRoomScreen(),
    );
  }
}

class ThoughtRoomScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Thought Room')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Welcome to Thought room', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => CreateRoomScreen()));
              },
              child: Text('Create Room'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => JoinRoomScreen()));
              },
              child: Text('Join Room'),
            ),
          ],
        ),
      ),
    );
  }
}

class CreateRoomScreen extends StatefulWidget {
  @override
  _CreateRoomScreenState createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  late String _roomCode;

  @override
  void initState() {
    super.initState();
    _roomCode = _generateRoomCode();
  }

  String _generateRoomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    Random random = Random();
    return String.fromCharCodes(
      Iterable.generate(5, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Room')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Your Room Code: $_roomCode', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _roomCode));
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Room code copied!')));
              },
              child: Text('Copy Code'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => RoomChatScreen(roomCode: _roomCode),
                ));
              },
              child: Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}

class JoinRoomScreen extends StatelessWidget {
  final TextEditingController _roomCodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Join Room')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Enter Room Code', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 20),
            TextField(
              controller: _roomCodeController,
              decoration: InputDecoration(hintText: 'Enter 5-letter code'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String roomCode = _roomCodeController.text.toUpperCase();
                if (roomCode.length == 5) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => RoomChatScreen(roomCode: roomCode)),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid room code')));
                }
              },
              child: Text('Join Room'),
            ),
          ],
        ),
      ),
    );
  }
}

class RoomChatScreen extends StatefulWidget {
  final String roomCode;
  const RoomChatScreen({required this.roomCode});

  @override
  _RoomChatScreenState createState() => _RoomChatScreenState();
}

class _RoomChatScreenState extends State<RoomChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(widget.roomCode)
          .collection('messages')
          .add({
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesRef = FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(widget.roomCode)
        .collection('messages')
        .orderBy('timestamp', descending: false);

    return Scaffold(
      appBar: AppBar(title: Text('Room Code: ${widget.roomCode}')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: messagesRef.snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                  final messages = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index]['text'] ?? '';
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 6),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(message, style: TextStyle(fontSize: 16)),
                      );
                    },
                  );
                },
              ),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(hintText: 'Type your thought...'),
                  ),
                ),
                IconButton(
                  onPressed: _sendMessage,
                  icon: Icon(Icons.send, color: Colors.lightBlue),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
