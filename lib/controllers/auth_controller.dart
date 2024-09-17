import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AuthController {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  Future<String> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return "success";
    } catch (e) {
      return e.toString();
    }
  }

  // Method to register a new user
  Future<String> registerNewUser(
      String name, String email, String password) async {
    String response = "Something went wrong";

    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Upload the user data to the database
      await _firebaseFirestore
          .collection('buyers')
          .doc(userCredential.user!.uid)
          .set({
        'fullName': name,
        'profileImage': "",
        'email': email,
        'uid': userCredential.user!.uid,
        'city': "",
        'state': "",
      });
      response = 'success';
    } catch (e) {
      response = e.toString();
    }

    return response;
  }

  // Method to log in a user
  Future<String> loginUser(String email, String password) async {
    String response = "Something went wrong";

    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      response = 'success';
    } catch (e) {
      response = e.toString();
    }

    return response;
  }

  // Method to upload profile picture to Firebase Storage
  Future<String> uploadProfilePicture(File imageFile, String fileName) async {
    try {
      // Upload the image to Firebase Storage
      Reference ref = _firebaseStorage.ref().child('profileImages/$fileName');
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Error uploading profile picture: $e');
    }
  }
}
