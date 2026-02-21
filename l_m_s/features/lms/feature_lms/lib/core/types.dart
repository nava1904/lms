// filepath: /Users/navadeepreddy/learning mangement system/l_m_s/features/lms/feature_lms/lib/core/types.dart

/// Core types for the LMS following Vyuh patterns
library;


/// User roles in the LMS system
enum UserRole {
  student,
  teacher,
  admin,
  guest;

  String get displayName {
    switch (this) {
      case UserRole.student: return 'Student';
      case UserRole.teacher: return 'Teacher';
      case UserRole.admin: return 'Admin';
      case UserRole.guest: return 'Guest';
    }
  }

  bool get canCreateContent => this == UserRole.teacher || this == UserRole.admin;
  bool get canManageUsers => this == UserRole.admin;
  bool get canTakeTests => this == UserRole.student;
  bool get canViewAnalytics => this == UserRole.teacher || this == UserRole.admin;
}

/// Authentication state
enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// Content types in the LMS
enum ContentType {
  course,
  subject,
  chapter,
  concept,
  video,
  document,
  quiz,
  assignment,
}

/// Test/Assessment status
enum TestStatus {
  draft,
  published,
  archived,
  inProgress,
  completed,
}

/// Attendance status
enum AttendanceStatus {
  present,
  absent,
  late,
  excused;

  String get displayName {
    switch (this) {
      case AttendanceStatus.present: return 'Present';
      case AttendanceStatus.absent: return 'Absent';
      case AttendanceStatus.late: return 'Late';
      case AttendanceStatus.excused: return 'Excused';
    }
  }
}

/// Result wrapper for operations
class Result<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  const Result.success(this.data) : error = null, isSuccess = true;
  const Result.failure(this.error) : data = null, isSuccess = false;

  R fold<R>(R Function(String error) onFailure, R Function(T data) onSuccess) {
    if (isSuccess && data != null) {
      return onSuccess(data as T);
    }
    return onFailure(error ?? 'Unknown error');
  }
}
