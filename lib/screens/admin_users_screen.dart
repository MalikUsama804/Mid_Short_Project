import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';

class AdminUsersScreen extends StatefulWidget {
  final AppUser adminProfile;

  const AdminUsersScreen({super.key, required this.adminProfile});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<AppUser> _users = [];
  bool _isLoading = true;
  String _error = '';
  bool _usingStream = true; // Toggle between Stream and Future

  @override
  void initState() {
    super.initState();
    _loadUsersWithStream();
  }

  // Method 1: Load with Stream
  void _loadUsersWithStream() {
    print('🔄 Loading users with Stream...');
    setState(() {
      _isLoading = true;
      _error = '';
      _usingStream = true;
    });
  }

  // Method 2: Load with Future
  Future<void> _loadUsersWithFuture() async {
    try {
      print('🔄 Loading users with Future...');
      setState(() {
        _isLoading = true;
        _error = '';
        _usingStream = false;
      });

      // Use Future method
      final users = await _firebaseService.getAllUsersFuture();

      print('✅ Loaded ${users.length} users with Future');
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading users with Future: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // Simple direct query as fallback
  Future<void> _loadUsersDirect() async {
    try {
      print('🔄 Loading users with direct query...');
      setState(() {
        _isLoading = true;
        _error = '';
      });

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .get();

      print('📊 Got ${snapshot.docs.length} users directly');

      List<AppUser> users = [];
      for (var doc in snapshot.docs) {
        try {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

          // Convert createdAt
          DateTime createdAt;
          if (data['createdAt'] is String) {
            createdAt = DateTime.parse(data['createdAt']);
          } else if (data['createdAt'] is Timestamp) {
            createdAt = (data['createdAt'] as Timestamp).toDate();
          } else {
            createdAt = DateTime.now();
          }

          users.add(AppUser(
            uid: doc.id,
            email: data['email'] ?? '',
            name: data['name'] ?? 'Unknown',
            role: data['role'] ?? 'resident',
            profileImage: data['profileImage'],
            phone: data['phone'] ?? '',
            address: data['address'] ?? '',
            block: data['block'] ?? '',
            houseNumber: data['houseNumber'] ?? '',
            createdAt: createdAt,
          ));
        } catch (e) {
          print('⚠️ Error parsing user ${doc.id}: $e');
        }
      }

      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Direct query error: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    const Icon(Icons.refresh, color: Colors.blue),
                    const SizedBox(width: 8),
                    const Text('Refresh'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'try_future',
                child: Row(
                  children: [
                    const Icon(Icons.timer, color: Colors.green),
                    const SizedBox(width: 8),
                    const Text('Use Future Method'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'try_direct',
                child: Row(
                  children: [
                    const Icon(Icons.directions_run, color: Colors.orange),
                    const SizedBox(width: 8),
                    const Text('Use Direct Query'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'refresh') {
                _loadUsersWithStream();
              } else if (value == 'try_future') {
                _loadUsersWithFuture();
              } else if (value == 'try_direct') {
                _loadUsersDirect();
              }
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading users...'),
          ],
        ),
      );
    }

    if (_error.isNotEmpty) {
      return _buildError();
    }

    if (_users.isEmpty) {
      return _buildEmpty();
    }

    return _buildUserList();
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 20),
            const Text(
              'Failed to Load Users',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _loadUsersDirect,
                  child: const Text('Try Direct Query'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                  ),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.people_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No Users Found',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'The users collection is empty',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadUsersDirect,
            child: const Text('Check Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList() {
    return Column(
      children: [
        // Status Card
        Card(
          margin: const EdgeInsets.all(12),
          color: Colors.green[50],
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_users.length} users loaded',
                        style: TextStyle(
                          color: Colors.green[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _usingStream ? 'Using Stream' : 'Using Future',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text('Admin: ${widget.adminProfile.name}'),
                  backgroundColor: Colors.red[50],
                ),
              ],
            ),
          ),
        ),

        // Users List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _users.length,
            itemBuilder: (context, index) {
              final user = _users[index];
              return UserCard(user: user);
            },
          ),
        ),
      ],
    );
  }
}

// UserCard Widget (same as your original)
class UserCard extends StatelessWidget {
  final AppUser user;

  const UserCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    Color roleColor = Colors.grey;
    IconData roleIcon = Icons.person;

    switch (user.role) {
      case 'admin':
        roleColor = Colors.red;
        roleIcon = Icons.admin_panel_settings;
        break;
      case 'resident':
        roleColor = Colors.green;
        roleIcon = Icons.person;
        break;
      case 'business_owner':
        roleColor = Colors.blue;
        roleIcon = Icons.business;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: roleColor.withOpacity(0.2),
                  child: Icon(roleIcon, color: roleColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user.email,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text(
                    user.role.toUpperCase(),
                    style: TextStyle(
                      color: roleColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: roleColor.withOpacity(0.1),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.phone, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(user.phone.isNotEmpty ? user.phone : 'No phone'),
                const Spacer(),
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text('${user.block}-${user.houseNumber}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text('Joined: ${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}'),
                const Spacer(),
                if (user.role != 'admin')
                  ElevatedButton.icon(
                    onPressed: () {
                      _showRoleChangeDialog(context, user);
                    },
                    icon: const Icon(Icons.edit, size: 14),
                    label: const Text('Change Role'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showRoleChangeDialog(BuildContext context, AppUser user) {
    String selectedRole = user.role;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change User Role'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select new role for:'),
              const SizedBox(height: 8),
              Text(
                user.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'resident',
                    child: Text('Resident'),
                  ),
                  DropdownMenuItem(
                    value: 'business_owner',
                    child: Text('Business Owner'),
                  ),
                  DropdownMenuItem(
                    value: 'admin',
                    child: Text('Admin'),
                  ),
                ],
                onChanged: (value) {
                  selectedRole = value!;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final firebaseService = FirebaseService();
                  await firebaseService.updateUserRole(user.uid, selectedRole);
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Role changed to ${selectedRole.toUpperCase()}'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }
}