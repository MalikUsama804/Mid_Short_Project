import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'role_selection_screen.dart';
import '../../services/firebase_service.dart';
import '../../models/user_model.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  bool showLogin = true;

  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();

  bool loading = false;
  late AnimationController _controller;
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
  }

  void toggle() {
    setState(() {
      showLogin = !showLogin;
      showLogin ? _controller.reverse() : _controller.forward();
      emailCtrl.clear();
      passCtrl.clear();
      if (showLogin) {
        nameCtrl.clear();
        phoneCtrl.clear();
      }
    });
  }

  Future<void> loginUser() async {
    if (emailCtrl.text.isEmpty || passCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() => loading = true);
    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passCtrl.text.trim(),
      );

      // Get user profile from Firestore
      final userProfile = await _firebaseService.getUserProfile(userCredential.user!.uid);

      if (userProfile != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => RoleSelectionScreen(userProfile: userProfile),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User profile not found')),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Login failed';
      if (e.code == 'user-not-found') {
        message = 'No user found with this email';
      } else if (e.code == 'wrong-password') {
        message = 'Incorrect password';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
    setState(() => loading = false);
  }

  Future<void> signupUser() async {
    if (emailCtrl.text.isEmpty ||
        passCtrl.text.isEmpty ||
        nameCtrl.text.isEmpty ||
        phoneCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    if (passCtrl.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return;
    }

    setState(() => loading = true);
    try {
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passCtrl.text.trim(),
      );

      // Create user profile using AppUser model
      final newUser = AppUser(
        uid: userCredential.user!.uid,
        email: emailCtrl.text.trim(),
        name: nameCtrl.text.trim(),
        role: 'resident', // Default role
        phone: phoneCtrl.text.trim(),
        createdAt: DateTime.now(),
      );

      // Save user data to Firestore
      await _firebaseService.createUserProfile(newUser);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Account Created Successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      toggle();
    } on FirebaseAuthException catch (e) {
      String message = 'Signup failed';
      if (e.code == 'email-already-in-use') {
        message = 'Email already in use';
      } else if (e.code == 'weak-password') {
        message = 'Password is too weak';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// NEW DIFFERENT BACKGROUND
          SizedBox.expand(
            child: Image.network(
              "https://images.unsplash.com/photo-1467269204594-9661b134dd2b?w=1200",
              fit: BoxFit.cover,
            ),
          ),

          /// DARK FADE
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.75),
                  Colors.black.withOpacity(0.30),
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),

          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.78,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.10),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withOpacity(0.20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              constraints: const BoxConstraints(maxHeight: 500),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 450),
                child: showLogin ? loginUI() : signupUI(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// LOGIN UI
  Widget loginUI() {
    return Column(
      key: const ValueKey("login"),
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "Welcome Back",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),

        field(emailCtrl, "Email"),
        const SizedBox(height: 12),

        field(passCtrl, "Password", isPass: true),
        const SizedBox(height: 25),

        mainButton("Login", loginUser),

        TextButton(
          onPressed: toggle,
          child: const Text("Create New Account", style: TextStyle(color: Colors.white70)),
        ),
      ],
    );
  }

  /// SIGNUP UI
  Widget signupUI() {
    return Column(
      key: const ValueKey("signup"),
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "Create Account",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),

        field(nameCtrl, "Full Name"),
        const SizedBox(height: 12),

        field(emailCtrl, "Email"),
        const SizedBox(height: 12),

        field(phoneCtrl, "Phone Number"),
        const SizedBox(height: 12),

        field(passCtrl, "Password", isPass: true),
        const SizedBox(height: 25),

        mainButton("Create Account", signupUser),

        TextButton(
          onPressed: toggle,
          child: const Text("Back to Login", style: TextStyle(color: Colors.white70)),
        ),
      ],
    );
  }

  /// INPUT FIELD — Only bottom white line
  Widget field(TextEditingController ctrl, String label, {bool isPass = false}) {
    return TextField(
      controller: ctrl,
      obscureText: isPass,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 1.5),
        ),
      ),
    );
  }

  /// MAIN BUTTON
  Widget mainButton(String text, Future<void> Function() func) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: loading ? null : () => func(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.25),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: loading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(text, style: const TextStyle(fontSize: 18)),
      ),
    );
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    nameCtrl.dispose();
    phoneCtrl.dispose();
    _controller.dispose();
    super.dispose();
  }
}