import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageSports extends StatefulWidget {
  const ManageSports({super.key});

  @override
  _ManageSportsState createState() => _ManageSportsState();
}

class _ManageSportsState extends State<ManageSports> {
  final TextEditingController _nameController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _editingSportId;
  bool _isLoading = false;

  Future<void> _addSport() async {
    if (_nameController.text.isEmpty) {
      _showSnackBar('Sport name cannot be empty');
      return;
    }

    bool confirmed = await _showConfirmationDialog(
      context,
      'Add Sport',
      'Are you sure you want to add this sport?',
    );

    if (confirmed) {
      setState(() {
        _isLoading = true;
      });
      await _firestore.collection('sports').add({'name': _nameController.text});
      _nameController.clear();
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Sport added successfully');
    }
  }

  Future<void> _updateSport() async {
    if (_nameController.text.isEmpty || _editingSportId == null) {
      _showSnackBar('Sport name cannot be empty');
      return;
    }

    bool confirmed = await _showConfirmationDialog(
      context,
      'Update Sport',
      'Are you sure you want to update this sport?',
    );

    if (confirmed) {
      setState(() {
        _isLoading = true;
      });
      await _firestore.collection('sports').doc(_editingSportId).update({'name': _nameController.text});
      _nameController.clear();
      setState(() {
        _editingSportId = null;
        _isLoading = false;
      });
      _showSnackBar('Sport updated successfully');
    }
  }

  Future<void> _deleteSport(String id) async {
    bool confirmed = await _showConfirmationDialog(
      context,
      'Delete Sport',
      'Are you sure you want to delete this sport?',
    );

    if (confirmed) {
      setState(() {
        _isLoading = true;
      });
      await _firestore.collection('sports').doc(id).delete();
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Sport deleted successfully');
    }
  }

  Future<bool> _showConfirmationDialog(BuildContext context, String title, String content) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    ) ?? false;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Sports'),
       backgroundColor:  const Color.fromARGB(255, 248, 215, 106),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: _editingSportId == null ? 'Add New Sport' : 'Edit Sport Name'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _editingSportId == null ? _addSport : _updateSport,
                  child: Text(_editingSportId == null ? 'Add Sport' : 'Update Sport'),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _firestore.collection('sports').snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      }
                      var sports = snapshot.data!.docs;
                      return ListView.builder(
                        itemCount: sports.length,
                        itemBuilder: (context, index) {
                          var sport = sports[index];
                          var sportName = sport['name'];
                          var sportId = sport.id;
                          return ListTile(
                            title: Text(sportName),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    _showEditDialog(sportId, sportName);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    _deleteSport(sportId);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  void _showEditDialog(String sportId, String currentName) {
    _nameController.text = currentName;
    setState(() {
      _editingSportId = sportId;
    });
  }
}

void main() {
  runApp(const MaterialApp(
    home: ManageSports(),
  ));
}
