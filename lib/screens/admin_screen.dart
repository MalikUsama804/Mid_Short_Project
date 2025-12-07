import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'admin_dashboard_screen.dart';

class AdminScreen extends StatelessWidget {
  final AppUser userProfile;

  const AdminScreen({super.key, required this.userProfile});

  @override
  Widget build(BuildContext context) {
    return AdminDashboardScreen(adminProfile: userProfile);
  }
}