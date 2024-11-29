import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GroupDataPage extends StatefulWidget {
  const GroupDataPage({super.key});

  @override
  _GroupDataPageState createState() => _GroupDataPageState();
}

class _GroupDataPageState extends State<GroupDataPage> {
  String selectedSport = ''; // Default selected sport
  List<String> sportsList = []; // List to hold sports fetched from Firestore

  @override
  void initState() {
    super.initState();
    fetchSportsList();
  }

  Future<void> fetchSportsList() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('sports').get();
      setState(() {
        sportsList = snapshot.docs.map((doc) => doc['name'] as String).toList();
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
        title: const Text('Group Data'),
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
            .collection('groups')
            .where('sport', isEqualTo: selectedSport) // Filter by selected sport
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No group data found.'));
          } else {
            final groupDocs = snapshot.data!.docs;

            return ListView.builder(
              itemCount: groupDocs.length,
              itemBuilder: (context, index) {
                final data = groupDocs[index].data() as Map<String, dynamic>;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: ListTile(
                    title: Text('Tournament ID: ${data['tournamentId']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Team Name: ${data['teamName']}'),
                        Text('Group: ${data['group']}'),
                        Text('Timestamp: ${(data['timestamp'] as Timestamp).toDate().toString()}'),
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
