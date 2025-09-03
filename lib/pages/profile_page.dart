import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb; // To check if we are on the web
import 'package:flutter/material.dart';
import 'dart:typed_data'; // Required for web image data
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'home_page.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // State variables
  Uint8List? _imageBytes; // For web image data
  File? _imageFile; // For mobile image file
  String? _imageUrl; // For the final URL from Firebase
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  // Text field controllers
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        setState(() {
          _nameController.text = data['name'] ?? '';
          _dobController.text = data['dob'] ?? '';
          _phoneController.text = data['phone'] ?? '';
          _addressController.text = data['address'] ?? '';
          _imageUrl = data['profileImageUrl'];
        });
      }
    }
  }

  // UPDATED: This function now handles web and mobile differently
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source, imageQuality: 50);
    if (pickedFile != null) {
      if (kIsWeb) {
        // For web, read the image data as bytes
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _imageFile = null; // Clear mobile file if it exists
        });
      } else {
        // For mobile, create a File object from the path
        setState(() {
          _imageFile = File(pickedFile.path);
          _imageBytes = null; // Clear web bytes if they exist
        });
      }
    }
  }

  void _showImageSourceDialog() {
    // ... This function remains the same
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Select Image Source"),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.camera_alt),
            label: const Text("Camera"),
            onPressed: () {
              Navigator.of(context).pop();
              _pickImage(ImageSource.camera);
            },
          ),
          TextButton.icon(
            icon: const Icon(Icons.photo_library),
            label: const Text("Gallery"),
            onPressed: () {
              Navigator.of(context).pop();
              _pickImage(ImageSource.gallery);
            },
          ),
        ],
      ),
    );
  }

  // UPDATED: This function now uploads data or a file based on the platform
  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User is not logged in.");
      }

      // Check if a new image was picked
      if (_imageFile != null || _imageBytes != null) {
        final storageRef = FirebaseStorage.instance.ref().child('profile_pictures').child('${user.uid}.jpg');

        if (kIsWeb) {
          // For web, upload the byte data
          await storageRef.putData(_imageBytes!);
        } else {
          // For mobile, upload the file
          await storageRef.putFile(_imageFile!);
        }
        _imageUrl = await storageRef.getDownloadURL();
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': _nameController.text,
        'dob': _dobController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
        'profileImageUrl': _imageUrl,
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile Saved!')));
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomePage()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An error occurred: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  // Helper function to determine the correct image provider
  ImageProvider _getImageProvider() {
    if (_imageBytes != null) {
      return MemoryImage(_imageBytes!); // New image from web
    }
    if (_imageFile != null) {
      return FileImage(_imageFile!); // New image from mobile
    }
    if (_imageUrl != null && _imageUrl!.isNotEmpty) {
      return NetworkImage(_imageUrl!); // Existing image from Firebase
    }
    return const NetworkImage('https://via.placeholder.com/150'); // Placeholder
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.green.shade800,
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: Stack(
        children: [
          FloatingActionButton.extended(
            onPressed: _isLoading ? null : _saveProfile,
            label: const Text("Save & Continue"),
            icon: const Icon(Icons.check),
            backgroundColor: _isLoading ? Colors.grey : Colors.green.shade700,
          ),
          if (_isLoading)
            const Positioned.fill(
              child: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: _getImageProvider(), // Use the helper function here
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.green.shade700,
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.white),
                      onPressed: _showImageSourceDialog,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: _dobController, decoration: const InputDecoration(labelText: 'Date of Birth', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: _addressController, decoration: const InputDecoration(labelText: 'Address', border: OutlineInputBorder())),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}




