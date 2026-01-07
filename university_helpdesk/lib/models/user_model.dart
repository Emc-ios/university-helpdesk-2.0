class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String? role; // 'student' or 'admin'
  final DateTime? createdAt;
  final String? phoneNumber;
  final String? studentId; // Optional student ID

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.role,
    this.createdAt,
    this.phoneNumber,
    this.studentId,
  });

  // Convert from Firestore document
  factory UserModel.fromFirestore(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      role: data['role'] ?? 'student',
      createdAt: data['createdAt']?.toDate(),
      phoneNumber: data['phoneNumber'],
      studentId: data['studentId'],
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'role': role ?? 'student',
      'createdAt': createdAt,
      'phoneNumber': phoneNumber,
      'studentId': studentId,
    };
  }

  // Create a copy with updated fields
  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? role,
    DateTime? createdAt,
    String? phoneNumber,
    String? studentId,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      studentId: studentId ?? this.studentId,
    );
  }
}
