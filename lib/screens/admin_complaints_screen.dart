import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/complaint_model.dart';
import '../services/firebase_service.dart';

class AdminComplaintsScreen extends StatefulWidget {
  final AppUser adminProfile;

  const AdminComplaintsScreen({super.key, required this.adminProfile});

  @override
  State<AdminComplaintsScreen> createState() => _AdminComplaintsScreenState();
}

class _AdminComplaintsScreenState extends State<AdminComplaintsScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Complaints'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog(context);
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Complaint>>(
        stream: _firebaseService.getAllComplaints(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final complaints = snapshot.data ?? [];

          if (complaints.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.report_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No complaints yet'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: complaints.length,
            itemBuilder: (context, index) {
              final complaint = complaints[index];
              return ComplaintCardAdmin(
                complaint: complaint,
                onUpdate: () {
                  setState(() {});
                },
                adminProfile: widget.adminProfile,
              );
            },
          );
        },
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter Complaints'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('All Complaints'),
                leading: const Icon(Icons.list),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Pending'),
                leading: Icon(Icons.pending, color: Colors.orange.shade700),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('In Progress'),
                leading: Icon(Icons.build, color: Colors.blue.shade700),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Resolved'),
                leading: Icon(Icons.check_circle, color: Colors.green.shade700),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class ComplaintCardAdmin extends StatelessWidget {
  final Complaint complaint;
  final VoidCallback onUpdate;
  final AppUser adminProfile;

  const ComplaintCardAdmin({
    super.key,
    required this.complaint,
    required this.onUpdate,
    required this.adminProfile,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor = Colors.grey;
    IconData statusIcon = Icons.pending;

    switch (complaint.status) {
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        break;
      case 'in-progress':
        statusColor = Colors.blue;
        statusIcon = Icons.build;
        break;
      case 'resolved':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    complaint.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Chip(
                  label: Text(complaint.status.toUpperCase()),
                  backgroundColor: statusColor.withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              complaint.description,
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(complaint.residentName),
                const SizedBox(width: 16),
                const Icon(Icons.email, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(complaint.residentEmail),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.category, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(complaint.category),
                const Spacer(),
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${complaint.date.day}/${complaint.date.month}/${complaint.date.year}',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (complaint.status != 'resolved')
                  ElevatedButton.icon(
                    onPressed: () {
                      _showUpdateDialog(context, complaint);
                    },
                    icon: Icon(statusIcon, size: 16),
                    label: const Text('Update Status'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: statusColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                const Spacer(),
                Text(
                  'Complaint ID: ${complaint.id.substring(0, 8)}...',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            if (complaint.adminResponse != null) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'Admin Response:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 4),
              Text(complaint.adminResponse!),
            ],
          ],
        ),
      ),
    );
  }

  void _showUpdateDialog(BuildContext context, Complaint complaint) {
    TextEditingController responseController = TextEditingController();
    String selectedStatus = complaint.status;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Complaint Status'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'pending',
                      child: Text('Pending'),
                    ),
                    DropdownMenuItem(
                      value: 'in-progress',
                      child: Text('In Progress'),
                    ),
                    DropdownMenuItem(
                      value: 'resolved',
                      child: Text('Resolved'),
                    ),
                  ],
                  onChanged: (value) {
                    selectedStatus = value!;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: responseController,
                  decoration: const InputDecoration(
                    labelText: 'Response (Optional)',
                    border: OutlineInputBorder(),
                    hintText: 'Add your response...',
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedStatus != complaint.status ||
                    responseController.text.isNotEmpty) {
                  try {
                    await FirebaseService().updateComplaintStatus(
                      complaint.id,
                      selectedStatus,
                      adminProfile.uid,
                      response: responseController.text.isNotEmpty
                          ? responseController.text
                          : null,
                    );

                    onUpdate();
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Complaint status updated to $selectedStatus'),
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