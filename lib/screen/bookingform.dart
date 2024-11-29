import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp_2/model/booking_form_data.dart';
import 'package:fyp_2/widget/availability.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: MyCustomForm(),
      ),
    );
  }
}

class MyCustomForm extends StatefulWidget {
  const MyCustomForm({super.key});

  @override
  MyCustomFormState createState() => MyCustomFormState();
}

class MyCustomFormState extends State<MyCustomForm> {
  String? selectedFacility;
  String? selectedSport;
  List<String> facilityList = [];
  List<String> sportsList = [];

  @override
  void initState() {
    super.initState();
    fetchFacilities();
    fetchSports();
  }

  Future<void> fetchFacilities() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('facility').get();
      List<String> facilities = querySnapshot.docs.map((doc) => doc['name'] as String).toList();
      setState(() {
        facilityList = facilities;
        selectedFacility = facilityList.isNotEmpty ? facilityList.first : null;
      });
    } catch (e) {
      print("Error fetching facilities: $e");
    }
  }

  Future<void> fetchSports() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('sports').get();
      List<String> sports = querySnapshot.docs.map((doc) => doc['name'] as String).toList();
      setState(() {
        sportsList = sports;
        selectedSport = sportsList.isNotEmpty ? sportsList.first : null;
      });
    } catch (e) {
      print("Error fetching sports: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Select the facility',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          facilityList.isNotEmpty
              ? DropdownButton<String>(
                  value: selectedFacility,
                  onChanged: (String? value) {
                    setState(() {
                      selectedFacility = value!;
                    });
                  },
                  items: facilityList.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                )
              : const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text(
            'Select the sport',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          sportsList.isNotEmpty
              ? DropdownButton<String>(
                  value: selectedSport,
                  onChanged: (String? value) {
                    setState(() {
                      selectedSport = value!;
                    });
                  },
                  items: sportsList.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                )
              : const CircularProgressIndicator(),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (selectedFacility != null && selectedSport != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookingCalendarDemoApp(
                      formData: BookingFormData(facility: selectedFacility!, sport: selectedSport!),
                    ),
                  ),
                );
              }
            },
            child: const Text('View Availability'),
          ),
        ],
      ),
    );
  }
}
