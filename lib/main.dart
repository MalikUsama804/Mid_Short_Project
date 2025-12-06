import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDxccBiyGHSfNcohTh38YOj-q8EAZ4iX9w",
      appId: "1:1020138806326:android:5bba37607793ff6fffcc97",
      messagingSenderId: "1020138806326",
      projectId: "citylinksystem",
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
