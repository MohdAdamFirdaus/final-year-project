import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isEmailVerified = false;
  String _profileImageUrl = '';
  bool _isEditing = false;
  File? _image;
  bool _isUploading = false;
  User? _user;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    _user = _auth.currentUser;
    if (_user != null) {
      await _user!.reload();
      _user = _auth.currentUser; // Refresh the user object
      setState(() {
        _displayNameController.text = _user!.displayName ?? '';
        _emailController.text = _user!.email ?? '';
        _isEmailVerified = _user!.emailVerified;
        _profileImageUrl = _user!.photoURL ?? '';
      });
    }
  }

  Future<void> _saveProfile() async {
    try {
      if (_image != null) {
        await _uploadImageToFirebase();
      }
      await _auth.currentUser!.updateDisplayName(_displayNameController.text.trim());
      await _auth.currentUser!.updateEmail(_emailController.text.trim());
      setState(() {
        _isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully')));
    } catch (e) {
      print('Error updating profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update profile: $e')));
    }
  }

  Future<void> _sendEmailVerification() async {
    try {
      await _auth.currentUser!.sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Verification email sent')));
    } catch (e) {
      print('Error sending verification email: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send verification email: $e')));
    }
  }

  Future<void> _pickImage(ImageSource source) async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: source);

  if (pickedFile != null) {
    setState(() {
      _image = File(pickedFile.path);
    });

    await _uploadImageToFirebase();
  }
}

Future<void> _uploadImageToFirebase() async {
  try {
    if (_image == null) return;

    setState(() {
      _isUploading = true;
    });

    // Upload image to Firebase Storage
    final Reference ref = FirebaseStorage.instance.ref().child('profile_images/${_auth.currentUser!.uid}');
    await ref.putFile(_image!);
    
    // Get download URL
    final String imageUrl = await ref.getDownloadURL();

    // Update user's profile with the image URL
    await _auth.currentUser!.updatePhotoURL(imageUrl);

    setState(() {
      _profileImageUrl = imageUrl;
      _isUploading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image uploaded successfully')));
  } catch (e) {
    print('Error uploading image to Firebase Storage: $e');
    setState(() {
      _isUploading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to upload image: $e')));
  }
}


  Future<void> _deleteAccount() async {
    try {
      await _auth.currentUser!.delete();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account deleted')));
      // Navigate to the login screen or another screen after account deletion
    } catch (e) {
      print('Error deleting account: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete account: $e')));
    }
  }

  Future<void> _confirmDeleteAccount() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete Account'),
          content: const Text('Are you sure you want to delete your account? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteAccount();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _changePassword() async {
    if (_user != null && _user!.email != null) {
      await _auth.sendPasswordResetEmail(email: _user!.email!);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password reset email sent')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color.fromARGB(255, 248, 215, 106),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: _image != null
                          ? FileImage(_image!)
                          : _profileImageUrl.isNotEmpty
                              ? NetworkImage(_profileImageUrl)
                              : const AssetImage('lib/assets/default_profile.png') as ImageProvider,
                      backgroundColor: Colors.grey[300],
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => _pickImage(ImageSource.gallery),
                        child: const CircleAvatar(
                          backgroundColor: Colors.blue,
                          radius: 20,
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 20.0),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    setState(() {
                      _isEditing = true;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            if (_isUploading)
              const Center(child: CircularProgressIndicator())
            else if (_isEditing)
              Column(
                children: [
                  TextField(
                    controller: _displayNameController,
                    decoration: InputDecoration(
                      labelText: 'Display Name',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _displayNameController.clear(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _emailController.clear(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: _saveProfile,
                    child: const Text('Save Profile'),
                  ),
                ],
              )
            else
              Column(
                children: [
                  Text(
                    _displayNameController.text,
                    style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10.0),
                  Text(
                    'Email: ${_user?.email ?? 'N/A'}',
                    style: const TextStyle(fontSize: 16.0),
                  ),
                  const SizedBox(height: 10.0),
                  Text(
                    'Password: ${'*' * 8}', // Display 8 asterisks as a placeholder
                    style: const TextStyle(fontSize: 16.0),
                  ),
                  const SizedBox(height: 20.0),
                  if (!_isEmailVerified && _auth.currentUser != null)
                    ElevatedButton(
                      onPressed: _sendEmailVerification,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300], // Background color
                      ),
                      child: const Text(
                        'Send Verification Email',
                        style: TextStyle(color: Colors.black), // Text color
                      ),
                    ),
                  const SizedBox(height: 10.0),
                  ElevatedButton(
                    onPressed: _changePassword,
                    child: const Text('Change Password'),
                  ),
                  const SizedBox(height: 10.0),
                  ElevatedButton(
                    onPressed: _confirmDeleteAccount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, // Background color
                    ),
                    child: const Text(
                      'Delete Account',
                      style: TextStyle(color: Colors.white), // Text color
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
