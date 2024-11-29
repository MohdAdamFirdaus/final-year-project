import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageFacilities extends StatefulWidget {
  const ManageFacilities({super.key});

  @override
  _ManageFacilitiesState createState() => _ManageFacilitiesState();
}

class _ManageFacilitiesState extends State<ManageFacilities> {
  final TextEditingController _nameController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _editingFacilityId;
  bool _isLoading = false;

  Future<void> _addFacility() async {
    if (_nameController.text.isEmpty) {
      _showSnackBar('Facility name cannot be empty');
      return;
    }

    bool confirmed = await _showConfirmationDialog(
      context,
      'Add Facility',
      'Are you sure you want to add this facility?',
    );

    if (confirmed) {
      setState(() {
        _isLoading = true;
      });
      await _firestore.collection('facility').add({'name': _nameController.text});
      _nameController.clear();
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Facility added successfully');
    }
  }

  Future<void> _updateFacility() async {
    if (_nameController.text.isEmpty || _editingFacilityId == null) {
      _showSnackBar('Facility name cannot be empty');
      return;
    }

    bool confirmed = await _showConfirmationDialog(
      context,
      'Update Facility',
      'Are you sure you want to update this facility?',
    );

    if (confirmed) {
      setState(() {
        _isLoading = true;
      });
      await _firestore.collection('facility').doc(_editingFacilityId).update({'name': _nameController.text});
      _nameController.clear();
      setState(() {
        _editingFacilityId = null;
        _isLoading = false;
      });
      _showSnackBar('Facility updated successfully');
    }
  }

  Future<void> _deleteFacility(String id) async {
    bool confirmed = await _showConfirmationDialog(
      context,
      'Delete Facility',
      'Are you sure you want to delete this facility?',
    );

    if (confirmed) {
      setState(() {
        _isLoading = true;
      });
      await _firestore.collection('facility').doc(id).delete();
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Facility deleted successfully');
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
        title: const Text('Manage Facilities'),
        backgroundColor: const Color.fromARGB(255, 248, 215, 106),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: _editingFacilityId == null ? 'Add New Facility' : 'Edit Facility Name'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _editingFacilityId == null ? _addFacility : _updateFacility,
                  child: Text(_editingFacilityId == null ? 'Add Facility' : 'Update Facility'),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _firestore.collection('facility').snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      }
                      var facilities = snapshot.data!.docs;
                      return ListView.builder(
                        itemCount: facilities.length,
                        itemBuilder: (context, index) {
                          var facility = facilities[index];
                          var facilityName = facility['name'];
                          var facilityId = facility.id;
                          return ListTile(
                            title: Text(facilityName),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    _showEditDialog(facilityId, facilityName);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    _deleteFacility(facilityId);
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

  void _showEditDialog(String facilityId, String currentName) {
    _nameController.text = currentName;
    setState(() {
      _editingFacilityId = facilityId;
    });
  }
}
