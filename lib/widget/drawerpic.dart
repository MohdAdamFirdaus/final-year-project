import 'package:flutter/material.dart';
import 'package:fyp_2/screen/sportspic/group_randomizer.dart';

import 'package:fyp_2/screen/sportspic/manage_tournament.dart';
import 'package:fyp_2/screen/sportspic/managescore.dart';
import 'package:fyp_2/screen/sportspic/match_randomizer.dart';

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
              'UTM Sports Tournament Management',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            title: const Text('Manage Tournament'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>const TournamentManagement(),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Group Management'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>const GroupRandomizer(),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Manage Matches'),
            onTap: (){
             Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>const MatchRandomizer(),
                ),
              );
            },
          ),
            ListTile(
            title: const Text('Manage Score'),
            onTap: (){
             Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>const ScoreManagementScreen(),
                ),
              );
            },
          ),
          //    ListTile(
          //   title: Text('Manage Facility'),
          //   onTap: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) => ManageFacilities(),
          //       ),
          //     );
          //   },
          // ),
          // Add more list tiles for additional items
        ],
      ),
    );
  }
}
