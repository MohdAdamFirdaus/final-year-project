import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fyp_2/screen/booking.dart';

import 'package:fyp_2/screen/login.dart';

void main() {
  runApp(const UserDashboardApp());
}

class UserDashboardApp extends StatelessWidget {
  const UserDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: UserDashboardPage(),
    );
  }
}

class UserDashboardPage extends StatefulWidget {
  const UserDashboardPage({super.key});

  @override
  _UserDashboardPageState createState() => _UserDashboardPageState();
}

class _UserDashboardPageState extends State<UserDashboardPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User _user;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    _user = _auth.currentUser!;
    setState(() {
      _isLoggedIn = _user != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoggedIn) {
      return const LoginPage(); // Navigate to login page if not logged in
    }
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Available Sports', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(child: _buildSportsList()),
            const SizedBox(height: 20),
            const Text('Your Bookings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(child: _buildBookingsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildSportsList() {
    final List<Color> cardColors = [const Color.fromARGB(255, 248, 215, 106), const Color.fromARGB(255, 248, 215, 106)];
    int colorIndex = 0;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('sports').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No available sports found.'));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final sport = snapshot.data!.docs[index];
              Color cardColor = cardColors[colorIndex];
              colorIndex = (colorIndex + 1) % cardColors.length;
              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                color: cardColor,
                child: ListTile(
                  title: Text(sport['name']),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Mytab(),
                      ),
                    );
                  },
                ),
              );
            },
          );
        }
      },
    );
  }

  Widget _buildBookingsList() {
    final List<Color> cardColors = [const Color.fromARGB(255, 248, 215, 106), const Color.fromARGB(255, 248, 215, 106)];
    int colorIndex = 0;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('combined_bookings')
          .where('userId', isEqualTo: _auth.currentUser!.uid) // Filter by current user's ID
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No bookings found.'));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final booking = snapshot.data!.docs[index];
              Color cardColor = cardColors[colorIndex];
              colorIndex = (colorIndex + 1) % cardColors.length;
              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                color: cardColor,
                child: ListTile(
                  title: Text('Booking ID: ${booking.id}'),
                  subtitle: Text('Facility: ${booking['facility']}, Sport: ${booking['sport']}'),
                ),
              );
            },
          );
        }
      },
    );
  }
}
