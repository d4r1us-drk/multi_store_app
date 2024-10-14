import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:multi_store_app/models/vendor_model.dart';
import 'package:multi_store_app/views/vendor_screens/main_vendor_screen.dart';
import 'package:multi_store_app/views/vendor_screens/registration_screen.dart';

class LandingScreen extends StatelessWidget {
  LandingScreen({super.key});

  final CollectionReference _vendorCollection =
      FirebaseFirestore.instance.collection('vendors');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: _vendorCollection
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // If vendor doesn't exist, send to registration screen
          if (!snapshot.data!.exists) {
            return const RegistrationScreen();
          }

          VendorModel vendor = VendorModel.fromJson(
              snapshot.data!.data() as Map<String, dynamic>);

// Check if vendor is approved
          if (!vendor.approved) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: vendor.imageUrl != null && vendor.imageUrl.isNotEmpty
                        ? Image.network(
                            vendor.imageUrl,
                            width: 90,
                            fit: BoxFit.cover,
                          )
                        : const Icon(
                            Icons.store, // Use an icon as a placeholder
                            size: 90,
                            color: Colors.grey,
                          ),
                  ),
                  const SizedBox(height: 20),
                  Text(vendor.businessName),
                  const SizedBox(height: 10),
                  const Text("Your application has been submitted."),
                  const SizedBox(height: 10),
                  const Text("Waiting for approval..."),
                  TextButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                    },
                    child: const Text("Sign out"),
                  ),
                ],
              ),
            );
          }

          // If approved, go to the main screen (dashboard)
          return MainVendorScreen();
        },
      ),
    );
  }
}
