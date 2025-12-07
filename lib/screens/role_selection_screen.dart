import 'package:flutter/material.dart';
import 'resident_screen.dart';
import 'admin_dashboard_screen.dart'; // IMPORT DIRECT
import 'auth_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/user_model.dart';

class RoleSelectionScreen extends StatelessWidget {
  final AppUser userProfile;

  const RoleSelectionScreen({super.key, required this.userProfile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          'City Link System',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 26,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.account_circle, color: Colors.white, size: 32),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'profile',
                  child: Row(
                    children: const [
                      Icon(Icons.person, color: Colors.green),
                      SizedBox(width: 10),
                      Text('My Profile'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: const [
                      Icon(Icons.logout, color: Colors.red),
                      SizedBox(width: 10),
                      Text('Sign Out'),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'logout') {
                  _signOut(context);
                } else if (value == 'profile') {
                  // Navigate to profile screen
                }
              },
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Image.network(
              "https://images.unsplash.com/photo-1477959858617-67f85cf4f1df?auto=format&fit=crop&w=900&q=80",
              fit: BoxFit.cover,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.65),
                  Colors.black.withOpacity(0.25),
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: const Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  userProfile.name,
                  style: const TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  userProfile.email,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  "Select Your Role",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 45),

                // RESIDENT BUTTON
                HoverRoleButton(
                  title: "Resident",
                  icon: Icons.person_rounded,
                  screen: ResidentScreen(userProfile: userProfile),
                ),

                const SizedBox(height: 25), // SPACING

                // ADMIN BUTTON - DIRECT LINK TO AdminDashboardScreen
                HoverRoleButton(
                  title: "Admin",
                  icon: Icons.admin_panel_settings_rounded,
                  screen: AdminDashboardScreen(adminProfile: userProfile), // DIRECT LINK
                ),

                const SizedBox(height: 25), // SPACING

                // BUSINESS OWNER BUTTON

              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: $e')),
      );
    }
  }
}

class HoverRoleButton extends StatefulWidget {
  final String title;
  final IconData icon;
  final Widget screen;

  const HoverRoleButton({
    Key? key,
    required this.title,
    required this.icon,
    required this.screen,
  }) : super(key: key);

  @override
  State<HoverRoleButton> createState() => _HoverRoleButtonState();
}

class _HoverRoleButtonState extends State<HoverRoleButton> {
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovering = true),
      onExit: (_) => setState(() => isHovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 280,
        height: 70,
        curve: Curves.easeOut,
        transform: isHovering ? (Matrix4.identity()..scale(1.04)) : Matrix4.identity(),
        decoration: BoxDecoration(
          color: isHovering ? Colors.white.withOpacity(0.20) : Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: Colors.white.withOpacity(isHovering ? 0.30 : 0.25),
            width: isHovering ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isHovering ? 0.45 : 0.30),
              blurRadius: isHovering ? 18 : 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => widget.screen),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(widget.icon, size: 30, color: Colors.white),
                const SizedBox(width: 14),
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}