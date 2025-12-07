import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';

class ProfileScreen extends StatefulWidget {
  final AppUser userProfile;

  const ProfileScreen({super.key, required this.userProfile});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _blockController;
  late TextEditingController _houseController;

  bool _isEditing = false;
  bool _isLoading = false;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.userProfile.name);
    _emailController = TextEditingController(text: widget.userProfile.email);
    _phoneController = TextEditingController(text: widget.userProfile.phone);
    _addressController = TextEditingController(text: widget.userProfile.address);
    _blockController = TextEditingController(text: widget.userProfile.block);
    _houseController = TextEditingController(text: widget.userProfile.houseNumber);
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        String? imageUrl;

        if (_profileImage != null) {
          imageUrl = await _firebaseService.uploadProfileImage(
              widget.userProfile.uid,
              _profileImage!
          );
        }

        await _firebaseService.updateUserProfile(widget.userProfile.uid, {
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'address': _addressController.text.trim(),
          'block': _blockController.text.trim(),
          'houseNumber': _houseController.text.trim(),
          if (imageUrl != null) 'profileImage': imageUrl,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        setState(() => _isEditing = false);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _saveProfile();
              } else {
                setState(() => _isEditing = true);
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 70,
                    backgroundColor: Colors.green[100],
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : (widget.userProfile.profileImage != null
                        ? NetworkImage(widget.userProfile.profileImage!)
                        : null) as ImageProvider?,
                    child: _profileImage == null &&
                        widget.userProfile.profileImage == null
                        ? const Icon(
                      Icons.person,
                      size: 70,
                      color: Colors.green,
                    )
                        : null,
                  ),
                  if (_isEditing)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt,
                              color: Colors.white, size: 20),
                          onPressed: _pickImage,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 30),
              _buildProfileField(
                label: 'Full Name',
                controller: _nameController,
                icon: Icons.person,
                enabled: _isEditing,
              ),
              const SizedBox(height: 15),
              _buildProfileField(
                label: 'Email',
                controller: _emailController,
                icon: Icons.email,
                enabled: false,
              ),
              const SizedBox(height: 15),
              _buildProfileField(
                label: 'Phone',
                controller: _phoneController,
                icon: Icons.phone,
                enabled: _isEditing,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: _buildProfileField(
                      label: 'Block',
                      controller: _blockController,
                      icon: Icons.apartment,
                      enabled: _isEditing,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildProfileField(
                      label: 'House No',
                      controller: _houseController,
                      icon: Icons.numbers,
                      enabled: _isEditing,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              _buildProfileField(
                label: 'Address',
                controller: _addressController,
                icon: Icons.home,
                enabled: _isEditing,
                maxLines: 2,
              ),
              const SizedBox(height: 15),
              _buildProfileField(
                label: 'Role',
                controller: TextEditingController(text: widget.userProfile.role),
                icon: Icons.badge,
                enabled: false,
              ),
              const SizedBox(height: 30),
              if (_isEditing)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'SAVE CHANGES',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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

  Widget _buildProfileField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool enabled = true,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.green),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: !enabled,
        fillColor: Colors.grey[100],
      ),
      validator: (value) {
        if (enabled && (value == null || value.isEmpty)) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }
}