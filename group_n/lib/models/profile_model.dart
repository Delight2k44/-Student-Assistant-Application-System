/*
 * 223022577
 * TD Tshitangano
 * Question: Profile Model
 */

class ProfileModel {
  final String id;
  final String fullName;
  final String studentNumber;
  final String role;

  ProfileModel({
    required this.id,
    required this.fullName,
    required this.studentNumber,
    required this.role,
  });

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      id: map['id'] ?? '',
      fullName: map['full_name'] ?? '',
      studentNumber: map['student_number'] ?? '',
      role: map['role'] ?? 'student',
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
