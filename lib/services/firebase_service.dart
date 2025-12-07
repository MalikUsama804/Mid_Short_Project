import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/user_model.dart';
import '../models/complaint_model.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Getter methods
  FirebaseFirestore get firestore => _firestore;
  FirebaseAuth get auth => _auth;
  FirebaseStorage get storage => _storage;
  User? get currentUser => _auth.currentUser;

  // ========== USER MANAGEMENT ==========
  Future<void> createUserProfile(AppUser user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<AppUser?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return _convertToAppUser(doc.id, doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> updates) async {
    await _firestore.collection('users').doc(uid).update(updates);
  }

  // ========== GET ALL USERS (ADMIN) ==========
  Stream<List<AppUser>> getAllUsers() {
    try {
      return _firestore
          .collection('users')
          .snapshots()
          .handleError((error) {
        print('Error in getAllUsers stream: $error');
        throw error;
      })
          .map((QuerySnapshot snapshot) {
        final users = <AppUser>[];

        for (var doc in snapshot.docs) {
          try {
            final appUser = _convertToAppUser(doc.id, doc.data() as Map<String, dynamic>);
            users.add(appUser);
          } catch (e) {
            print('Error converting user ${doc.id}: $e');
          }
        }

        return users;
      });
    } catch (e) {
      print('Error creating getAllUsers stream: $e');
      return Stream.value([]);
    }
  }

  // ALTERNATIVE: Future version
  Future<List<AppUser>> getAllUsersFuture() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      final users = <AppUser>[];

      for (var doc in snapshot.docs) {
        try {
          final appUser = _convertToAppUser(doc.id, doc.data() as Map<String, dynamic>);
          users.add(appUser);
        } catch (e) {
          print('Error converting user ${doc.id}: $e');
        }
      }

      return users;
    } catch (e) {
      print('Error in getAllUsersFuture: $e');
      return [];
    }
  }

  Future<void> updateUserRole(String uid, String newRole) async {
    await _firestore.collection('users').doc(uid).update({
      'role': newRole,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ========== HELPER METHOD ==========
  AppUser _convertToAppUser(String docId, Map<String, dynamic> data) {
    // Handle createdAt field conversion
    DateTime createdAt;

    if (data['createdAt'] is String) {
      // If stored as ISO string
      createdAt = DateTime.parse(data['createdAt']);
    } else if (data['createdAt'] is Timestamp) {
      // If stored as Firestore Timestamp
      createdAt = (data['createdAt'] as Timestamp).toDate();
    } else {
      // Default to current time
      createdAt = DateTime.now();
    }

    return AppUser(
      uid: docId,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      role: data['role'] ?? 'resident',
      profileImage: data['profileImage'],
      phone: data['phone'] ?? '',
      address: data['address'] ?? '',
      block: data['block'] ?? '',
      houseNumber: data['houseNumber'] ?? '',
      createdAt: createdAt,
    );
  }

  // ========== COMPLAINT MANAGEMENT ==========
  Future<void> addComplaint(Complaint complaint) async {
    await _firestore.collection('complaints').doc(complaint.id).set({
      'id': complaint.id,
      'residentId': complaint.residentId,
      'residentName': complaint.residentName,
      'residentEmail': complaint.residentEmail,
      'title': complaint.title,
      'description': complaint.description,
      'category': complaint.category,
      'date': complaint.date.toIso8601String(),
      'status': complaint.status,
      'adminResponse': complaint.adminResponse,
      'adminId': complaint.adminId,
      'resolveDate': complaint.resolveDate?.toIso8601String(),
      'resolvedBy': complaint.resolvedBy,
    });
  }

  Stream<List<Complaint>> getComplaintsByResident(String residentId) {
    return _firestore
        .collection('complaints')
        .where('residentId', isEqualTo: residentId)
        .snapshots()
        .map((snapshot) {
      final complaints = snapshot.docs
          .map((doc) => Complaint.fromMap(doc.data()))
          .toList();
      complaints.sort((a, b) => b.date.compareTo(a.date));
      return complaints;
    });
  }

  Stream<List<Complaint>> getAllComplaints() {
    return _firestore
        .collection('complaints')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Complaint.fromMap(doc.data()))
        .toList());
  }

  Future<void> updateComplaintStatus(
      String complaintId,
      String status,
      String adminId, {
        String? response,
      }) async {
    final updateData = {
      'status': status,
      'adminId': adminId,
      if (response != null) 'adminResponse': response,
      if (status == 'resolved') 'resolveDate': DateTime.now().toIso8601String(),
    };
    await _firestore.collection('complaints').doc(complaintId).update(updateData);
  }

  // ========== ANNOUNCEMENT MANAGEMENT ==========
  Future<void> addAnnouncement({
    required String title,
    required String description,
    required String postedBy,
    String priority = 'normal',
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await _firestore.collection('announcements').doc(id).set({
      'id': id,
      'title': title,
      'description': description,
      'postedBy': postedBy,
      'priority': priority,
      'date': DateTime.now().toIso8601String(),
    });
  }

  Stream<List<Map<String, dynamic>>> getAnnouncements() {
    return _firestore
        .collection('announcements')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // ========== PARKING MANAGEMENT ==========
  Future<void> addParkingRequest({
    required String residentId,
    required String residentName,
    required String vehicleNumber,
    required String vehicleType,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await _firestore.collection('parking_requests').doc(id).set({
      'id': id,
      'residentId': residentId,
      'residentName': residentName,
      'vehicleNumber': vehicleNumber,
      'vehicleType': vehicleType,
      'status': 'pending',
      'requestedDate': DateTime.now().toIso8601String(),
    });
  }

  Stream<List<Map<String, dynamic>>> getParkingRequests(String residentId) {
    return _firestore
        .collection('parking_requests')
        .where('residentId', isEqualTo: residentId)
        .snapshots()
        .map((snapshot) {
      final requests = snapshot.docs.map((doc) => doc.data()).toList();
      requests.sort((a, b) {
        final dateA = DateTime.parse(a['requestedDate']);
        final dateB = DateTime.parse(b['requestedDate']);
        return dateB.compareTo(dateA);
      });
      return requests;
    });
  }

  // ========== IMAGE UPLOAD ==========
  Future<String> uploadProfileImage(String uid, File imageFile) async {
    final ref = _storage.ref().child('profile_images/$uid.jpg');
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }

  // Add this method to your FirebaseService class
  Stream<List<Map<String, dynamic>>> getAllParkingRequests() {
    return firestore
        .collection('parking_requests')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList());
  }
}