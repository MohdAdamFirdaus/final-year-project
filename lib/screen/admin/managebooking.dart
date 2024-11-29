import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingManagement extends StatefulWidget {
  const BookingManagement({super.key});

  @override
  _BookingManagementState createState() => _BookingManagementState();
}

class _BookingManagementState extends State<BookingManagement> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Bookings'),
        backgroundColor:const Color.fromARGB(255, 248, 215, 106),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('combined_bookings').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No bookings found.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final booking = snapshot.data!.docs[index];
                final bookingData = booking.data() as Map<String, dynamic>;
                final bookingStatus = bookingData['status'] ?? 'pending';

                return Card(
                  margin: const EdgeInsets.all(10.0),
                  child: ListTile(
                    title: Text('${bookingData['sport']} Booking'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date: ${bookingData['bookingStart'].toDate()} - ${bookingData['bookingEnd'].toDate()}',
                        ),
                        Text('Facility: ${bookingData['facility']}'),
                        Text('Status: ${bookingStatus == 'approved' ? 'accepted' : bookingStatus}'),
                      ],
                    ),
                    trailing: bookingStatus == 'pending'
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.check, color: Colors.green),
                                onPressed: () {
                                  _showConfirmationDialog(context, booking.id, 'approved');
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.red),
                                onPressed: () {
                                  _showConfirmationDialog(context, booking.id, 'rejected');
                                },
                              ),
                            ],
                          )
                        : null,
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<void> _showConfirmationDialog(BuildContext context, String bookingId, String status) async {
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
              },
            ),
          ],
        );
      },
    );
  }
}
