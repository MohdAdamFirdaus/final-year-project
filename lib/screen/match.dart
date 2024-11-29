import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MatchDataPage extends StatefulWidget {
  const MatchDataPage({super.key});

  @override
  _MatchDataPageState createState() => _MatchDataPageState();
}

class _MatchDataPageState extends State<MatchDataPage> {
  String selectedSport = ''; // Default selected sport
  List<String> sportsList = []; // List to hold sports fetched from Firestore

  @override
  void initState() {
    super.initState();
    fetchSportsList();
  }

  Future<void> fetchSportsList() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('sports').get();
      setState(() {
        sportsList =
            snapshot.docs.map((doc) => doc['name'] as String).toList();
        if (sportsList.isNotEmpty) {
          selectedSport = sportsList[0]; // Select the first sport by default
        }
      });
    } catch (e) {
      print('Failed to fetch sports: $e');
      // Handle error as needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Matches Data'),
        backgroundColor: const Color.fromARGB(255, 248, 215, 106),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: DropdownButton<String>(
              value: selectedSport,
              onChanged: (newValue) {
                setState(() {
                  selectedSport = newValue!;
                });
              },
              items: sportsList.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('matches')
            .where('sport', isEqualTo: selectedSport) // Filter by selected sport
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No match data found.'));
          } else {
            final matchDocs = snapshot.data!.docs;

            return ListView.builder(
              itemCount: matchDocs.length,
              itemBuilder: (context, index) {
                final data = matchDocs[index].data() as Map<String, dynamic>;

                // Extracting relevant fields
                final team1 = data['team1'];
                final team2 = data['team2'];
                final score1 = data['score1'] ?? 0; // Default to 0 if null
                final score2 = data['score2'] ?? 0; // Default to 0 if null

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('$team1 vs $team2'),
                        Text('$score1 - $score2'),
                      ],
                    ),
                    onTap: () {
                      // Handle onTap action if needed
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
