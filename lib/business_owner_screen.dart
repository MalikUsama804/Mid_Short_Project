import 'package:flutter/material.dart';

class BusinessOwnerScreen extends StatelessWidget {
  const BusinessOwnerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Owner Section'),
        backgroundColor: Colors.green,
      ),
      body: const Center(
        child: Text(
          'Welcome Business Owner!\nThis is your dashboard (temporary view).',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
