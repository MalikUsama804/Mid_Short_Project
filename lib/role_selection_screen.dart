import 'package:flutter/material.dart';
import 'resident_screen.dart';
import 'business_owner_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar with bold, centered, white title and search box
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'City Link System',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.pinkAccent,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: SizedBox(
              width: 200,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
            ),
          ),
        ],
      ),

      // Body with background image and two options
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/my.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Resident box
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ResidentScreen(),
                    ),
                  );
                },
                child: Container(
                  width: 250,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.lightBlue.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Resident',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Business Owner box
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BusinessOwnerScreen(),
                    ),
                  );
                },
                child: Container(
                  width: 250,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.lightBlue.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Business Owner',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
