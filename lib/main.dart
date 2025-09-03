import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/auth_gate.dart'; // Make sure this path is correct

void main() async {
  // These two lines are essential for Firebase to work
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // This is the root of your application
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthGate(), // This is the starting point for your app's UI
    );
  }
}