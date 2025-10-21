import 'package:flutter/material.dart';
import '../chatbot_memory.dart';

class AvatarCreationScreen extends StatefulWidget {
  const AvatarCreationScreen({super.key});

  @override
  State<AvatarCreationScreen> createState() => _AvatarCreationScreenState();
}

class _AvatarCreationScreenState extends State<AvatarCreationScreen> {
  final TextEditingController _nameCtrl = TextEditingController();
  String hair = 'short';
  String eyes = 'brown';
  String skin = 'light';

  void _saveAvatar() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please provide a name for the avatar.')));
      return;
    }

    final avatar = {
      'name': name,
      'hair': hair,
      'eyes': eyes,
      'skin': skin,
      'created_at': DateTime.now().toIso8601String(),
    };

    await ChatbotMemory.saveAvatar(avatar);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Avatar saved.')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Avatar'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Avatar name')),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: hair,
              items: const [
                DropdownMenuItem(value: 'short', child: Text('Short hair')),
                DropdownMenuItem(value: 'long', child: Text('Long hair')),
                DropdownMenuItem(value: 'curly', child: Text('Curly')),
              ],
              onChanged: (v) => setState(() => hair = v ?? hair),
              decoration: const InputDecoration(labelText: 'Hair style'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: eyes,
              items: const [
                DropdownMenuItem(value: 'brown', child: Text('Brown')),
                DropdownMenuItem(value: 'blue', child: Text('Blue')),
                DropdownMenuItem(value: 'green', child: Text('Green')),
              ],
              onChanged: (v) => setState(() => eyes = v ?? eyes),
              decoration: const InputDecoration(labelText: 'Eye color'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: skin,
              items: const [
                DropdownMenuItem(value: 'light', child: Text('Light')),
                DropdownMenuItem(value: 'medium', child: Text('Medium')),
                DropdownMenuItem(value: 'dark', child: Text('Dark')),
              ],
              onChanged: (v) => setState(() => skin = v ?? skin),
              decoration: const InputDecoration(labelText: 'Skin tone'),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Save Avatar'),
              onPressed: _saveAvatar,
            )
          ],
        ),
      ),
    );
  }
}
