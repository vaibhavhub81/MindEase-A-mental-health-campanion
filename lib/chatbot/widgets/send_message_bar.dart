import 'package:flutter/material.dart';

class SendMessageBar extends StatefulWidget {
  final Function(String) onSend;

  const SendMessageBar({required this.onSend, super.key});

  @override
  State<SendMessageBar> createState() => _SendMessageBarState();
}

class _SendMessageBarState extends State<SendMessageBar> {
  final controller = TextEditingController();

  void _handleSend() {
    final text = controller.text.trim();
    if (text.isNotEmpty) {
      widget.onSend(text);
      controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[900],
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Type your thoughts...",
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.yellow),
            onPressed: _handleSend,
          ),
        ],
      ),
    );
  }
}
