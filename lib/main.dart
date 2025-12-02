import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyA860vVZH-FgisvShcKDnThgHuwcsq050I",
      appId: "1:899937264106:android:d62d908d9184297102d293",
      messagingSenderId: "899937264106",
      projectId: "smart-city-link-system-76ec5",
    ),
  );

  runApp(const CityLinkApp());
}

class CityLinkApp extends StatelessWidget {
  const CityLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'City Link System',
      home: AuthScreen(),
    );
  }
}
