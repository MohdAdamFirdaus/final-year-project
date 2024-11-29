import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp_2/widget/drawerpic.dart'; // Assuming MyDrawer is implemented to show the drawer
import '../login.dart'; // Import your login page or replace with appropriate import

class SportsPIC extends StatefulWidget {
  const SportsPIC({super.key});

  @override
  State<SportsPIC> createState() => _SportsPICState();
}

class _SportsPICState extends State<SportsPIC> {
  String selectedSport = 'All Sports'; // Track selected sport for filtering
  late List<String> sports = []; // Initialize sports with an empty list

  @override
  void initState() {
    super.initState();
    _fetchSports();
  }

  Future<void> _fetchSports() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('sports').get();
      final sportList = snapshot.docs.map((doc) => doc['name'] as String).toList();
      setState(() {
        sports = ['All Sports', ...sportList]; // Add 'All Sports' option to the beginning
        selectedSport = sports.first; // Default selected sport to the first one (All Sports)
      });
    } catch (e) {
      print('Error fetching sports: $e');
      // Handle error appropriately, e.g., show a message to the user
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Person in Charge"),
        backgroundColor: const Color.fromARGB(255, 248, 215, 106),
        actions: [
          IconButton(
            onPressed: () {
              logout(context);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      drawer: const MyDrawer(), // Assuming MyDrawer is implemented to show the drawer
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Welcome to the Person in Charge Page",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildSportDropdown(), // Dropdown to filter by sport
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _getMatchesStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No matches found.'));
                  } else {
                    final matches = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: matches.length,
                      itemBuilder: (context, index) {
                        final match = matches[index];
                        final sport = match['sport'];
                        final team1 = match['team1'];
                        final team2 = match['team2'];
                        final group1 = match['group1'];
                        final group2 = match['group2'];

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text('$sport Match'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Team 1: $team1 (Group: $group1)'),
                                Text('Team 2: $team2 (Group: $group2)'),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSportDropdown() {
    if (sports.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return DropdownButton<String>(
      value: selectedSport,
      onChanged: (newValue) {
        setState(() {
          selectedSport = newValue!;
        });
      },
      items: _buildSportDropdownItems(),
    );
  }

  List<DropdownMenuItem<String>> _buildSportDropdownItems() {
    return sports.map((sport) {
      return DropdownMenuItem<String>(
        value: sport,
        child: Text(sport),
      );
    }).toList();
  }

  Stream<QuerySnapshot> _getMatchesStream() {
    if (selectedSport == 'All Sports') {
      return FirebaseFirestore.instance.collection('matches').snapshots();
    } else {
      return FirebaseFirestore.instance.collection('matches').where('sport', isEqualTo: selectedSport).snapshots();
    }
  }

  Future<void> logout(BuildContext context) async {
    const CircularProgressIndicator();
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
  }
}
