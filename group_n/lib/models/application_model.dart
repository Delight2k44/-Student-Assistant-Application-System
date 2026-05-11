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

  const ApplicationModel({
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
  });

  factory ApplicationModel.fromMap(Map<String, dynamic> map) {
    return ApplicationModel(
      id: (map['id'] ?? '').toString(),
      userId: (map['user_id'] ?? map['userId'] ?? '').toString(),
      yearOfStudy: (map['year_of_study'] ?? map['yearOfStudy'] ?? '').toString(),
      academicLevel1:
          (map['academic_level_1'] ?? map['academicLevel1'] ?? '').toString(),
      module1: (map['module_1'] ?? map['module1'] ?? '').toString(),
      academicLevel2: (map['academic_level_2'] ?? map['academicLevel2'])
          ?.toString(),
      module2: (map['module_2'] ?? map['module2'])?.toString(),
      eligibilityConfirmed: (map['eligibility_confirmed'] ??
              map['eligibilityConfirmed'] ??
              false)
          is bool
          ? (map['eligibility_confirmed'] ?? map['eligibilityConfirmed'] ?? false)
          : ((map['eligibility_confirmed'] ?? map['eligibilityConfirmed'] ?? false)
              .toString()
              .toLowerCase() ==
              'true'),
      documentUrl: (map['document_url'] ?? map['documentUrl'])?.toString(),
      status: (map['status'] ?? '').toString(),
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
    };
  }
}

