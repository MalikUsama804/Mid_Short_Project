import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';

class AdminParkingScreen extends StatefulWidget {
  final AppUser adminProfile;

  const AdminParkingScreen({super.key, required this.adminProfile});

  @override
  State<AdminParkingScreen> createState() => _AdminParkingScreenState();
}

class _AdminParkingScreenState extends State<AdminParkingScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  String _selectedStatus = 'pending';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parking Management'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Status Filter Buttons
          Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStatusButton('pending', 'Pending'),
                const SizedBox(width: 8),
                _buildStatusButton('approved', 'Approved'),
                const SizedBox(width: 8),
                _buildStatusButton('rejected', 'Rejected'),
              ],
            ),
          ),
          Expanded(
            child: _buildParkingList(_selectedStatus),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusButton(String status, String label) {
    final bool isSelected = _selectedStatus == status;

    Color buttonColor = Colors.grey;
    if (status == 'pending') buttonColor = Colors.orange;
    if (status == 'approved') buttonColor = Colors.green;
    if (status == 'rejected') buttonColor = Colors.red;

    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedStatus = status;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? buttonColor : buttonColor.withOpacity(0.3),
        foregroundColor: isSelected ? Colors.white : Colors.black,
      ),
      child: Text(label),
    );
  }

  Widget _buildParkingList(String status) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _firebaseService.getAllParkingRequests(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final allRequests = snapshot.data ?? [];

        // Filter by status locally instead of Firestore query
        final requests = allRequests.where((request) {
          return request['status'] == status;
        }).toList();

        if (requests.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_parking, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No parking requests',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        // Sort by date (newest first)
        requests.sort((a, b) {
          final dateA = DateTime.parse(a['requestedDate']);
          final dateB = DateTime.parse(b['requestedDate']);
          return dateB.compareTo(dateA);
        });

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            return ParkingRequestCardAdmin(
              request: requests[index],
              onUpdate: () {
                setState(() {});
              },
            );
          },
        );
      },
    );
  }
}

class ParkingRequestCardAdmin extends StatelessWidget {
  final Map<String, dynamic> request;
  final VoidCallback onUpdate;

  const ParkingRequestCardAdmin({
    super.key,
    required this.request,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse(request['requestedDate']);
    Color statusColor = Colors.grey;
    IconData statusIcon = Icons.pending;

    switch (request['status']) {
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        break;
      case 'approved':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
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
                    'Vehicle: ${request['vehicleNumber']}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    request['status'].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Type: ${request['vehicleType']}',
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Owner: ${request['residentName']}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${date.day}/${date.month}/${date.year}',
                ),
              ],
            ),
            if (request['slotNumber'] != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.local_parking, size: 16, color: Colors.green),
                  const SizedBox(width: 4),
                  Text(
                    'Slot: ${request['slotNumber']}',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            if (request['status'] == 'pending')
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showApproveDialog(context, request);
                      },
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _rejectRequest(context, request);
                      },
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Reject'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
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

  void _showApproveDialog(BuildContext context, Map<String, dynamic> request) {
    final slotController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Approve Parking Request'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.directions_car),
                  title: Text('Vehicle: ${request['vehicleNumber']}'),
                ),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: Text('Owner: ${request['residentName']}'),
                ),
                const SizedBox(height: 16),
                Form(
                  key: formKey,
                  child: TextFormField(
                    controller: slotController,
                    decoration: const InputDecoration(
                      labelText: 'Parking Slot Number',
                      border: OutlineInputBorder(),
                      hintText: 'e.g., A-01, B-12',
                      prefixIcon: Icon(Icons.numbers),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter slot number';
                      }
                      return null;
                    },
                  ),
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
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  _approveRequest(context, request, slotController.text);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('Approve'),
            ),
          ],
        );
      },
    );
  }

  void _approveRequest(BuildContext context, Map<String, dynamic> request, String slotNumber) async {
    try {
      await FirebaseService().firestore
          .collection('parking_requests')
          .doc(request['id'])
          .update({
        'status': 'approved',
        'slotNumber': slotNumber,
        'approvedAt': DateTime.now().toIso8601String(),
        'approvedBy': 'Admin',
      });

      Navigator.pop(context);
      onUpdate();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Parking request approved!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
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

  void _rejectRequest(BuildContext context, Map<String, dynamic> request) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Request'),
        content: const Text('Are you sure you want to reject this parking request?'),
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
            child: const Text('Reject'),
          ),
        ],
      ),
    ) ?? false;

    if (!confirm) return;

    try {
      await FirebaseService().firestore
          .collection('parking_requests')
          .doc(request['id'])
          .update({
        'status': 'rejected',
        'rejectedAt': DateTime.now().toIso8601String(),
        'rejectedBy': 'Admin',
      });

      onUpdate();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Parking request rejected'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
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
}