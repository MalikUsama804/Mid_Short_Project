import 'package:flutter/material.dart';

class ResidentScreen extends StatelessWidget {
  const ResidentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resident Section'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Container(
        // Background image
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/my.jpg'), // change your image
            fit: BoxFit.cover,
          ),
        ),
        child: Row(
          children: [
            // Left side panel / design area
            Container(
              width: 80, // thoda wide panel
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.2), // light transparent shade
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Center(
                child: RotatedBox(
                  quarterTurns: 3,
                  child: Text(
                    'Resident Area',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            // Main content
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Center welcome text
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Text(
                      'Welcome Resident!\nThis is your dashboard (temporary view).',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // white + bold
                        shadows: [
                          Shadow(
                            color: Colors.black45,
                            offset: Offset(1, 1),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Options: Report, Updates, Business
                  Column(
                    children: [
                      _optionBox(context, 'Report'),
                      const SizedBox(height: 20),
                      _optionBox(context, 'Updates'),
                      const SizedBox(height: 20),
                      _optionBox(context, 'Business'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget for option box
  Widget _optionBox(BuildContext context, String title) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title tapped (temporary action)')),
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
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}
