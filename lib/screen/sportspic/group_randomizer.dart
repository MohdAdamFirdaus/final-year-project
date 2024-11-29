import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GroupRandomizer extends StatefulWidget {
  const GroupRandomizer({super.key});

  @override
  _GroupRandomizerState createState() => _GroupRandomizerState();
}

class _GroupRandomizerState extends State<GroupRandomizer> {
  bool _isAssigningGroup = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Randomize Groups'),
        backgroundColor: const Color.fromARGB(255, 248, 215, 106),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('tournaments').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No tournaments found.'));
          } else {
            final groupedTournaments = _groupTournaments(snapshot.data!.docs);

            return ListView.builder(
              itemCount: groupedTournaments.keys.length,
              itemBuilder: (context, index) {
                final tournamentName = groupedTournaments.keys.elementAt(index);
                final sportsMap = groupedTournaments[tournamentName]!;

                return ExpansionTile(
                  title: Text(tournamentName),
                  children: sportsMap.keys.map<Widget>((sport) {
                    final tournaments = sportsMap[sport]!;

                    return ExpansionTile(
                      title: Text('Sport: $sport'),
                      children: tournaments.map<Widget>((tournament) {
                        final tournamentData = tournament.data() as Map<String, dynamic>;
                        final tournamentGroup = tournamentData['group'] ?? 'Not assigned';
                        final groupColor = _getGroupColor(tournamentGroup);

                        return Card(
                          color: groupColor,
                          margin: const EdgeInsets.all(10.0),
                          child: ListTile(
                            title: Text('${tournamentData['tournament']}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Date: ${tournamentData['date']}'),
                                Text('Team Name: ${tournamentData['teamName']}'),
                                Text('Group: $tournamentGroup'),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.shuffle, color: Colors.blue),
                              onPressed: () {
                                _showGroupAssignmentConfirmationDialog(context, tournament.id, sport, tournamentData['tournament']);
                              },
                            ),
                            onTap: () {
                              _showTournamentDetails(context, tournamentData);
                            },
                          ),
                        );
                      }).toList(),
                    );
                  }).toList(),
                );
              },
            );
          }
        },
      ),
    );
  }

  Map<String, Map<String, List<QueryDocumentSnapshot>>> _groupTournaments(List<QueryDocumentSnapshot> tournaments) {
    final Map<String, Map<String, List<QueryDocumentSnapshot>>> groupedTournaments = {};

    for (var tournament in tournaments) {
      final tournamentData = tournament.data() as Map<String, dynamic>;
      final tournamentName = tournamentData['tournament'];
      final sport = tournamentData['sport'];

      if (!groupedTournaments.containsKey(tournamentName)) {
        groupedTournaments[tournamentName] = {};
      }

      if (!groupedTournaments[tournamentName]!.containsKey(sport)) {
        groupedTournaments[tournamentName]![sport] = [];
      }

      groupedTournaments[tournamentName]![sport]!.add(tournament);
    }

    return groupedTournaments;
  }

  Future<void> _showGroupAssignmentConfirmationDialog(BuildContext context, String tournamentId, String sport, String tournamentName) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const Text('Are you sure you want to assign a random group to this tournament?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _assignRandomGroupToTournament(tournamentId, sport, tournamentName);
              },
              child: const Text('Assign Group'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _assignRandomGroupToTournament(String tournamentId, String sport, String tournamentName) async {
    final random = Random();
    final groupNumber = random.nextInt(4) + 1; // Assuming 4 groups
    final group = 'Group $groupNumber';

    setState(() {
      _isAssigningGroup = true;
    });

    try {
      // Get tournament data to retrieve the team name
      DocumentSnapshot tournamentSnapshot = await FirebaseFirestore.instance.collection('tournaments').doc(tournamentId).get();
      final tournamentData = tournamentSnapshot.data() as Map<String, dynamic>;
      final teamName = tournamentData['teamName'];

      // Update the tournament document with the new group
      await FirebaseFirestore.instance.collection('tournaments').doc(tournamentId).update({'group': group});

      // Add an entry to the groups collection
      await FirebaseFirestore.instance.collection('groups').add({
        'tournamentId': tournamentId,
        'tournament': tournamentName,
        'teamName': teamName,
        'group': group,
        'sport': sport,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tournament assigned to $group.'),
        ),
      );
    } catch (e) {
      print('Failed to assign group: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to assign group.'),
        ),
      );
    }

    setState(() {
      _isAssigningGroup = false;
    });
  }

  void _showTournamentDetails(BuildContext context, Map<String, dynamic> tournamentData) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('${tournamentData['tournament']} Details'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Sport: ${tournamentData['sport']}'),
              Text('Date: ${tournamentData['date']}'),
              Text('Team Name: ${tournamentData['teamName']}'),
              Text('Group: ${tournamentData['group'] ?? 'Not assigned'}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Color _getGroupColor(String group) {
    switch (group) {
      case 'Group 1':
        return Colors.blue[100]!;
      case 'Group 2':
        return Colors.orange[100]!;
      case 'Group 3':
        return Colors.purple[100]!;
      case 'Group 4':
        return Colors.green[100]!;
      default:
        return Colors.grey[100]!;
    }
  }
}
