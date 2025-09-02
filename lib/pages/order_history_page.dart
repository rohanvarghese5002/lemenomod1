import 'package:flutter/material.dart';

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100], // ✅ Light green background
      appBar: AppBar(
        title: const Text('Order History'),
        backgroundColor: Colors.green, // ✅ Green AppBar
      ),
      body: const Center(
        child: Text(
          'Looks like your history page is still on vacation… go give it some company!',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.green, // ✅ Green text
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
