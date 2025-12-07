import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyContactsScreen extends StatelessWidget {
  const EmergencyContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final contacts = [
      {
        'name': 'Police',
        'number': '100',
        'icon': Icons.local_police,
        'color': Colors.blue,
      },
      {
        'name': 'Ambulance',
        'number': '102',
        'icon': Icons.medical_services,
        'color': Colors.red,
      },
      {
        'name': 'Fire Brigade',
        'number': '101',
        'icon': Icons.fire_truck,
        'color': Colors.orange,
      },
      {
        'name': 'Security Guard',
        'number': '+92 300 1234567',
        'icon': Icons.security,
        'color': Colors.green,
      },
      {
        'name': 'Building Manager',
        'number': '+92 300 7654321',
        'icon': Icons.manage_accounts_rounded,
        'color': Colors.purple,
      },
      {
        'name': 'Maintenance',
        'number': '+92 300 9876543',
        'icon': Icons.build,
        'color': Colors.brown,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Contacts'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          final contact = contacts[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: contact['color'] as Color,
                child: Icon(
                  contact['icon'] as IconData,
                  color: Colors.white,
                ),
              ),
              title: Text(
                contact['name'] as String,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(contact['number'] as String),
              trailing: IconButton(
                icon: const Icon(
                  Icons.call,
                  color: Colors.green,
                ),
                onPressed: () {
                  _makePhoneCall(contact['number'] as String);
                },
              ),
              onTap: () {
                _makePhoneCall(contact['number'] as String);
              },
            ),
          );
        },
      ),
    );
  }

  void _makePhoneCall(String phoneNumber) async {
    final url = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }
}