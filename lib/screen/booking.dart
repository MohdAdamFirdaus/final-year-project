import 'package:flutter/material.dart';
import 'package:fyp_2/screen/bookingform.dart';
import 'package:fyp_2/screen/tournamentform.dart';
import 'package:fyp_2/widget/bottomnav.dart';



void main() => runApp(const Mytab());

class Mytab extends StatelessWidget {
  const Mytab({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UTM Sports Booking System',
      home: Scaffold(
       appBar: AppBar(
        
        title: const Text("Booking and Tournament Form"),
        // backgroundColor: Colors.redAccent,
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
        body: const DefaultTabController(
          length: 2,
          child: Column(
            children: [
              TabBar(
                tabs: [
                  Tab(text: 'Booking'),
                  Tab(text: 'Tournament'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    MyCustomForm(),
                    TournamentForm(),
                 
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
