import 'package:flutter/material.dart';

// 🎨 Styled TextField
Widget buildTextField(TextEditingController controller, String label, IconData icon, {bool obscureText = false}) {
  return TextField(
    controller: controller,
    obscureText: obscureText,
    style: const TextStyle(color: Colors.white),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.yellowAccent),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.yellowAccent),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white),
        borderRadius: BorderRadius.circular(12),
      ),
      prefixIcon: Icon(icon, color: Colors.yellowAccent),
    ),
  );
}

// 🎨 Styled Button
Widget buildButton(String text, Color color, VoidCallback onPressed) {
  return ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    child: Text(
      text,
      style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
    ),
  );
}
