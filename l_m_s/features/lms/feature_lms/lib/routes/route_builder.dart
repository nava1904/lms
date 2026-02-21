// filepath: /Users/navadeepreddy/learning mangement system/l_m_s/features/lms/feature_lms/lib/routes/route_builder.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/types.dart';
import '../plugins/auth_plugin.dart';

/// Route configuration following Vyuh patterns
class LmsRoute {
  final String path;
  final String name;
  final Widget Function(BuildContext, GoRouterState) builder;
  final List<UserRole>? allowedRoles;
  final bool requiresAuth;
  final List<LmsRoute> children;

  const LmsRoute({
    required this.path,
    required this.name,
    required this.builder,
    this.allowedRoles,
    this.requiresAuth = false,
    this.children = const [],
  });

  /// Convert to GoRoute
  GoRoute toGoRoute() {
    return GoRoute(
      path: path,
      name: name,
      pageBuilder: (context, state) {
        // Check authentication
        if (requiresAuth && !AuthPlugin().isAuthenticated) {
          return const NoTransitionPage(
            child: _UnauthorizedScreen(),
          );
        }
        
        // Check role permissions
        if (allowedRoles != null && allowedRoles!.isNotEmpty) {
          final userRole = AuthPlugin().userRole;
          if (userRole == null || !allowedRoles!.contains(userRole)) {
            return const NoTransitionPage(
              child: _ForbiddenScreen(),
            );
          }
        }
        
        return NoTransitionPage(child: builder(context, state));
      },
      routes: children.map((r) => r.toGoRoute()).toList(),
    );
  }
}

/// Route builder utility
class LmsRouteBuilder {
  /// Build routes from LmsRoute definitions
  static List<RouteBase> buildRoutes(List<LmsRoute> routes) {
    return routes.map((r) => r.toGoRoute()).toList();
  }

  /// Create a protected route (requires auth)
  static LmsRoute protected({
    required String path,
    required String name,
    required Widget Function(BuildContext, GoRouterState) builder,
    List<UserRole>? allowedRoles,
    List<LmsRoute> children = const [],
  }) {
    return LmsRoute(
      path: path,
      name: name,
      builder: builder,
      requiresAuth: true,
      allowedRoles: allowedRoles,
      children: children,
    );
  }

  /// Create a public route
  static LmsRoute public({
    required String path,
    required String name,
    required Widget Function(BuildContext, GoRouterState) builder,
    List<LmsRoute> children = const [],
  }) {
    return LmsRoute(
      path: path,
      name: name,
      builder: builder,
      requiresAuth: false,
      children: children,
    );
  }

  /// Create a student-only route
  static LmsRoute studentOnly({
    required String path,
    required String name,
    required Widget Function(BuildContext, GoRouterState) builder,
  }) {
    return protected(
      path: path,
      name: name,
      builder: builder,
      allowedRoles: [UserRole.student],
    );
  }

  /// Create a teacher-only route
  static LmsRoute teacherOnly({
    required String path,
    required String name,
    required Widget Function(BuildContext, GoRouterState) builder,
  }) {
    return protected(
      path: path,
      name: name,
      builder: builder,
      allowedRoles: [UserRole.teacher, UserRole.admin],
    );
  }

  /// Create an admin-only route
  static LmsRoute adminOnly({
    required String path,
    required String name,
    required Widget Function(BuildContext, GoRouterState) builder,
  }) {
    return protected(
      path: path,
      name: name,
      builder: builder,
      allowedRoles: [UserRole.admin],
    );
  }
}

/// Unauthorized screen
class _UnauthorizedScreen extends StatelessWidget {
  const _UnauthorizedScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Please login to continue', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/login'),
              child: const Text('Go to Login'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Forbidden screen
class _ForbiddenScreen extends StatelessWidget {
  const _ForbiddenScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.block, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Access Denied', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            const Text('You don\'t have permission to access this page'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Extension for easy navigation
extension LmsNavigation on BuildContext {
  /// Navigate to student dashboard
  void goToStudentDashboard({
    required String studentName,
    required String studentId,
    String? rollNumber,
  }) {
    go('/student-dashboard/$studentId', extra: {
      'studentName': studentName,
      'rollNumber': rollNumber ?? '',
    });
  }

  /// Navigate to teacher dashboard
  void goToTeacherDashboard({
    required String teacherName,
    required String teacherId,
  }) {
    go('/teacher-dashboard', extra: {
      'teacherName': teacherName,
      'teacherId': teacherId,
    });
  }

  /// Navigate to admin dashboard
  void goToAdminDashboard({
    required String adminId,
    required String adminName,
    required String adminEmail,
    required String adminRole,
  }) {
    go('/admin-dashboard', extra: {
      'adminId': adminId,
      'adminName': adminName,
      'adminEmail': adminEmail,
      'adminRole': adminRole,
    });
  }

  /// Navigate to test
  void goToTest(String testId) {
    go('/test/$testId');
  }

  /// Navigate to content
  void goToContent({String? courseId, String? subjectId, String? chapterId}) {
    go('/content', extra: {
      'courseId': courseId,
      'subjectId': subjectId,
      'chapterId': chapterId,
    });
  }
}
