import 'package:flutter/material.dart';
import 'resident_screen.dart';
import 'business_owner_screen.dart';
import 'admin_screen.dart';
import 'auth_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

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
            child: IconButton(
              icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 28),
              tooltip: 'Sign Out',
              onPressed: () async {
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
              }, // sign out
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
          ), // background image

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
          ), // dark overlay

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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

                HoverRoleButton(
                  title: "Resident",
                  icon: Icons.person_rounded,
                  screen: const ResidentScreen(),
                ),

                const SizedBox(height: 25),

                HoverRoleButton(
                  title: "Business Owner",
                  icon: Icons.store_rounded,
                  screen: const BusinessOwnerScreen(),
                ),

                const SizedBox(height: 25),

                HoverRoleButton(
                  title: "Admin",
                  icon: Icons.admin_panel_settings_rounded,
                  screen: const AdminScreen(),
                ),
              ],
            ),
          ), // role buttons
        ],
      ),
    );
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
