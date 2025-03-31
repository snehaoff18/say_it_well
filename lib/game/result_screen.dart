import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final bool won;
  final int score; // ✅ Accept score

  const ResultScreen({
    super.key,
    required this.won,
    required this.score,
  }); // ✅ Update constructor

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          won ? const Color.fromARGB(255, 180, 108, 219) : Colors.red,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              won ? Icons.emoji_events : Icons.warning,
              color: Colors.white,
              size: 100,
            ),
            const SizedBox(height: 20),
            Text(
              won
                  ? "🎉 You Won! Great Job!"
                  : "⏳ Time's Up! Better Luck Next Time!",
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              "Your Score: $score", // ✅ Display the score
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Back to Game"),
            ),
          ],
        ),
      ),
    );
  }
}
