/// Vyuh-inspired Auth Configuration
/// Following Vyuh architecture patterns for extensible authentication
class VyuhAuthConfig {
  /// Mock user database for demo/testing
  static final mockUsers = {
    'student@example.com': {
      'id': 'student_001',
      'password': 'student123',
      'name': 'Rahul Kumar',
      'role': 'student',
      'email': 'student@example.com',
      'avatar': 'https://i.pravatar.cc/150?img=1',
      'createdAt': '2024-01-01',
    },
    'teacher@example.com': {
      'id': 'teacher_001',
      'password': 'teacher123',
      'name': 'Prof. Amit Kumar',
      'role': 'teacher',
      'email': 'teacher@example.com',
      'avatar': 'https://i.pravatar.cc/150?img=2',
      'createdAt': '2024-01-01',
    },
    'admin@example.com': {
      'id': 'admin_001',
      'password': 'admin123',
      'name': 'Admin User',
      'role': 'admin',
      'email': 'admin@example.com',
      'avatar': 'https://i.pravatar.cc/150?img=3',
      'createdAt': '2024-01-01',
    },
  };

  /// Auth configuration options
  static const authOptions = {
    'enableAutoLogin': true,
    'enableBiometric': false,
    'enableSocialLogin': false,
    'enablePasswordReset': true,
    'enableRegistration': true,
    'sessionTimeout': 3600, // 1 hour
  };

  /// Get demo user by email
  static Map<String, dynamic>? getDemoUser(String email) {
    return mockUsers[email];
  }

  /// Validate demo credentials
  static bool validateCredentials(String email, String password) {
    final user = mockUsers[email];
    return user != null && user['password'] == password;
  }

  /// Get all user roles
  static const userRoles = ['student', 'teacher', 'admin'];

  /// Role-based permissions
  static const rolePermissions = {
    'student': [
      'view_courses',
      'submit_assignments',
      'take_tests',
      'view_grades',
      'access_forum',
    ],
    'teacher': [
      'create_courses',
      'manage_assignments',
      'create_tests',
      'grade_submissions',
      'manage_forum',
      'view_reports',
    ],
    'admin': [
      'manage_users',
      'manage_courses',
      'manage_tests',
      'view_analytics',
      'system_settings',
      'manage_documents',
    ],
  };
}
