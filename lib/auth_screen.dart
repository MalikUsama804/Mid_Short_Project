import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'role_selection_screen.dart';

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

  bool loading = false;
  late AnimationController _controller;

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
    });
  }

  Future<void> loginUser() async {
    setState(() => loading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passCtrl.text.trim(),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
    setState(() => loading = false);
  }

  Future<void> signupUser() async {
    setState(() => loading = true);
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passCtrl.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account Created Successfully!")),
      );

      toggle();
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
              constraints: const BoxConstraints(maxHeight: 430),
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

  /// SIGNUP UI (Username removed)
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

        field(emailCtrl, "Email"),
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
  Widget mainButton(String text, Function func) {
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
}
