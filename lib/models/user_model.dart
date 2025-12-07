class AppUser {
  final String uid;
  final String email;
  final String name;
  final String role; // 'resident', 'business_owner', 'admin'
  final String? profileImage;
  final String phone;
  final String address;
  final String block;
  final String houseNumber;
  final DateTime createdAt;

  AppUser({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.profileImage,
    this.phone = '',
    this.address = '',
    this.block = '',
    this.houseNumber = '',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role,
      'profileImage': profileImage,
      'phone': phone,
      'address': address,
      'block': block,
      'houseNumber': houseNumber,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static AppUser fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'],
      email: map['email'],
      name: map['name'],
      role: map['role'],
      profileImage: map['profileImage'],
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      block: map['block'] ?? '',
      houseNumber: map['houseNumber'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  bool get isAdmin => role == 'admin';
  bool get isResident => role == 'resident';
  bool get isBusinessOwner => role == 'business_owner';
}