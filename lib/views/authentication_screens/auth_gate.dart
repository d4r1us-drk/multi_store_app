import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

import '../main_screen.dart';
import '../vendor_screens/landing_screen.dart';

class AuthGate extends StatelessWidget {
  final String userType;

  const AuthGate({super.key, required this.userType});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      initialData: FirebaseAuth.instance.currentUser,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SignInScreen(
            providers: [EmailAuthProvider()],
          );
        }

        // Check if user is vendor or buyer and handle Firestore data accordingly
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection(userType == 'vendor' ? 'vendors' : 'buyers')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .get(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            // If user is not registered, show the custom registration form
            if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
              return LandingScreen();
            }

            // If registered, navigate to the appropriate landing page
            return userType == 'vendor' ? LandingScreen() : MainScreen();
          },
        );
      },
    );
  }
}
