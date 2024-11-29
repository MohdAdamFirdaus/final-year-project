import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp_2/widget/draweradmin.dart';
import '../login.dart';

class Admin extends StatefulWidget {
  const Admin({super.key});

  @override
  State<Admin> createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  int totalBookings = 0;
  int pendingBookings = 0;
  int approvedBookings = 0;
  int rejectedBookings = 0;
  StreamSubscription<QuerySnapshot>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscribeToBookingChanges();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _subscribeToBookingChanges() {
    _subscription = FirebaseFirestore.instance.collection('combined_bookings').snapshots().listen((snapshot) {
      setState(() {
        totalBookings = snapshot.size;
        pendingBookings = snapshot.docs.where((doc) => doc['status'] == 'pending' || doc['status'] == null || doc['status'] == 'Pending').length;
        approvedBookings = snapshot.docs.where((doc) => doc['status'] == 'approved' || doc['status'] == 'Approved').length;
        rejectedBookings = snapshot.docs.where((doc) => doc['status'] == 'rejected' || doc['status'] == 'Rejected').length;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Administrator"),
        backgroundColor: const Color.fromARGB(255, 248, 215, 106),
        actions: [
          IconButton(
            onPressed: () {
              logout(context);
            },
            icon: const Icon(
              Icons.logout,
            ),
          )
        ],
      ),
      drawer: const MyDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildDashboard(),
            const SizedBox(height: 20),
            _buildPendingBookingsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard() {
    return Card(
      color: const Color.fromARGB(255, 248, 215, 106),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Dashboard Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard('Total', totalBookings),
                _buildStatCard('Pending', pendingBookings),
                _buildStatCard('Approved', approvedBookings),
                _buildStatCard('Rejected', rejectedBookings),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, int count) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 5),
        Text('$count', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildPendingBookingsList() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pending Bookings',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('combined_bookings').where('status', isEqualTo: 'pending').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No pending bookings found.'));
              } else {
                List<QueryDocumentSnapshot> pendingBookings = snapshot.data!.docs;
                return Expanded(
                  child: ListView.builder(
                    itemCount: pendingBookings.length,
                    itemBuilder: (context, index) {
                      final booking = pendingBookings[index];
                      return ListTile(
                        title: Text('Booking ID: ${booking.id}'),
                        subtitle: Text('Facility: ${booking['facility']}, Sport: ${booking['sport']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check, color: Colors.green),
                              onPressed: () {
                                _showConfirmationDialog(context, booking.id, booking['userId'], 'approved');
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () {
                                _showConfirmationDialog(context, booking.id, booking['userId'], 'rejected');
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showConfirmationDialog(BuildContext context, String bookingId, String userId, String status) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm $status'),
          content: Text('Are you sure you want to $status this booking?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Confirm'),
              onPressed: () async {
                await FirebaseFirestore.instance.collection('combined_bookings').doc(bookingId).update({
                  'status': status,
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Booking $status successfully.'),
                ));
                _sendNotificationForBooking(bookingId, userId, status);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendNotificationForBooking(String bookingId, String userId, String status) async {
    try {
      await FirebaseFirestore.instance.collection('notifications').add({
        'bookingId': bookingId,
        'userId': userId, // Add userId to target specific user
        'title': 'Booking $status',
        'message': 'Your booking has been $status.',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Failed to send notification: $e');
    }
  }

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
  }
}
