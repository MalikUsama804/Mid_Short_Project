import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'profile_screen.dart';
import 'resident_complaints_screen.dart';
import 'announcements_screen.dart';
import 'parking_screen.dart';
import 'business_owner_screen.dart';
import 'notifications_screen.dart';
import 'emergency_contacts_screen.dart';

class ResidentScreen extends StatelessWidget {
  final AppUser userProfile;

  const ResidentScreen({super.key, required this.userProfile});

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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Welcome ${userProfile.name} 👋",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Resident Dashboard',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                IconButton(
                  icon: Badge(
                    label: FutureBuilder<int>(
                      future: _getUnreadNotificationCount(),
                      builder: (context, snapshot) {
                        final count = snapshot.data ?? 0;
                        return Text(count > 0 ? '$count' : '');
                      },
                    ),
                    child: const Icon(Icons.notifications_active_rounded,
                        color: Colors.white, size: 26),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NotificationsScreen(userProfile: userProfile),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 14),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileScreen(userProfile: userProfile),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Colors.green, size: 26),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Image.network(
              'https://images.unsplash.com/photo-1507537297725-24a1c029d3ca?auto=format&fit=crop&w=800&q=80',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.black.withOpacity(0),
              ),
            ),
          ),
          ListView(
            padding: const EdgeInsets.all(12),
            children: [
              functionalityTile(
                title: 'Profile Management',
                icon: Icons.man_3_rounded,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(userProfile: userProfile),
                    ),
                  );
                },
              ),
              functionalityTile(
                title: 'Complaints',
                icon: Icons.report_rounded,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ResidentComplaintsScreen(userProfile: userProfile),
                    ),
                  );
                },
              ),
              functionalityTile(
                title: 'Announcements',
                icon: Icons.announcement_rounded,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AnnouncementsScreen(userProfile: userProfile),
                    ),
                  );
                },
              ),
              functionalityTile(
                title: 'Parking Management',
                icon: Icons.local_parking_rounded,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ParkingScreen(userProfile: userProfile),
                    ),
                  );
                },
              ),
              functionalityTile(
                title: 'Business',
                icon: Icons.business_rounded,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BusinessOwnerScreen(userProfile: userProfile),
                    ),
                  );
                },
              ),
              functionalityTile(
                title: 'Emergency Contacts',
                icon: Icons.emergency,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EmergencyContactsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget functionalityTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white70,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.green, size: 30),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 20),
        onTap: onTap,
      ),
    );
  }

  Future<int> _getUnreadNotificationCount() async {
    return 0;
  }
}