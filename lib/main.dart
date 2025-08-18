// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:lumeno_app/auth_gate.dart'; // Import the new AuthGate
import 'package:lumeno_app/firebase_options.dart';

void main() async {
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
    return MaterialApp(
      title: 'LUMENO',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      // CHANGED: The app now starts at the AuthGate
      home: const AuthGate(),
      debugShowCheckedModeBanner: false,
    );
  }
}