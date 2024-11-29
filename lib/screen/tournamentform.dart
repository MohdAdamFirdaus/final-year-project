import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tournament Registration',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TournamentForm(),
    );
  }
}

class TournamentForm extends StatefulWidget {
  const TournamentForm({super.key});

  @override
  _TournamentFormState createState() => _TournamentFormState();
}

class _TournamentFormState extends State<TournamentForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _dateController;
  late TextEditingController _teamNameController;
  final List<TextEditingController> _participantControllers = [];
  String? _selectedTournament;
  String? _selectedSport;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController();
    _teamNameController = TextEditingController();
    _participantControllers.add(TextEditingController());
  }

  @override
  void dispose() {
    _dateController.dispose();
    _teamNameController.dispose();
    for (var controller in _participantControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  void _addParticipant() {
    setState(() {
      _participantControllers.add(TextEditingController());
    });
  }

  void _clearFields() {
    setState(() {
      _dateController.clear();
      _teamNameController.clear();
      _participantControllers.clear();
      _participantControllers.add(TextEditingController());
      _selectedTournament = null;
      _selectedSport = null;
      _errorMessage = null;
    });
  }

  Future<void> _storeTournamentData() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('No user logged in');
      }

      // Set the initial status to pending
      String status = 'pending';

      // Store tournament data
      DocumentReference docRef = await firestore.collection('tournaments').add({
        'userId': user.uid, // Include userId
        'teamName': _teamNameController.text,
        'date': _dateController.text,
        'tournament': _selectedTournament,
        'sport': _selectedSport,
        'participants': _participantControllers.map((controller) => controller.text).toList(),
        'status': status,
      });

      print('Document added with ID: ${docRef.id}');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tournament registered successfully')),
      );

      _clearFields();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error storing tournament data: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tournament Registration'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  controller: _teamNameController,
                  decoration: const InputDecoration(labelText: 'Team Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the team name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _dateController,
                  decoration: InputDecoration(
                    labelText: 'Date',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () => _selectDate(context),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please pick a date';
                    }
                    return null;
                  },
                  readOnly: true,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedTournament,
                  decoration: const InputDecoration(labelText: 'Select Tournament'),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedTournament = newValue;
                    });
                  },
                  items: <String>['Tournament A', 'Tournament B', 'Tournament C']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a tournament';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('sports').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Text('Loading...');
                    }

                    List<String> sports = snapshot.data!.docs.map((doc) => doc['name'] as String).toList();

                    return DropdownButtonFormField<String>(
                      value: _selectedSport,
                      decoration: const InputDecoration(labelText: 'Select Sport'),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedSport = newValue;
                        });
                      },
                      items: sports
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a sport';
                        }
                        return null;
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Participant Names:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: _participantControllers.length,
                  itemBuilder: (context, index) {
                    return TextFormField(
                      controller: _participantControllers[index],
                      decoration: InputDecoration(
                        labelText: 'Participant ${index + 1}',
                        suffixIcon: index == _participantControllers.length - 1
                            ? IconButton(
                                onPressed: _addParticipant,
                                icon: const Icon(Icons.add),
                              )
                            : null,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the participant name';
                        }
                        return null;
                      },
                    );
                  },
                ),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _storeTournamentData();
                        } else {
                          setState(() {
                            _errorMessage = 'Please fill out all fields correctly';
                          });
                        }
                      },
                      child: const Text('Submit Tournament'),
                    ),
                    ElevatedButton(
                      onPressed: _clearFields,
                      child: const Text('Clear Fields'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
