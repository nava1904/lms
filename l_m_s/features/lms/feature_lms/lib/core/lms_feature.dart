// filepath: /Users/navadeepreddy/learning mangement system/l_m_s/features/lms/feature_lms/lib/core/lms_feature.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/admin_dashboard_screen.dart';
import '../screens/login_screen.dart';
import '../screens/student_dashboard_screen.dart';
import '../screens/teacher_dashboard_screen.dart';
import '../services/sanity_service.dart';
import 'content_blocks.dart';
import 'extension_points.dart';
import 'feature_descriptor.dart';
import 'plugins.dart';
import 'route_builder.dart';

/// LMS Feature Descriptor (legacy).
/// **Deprecated**: Use [feature] from ../feature.dart as the single Vyuh entry.
@Deprecated('Use feature from feature.dart instead')
class LmsFeature extends FeatureDescriptor {
  static final LmsFeature _instance = LmsFeature._internal();
  factory LmsFeature() => _instance;
  LmsFeature._internal();
  
  final SanityService _sanityService = SanityService();
  
  @override
  String get name => 'lms';
  
  @override
  String get title => 'Learning Management System';
  
  @override
  String get description => 'Complete LMS with courses, tests, and student management';
  
  @override
  IconData get icon => Icons.school;
  
  @override
  List<RouteBase> get routes => [
    // Login Route
    VyuhRouteBuilder.route(
      path: '/',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    
    // Student Dashboard
    VyuhRouteBuilder.route(
      path: '/student/:studentId',
      name: 'student-dashboard',
      builder: (context, state) {
        final studentId = state.pathParameters['studentId'] ?? '';
        final extra = state.extra as Map<String, dynamic>?;
        return StudentDashboardScreen(
          studentId: studentId,
          studentName: extra?['name'] ?? 'Student',
          studentRollNumber: extra?['rollNumber'],
        );
      },
    ),
    
    // Teacher Dashboard
    VyuhRouteBuilder.route(
      path: '/teacher/:teacherId',
      name: 'teacher-dashboard',
      builder: (context, state) {
        final teacherId = state.pathParameters['teacherId'] ?? '';
        final extra = state.extra as Map<String, dynamic>?;
        return TeacherDashboardScreen(
          teacherId: teacherId,
          teacherName: extra?['name'] ?? 'Teacher',
        );
      },
    ),
    
    // Admin Dashboard
    VyuhRouteBuilder.route(
      path: '/admin/:adminId',
      name: 'admin-dashboard',
      builder: (context, state) {
        final adminId = state.pathParameters['adminId'] ?? '';
        final extra = state.extra as Map<String, dynamic>?;
        return AdminDashboardScreen(
          adminId: adminId,
          adminName: extra?['name'] ?? 'Admin',
          adminEmail: extra?['email'] ?? '',
          adminRole: extra?['role'] ?? 'admin',
        );
      },
    ),
  ];
  
  @override
  Map<String, ContentBuilder> get contentBuilders => {
    'course': (context, content) => CourseCardBlock().build(context, content),
    'subject': (context, content) => SubjectCardBlock().build(context, content),
    'chapter': (context, content) => ChapterCardBlock().build(context, content),
    'concept': (context, content) => LessonBlock().build(context, content),
    'test': (context, content) => TestCardBlock().build(context, content),
    'question': (context, content) => QuestionBlock().build(context, content),
    'student': (context, content) => StudentProfileBlock().build(context, content),
    'teacher': (context, content) => TeacherProfileBlock().build(context, content),
  };
  
  @override
  List<ExtensionPoint> get extensionPoints => LmsExtensionPoints.all;
  
  @override
  List<Plugin> get plugins => [
    AnalyticsPlugin(),
    AuthPlugin(),
    NotificationPlugin(),
    CachePlugin(),
  ];
  
  @override
  Future<void> init() async {
    debugPrint('🎓 LMS Feature initializing...');
    
    // Register content blocks
    registerContentBlocks();
    
    // Register built-in extensions
    registerBuiltInExtensions();
    
    // Initialize plugins
    for (final plugin in plugins) {
      await plugin.init();
    }
    
    debugPrint('🎓 LMS Feature initialized');
  }
  
  @override
  Future<void> dispose() async {
    for (final plugin in plugins) {
      await plugin.dispose();
    }
    debugPrint('🎓 LMS Feature disposed');
  }
  
  /// Get the Sanity service
  SanityService get sanityService => _sanityService;
  
  /// Build content from CMS data
  Widget buildContent(BuildContext context, Map<String, dynamic> content) {
    final type = content['_type'] as String?;
    if (type == null) return const SizedBox.shrink();
    
    final builder = contentBuilders[type];
    if (builder == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Unknown content type: $type'),
        ),
      );
    }
    
    return builder(context, content);
  }
  
  /// Build a list of content items
  Widget buildContentList(BuildContext context, List<Map<String, dynamic>> items) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: buildContent(context, items[index]),
      ),
    );
  }
  
  /// Build a grid of content items
  Widget buildContentGrid(BuildContext context, List<Map<String, dynamic>> items, {int crossAxisCount = 3}) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => buildContent(context, items[index]),
    );
  }
}

/// Global access to the LMS feature
LmsFeature get lmsFeature => LmsFeature();
