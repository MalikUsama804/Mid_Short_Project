import 'dart:ui';
import 'package:flutter/material.dart';

class BusinessOwnerScreen extends StatelessWidget {
  const BusinessOwnerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Owner Dashboard'),
        backgroundColor: Colors.green,
      ),
      body: Stack(
        children: [
          // Background Image
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Image.network(
              'https://images.unsplash.com/photo-1507537297725-24a1c029d3ca?auto=format&fit=crop&w=800&q=80',
              fit: BoxFit.cover,
            ),
          ),
          // Blur Effect
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // thoda zyada blur
              child: Container(
                color: Colors.black.withOpacity(0), // required container
              ),
            ),
          ),
          // List
          ListView(
            padding: const EdgeInsets.all(12),
            children: [
              functionalityTile(title: 'Add Product', icon: Icons.add_box, onTap: () {}),
              functionalityTile(title: 'View Products', icon: Icons.list_alt, onTap: () {}),
              functionalityTile(title: 'Sales', icon: Icons.shopping_cart, onTap: () {}),
              functionalityTile(title: 'Reports', icon: Icons.bar_chart, onTap: () {}),
              functionalityTile(title: 'Customers', icon: Icons.people, onTap: () {}),
              functionalityTile(title: 'Settings', icon: Icons.settings, onTap: () {}),
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
      margin: const EdgeInsets.symmetric(vertical: 8), // thoda zyada spacing
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16), // tile me padding bada
      decoration: BoxDecoration(
        color: Colors.white70, // semi-transparent white
        borderRadius: BorderRadius.circular(12), // thoda rounded corner
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.green, size: 30), // icon bada
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18, // text bada
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 20),
        onTap: onTap,
      ),
    );
  }
}
