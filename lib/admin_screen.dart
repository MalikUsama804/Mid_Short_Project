import 'package:flutter/material.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,

        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF2ECC71),
                Color(0xFF27AE60),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 12,
                offset: Offset(0, 6),
              )
            ],
          ),
        ),

        toolbarHeight: 90,

        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [

            // 🔙 BACK BUTTON (Perfect LEFT)
            InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(50),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),

            const SizedBox(width: 15),

            // TEXT
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  "Welcome Back 👋",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Admin Dashboard',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),

            const Spacer(), // Push right icons to right side

            // RIGHT SIDE ICONS
            Row(
              children: [
                Icon(Icons.notifications_active_rounded,
                    color: Colors.white, size: 26),
                const SizedBox(width: 14),
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Colors.green, size: 26),
                ),
              ],
            ),
          ],
        ),
      ),


      body: const Center(
        child: Text(
          "Welcome Admin",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
      ),
    );
  }
}
