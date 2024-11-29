import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MatchRandomizer extends StatefulWidget {
  const MatchRandomizer({super.key});

  @override
  _MatchRandomizerState createState() => _MatchRandomizerState();
}

class _MatchRandomizerState extends State<MatchRandomizer> {
  bool _isRandomizing = false;
  String _randomizationStatus = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Randomize Matches'),
        backgroundColor: const Color.fromARGB(255, 248, 215, 106),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _randomizationStatus = '';
              });
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('groups').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No groups found.'));
          } else {
            final groupedData = _groupDataBySportAndTournament(snapshot.data!.docs);

            return ListView(
              children: groupedData.entries.map((sportEntry) {
                final sport = sportEntry.key;
                final tournaments = sportEntry.value;

                return Card(
                  margin: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          sport,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      ...tournaments.entries.map((tournamentEntry) {
                        final tournament = tournamentEntry.key;
                        final teams = tournamentEntry.value;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Tournament: $tournament',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            ElevatedButton(
                              onPressed: _isRandomizing ? null : () => _randomizeMatches(sport, tournament, teams),
                              child: const Text('Randomize Matches'),
                            ),
                          ],
                        );
                      }),
                      if (_randomizationStatus.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            _randomizationStatus,
                            style: const TextStyle(color: Colors.green, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
            );
          }
        },
      ),
    );
  }

  Map<String, Map<String, List<Map<String, String>>>> _groupDataBySportAndTournament(List<QueryDocumentSnapshot> docs) {
    final Map<String, Map<String, List<Map<String, String>>>> groupedData = {};

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final sport = data['sport'] ?? 'Unknown Sport';
      final tournament = data['tournament'] ?? 'Unknown Tournament';
      final group = data['group'] ?? 'Unknown Group';
      final teamName = data['teamName'] ?? 'Unknown Team';

      if (!groupedData.containsKey(sport)) {
        groupedData[sport] = {};
      }

      if (!groupedData[sport]!.containsKey(tournament)) {
        groupedData[sport]![tournament] = [];
      }

      groupedData[sport]![tournament]!.add({
        'teamName': teamName,
        'group': group,
      });
    }

    return groupedData;
  }

  Future<void> _randomizeMatches(String sport, String tournament, List<Map<String, String>> teamsData) async {
    setState(() {
      _isRandomizing = true;
      _randomizationStatus = 'Randomizing matches...';
    });

    final random = Random();
    teamsData.shuffle(random);

    List<Map<String, String>> matches = [];
    for (int i = 0; i < teamsData.length; i += 2) {
      if (i + 1 < teamsData.length) {
        matches.add({
          'team1': teamsData[i]['teamName']!,
          'team2': teamsData[i + 1]['teamName']!,
          'group1': teamsData[i]['group']!,
          'group2': teamsData[i + 1]['group']!,
        });
      } else {
        matches.add({
          'team1': teamsData[i]['teamName']!,
          'team2': 'Waiting for opponent',
          'group1': teamsData[i]['group']!,
          'group2': '',
        });
      }
    }

    try {
      for (var match in matches) {
        await FirebaseFirestore.instance.collection('matches').add({
          'sport': sport,
          'tournament': tournament,
          'team1': match['team1'],
          'team2': match['team2'],
          'group1': match['group1'],
          'group2': match['group2'],
        });
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Randomized Matches'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: matches.map((match) {
                  return Text('${match['team1']} vs ${match['team2']}');
                }).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );

      setState(() {
        _randomizationStatus = 'Matches randomized successfully!';
      });
    } catch (e) {
      print('Failed to save match: $e');
      setState(() {
        _randomizationStatus = 'Failed to randomize matches.';
      });
    } finally {
      setState(() {
        _isRandomizing = false;
      });
    }
  }
}
