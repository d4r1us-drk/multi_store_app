import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:multi_store_app/views/authentication_screens/login_screen.dart';

// For security reasons the Firebase config is loaded from an .env file
// in the root of the project directory. You must create a .env file
// like the following:
//
//   FIREBASE_API_KEY="your-api-key"
//   FIREBASE_APP_ID="your-app-id"
//   FIREBASE_MESSAGING_SENDER_ID="your-sender-id"
//   FIREBASE_PROJECT_ID="your-project-id"
//   FIREBASE_STORAGE_BUCKET="your-storage-bucket"
//
// Then add it to pubspec.yaml assets:
//
//   assets:
//     - .env
//
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from the .env file
  await dotenv.load(fileName: ".env");

  // Use environment variables to initialize Firebase
  if (Platform.isAndroid) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: dotenv.env['FIREBASE_API_KEY']!,
        appId: dotenv.env['FIREBASE_APP_ID']!,
        messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID']!,
        projectId: dotenv.env['FIREBASE_PROJECT_ID']!,
        storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET']!,
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );
    return const MaterialApp(
      title: 'Multi Store App',
      home: LoginScreen(),
    );
  }
}
