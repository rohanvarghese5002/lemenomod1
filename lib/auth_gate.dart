import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart'; // THIS LINE IS NOW CORRECT
import 'package:lumeno_app/pages/home_page.dart';
import 'package:lumeno_app/pages/welcome_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // 1. Is the user logged in?
          if (snapshot.hasData) {
            // If yes, show the HomePage
            return const HomePage();
          }
          // 2. Is the user NOT logged in?
          else {
            // If no, show the WelcomePage
            return const WelcomePage();
          }
        },
      ),
    );
  }
}