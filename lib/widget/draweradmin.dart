import 'package:flutter/material.dart';
import 'package:fyp_2/screen/admin/managebooking.dart';
import 'package:fyp_2/screen/admin/managefacility.dart';
import 'package:fyp_2/screen/admin/managesports.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 248, 215, 106),
            ),
            child: Text(
              'UTM Sports Booking Management',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            title: const Text('Manage Booking'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>const BookingManagement(),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Manage Sports'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManageSports(),
                ),
              );
            },
          ),
             ListTile(
            title: const Text('Manage Facility'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManageFacilities(),
                ),
              );
            },
          ),
          // Add more list tiles for additional items
        ],
      ),
    );
  }
}
