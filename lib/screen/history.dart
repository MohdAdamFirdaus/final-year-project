import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fyp_2/widget/bottomnav.dart';

class BookingHistoryScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

   BookingHistoryScreen({super.key});

  Future<List<Map<String, dynamic>>> _fetchBookingHistory() async {
    final User? user = _auth.currentUser;
    if (user == null) {
      return [];
    }

    QuerySnapshot querySnapshot = await _firestore
        .collection('combined_bookings')
        .where('userId', isEqualTo: user.uid) // Filter by current user's ID
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        'type': 'Booking',
        'facility': data['facility'] ?? 'Unknown facility',
        'sport': data['sport'] ?? 'Unknown sport',
        'bookingEnd': data['bookingEnd'],
        'bookingStart': data['bookingStart'],
        'status': data['status'] ?? 'pending',
        'teamName': data['teamName'] ?? 'Unknown team', // Include team name if available
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _fetchTournamentHistory() async {
    final User? user = _auth.currentUser;
    if (user == null) {
      return [];
    }

    QuerySnapshot querySnapshot = await _firestore
        .collection('tournaments')
        .where('userId', isEqualTo: user.uid) // Filter by current user's ID
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        'type': 'Tournament',
        'tournamentName': data['tournament'] ?? 'Unknown tournament',
        'sport': data['sport'] ?? 'Unknown sport',
        'date': data['date'],
        'status': data['status'] ?? 'pending', // Ensure the 'status' field is properly included
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Bottom()),
            );
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Booking History',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: _buildHistoryList(_fetchBookingHistory),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Tournament History',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: _buildHistoryList(_fetchTournamentHistory),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(Future<List<Map<String, dynamic>>> Function() fetchFunction) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchFunction(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No history found.'));
        } else {
          List<Map<String, dynamic>> history = snapshot.data!;
          return ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final item = history[index];
              final String type = item['type'];
              final String status = item['status'];

              Color cardColor;
              if (status == 'approved') {
                cardColor = Colors.green[100]!;
              } else if (status == 'rejected') {
                cardColor = Colors.red[100]!;
              } else {
                cardColor = Colors.yellow[100]!;
              }

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                color: cardColor, // Set card color based on status
                child: ListTile(
                  onTap: () {
                    // Handle tapping on the history item
                  },
                  title: Text('$type: ${type == 'Booking' ? item['sport'] : item['tournamentName']}'),
                  subtitle: type == 'Booking'
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Date: ${item['bookingStart'].toDate()} - ${item['bookingEnd'].toDate()}',
                            ),
                            Text('Facility: ${item['facility']}'),
                            Text('Status: ${status == 'approved' ? 'accepted' : status}'),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Sport: ${item['sport']}'),
                            Text('Date: ${item['date']}'),
                            Text('Status: $status'),
                          ],
                        ),
                ),
              );
            },
          );
        }
      },
    );
  }
}
