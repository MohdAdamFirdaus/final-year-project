
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fyp_2/screen/booking.dart';
import 'package:fyp_2/screen/groupdata.dart';
import 'package:fyp_2/screen/history.dart';
import 'package:fyp_2/screen/home.dart';
import 'package:fyp_2/screen/login.dart';
import 'package:fyp_2/screen/match.dart';
import 'package:fyp_2/screen/profilescreen.dart';
import 'package:fyp_2/widget/notification.dart';

class Bottom extends StatefulWidget {
  const Bottom({super.key});

  @override
  State<Bottom> createState() => _BottomState();
}

class _BottomState extends State<Bottom> {
  int index_color = 0;
  List<Widget> screens = [
    const UserDashboardApp(),
    BookingHistoryScreen(),
    const Mytab(),
    const UserNotifications(),
    const ProfilePage(),

  ];

  // Function to handle sign-out
  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      // Navigate back to the sign-in or home screen after sign-out
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginPage()));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Signed out successfully')));
    } catch (e) {
      print('Error signing out: $e');
      // Handle sign-out error
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error signing out: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("UTM Sports Booking System"),
        backgroundColor: const Color.fromARGB(255, 248, 215, 106),
        actions: [
          // Pop-up menu button for group data
          PopupMenuButton<int>(
            icon: const Icon(Icons.list),
            onSelected: (value) {
              if (value == 0) {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const GroupDataPage()),
                );
              }
              if (value == 1) {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const MatchDataPage()),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 0,
                child: Text("Group Data"),
              ),
              const PopupMenuItem(
                value: 1,
                child: Text("Matches Data"),
              ),
            ],
          ),
          // Sign-out button
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: screens[index_color],
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Padding(
          padding: const EdgeInsets.only(top: 7.5, bottom: 7.5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // GestureDetector widgets for bottom navigation items
              GestureDetector(
                onTap: () {
                  setState(() {
                    index_color = 0;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Home')));
                },
                child: Tooltip(
                  message: 'Home',
                  child: Icon(
                    Icons.home,
                    size: 30,
                    color: index_color == 0
                        ? const Color.fromARGB(255, 185, 181, 46)
                        : const Color.fromARGB(255, 128, 107, 3),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    index_color = 1;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('History')));
                },
                child: Tooltip(
                  message: 'History',
                  child: Icon(
                    Icons.history,
                    size: 30,
                    color: index_color == 1
                        ? const Color.fromARGB(255, 185, 181, 46)
                        : const Color.fromARGB(255, 128, 107, 3),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    index_color = 2;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add')));
                },
                child: Tooltip(
                  message: 'Add Booking',
                  child: Icon(
                    Icons.add,
                    size: 30,
                    color: index_color == 2
                        ? const Color.fromARGB(255, 185, 181, 46)
                        : const Color.fromARGB(255, 128, 107, 3),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    index_color = 3;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notifications')));
                },
                child: Tooltip(
                  message: 'Notifications',
                  child: Icon(
                    Icons.notifications_active,
                    size: 30,
                    color: index_color == 3
                        ? const Color.fromARGB(255, 185, 181, 46)
                        : const Color.fromARGB(255, 128, 107, 3),
                  ),
                ),
              ),
            GestureDetector(
                onTap: () {
                  setState(() {
                    index_color = 4;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile')));
                },
                child: Tooltip(
                  message: 'Profile',
                  child: Icon(
                    Icons.person,
                    size: 30,
                    color: index_color == 3
                        ? const Color.fromARGB(255, 185, 181, 46)
                        : const Color.fromARGB(255, 128, 107, 3),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
