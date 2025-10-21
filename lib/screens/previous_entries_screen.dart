import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PreviousEntriesScreen extends StatelessWidget {
  const PreviousEntriesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final entriesRef = FirebaseFirestore.instance
        .collection('journal_entries')
        .doc(uid)
        .collection('entries')
        .orderBy('created_at', descending: true);

    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C2C2E),
        title: const Text(
          'Your Entries',
          style: TextStyle(color: Color(0xFFFFB703)),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: entriesRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final entries = snapshot.data?.docs ?? [];

          if (entries.isEmpty) {
            return const Center(
              child: Text(
                'No entries yet!',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final data = entries[index].data() as Map<String, dynamic>;
              final content = data['content'] ?? '';
              final timestamp = data['created_at'] as Timestamp?;
              final date = timestamp?.toDate();

              return Card(
                color: const Color(0xFF2C2C2E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (date != null)
                        Text(
                          '${date.day}/${date.month}/${date.year} – ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        content,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
