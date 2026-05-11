/*
 * Student Numbers: (all your group member numbers here)
 * Student Names: (all your group member names here)
 * Question: Profile Model
 */

class ProfileModel {
  final String id;
  final String fullName;
  final String studentNumber;
  final String role;

  const ProfileModel({
    required this.id,
    required this.fullName,
    required this.studentNumber,
    required this.role,
  });

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      id: (map['id'] ?? '').toString(),
      fullName: (map['full_name'] ?? map['fullName'] ?? '').toString(),
      studentNumber: (map['student_number'] ?? map['studentNumber'] ?? '')
          .toString(),
      role: (map['role'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'student_number': studentNumber,
      'role': role,
    };
  }
}

