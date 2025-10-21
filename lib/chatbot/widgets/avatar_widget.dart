import 'package:flutter/material.dart';

class AvatarWidget extends StatelessWidget {
  final String emotion;
  const AvatarWidget({super.key, required this.emotion});

  // Map emotion tag to display emoji and color
  Map<String, Map<String, dynamic>> get _map => {
    'positive': {'emoji': '😊', 'color': Colors.green},
    'neutral': {'emoji': '🙂', 'color': Colors.blueGrey},
    'concerned': {'emoji': '😟', 'color': Colors.orange},
    'encouraging': {'emoji': '👍', 'color': Colors.teal},
    'sad': {'emoji': '😔', 'color': Colors.indigo},
  };

  @override
  Widget build(BuildContext context) {
    final info = _map[emotion] ?? _map['neutral']!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Circular avatar placeholder
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: (info['color'] as Color).withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(color: info['color'] as Color, width: 2),
          ),
          child: Center(
            child: Text(
              info['emoji'] as String,
              style: const TextStyle(fontSize: 40),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your Avatar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text('Emotion: ${emotion}', style: const TextStyle(color: Colors.white70)),
          ],
        )
      ],
    );
  }
}
