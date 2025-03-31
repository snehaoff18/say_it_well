import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ✅ Firebase Firestore
import 'package:flutter_tts/flutter_tts.dart'; // ✅ Text-to-Speech
import 'package:say_it_well/pages/mainscreen.dart'; // ✅ Navigation back to MainScreen

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  final FlutterTts _tts = FlutterTts(); // ✅ Initialize TTS
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // ✅ Firestore instance

  @override
  void initState() {
    super.initState();
    _configureTTS();
  }

  // ✅ Configure TTS Settings
  Future<void> _configureTTS() async {
    await _tts.setLanguage('en-US');
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(0.5);
  }

  // ✅ Function to speak the word aloud
  Future<void> _speak(String word) async {
    await _tts.speak(word);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Hear and Say It!',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF7B61FF), // Matching theme color
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            _firestore
                .collection('words')
                .snapshots(), // ✅ Fetch words from Firestore
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading words'));
          }

          final words = snapshot.data?.docs ?? [];

          if (words.isEmpty) {
            return const Center(child: Text('No words found'));
          }

          return ListView.builder(
            itemCount: words.length,
            itemBuilder: (context, index) {
              // ✅ Access the `value` field inside each document
              final word = words[index]['text'] ?? 'Unknown';

              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: ListTile(
                  title: Text(
                    word, // ✅ Display the word from the `value` field
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.volume_up, color: Colors.blue),
                    onPressed: () => _speak(word), // ✅ Speak the word aloud
                  ),
                ),
              );
            },
          );
        },
      ),

      // ✅ Quit button at the bottom
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MainScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, // Quit button color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'QUIT',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
