import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScoreManagementScreen extends StatefulWidget {
  const ScoreManagementScreen({super.key});

  @override
  _ScoreManagementScreenState createState() => _ScoreManagementScreenState();
}

class _ScoreManagementScreenState extends State<ScoreManagementScreen> {
  final CollectionReference matchesCollection = FirebaseFirestore.instance.collection('matches');

  // Function to update the scores for both teams
  void _updateScores(String matchId, int score1, int score2) {
    matchesCollection.doc(matchId).update({'score1': score1, 'score2': score2});
  }

  // Function to delete a match
  void _deleteMatch(String matchId) {
    matchesCollection.doc(matchId).delete();
  }

  // Function to show a dialog for updating scores
  void _showScoreDialog(String matchId, int currentScore1, int currentScore2) {
    final TextEditingController score1Controller = TextEditingController(text: currentScore1.toString());
    final TextEditingController score2Controller = TextEditingController(text: currentScore2.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Scores'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: score1Controller,
                decoration: const InputDecoration(labelText: 'Score Team 1'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: score2Controller,
                decoration: const InputDecoration(labelText: 'Score Team 2'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final int updatedScore1 = int.parse(score1Controller.text);
                final int updatedScore2 = int.parse(score2Controller.text);
                _updateScores(matchId, updatedScore1, updatedScore2);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Scores'),
        backgroundColor: const Color.fromARGB(255, 248, 215, 106),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: matchesCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No matches found.'));
          }

          final matches = snapshot.data!.docs;

          return ListView.builder(
            itemCount: matches.length,
            itemBuilder: (context, index) {
              final match = matches[index];
              final matchData = match.data() as Map<String, dynamic>;

              // Check for the 'name', 'team1', 'team2', 'score1', and 'score2' fields, provide default values if they are missing
              final matchName = matchData['name'] ?? 'Unknown Match';
              final team1 = matchData['team1'] ?? 'Unknown Team 1';
              final team2 = matchData['team2'] ?? 'Unknown Team 2';
              final score1 = matchData['score1'] ?? 0;
              final score2 = matchData['score2'] ?? 0;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  
                      const SizedBox(height: 8),
                      Text(
                        '$team1 vs $team2',
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Score: $score1 - $score2',
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showScoreDialog(match.id, score1, score2),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteMatch(match.id),
                          ),
                        ],
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
