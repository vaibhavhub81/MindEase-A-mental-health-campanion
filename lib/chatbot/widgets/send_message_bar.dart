import 'package:flutter/material.dart';

class SendMessageBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  const SendMessageBar({super.key, required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Colors.grey[900],
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration.collapsed(
                  hintText: "Type your thoughts...",
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                minLines: 1,
                maxLines: 4,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send, color: Colors.lightBlueAccent),
              onPressed: onSend,
            )
          ],
        ),
      ),
    );
  }
}
