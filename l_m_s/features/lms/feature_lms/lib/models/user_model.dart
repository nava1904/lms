// filepath: /Users/navadeepreddy/learning mangement system/l_m_s/features/lms/feature_lms/lib/models/user_model.dart

import '../core/types.dart';

/// Base user model
abstract class UserModel {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? phone;
  final String? profileImage;
  final bool isActive;
  final DateTime? createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.profileImage,
    this.isActive = true,
    this.createdAt,
  });

  Map<String, dynamic> toJson();
}

/// Student model
class StudentModel extends UserModel {
  final String rollNumber;
  final List<String> enrolledCourseIds;
  final DateTime? dateOfBirth;
  final String? address;

  const StudentModel({
    required super.id,
    required super.name,
    required super.email,
    required this.rollNumber,
    this.enrolledCourseIds = const [],
    this.dateOfBirth,
    this.address,
    super.phone,
    super.profileImage,
    super.isActive,
    super.createdAt,
  }) : super(role: UserRole.student);

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      rollNumber: json['rollNumber'] ?? '',
      phone: json['phone'],
      profileImage: json['profileImage']?['asset']?['url'],
      isActive: json['isActive'] ?? true,
      enrolledCourseIds: (json['enrolledCourses'] as List?)
          ?.map((c) => c['_id']?.toString() ?? '')
          .toList() ?? [],
      dateOfBirth: json['dateOfBirth'] != null ? DateTime.tryParse(json['dateOfBirth']) : null,
      address: json['address'],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    '_type': 'student',
    'name': name,
    'email': email,
    'rollNumber': rollNumber,
    'phone': phone,
    'isActive': isActive,
    'address': address,
    'dateOfBirth': dateOfBirth?.toIso8601String().split('T')[0],
  };
}

/// Teacher model
class TeacherModel extends UserModel {
  final String? specialization;
  final String? qualification;
  final String? bio;
  final List<String> subjectIds;

  const TeacherModel({
    required super.id,
    required super.name,
    required super.email,
    this.specialization,
    this.qualification,
    this.bio,
    this.subjectIds = const [],
    super.phone,
    super.profileImage,
    super.isActive,
    super.createdAt,
  }) : super(role: UserRole.teacher);

  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    return TeacherModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      specialization: json['specialization'],
      qualification: json['qualification'],
      bio: json['bio'],
      phone: json['phone'],
      profileImage: json['profileImage']?['asset']?['url'],
      isActive: json['isActive'] ?? true,
      subjectIds: (json['subjects'] as List?)
          ?.map((s) => s['_id']?.toString() ?? '')
          .toList() ?? [],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    '_type': 'teacher',
    'name': name,
    'email': email,
    'phone': phone,
    'specialization': specialization,
    'qualification': qualification,
    'bio': bio,
    'isActive': isActive,
  };
}

/// Admin model
class AdminModel extends UserModel {
  final String adminRole;
  final List<String> permissions;

  const AdminModel({
    required super.id,
    required super.name,
    required super.email,
    this.adminRole = 'content_manager',
    this.permissions = const [],
    super.phone,
    super.profileImage,
    super.isActive,
    super.createdAt,
  }) : super(role: UserRole.admin);

  factory AdminModel.fromJson(Map<String, dynamic> json) {
    return AdminModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      adminRole: json['role'] ?? 'content_manager',
      permissions: (json['permissions'] as List?)?.cast<String>() ?? [],
      phone: json['phone'],
      profileImage: json['profileImage']?['asset']?['url'],
      isActive: json['isActive'] ?? true,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    '_type': 'admin',
    'name': name,
    'email': email,
    'role': adminRole,
    'permissions': permissions,
    'isActive': isActive,
  };
}
