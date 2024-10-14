import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:multi_store_app/views/vendor_screens/landing_screen.dart';
import 'package:multi_store_app/views/vendor_screens/registration_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      // If the user is already signed-in, use it as initial data
      initialData: FirebaseAuth.instance.currentUser,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          // User is not signed in
          return SignInScreen(
            providers: [EmailAuthProvider()],
          );
        }

        // Check if the vendor exists in the Firestore collection
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('vendors')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .get(),
          builder: (context, vendorSnapshot) {
            if (vendorSnapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            // If the vendor doesn't exist, show the registration screen
            if (!vendorSnapshot.hasData || !vendorSnapshot.data!.exists) {
              return const RegistrationScreen();
            }

            // If the vendor is found, continue to the landing screen
            return LandingScreen();
          },
        );
      },
    );
  }
}
