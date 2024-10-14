import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:multi_store_app/controllers/auth_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthController _authController = AuthController();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();

  bool _isLoading = false;
  File? _imageFile;
  String? _profileImageUrl;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    _loadUserData();
  }

  // Load user data from Firestore and FirebaseAuth
  void _loadUserData() async {
    if (_currentUser != null) {
      // Fetch data from Firestore
      DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection('buyers')
          .doc(_currentUser!.uid)
          .get();

      // Pre-populate fields with existing data (if available)
      nameController.text = userData['fullName'] ?? "";
      emailController.text =
          _currentUser!.email ?? ""; // Fetch email from FirebaseAuth
      phoneController.text = userData['phone'] ?? "";
      bioController.text = userData['bio'] ?? "";
      cityController.text = userData['city'] ?? "";
      stateController.text = userData['state'] ?? "";
      _profileImageUrl = userData['profileImage'];

      setState(() {});
    }
  }

  // Method to select a profile picture
  Future<void> _selectProfilePicture() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _imageFile = File(result.files.single.path!); // Load the selected image
      });
    }
  }

  // Method to update user profile
  Future<void> _updateProfile() async {
    setState(() {
      _isLoading = true;
    });

    // Upload new profile picture only if an image is selected
    if (_imageFile != null) {
      String fileName = "${_currentUser!.uid}_profile.jpg";
      _profileImageUrl =
          await _authController.uploadProfilePicture(_imageFile!, fileName);
    }

    // Update email in FirebaseAuth if it has changed
    if (_currentUser!.email != emailController.text) {
      try {
        await _currentUser!.verifyBeforeUpdateEmail(emailController.text);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error updating email: $e")),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }
    }

    // Update Firestore user data
    await FirebaseFirestore.instance
        .collection('buyers')
        .doc(_currentUser!.uid)
        .update({
      'fullName': nameController.text,
      'email': emailController.text, // Store email in Firestore as well
      'phone': phoneController.text,
      'bio': bioController.text,
      'city': cityController.text,
      'state': stateController.text,
      if (_profileImageUrl != null)
        'profileImage':
            _profileImageUrl, // Only update profileImage if not null
    });

    setState(() {
      _isLoading = false;
      _imageFile = null; // Clear the selected image
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Account"),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Picture
                    Center(
                      child: Stack(
                        children: [
                          _imageFile != null
                              ? CircleAvatar(
                                  radius: 50,
                                  backgroundImage: FileImage(
                                      _imageFile!), // Display selected image
                                )
                              : _profileImageUrl != null &&
                                      _profileImageUrl!.isNotEmpty
                                  ? CircleAvatar(
                                      radius: 50,
                                      backgroundImage:
                                          CachedNetworkImageProvider(
                                              _profileImageUrl!),
                                    )
                                  : const CircleAvatar(
                                      radius: 50,
                                      backgroundImage:
                                          AssetImage('assets/icons/user.png'),
                                    ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: IconButton(
                              icon: const Icon(Icons.camera_alt),
                              onPressed: _selectProfilePicture,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Full Name
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: "Full Name",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Email
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Phone
                    TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: "Phone",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Bio
                    TextFormField(
                      controller: bioController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: "Bio",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // City
                    TextFormField(
                      controller: cityController,
                      decoration: const InputDecoration(
                        labelText: "City",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // State
                    TextFormField(
                      controller: stateController,
                      decoration: const InputDecoration(
                        labelText: "State",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Update Button
                    Center(
                      child: ElevatedButton(
                        onPressed: _updateProfile,
                        child: const Text("Update Profile"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
