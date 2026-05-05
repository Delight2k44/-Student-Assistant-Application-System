/*
 * Student Numbers: (all your group member numbers here)
 * Student Names: (all your group member names here)
 * Question: Application Model
 */

class ApplicationModel {
  final String id;
  final String userId;
  final String yearOfStudy;
  final String academicLevel1;
  final String module1;
  final String? academicLevel2;
  final String? module2;
  final bool eligibilityConfirmed;
  final String? documentUrl;
  final String status;
  final DateTime createdAt;

  ApplicationModel({
    required this.id,
    required this.userId,
    required this.yearOfStudy,
    required this.academicLevel1,
    required this.module1,
    this.academicLevel2,
    this.module2,
    required this.eligibilityConfirmed,
    this.documentUrl,
    required this.status,
    required this.createdAt,
  });

  factory ApplicationModel.fromMap(Map<String, dynamic> map) {
    return ApplicationModel(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      yearOfStudy: map['year_of_study'] ?? '',
      academicLevel1: map['academic_level_1'] ?? '',
      module1: map['module_1'] ?? '',
      academicLevel2: map['academic_level_2'],
      module2: map['module_2'],
      eligibilityConfirmed: map['eligibility_confirmed'] ?? false,
      documentUrl: map['document_url'],
      status: map['status'] ?? 'pending',
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'year_of_study': yearOfStudy,
      'academic_level_1': academicLevel1,
      'module_1': module1,
      'academic_level_2': academicLevel2,
      'module_2': module2,
      'eligibility_confirmed': eligibilityConfirmed,
      'document_url': documentUrl,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
