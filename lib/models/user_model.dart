/*
TPG316C Group Assignment - GROUP_A
Student Assistant Application System
Contributor: YOUR_NAME (YOUR_STUDENT_NUMBER) - Authentication Screen
*/

class UserModel {
  final String id;
  final String email;
  final String role; // 'student' or 'admin'

  UserModel({
    required this.id,
    required this.email,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      role: json['user_metadata']['role'] ?? 'student',
    );
  }
}