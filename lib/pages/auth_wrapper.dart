import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'profile_page.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    _checkIfNewUser();
  }

  Future<void> _checkIfNewUser() async {
    final prefs = await SharedPreferences.getInstance();
    final isNewUser = prefs.getBool('isNewUser') ?? true;

    if (!mounted) return;

    if (isNewUser) {
      await prefs.setBool('isNewUser', false);
      Navigator.pushReplacement(
        context,
        // The only change is here: `const` has been removed because ProfilePage is stateful.
        MaterialPageRoute(builder: (context) => ProfilePage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading circle while the check is happening.
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}