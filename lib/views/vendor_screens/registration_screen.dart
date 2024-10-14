import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  File? _selectedImage;
  String? _businessName,
      _city,
      _state,
      _country,
      _email,
      _phoneNumber,
      _rnc,
      _tax;
  bool _isSubmitting = false;

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Vendor'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Vendor Registration',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                _buildTextField(
                  label: 'Business Name',
                  onSaved: (value) => _businessName = value,
                  validator: _validateRequired,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'City',
                  onSaved: (value) => _city = value,
                  validator: _validateRequired,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'State',
                  onSaved: (value) => _state = value,
                  validator: _validateRequired,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Country',
                  onSaved: (value) => _country = value,
                  validator: _validateRequired,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Email',
                  onSaved: (value) => _email = value,
                  validator: _validateEmail,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Phone Number',
                  onSaved: (value) => _phoneNumber = value,
                  validator: _validatePhoneNumber,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'RNC',
                  onSaved: (value) => _rnc = value,
                  validator: _validateRequired,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Country Tax Rate',
                  onSaved: (value) => _tax = value,
                  validator: _validateRequired,
                ),
                const SizedBox(height: 16),
                _buildImagePicker(),
                const SizedBox(height: 24),
                if (_isSubmitting) ...[
                  const Center(child: CircularProgressIndicator()),
                ] else ...[
                  Center(
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text('Submit Application'),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      FirebaseAuth.instance.signOut();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                    ),
                    child: const Text('Log out'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Function to build a text field
  Widget _buildTextField({
    required String label,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    Function(String?)? onSaved,
  }) {
    return TextFormField(
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: validator,
      onSaved: onSaved,
    );
  }

  // Widget for the image picker
  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Upload Image",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            FilePickerResult? result = await FilePicker.platform.pickFiles(
              type: FileType.image,
            );
            if (result != null) {
              setState(() {
                _selectedImage = File(result.files.single.path!);
              });
            }
          },
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey[400]!,
              ),
            ),
            child: _selectedImage != null
                ? Image.file(
                    _selectedImage!,
                    fit: BoxFit.cover,
                  )
                : const Center(
                    child: Icon(
                      Icons.add_a_photo,
                      color: Colors.grey,
                      size: 40,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  // Submit form logic
  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      setState(() {
        _isSubmitting = true;
      });

      try {
        // Ensure the user is authenticated
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('User not authenticated! Please sign in.')),
          );
          return;
        }

        // Upload the image if one is selected
        String? imageUrl;
        if (_selectedImage != null) {
          final ref = FirebaseStorage.instance
              .ref()
              .child('vendor_images')
              .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
          await ref.putFile(_selectedImage!);
          imageUrl = await ref.getDownloadURL();
        }

        // Use the authenticated user's UID as the vendorId
        final vendorId = user.uid;
        final vendorData = {
          'vendorId': vendorId,
          'approved': false, // default status for new vendors
          'businessName': _businessName,
          'city': _city,
          'state': _state,
          'country': _country,
          'email': _email,
          'phoneNumber': _phoneNumber,
          'imageUrl': imageUrl ?? '',
          'rnc': _rnc,
          'tax': _tax,
        };

        // Save the vendor to Firestore
        await _firestore.collection('vendors').doc(vendorId).set(vendorData);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vendor registration successful!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit: $e')),
        );
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  // Validators
  String? _validateRequired(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
      return 'Enter a valid phone number';
    }
    return null;
  }
}
