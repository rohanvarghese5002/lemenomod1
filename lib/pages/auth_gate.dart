import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'auth_wrapper.dart'; // Imports the "traffic cop"
import 'welcome_page.dart'; // Imports your login screen

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // If the user is logged in...
          if (snapshot.hasData) {
            // ...send them to the AuthWrapper to check if they are new.
            return AuthWrapper();
          }
          // If the user is NOT logged in...
          else {
            // ...show the welcome/login screen.
            return const WelcomePage();
          }
        },
      ),
    );
  }
}
