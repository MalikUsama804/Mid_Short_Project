import 'package:flutter/material.dart';
import 'resident_screen.dart';
import 'business_owner_screen.dart';
import 'admin_screen.dart';

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
      ),

      body: Stack(
        children: [
          /// 🌆 NEW PREMIUM BLURRED BACKGROUND IMAGE
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Image.network(
              "https://images.unsplash.com/photo-1477959858617-67f85cf4f1df?auto=format&fit=crop&w=900&q=80",
              fit: BoxFit.cover,
            ),
          ),

          /// DARK GRADIENT OVERLAY → mobile app feel
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

          /// CONTENT
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

                /// RESIDENT BUTTON
                _buildRoleButton(
                  context,
                  title: "Resident",
                  icon: Icons.person_rounded,
                  screen: const ResidentScreen(),
                ),

                const SizedBox(height: 25),

                /// BUSINESS OWNER
                _buildRoleButton(
                  context,
                  title: "Business Owner",
                  icon: Icons.store_rounded,
                  screen: const BusinessOwnerScreen(),
                ),

                const SizedBox(height: 25),

                /// ADMIN
                _buildRoleButton(
                  context,
                  title: "Admin",
                  icon: Icons.admin_panel_settings_rounded,
                  screen: const AdminScreen(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// GLASS BUTTON WIDGET (Mobile App style)
  Widget _buildRoleButton(
      BuildContext context,
      {required String title,
        required IconData icon,
        required Widget screen}) {

    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => screen)),

      child: Container(
        width: 280,
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withOpacity(0.25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),

        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: Colors.white),
              const SizedBox(width: 14),
              Text(
                title,
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
    );
  }
}
