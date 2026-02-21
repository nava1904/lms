// filepath: /Users/navadeepreddy/learning mangement system/l_m_s/features/lms/feature_lms/lib/lms_feature.dart
/// LMS Feature Descriptor - Following Vyuh Architecture Pattern
///
/// **Deprecated**: Use [feature] from feature.dart as the single Vyuh FeatureDescriptor.
/// This file is kept for backward compatibility only.

library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Services
import 'services/sanity_service.dart';

// Screens
import 'screens/login_screen.dart';
import 'screens/student_dashboard_screen.dart';
import 'screens/teacher_dashboard_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/content_screen.dart';

/// Feature Descriptor for LMS Module (legacy).
/// **Deprecated**: Use [feature] from feature.dart as the single Vyuh entry.
@Deprecated('Use feature from feature.dart instead')
class LmsFeatureDescriptor {
  /// Feature name
  static const String name = 'lms';
  
  /// Feature title for display
  static const String title = 'Learning Management System';
  
  /// Feature version
  static const String version = '1.0.0';
  
  /// Feature icon
  static const IconData icon = Icons.school;
  
  /// Sanity schema types this feature uses
  static const List<String> contentTypes = [
    'course',
    'subject', 
    'chapter',
    'concept',
    'student',
    'teacher',
    'admin',
    'test',
    'question',
    'testAttempt',
    'attendance',
    'enrollment',
    'progress',
    'assignment',
    'resource',
    'discussion',
  ];
  
  /// User roles supported by this feature
  static const List<String> userRoles = ['student', 'teacher', 'admin'];
}

/// LMS Route Configuration
/// 
/// Defines all routes for the LMS feature following Vyuh's route pattern.
class LmsRoutes {
  static const String login = '/';
  static const String studentDashboard = '/student';
  static const String teacherDashboard = '/teacher';
  static const String adminDashboard = '/admin';
  static const String content = '/content';
  static const String test = '/test/:testId';
  static const String course = '/course/:courseId';
  
  /// Get all routes for this feature
  static List<RouteBase> getRoutes() {
    return [
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: studentDashboard,
        name: 'studentDashboard',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return StudentDashboardScreen(
            studentName: extra['name'] ?? 'Student',
            studentId: extra['id'] ?? '',
            studentRollNumber: extra['rollNumber'],
          );
        },
      ),
      GoRoute(
        path: teacherDashboard,
        name: 'teacherDashboard',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return TeacherDashboardScreen(
            teacherName: extra['name'] ?? 'Teacher',
            teacherId: extra['id'] ?? '',
          );
        },
      ),
      GoRoute(
        path: adminDashboard,
        name: 'adminDashboard',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return AdminDashboardScreen(
            adminId: extra['id'] ?? '',
            adminName: extra['name'] ?? 'Admin',
            adminEmail: extra['email'] ?? '',
            adminRole: extra['role'] ?? 'admin',
          );
        },
      ),
      GoRoute(
        path: content,
        name: 'content',
        builder: (context, state) => const ContentScreen(),
      ),
    ];
  }
}

/// LMS Content Blocks - Vyuh-style Content Components
/// 
/// These represent different content types that can be rendered
/// from Sanity CMS data.
abstract class LmsContentBlock {
  String get type;
  Widget build(BuildContext context, Map<String, dynamic> data);
}

/// Course Card Block
class CourseCardBlock implements LmsContentBlock {
  @override
  String get type => 'course';
  
  @override
  Widget build(BuildContext context, Map<String, dynamic> data) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.book, color: Colors.blue),
        title: Text(data['title'] ?? 'Course'),
        subtitle: Text(data['description'] ?? ''),
        trailing: Chip(label: Text(data['level'] ?? 'beginner')),
      ),
    );
  }
}

/// Subject Card Block
class SubjectCardBlock implements LmsContentBlock {
  @override
  String get type => 'subject';
  
  @override
  Widget build(BuildContext context, Map<String, dynamic> data) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.subject, color: Colors.green),
        title: Text(data['title'] ?? 'Subject'),
        subtitle: Text('${data['chapterCount'] ?? 0} chapters'),
      ),
    );
  }
}

/// Chapter Card Block
class ChapterCardBlock implements LmsContentBlock {
  @override
  String get type => 'chapter';
  
  @override
  Widget build(BuildContext context, Map<String, dynamic> data) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.article, color: Colors.orange),
        title: Text(data['title'] ?? 'Chapter'),
        subtitle: Text('${data['conceptCount'] ?? 0} lessons'),
      ),
    );
  }
}

/// Lesson/Concept Card Block
class LessonCardBlock implements LmsContentBlock {
  @override
  String get type => 'concept';
  
  @override
  Widget build(BuildContext context, Map<String, dynamic> data) {
    return Card(
      child: ListTile(
        leading: Icon(
          data['videoUrl'] != null ? Icons.play_circle : Icons.description,
          color: Colors.purple,
        ),
        title: Text(data['title'] ?? 'Lesson'),
        subtitle: Text(data['videoUrl'] != null ? 'Video lesson' : 'Text lesson'),
      ),
    );
  }
}

/// Test Card Block
class TestCardBlock implements LmsContentBlock {
  @override
  String get type => 'test';
  
  @override
  Widget build(BuildContext context, Map<String, dynamic> data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.quiz, color: Colors.indigo),
                const SizedBox(width: 8),
                Expanded(child: Text(data['title'] ?? 'Test', style: const TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
            const SizedBox(height: 8),
            Text('Duration: ${data['duration'] ?? 0} min • Total: ${data['totalMarks'] ?? 0} marks'),
          ],
        ),
      ),
    );
  }
}

/// LMS Content Block Registry
/// 
/// Register all content blocks for dynamic rendering.
class LmsContentRegistry {
  static final Map<String, LmsContentBlock> _blocks = {
    'course': CourseCardBlock(),
    'subject': SubjectCardBlock(),
    'chapter': ChapterCardBlock(),
    'concept': LessonCardBlock(),
    'test': TestCardBlock(),
  };
  
  /// Get a content block by type
  static LmsContentBlock? getBlock(String type) => _blocks[type];
  
  /// Render content dynamically based on type
  static Widget renderContent(BuildContext context, String type, Map<String, dynamic> data) {
    final block = _blocks[type];
    if (block != null) {
      return block.build(context, data);
    }
    return Card(child: ListTile(title: Text('Unknown: $type')));
  }
  
  /// Render a list of content items
  static Widget renderContentList(BuildContext context, String type, List<Map<String, dynamic>> items) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) => renderContent(context, type, items[index]),
    );
  }
}

/// LMS Feature Extension Point
/// 
/// Allows other features to extend LMS functionality.
abstract class LmsExtension {
  String get name;
  void initialize();
  void dispose();
}

/// Analytics Extension Example
class AnalyticsExtension implements LmsExtension {
  @override
  String get name => 'analytics';
  
  @override
  void initialize() {
    debugPrint('📊 Analytics extension initialized');
  }
  
  @override
  void dispose() {
    debugPrint('📊 Analytics extension disposed');
  }
  
  void trackEvent(String event, Map<String, dynamic>? params) {
    debugPrint('📊 Track: $event - $params');
  }
}

/// LMS Feature Manager
/// 
/// Main class to initialize and manage the LMS feature.
class LmsFeature {
  static final LmsFeature _instance = LmsFeature._internal();
  factory LmsFeature() => _instance;
  LmsFeature._internal();
  
  final SanityService _sanityService = SanityService();
  final List<LmsExtension> _extensions = [];
  bool _initialized = false;
  
  /// Get the singleton instance
  static LmsFeature get instance => _instance;
  
  /// Get Sanity service
  SanityService get sanityService => _sanityService;
  
  /// Check if feature is initialized
  bool get isInitialized => _initialized;
  
  /// Initialize the LMS feature
  Future<void> initialize() async {
    if (_initialized) return;
    
    debugPrint('🚀 Initializing LMS Feature v${LmsFeatureDescriptor.version}');
    
    // Initialize extensions
    for (final extension in _extensions) {
      extension.initialize();
    }
    
    _initialized = true;
    debugPrint('✅ LMS Feature initialized');
  }
  
  /// Register an extension
  void registerExtension(LmsExtension extension) {
    _extensions.add(extension);
    if (_initialized) {
      extension.initialize();
    }
  }
  
  /// Dispose the feature
  void dispose() {
    for (final extension in _extensions) {
      extension.dispose();
    }
    _extensions.clear();
    _initialized = false;
  }
  
  /// Get routes for this feature
  List<RouteBase> getRoutes() => LmsRoutes.getRoutes();
}
