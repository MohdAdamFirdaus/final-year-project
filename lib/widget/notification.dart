import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserNotifications extends StatefulWidget {
  const UserNotifications({super.key});

  @override
  _UserNotificationsState createState() => _UserNotificationsState();
}

class _UserNotificationsState extends State<UserNotifications> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Notification'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context); // Navigate back to previous screen
            },
          ),
        ),
        body: const Center(
          child: Text('No user logged in'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('userId',
                isEqualTo: user.uid) // Filter notifications by userId
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No notifications found.'));
          } else {
            final notifications = snapshot.data!.docs;

            return ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                final notificationData =
                    notification.data() as Map<String, dynamic>;

                // Determine whether it's a booking or tournament notification
                final isBookingNotification =
                    notificationData.containsKey('bookingId');
                final isTournamentNotification =
                    notificationData.containsKey('tournamentId');

                // Get the message from the notification data
                String message =
                    notificationData['message'] ?? 'New notification received.';

                // Customize message based on notification type
                if (isBookingNotification) {
                  message = 'Booking Update: $message';
                } else if (isTournamentNotification) {
                  message = 'Tournament Update: $message';
                }

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 2), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Notification',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        message,
                        style: const TextStyle(fontSize: 16.0),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'Received on: ${notificationData['timestamp'].toDate().toString()}',
                        style: const TextStyle(
                          fontSize: 14.0,
                          color: Colors.grey,
                        ),
                      ),
                    ],
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
