import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'role_selection_screen.dart';
import 'admin_dashboard_screen.dart';
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
  bool isAdminLogin = false;

  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  // Admin code controller removed

  bool loading = false;
  late AnimationController _controller;
  final FirebaseService _firebaseService = FirebaseService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  void toggleLoginMode() {
    setState(() {
      isAdminLogin = !isAdminLogin;
      emailCtrl.clear();
      passCtrl.clear();
    });
  }

  Future<void> loginUser() async {
    if (emailCtrl.text.isEmpty || passCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    // ADMIN CODE CHECK REMOVED
    // Users can now login as admin if their role in database is 'admin'

    setState(() => loading = true);
    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passCtrl.text.trim(),
      );

      final user = userCredential.user!;

      // Check if user document exists in 'users' collection
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        // User doesn't exist in Firestore - create document
        final newUserProfile = AppUser(
          uid: user.uid,
          email: user.email ?? emailCtrl.text.trim(),
          name: user.displayName ?? emailCtrl.text.split('@').first,
          role: isAdminLogin ? 'admin' : 'resident',
          phone: '',
          address: '',
          block: '',
          houseNumber: '',
          createdAt: DateTime.now(),
        );

        await _firestore.collection('users').doc(user.uid).set(newUserProfile.toMap());

        // For new admin users, navigate to admin dashboard
        if (isAdminLogin) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => AdminDashboardScreen(adminProfile: newUserProfile),
            ),
          );
          return;
        }
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final userProfile = AppUser.fromMap(userData);

      // Check if user is admin
      final isAdmin = userProfile.role == "admin";

      if (isAdminLogin && !isAdmin) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This account is not authorized as admin'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => loading = false);
        return;
      }

      if (isAdminLogin && isAdmin) {
        // Navigate to admin dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AdminDashboardScreen(adminProfile: userProfile),
          ),
        );
      } else if (!isAdminLogin) {
        // Navigate to resident role selection
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => RoleSelectionScreen(userProfile: userProfile),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Login failed';
      if (e.code == 'user-not-found') {
        message = 'No user found with this email';
      } else if (e.code == 'wrong-password') {
        message = 'Incorrect password';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email format';
      } else if (e.code == 'user-disabled') {
        message = 'This account has been disabled';
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
    // Only allow resident signup
    if (isAdminLogin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Admin accounts cannot be created publicly'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

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

    // Validate email format
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(emailCtrl.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }

    // Validate phone number
    if (!RegExp(r'^[0-9]{10,15}$').hasMatch(phoneCtrl.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid phone number (10-15 digits)')),
      );
      return;
    }

    setState(() => loading = true);
    try {
      // Create user in Firebase Authentication
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passCtrl.text.trim(),
      );

      final user = userCredential.user!;

      // Update display name in Firebase Auth
      await user.updateDisplayName(nameCtrl.text.trim());

      // Create user profile in Firestore
      final newUser = AppUser(
        uid: user.uid,
        email: emailCtrl.text.trim(),
        name: nameCtrl.text.trim(),
        role: 'resident', // Default role for public signup
        phone: phoneCtrl.text.trim(),
        address: '',
        block: '',
        houseNumber: '',
        createdAt: DateTime.now(),
      );

      // Save to 'users' collection
      await _firestore.collection('users').doc(user.uid).set(newUser.toMap());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Account Created Successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      // IMPORTANT: After successful signup, user must LOG IN
      // Clear fields and switch back to login screen
      emailCtrl.clear();
      passCtrl.clear();
      nameCtrl.clear();
      phoneCtrl.clear();

      setState(() {
        loading = false;
        showLogin = true;
        isAdminLogin = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please login with your new credentials"),
          backgroundColor: Colors.blue,
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message = 'Signup failed';
      if (e.code == 'email-already-in-use') {
        message = 'Email already in use';
      } else if (e.code == 'weak-password') {
        message = 'Password is too weak';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email address';
      } else if (e.code == 'operation-not-allowed') {
        message = 'Email/password accounts are not enabled';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      setState(() => loading = false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.network(
              "https://images.unsplash.com/photo-1467269204594-9661b134dd2b?w=1200",
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[900],
                  child: const Center(
                    child: Icon(Icons.image, color: Colors.grey, size: 100),
                  ),
                );
              },
            ),
          ),
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
            child: SingleChildScrollView(
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
                constraints: const BoxConstraints(maxHeight: 600),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 450),
                  child: showLogin ? loginUI() : signupUI(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// LOGIN UI with switch
  Widget loginUI() {
    return Column(
      key: const ValueKey("login"),
      mainAxisSize: MainAxisSize.min,
      children: [
        // Login Type Switch
        Container(
          width: 300,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (isAdminLogin) toggleLoginMode();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: !isAdminLogin
                          ? Colors.white.withOpacity(0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Center(
                      child: Text(
                        "Resident Login",
                        style: TextStyle(
                          color: !isAdminLogin ? Colors.white : Colors.white70,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (!isAdminLogin) toggleLoginMode();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: isAdminLogin
                          ? Colors.white.withOpacity(0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Center(
                      child: Text(
                        "Admin Login",
                        style: TextStyle(
                          color: isAdminLogin ? Colors.white : Colors.white70,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        Text(
          isAdminLogin ? "Admin Login" : "Welcome Back",
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        if (isAdminLogin) const SizedBox(height: 10),

        if (isAdminLogin)
          const Text(
            "Enter admin credentials",
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),

        const SizedBox(height: 20),

        field(emailCtrl, "Email", keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 12),

        field(passCtrl, "Password", isPass: true),

        // ADMIN CODE FIELD REMOVED

        const SizedBox(height: 25),

        mainButton(isAdminLogin ? "Login as Admin" : "Login", loginUser),

        if (!isAdminLogin)
          TextButton(
            onPressed: toggle,
            child: const Text("Create New Account",
                style: TextStyle(color: Colors.white70)),
          ),
      ],
    );
  }

  /// SIGNUP UI (only for residents)
  Widget signupUI() {
    return Column(
      key: const ValueKey("signup"),
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "Create Resident Account",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),

        field(nameCtrl, "Full Name"),
        const SizedBox(height: 12),

        field(emailCtrl, "Email", keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 12),

        field(phoneCtrl, "Phone Number", keyboardType: TextInputType.phone),
        const SizedBox(height: 12),

        field(passCtrl, "Password", isPass: true),
        const SizedBox(height: 25),

        mainButton("Create Account", signupUser),

        TextButton(
          onPressed: toggle,
          child: const Text("Back to Login",
              style: TextStyle(color: Colors.white70)),
        ),
      ],
    );
  }

  /// INPUT FIELD
  Widget field(TextEditingController ctrl, String label,
      {bool isPass = false, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: ctrl,
      obscureText: isPass,
      style: const TextStyle(color: Colors.white),
      keyboardType: keyboardType,
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
          backgroundColor: isAdminLogin
              ? Colors.red.withOpacity(0.8)
              : Colors.white.withOpacity(0.25),
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
    // Admin code controller removed from dispose
    _controller.dispose();
    super.dispose();
  }
}