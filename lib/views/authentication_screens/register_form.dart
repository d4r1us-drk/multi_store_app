import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../../models/buyer_model.dart';
import '../../models/vendor_model.dart';

class RegisterForm extends StatefulWidget {
  final String userType;
  const RegisterForm({super.key, required this.userType});

  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  String? _fullName,
      _businessName,
      _city,
      _state,
      _country,
      _email,
      _phoneNumber,
      _rnc,
      _tax,
      _address;
  File? _selectedImage;

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      final user = FirebaseAuth.instance.currentUser;
      final userId = user!.uid;

      try {
        // Upload image if available
        String? imageUrl;
        if (_selectedImage != null) {
          final ref = FirebaseStorage.instance
              .ref()
              .child('${widget.userType}_images')
              .child('$userId.jpg');
          await ref.putFile(_selectedImage!);
          imageUrl = await ref.getDownloadURL();
        }

        final userData = widget.userType == 'vendor'
            ? VendorModel(
                vendorId: userId,
                approved: false,
                businessName: _businessName!,
                city: _city!,
                state: _state!,
                country: _country!,
                email: _email!,
                phoneNumber: _phoneNumber!,
                imageUrl: imageUrl ?? '',
                rnc: _rnc!,
                tax: _tax!,
              ).toJson()
            : BuyerModel(
                buyerId: userId,
                fullName: _fullName!,
                email: _email!,
                phoneNumber: _phoneNumber!,
                address: _address!,
              ).toJson();

        await FirebaseFirestore.instance
            .collection(widget.userType == 'vendor' ? 'vendors' : 'buyers')
            .doc(userId)
            .set(userData);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
              '${widget.userType.replaceFirst(widget.userType[0], widget.userType[0].toUpperCase())} Registration')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              widget.userType == 'vendor'
                  ? _buildTextField(
                      'Business Name', (value) => _businessName = value)
                  : _buildTextField('Full Name', (value) => _fullName = value),
              _buildTextField('Email', (value) => _email = value,
                  TextInputType.emailAddress),
              _buildTextField('Phone Number', (value) => _phoneNumber = value,
                  TextInputType.phone),
              widget.userType == 'vendor'
                  ? _buildTextField('RNC', (value) => _rnc = value)
                  : _buildTextField('Address', (value) => _address = value),
              widget.userType == 'vendor'
                  ? Column(children: [
                      _buildTextField('City', (value) => _city = value),
                      _buildTextField('State', (value) => _state = value),
                      _buildTextField('Country', (value) => _country = value),
                      _buildTextField('Tax', (value) => _tax = value),
                      _buildImagePicker(),
                    ])
                  : Container(),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, Function(String?) onSaved,
      [TextInputType keyboardType = TextInputType.text]) {
    return TextFormField(
      decoration: InputDecoration(labelText: label),
      keyboardType: keyboardType,
      onSaved: onSaved,
      validator: (value) =>
          value == null || value.isEmpty ? 'Field is required' : null,
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: () async {
        FilePickerResult? result =
            await FilePicker.platform.pickFiles(type: FileType.image);
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
          border: Border.all(color: Colors.grey[400]!),
        ),
        child: _selectedImage != null
            ? Image.file(_selectedImage!, fit: BoxFit.cover)
            : const Center(child: Icon(Icons.add_a_photo, size: 40)),
      ),
    );
  }
}
