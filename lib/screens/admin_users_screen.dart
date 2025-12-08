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

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      // Use the FirebaseService method
      List<AppUser> users = await _firebaseService.getAllUsersFuture();

      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading users: $e');

      // Fallback to direct Firestore query
      try {
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('users')
            .get();

        List<AppUser> users = [];
        for (var doc in snapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

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
        }

        setState(() {
          _users = users;
          _isLoading = false;
        });
      } catch (e2) {
        setState(() {
          _error = e2.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteUser(String userId, String userName) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete $userName? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        // Delete from Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .delete();

        // Also delete from Firebase Auth (if using authentication)
        try {
          // If you have auth users, delete them too
          // await FirebaseAuth.instance.currentUser!.delete();
        } catch (e) {
          print('Error deleting from auth: $e');
        }

        // Update local state
        setState(() {
          _users.removeWhere((user) => user.uid == userId);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User $userName deleted successfully'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } catch (e) {
        print('Delete error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting user: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _updateUserRole(String userId, String newRole) async {
    try {
      print('Updating user $userId to role $newRole');

      // Update in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({
        'role': newRole,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update local state
      setState(() {
        int index = _users.indexWhere((user) => user.uid == userId);
        if (index != -1) {
          AppUser updatedUser = AppUser(
            uid: _users[index].uid,
            email: _users[index].email,
            name: _users[index].name,
            role: newRole,
            profileImage: _users[index].profileImage,
            phone: _users[index].phone,
            address: _users[index].address,
            block: _users[index].block,
            houseNumber: _users[index].houseNumber,
            createdAt: _users[index].createdAt,
          );
          _users[index] = updatedUser;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User role updated to $newRole'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Role update error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating role: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).padding.top + kToolbarHeight,
            color: Colors.red,
            child: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top,
                left: 16,
                right: 16,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
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
                      const Text(
                        'Manage Users',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: _loadUsers,
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    const Text('Loading users...'),
                  ],
                ),
              ),
            )
          else if (_error.isNotEmpty)
            Expanded(
              child: Center(
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
                    ElevatedButton(
                      onPressed: _loadUsers,
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            )
          else if (_users.isEmpty)
              Expanded(
                child: Center(
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
                        onPressed: _loadUsers,
                        child: const Text('Check Again'),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Icon(Icons.group, color: Colors.blue[700]),
                          const SizedBox(width: 8),
                          Text(
                            'Total Users: ${_users.length}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: _loadUsers,
                            tooltip: 'Refresh',
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _users.length,
                        itemBuilder: (context, index) {
                          final user = _users[index];
                          return UserCard(
                            user: user,
                            onDelete: () => _deleteUser(user.uid, user.name),
                            onRoleChange: (newRole) => _updateUserRole(user.uid, newRole),
                            isCurrentAdmin: user.uid == widget.adminProfile.uid,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

class UserCard extends StatelessWidget {
  final AppUser user;
  final VoidCallback onDelete;
  final Function(String) onRoleChange;
  final bool isCurrentAdmin;

  const UserCard({
    super.key,
    required this.user,
    required this.onDelete,
    required this.onRoleChange,
    required this.isCurrentAdmin,
  });

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
                      if (isCurrentAdmin)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'You',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
                Text(
                    'Joined: ${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}'),
                const Spacer(),
                if (!isCurrentAdmin)
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          _showRoleChangeDialog(context, user);
                        },
                        icon: const Icon(Icons.edit, size: 14),
                        label: const Text('Role'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () => onDelete(),
                        icon: const Icon(Icons.delete, size: 14),
                        label: const Text('Delete'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
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
        return StatefulBuilder(
          builder: (context, setState) {
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
                      setState(() {
                        selectedRole = value!;
                      });
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
                  onPressed: () {
                    onRoleChange(selectedRole);
                    Navigator.pop(context);
                  },
                  child: const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}