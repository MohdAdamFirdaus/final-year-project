import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TournamentManagement extends StatefulWidget {
  const TournamentManagement({super.key});

  @override
  _TournamentManagementState createState() => _TournamentManagementState();
}

class _TournamentManagementState extends State<TournamentManagement> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Tournaments'),
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
                        final tournamentStatus = tournamentData['status'] ?? 'pending';

                        return Card(
                          color: tournamentStatus == 'approved'
                              ? Colors.green[100]
                              : tournamentStatus == 'rejected'
                                  ? Colors.red[100]
                                  : Colors.yellow[100],
                          margin: const EdgeInsets.all(10.0),
                          child: ListTile(
                            title: Text('${tournamentData['tournament']}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Date: ${tournamentData['date']}'),
                                Text('Team Name: ${tournamentData['teamName']}'),
                                Text('Status: ${tournamentStatus == 'approved' ? 'accepted' : tournamentStatus}'),
                              ],
                            ),
                            trailing: tournamentStatus == 'pending'
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.check, color: Colors.green),
                                        onPressed: () {
                                          _showConfirmationDialog(context, tournament.id, 'approved');
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close, color: Colors.red),
                                        onPressed: () {
                                          _showConfirmationDialog(context, tournament.id, 'rejected');
                                        },
                                      ),
                                    ],
                                  )
                                : null,
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

 Future<void> _updateTournamentStatus(String tournamentId, String status) async {
  try {
    await FirebaseFirestore.instance.collection('tournaments').doc(tournamentId).update({
      'status': status,
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Tournament $status successfully.'),
    ));
    
    // Retrieve the tournament document
    final tournamentDoc = await FirebaseFirestore.instance.collection('tournaments').doc(tournamentId).get();
    
    // Check if the userId field exists
    if (tournamentDoc.exists && tournamentDoc.data()!.containsKey('userId')) {
      final userId = tournamentDoc['userId'];

      // Send notification to userId
      await _sendNotificationForTournament(tournamentId, status, userId);
    } else {
      print('userId field does not exist in the tournament document.');
    }
  } catch (e) {
    print('Failed to update tournament status: $e');
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Failed to update tournament status.'),
      backgroundColor: Colors.red,
    ));
  }
}

Future<void> _sendNotificationForTournament(String tournamentId, String status, String userId) async {
  try {
    await FirebaseFirestore.instance.collection('notifications').add({
      'tournamentId': tournamentId,
      'userId': userId,
      'title': 'Tournament $status',
      'message': 'Your tournament has been $status.',
      'timestamp': FieldValue.serverTimestamp(),
    });
  } catch (e) {
    print('Failed to send notification: $e');
  }
}

  Future<void> _showConfirmationDialog(BuildContext context, String tournamentId, String status) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: Text('Are you sure you want to $status this tournament?'),
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
                _updateTournamentStatus(tournamentId, status);
              },
              child: Text(status),
            ),
          ],
        );
      },
    );
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
              Text('Status: ${tournamentData['status']}'),
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
}
