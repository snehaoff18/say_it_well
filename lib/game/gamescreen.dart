import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ✅ Import FirebaseAuth

import 'speech_service.dart';
import 'result_screen.dart'; // Import the ResultScreen for navigation
import 'package:say_it_well/pages/mainscreen.dart'; // Import the HomeScreen for navigation

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final SpeechService _speechService = SpeechService();
  List<String> wordList = [];
  int currentWordIndex = 0;
  String recognizedWord = "";
  bool showSpeakingPrompt = false;
  bool wordCorrect = false;
  int score = 0;

  // Timer Variables
  Timer? _timer;
  int timeLeft = 60; // ⏳ Fixed time for the entire game (adjustable)

  @override
  void initState() {
    super.initState();
    fetchWordsFromFirestore();
  }

  // Fetch words from Firestore and start the timer
  Future<void> fetchWordsFromFirestore() async {
    try {
      var snapshot = await FirebaseFirestore.instance.collection('words').get();
      setState(() {
        wordList = snapshot.docs.map((doc) => doc['text'] as String).toList();
      });

      _startTimer(); // ✅ Start timer ONCE for the whole game
    } catch (e) {
      print("Error fetching words: $e");
    }
  }

  // ✅ Start timer ONCE for the whole game
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft > 0) {
        setState(() => timeLeft--);
      } else {
        _timer?.cancel();
        _endGame(false); // ⏳ Time's up — Game Over
      }
    });
  }

  bool isProcessing = false; // ✅ Prevents multiple calls

  void _onTextRecognized(String text, bool hasStutter, bool hasPause) {
    if (!mounted || isProcessing) return;

    setState(() {
      recognizedWord = text;
      wordCorrect = false;
      isProcessing = true;
    });

    if (hasPause) {
      _showSnackBar('⏸️ Pause detected! Try speaking smoothly.');
    } else if (hasStutter) {
      _showSnackBar('⚠️ Stuttering detected! Try again.');
    } else if (recognizedWord.trim().toLowerCase() ==
        wordList[currentWordIndex].toLowerCase()) {
      _showSnackBar('✅ Correct! Well done!');

      setState(() {
        wordCorrect = true;
        score += 5;
      });

      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) _nextWord();
      });
    } else {
      _showSnackBar('❌ Try again!');
    }

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => isProcessing = false);
    });
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _nextWord() {
    setState(() {
      recognizedWord = "";
      showSpeakingPrompt = false;
      wordCorrect = false;

      if (currentWordIndex < wordList.length - 1) {
        currentWordIndex++;
      } else {
        _endGame(true); // ✅ End game when words are finished
      }
    });
  }

  // ✅ Save the user's score in Firestore

  Future<void> _saveScore() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {
          'scores': FieldValue.arrayUnion([score]),
        },
      );
    }
  }

  void _endGame(bool won) async {
    _timer?.cancel(); // ✅ Stop timer

    // ✅ Save score before navigating to the result screen
    await _saveScore();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(won: won, score: score),
      ), // ✅ Pass score
    );
  }

  void _quitGame() {
    _timer?.cancel(); // ✅ Stop timer
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (wordList.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 125, 55, 194),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Score: $score",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              height: 200, // Adjust height as needed
              width: 300, // Ensures it takes full width
              decoration: BoxDecoration(
                color: Colors.white, // Background color
                borderRadius: BorderRadius.circular(12), // Rounded edges 🎯
              ),
              alignment: Alignment.center, // Centers text inside
              child: Text(
                wordList[currentWordIndex],
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color:
                      wordCorrect
                          ? const Color.fromARGB(255, 49, 158, 60)
                          : Colors.black, // ✅ Change color if correct
                ),
              ),
            ),

            const SizedBox(height: 20),

            if (showSpeakingPrompt)
              const Text(
                "You can start speaking...",
                style: TextStyle(fontSize: 20, color: Colors.blue),
              ),

            Text(
              recognizedWord.isEmpty ? "Speak now..." : recognizedWord,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),

            Text(
              "Time Left: $timeLeft seconds",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: timeLeft > 3 ? Colors.green : Colors.red,
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                if (_speechService.isListening) {
                  _speechService.stopListening();
                  setState(() => showSpeakingPrompt = false);
                } else {
                  _speechService.startListening(_onTextRecognized);
                  setState(() => showSpeakingPrompt = true);
                }
              },
              child: Text(
                _speechService.isListening
                    ? "Stop Listening"
                    : "Start Listening",
              ),
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _quitGame,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Quit", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
