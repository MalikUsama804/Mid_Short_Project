import 'dart:ui';
import 'package:flutter/material.dart';

class BusinessOwnerScreen extends StatefulWidget {
  const BusinessOwnerScreen({super.key});

  @override
  State<BusinessOwnerScreen> createState() => _BusinessOwnerScreenState();
}

class _BusinessOwnerScreenState extends State<BusinessOwnerScreen> {
  bool isCardView = false; // 🔥 Toggle variable

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
              colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
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
                child: const Icon(Icons.arrow_back_ios_new,
                    color: Colors.white, size: 20),
              ),
            ),

            const SizedBox(width: 15),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("Welcome Back 👋",
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        fontWeight: FontWeight.w400)),
                SizedBox(height: 4),
                Text('Business Owner Dashboard',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1)),
              ],
            ),

            const Spacer(),

            // 🔥 VIEW SWITCH BUTTON
            IconButton(
              icon: Icon(
                isCardView ? Icons.view_list : Icons.grid_view_rounded,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () {
                setState(() {
                  isCardView = !isCardView;
                });
              },
            ),

            const SizedBox(width: 10),

            const Icon(Icons.notifications_active_rounded,
                color: Colors.white, size: 26),
            const SizedBox(width: 14),
            const CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.green, size: 26),
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
              child: Container(color: Colors.black.withOpacity(0)),
            ),
          ),

          // 🔥 CHECK WHICH VIEW TO SHOW
          isCardView ? cardView() : listView(),
        ],
      ),
    );
  }

  // ---------------- LIST VIEW ----------------
  Widget listView() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        HoverListTile(title: 'Add Product', icon: Icons.add_box, onTap: () {}),
        HoverListTile(title: 'View Products', icon: Icons.list_alt, onTap: () {}),
        HoverListTile(title: 'Sales', icon: Icons.shopping_cart, onTap: () {}),
        HoverListTile(title: 'Reports', icon: Icons.bar_chart, onTap: () {}),
        HoverListTile(title: 'Customers', icon: Icons.people, onTap: () {}),
        HoverListTile(title: 'Settings', icon: Icons.settings, onTap: () {}),
      ],
    );
  }

  // ---------------- CARD VIEW ----------------
  Widget cardView() {
    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.all(12),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        HoverCardTile(title: 'Add Product', icon: Icons.add_box),
        HoverCardTile(title: 'View Products', icon: Icons.list_alt),
        HoverCardTile(title: 'Sales', icon: Icons.shopping_cart),
        HoverCardTile(title: 'Reports', icon: Icons.bar_chart),
        HoverCardTile(title: 'Customers', icon: Icons.people),
        HoverCardTile(title: 'Settings', icon: Icons.settings),
      ],
    );
  }
}

/// ===========================
/// Hoverable LIST TILE Widget
/// ===========================
class HoverListTile extends StatefulWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const HoverListTile({
    Key? key,
    required this.title,
    required this.icon,
    required this.onTap,
  }) : super(key: key);

  @override
  State<HoverListTile> createState() => _HoverListTileState();
}

class _HoverListTileState extends State<HoverListTile> {
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovering = true),
      onExit: (_) => setState(() => isHovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isHovering ? Colors.white.withOpacity(0.82) : Colors.white70,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: isHovering ? 10 : 4,
              offset: const Offset(2, 2),
            ),
          ],
          border: Border.all(
            color: isHovering ? Colors.green.withOpacity(0.8) : Colors.transparent,
            width: isHovering ? 1.5 : 0,
          ),
        ),
        transform: isHovering ? (Matrix4.identity()..scale(1.01)) : Matrix4.identity(),
        child: ListTile(
          leading: Icon(widget.icon, color: Colors.green, size: 30),
          title: Text(widget.title,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: isHovering ? Colors.black87 : Colors.black)),
          trailing: const Icon(Icons.arrow_forward_ios, size: 20),
          onTap: widget.onTap,
        ),
      ),
    );
  }
}

/// ===========================
/// Hoverable CARD TILE Widget
/// ===========================
class HoverCardTile extends StatefulWidget {
  final String title;
  final IconData icon;

  const HoverCardTile({
    Key? key,
    required this.title,
    required this.icon,
  }) : super(key: key);

  @override
  State<HoverCardTile> createState() => _HoverCardTileState();
}

class _HoverCardTileState extends State<HoverCardTile> {
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovering = true),
      onExit: (_) => setState(() => isHovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: isHovering ? Colors.white.withOpacity(0.90) : Colors.white70,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: isHovering ? 14 : 4,
              offset: const Offset(2, 2),
            ),
          ],
          border: Border.all(
            color: isHovering ? Colors.green.withOpacity(0.85) : Colors.transparent,
            width: isHovering ? 1.5 : 0,
          ),
        ),
        transform: isHovering ? (Matrix4.identity()..scale(1.03)) : Matrix4.identity(),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {}, // keep same behavior as before (you can fill)
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: Colors.green, size: isHovering ? 46 : 40),
              const SizedBox(height: 10),
              Text(widget.title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isHovering ? Colors.black87 : Colors.black)),
            ],
          ),
        ),
      ),
    );
  }
}
