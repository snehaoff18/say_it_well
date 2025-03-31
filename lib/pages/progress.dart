import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:say_it_well/pages/mainscreen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  late Future<List<Map<String, dynamic>>> _recentScoresFuture;

  @override
  void initState() {
    super.initState();
    _recentScoresFuture = fetchRecentScores();
  }

  Future<List<Map<String, dynamic>>> fetchRecentScores() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print("No authenticated user found.");
      return [];
    }

    List<Map<String, dynamic>> scores = [];

    try {
      // Fetch user document
      final docSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      if (!docSnapshot.exists) {
        print("User document does not exist.");
        return [];
      }

      final data = docSnapshot.data();
      print("🔥 Firestore data: $data");

      if (data == null || !data.containsKey('scores')) {
        print("⚠️ 'scores' field not found.");
        return [];
      }

      List<dynamic> scoreArray = List.from(data['scores']);

      if (scoreArray.isEmpty) {
        print("⚠️ Score array is empty.");
        return [];
      }

      print("✅ Raw score array: $scoreArray");

      // Take last 3 scores, assume each is from a previous day
      int totalScores = scoreArray.length;
      int startIndex = totalScores >= 3 ? totalScores - 3 : 0;

      for (int i = startIndex; i < totalScores; i++) {
        scores.add({
          'x': i - startIndex, // X-axis index
          'score': scoreArray[i], // Actual score
          'timestamp': DateTime.now(), //
        });
      }

      print("✅ Processed scores: $scores");
    } catch (e) {
      print("❌ Error fetching scores: $e");
    }

    return scores;
  }

  void _refreshScores() {
    setState(() {
      _recentScoresFuture = fetchRecentScores();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Profile Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFF7B61FF),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MainScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 40, color: Colors.purple),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      user?.displayName ?? "User",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Score Chart
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _recentScoresFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text("No recent scores available.");
                  }

                  List<Map<String, dynamic>> scores = snapshot.data!;

                  return Column(
                    children: [
                      // Chart Container
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7B61FF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Recent Scores",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              height: 250,
                              child: BarChart(
                                BarChartData(
                                  gridData: const FlGridData(show: false),
                                  borderData: FlBorderData(show: false),
                                  barTouchData: BarTouchData(enabled: false),
                                  titlesData: FlTitlesData(
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (double value, _) {
                                          int index = value.toInt();
                                          if (index >= 0 &&
                                              index < scores.length) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                top: 8.0,
                                              ),
                                              child: Text(
                                                DateFormat('MM/dd').format(
                                                  scores[index]['timestamp'],
                                                ),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            );
                                          }
                                          return const Text("");
                                        },
                                      ),
                                    ),
                                    leftTitles: const AxisTitles(),
                                    topTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (double value, _) {
                                          int index = value.toInt();
                                          if (index >= 0 &&
                                              index < scores.length) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 8.0,
                                              ),
                                              child: Text(
                                                scores[index]['score']
                                                    .toString(),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            );
                                          }
                                          return const Text("");
                                        },
                                      ),
                                    ),
                                  ),
                                  barGroups:
                                      scores.map((entry) {
                                        return BarChartGroupData(
                                          x: entry['x'],
                                          barRods: [
                                            BarChartRodData(
                                              toY: entry['score'].toDouble(),
                                              color: const Color.fromARGB(
                                                255,
                                                215,
                                                145,
                                                233,
                                              ),
                                              width: 30,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                          ],
                                        );
                                      }).toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Display Scores Below the Chart
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 5,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          children:
                              scores.map((entry) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 5,
                                  ),
                                  child: Text(
                                    "Score: ${entry['score']} on ${DateFormat('MMM d, yyyy').format(entry['timestamp'])}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshScores,
        backgroundColor: Colors.purple,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}
