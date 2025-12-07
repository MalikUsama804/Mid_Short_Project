class Complaint {
  final String id;
  final String residentId;
  final String residentName;
  final String residentEmail;
  final String title;
  final String description;
  final String category;
  final DateTime date;
  final String status; // 'pending', 'in-progress', 'resolved', 'rejected'
  final String? adminResponse;
  final String? adminId;
  final DateTime? resolveDate;
  final String? resolvedBy;

  Complaint({
    required this.id,
    required this.residentId,
    required this.residentName,
    required this.residentEmail,
    required this.title,
    required this.description,
    required this.category,
    required this.date,
    this.status = 'pending',
    this.adminResponse,
    this.adminId,
    this.resolveDate,
    this.resolvedBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'residentId': residentId,
      'residentName': residentName,
      'residentEmail': residentEmail,
      'title': title,
      'description': description,
      'category': category,
      'date': date.toIso8601String(),
      'status': status,
      'adminResponse': adminResponse,
      'adminId': adminId,
      'resolveDate': resolveDate?.toIso8601String(),
      'resolvedBy': resolvedBy,
    };
  }

  static Complaint fromMap(Map<String, dynamic> map) {
    return Complaint(
      id: map['id'] ?? '',
      residentId: map['residentId'] ?? '',
      residentName: map['residentName'] ?? '',
      residentEmail: map['residentEmail'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'Other',
      date: map['date'] != null
          ? DateTime.parse(map['date'])
          : DateTime.now(),
      status: map['status'] ?? 'pending',
      adminResponse: map['adminResponse'],
      adminId: map['adminId'],
      resolveDate: map['resolveDate'] != null
          ? DateTime.parse(map['resolveDate'])
          : null,
      resolvedBy: map['resolvedBy'],
    );
  }
}