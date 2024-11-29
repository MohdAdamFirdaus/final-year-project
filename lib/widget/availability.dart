import 'package:booking_calendar/booking_calendar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp_2/model/booking_form_data.dart';
import 'package:intl/date_symbol_data_local.dart'; // Import BookingFormData

class BookingCalendarDemoApp extends StatelessWidget {
  final BookingFormData formData;

  const BookingCalendarDemoApp({super.key, required this.formData});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: initializeDateFormatting('en_US', null),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            title: 'Booking Time Slot',
            theme: ThemeData(primarySwatch: Colors.blue),
            debugShowCheckedModeBanner: false, // Remove the debug banner
            home: BookingCalendarPage(formData: formData),
          );
        } else {
          return const MaterialApp(
            title: 'Booking Time Slot',
            debugShowCheckedModeBanner: false, // Remove the debug banner
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }
      },
    );
  }
}

class BookingCalendarPage extends StatelessWidget {
  final BookingFormData formData;

  const BookingCalendarPage({super.key, required this.formData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Available Slot')),
      body: SingleChildScrollView(
        child: BookingCalendarWidget(formData: formData),
      ),
    );
  }
}

class BookingCalendarWidget extends StatefulWidget {
  final BookingFormData formData;

  const BookingCalendarWidget({super.key, required this.formData});

  @override
  _BookingCalendarWidgetState createState() => _BookingCalendarWidgetState();
}

class _BookingCalendarWidgetState extends State<BookingCalendarWidget> {
  final now = DateTime.now();
  late BookingService mockBookingService;
  List<DateTimeRange> converted = [];

  @override
  void initState() {
    super.initState();
    mockBookingService = BookingService(
      serviceName: 'Mock Service',
      serviceDuration: 60,
      bookingEnd: DateTime(now.year, now.month, now.day, 23, 0),
      bookingStart: DateTime(now.year, now.month, now.day, 8, 0),
    );
  }

  // Function to get booking stream for the current user
  Stream<List<DocumentSnapshot>> getBookingStreamMock(
      {required DateTime end, required DateTime start}) {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('combined_bookings')
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  // Function to upload booking for the current user
  Future<void> uploadBookingMock({required BookingService newBooking}) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    try {
      // Create a map with the booking data including userId
      Map<String, dynamic> bookingData = {
        'userId': userId,
        'facility': widget.formData.facility,
        'sport': widget.formData.sport,
        'bookingStart': newBooking.bookingStart,
        'bookingEnd': newBooking.bookingEnd,
        'status': 'pending',
      };

      // Add the booking data to Firestore
      await FirebaseFirestore.instance
          .collection('combined_bookings')
          .add(bookingData);
      print('${newBooking.toJson()} has been uploaded to Firestore');
    } catch (e) {
      print('Failed to upload booking data to Firestore: $e');
    }
  }

  List<DateTimeRange> convertStreamResultMock({required dynamic streamResult}) {
    List<DateTimeRange> bookedSlots = [];
    for (var booking in streamResult) {
      DateTime start = (booking['bookingStart'] as Timestamp).toDate();
      DateTime end = (booking['bookingEnd'] as Timestamp).toDate();
      bookedSlots.add(DateTimeRange(start: start, end: end));
    }
    return bookedSlots;
  }

  List<DateTimeRange> generatePauseSlots() {
    return [
      DateTimeRange(
        start: DateTime(now.year, now.month, now.day, 12, 0),
        end: DateTime(now.year, now.month, now.day, 13, 0),
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<DocumentSnapshot>>(
      stream: getBookingStreamMock(
          end: mockBookingService.bookingEnd,
          start: mockBookingService.bookingStart),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<DateTimeRange> bookedSlots =
              convertStreamResultMock(streamResult: snapshot.data);
          return SizedBox(
            height: 600, // Adjust height as needed
            child: BookingCalendar(
              bookingService: mockBookingService,
              convertStreamResultToDateTimeRanges:
                  ({required dynamic streamResult}) => bookedSlots,
              getBookingStream: getBookingStreamMock,
              uploadBooking: uploadBookingMock,
              pauseSlots: generatePauseSlots(),
              pauseSlotText: 'LUNCH',
              hideBreakTime: false,
              loadingWidget: const Text('Fetching data...'),
              uploadingWidget: const CircularProgressIndicator(),
              locale: 'en_US', // Changed locale to 'en_US' for English
              startingDayOfWeek: StartingDayOfWeek.tuesday,
              wholeDayIsBookedWidget:
                  const Text('Sorry, for this day everything is booked'),
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
