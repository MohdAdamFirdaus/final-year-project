import 'package:flutter/material.dart';

class BookingItem extends StatelessWidget {
  final Map<String, dynamic> booking;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const BookingItem({super.key, 
    required this.booking,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final String id = booking['id'] ?? '';
    final String user = booking['user'] ?? '';
    final String date = booking['date'] ?? '';
    final String status = booking['status'] ?? '';

    return ListTile(
      title: Text('Booking ID: $id'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('User: $user'),
          Text('Date: $date'),
          Text('Status: $status'),
        ],
      ),
      trailing: _buildActionButtons(status),
    );
  }

  Widget _buildActionButtons(String status) {
    if (status == 'approved' || status == 'rejected') {
      return const SizedBox.shrink(); // Hide buttons if already approved or rejected
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: onApprove,
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onReject,
          ),
        ],
      );
    }
  }
}
