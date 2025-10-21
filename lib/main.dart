import 'package:flutter/material.dart';
import 'role_selection_screen.dart';

void main() {
  runApp(const CityLinkApp());
}

class CityLinkApp extends StatelessWidget {
  const CityLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'City Link System',
      home: RoleSelectionScreen(),
    );
  }
}
