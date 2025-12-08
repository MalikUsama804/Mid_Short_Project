import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

<<<<<<< HEAD
  // Initialize Firebase only once
  try {
    // Check if Firebase is already initialized (important for hot restart)
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyDxccBiyGHSfNcohTh38YOj-q8EAZ4iX9w",
          appId: "1:1020138806326:android:5bba37607793ff6fffcc97",
          messagingSenderId: "1020138806326",
          projectId: "citylinksystem",
          storageBucket: "citylinksystem.appspot.com",
        ),
      );
      print("✅ Firebase initialized successfully");
    } else {
      // Use existing instance
      Firebase.app();
      print("✅ Firebase already initialized, using existing instance");
    }
  } catch (e) {
    print("❌ Firebase initialization error: $e");
  }
=======
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDxccBiyGHSfNcohTh38YOj-q8EAZ4iX9w",
      appId: "1:1020138806326:android:5bba37607793ff6fffcc97",
      messagingSenderId: "1020138806326",
      projectId: "citylinksystem",
    ),
  );
>>>>>>> d6002b1f23ff742e8eb357478b02967071751393

  runApp(const CityLinkApp());
}

class CityLinkApp extends StatelessWidget {
  const CityLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'City Link System',
      theme: ThemeData(
        primaryColor: const Color(0xFF2ECC71),
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2ECC71),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2ECC71),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
          ),
        ),
      ),
      home: const AuthScreen(),
    );
  }
}