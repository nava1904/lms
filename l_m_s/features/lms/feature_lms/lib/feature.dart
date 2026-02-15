import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vyuh_core/vyuh_core.dart';

import 'screens/attendance_screen.dart';
import 'screens/content_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'screens/test_window_screen.dart';
import 'screens/tests_screen.dart';
import 'screens/teacher_dashboard_screen.dart';
import 'screens/chapter_management_screen.dart';
import 'screens/content_editor_screen.dart';
import 'screens/student_analytics_screen.dart';
import 'screens/admin_login_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/premium_home_dashboard.dart';
import 'screens/figma_landing_page.dart';

const lmsFeatureId = 'lms';

final feature = FeatureDescriptor(
  name: 'lms',
  title: 'Learning Management',
  description: 'Content, attendance, and tests for students',
  icon: Icons.school_outlined,
  routes: () async {
    return [
      GoRoute(
        path: '/',
        builder: (context, state) => const FigmaLandingPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/student-dashboard',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final studentName = extra?['studentName'] as String? ?? '';
          final rollNumber = extra?['rollNumber'] as String? ?? '';
          final studentId = extra?['studentId'] as String? ?? '';
          return DashboardScreen(studentName: studentName, rollNumber: rollNumber, studentId: studentId);
        },
      ),
      GoRoute(
        path: '/teacher-dashboard',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final teacherName = extra?['teacherName'] as String? ?? 'Teacher';
          final teacherId = extra?['teacherId'] as String? ?? '';
          return TeacherDashboardScreen(teacherName: teacherName, teacherId: teacherId);
        },
      ),
      GoRoute(
        path: '/content-editor',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final chapterId = extra?['chapterId'] as String? ?? '';
          final chapterTitle = extra?['chapterTitle'] as String? ?? 'Chapter';
          final subjectTitle = extra?['subjectTitle'] as String? ?? 'Subject';
          return ContentEditorScreen(
            chapterId: chapterId,
            chapterTitle: chapterTitle,
            subjectTitle: subjectTitle,
          );
        },
      ),
      GoRoute(
        path: '/admin-login',
        builder: (context, state) => const AdminLoginScreen(),
      ),
      GoRoute(
        path: '/admin-dashboard',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final adminId = extra?['adminId'] as String? ?? '';
          final adminName = extra?['adminName'] as String? ?? 'Admin';
          final adminEmail = extra?['adminEmail'] as String? ?? '';
          final adminRole = extra?['adminRole'] as String? ?? '';
          return AdminDashboardScreen(
            adminId: adminId,
            adminName: adminName,
            adminEmail: adminEmail,
            adminRole: adminRole,
          );
        },
      ),
      GoRoute(
        path: '/premium-home',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final userName = extra?['userName'] as String? ?? 'Student';
          final userRole = extra?['userRole'] as String? ?? 'student';
          return PremiumHomeDashboard(
            userName: userName,
            userRole: userRole,
          );
        },
      ),
      GoRoute(
        path: '/content',
        builder: (context, state) {
          final subject = state.extra as Map<String, dynamic>?;
          if (subject == null) {
            return const Scaffold(body: Center(child: Text('No subject provided')));
          }
          return ContentScreen(subject: subject);
        },
      ),
      GoRoute(
        path: '/attendance',
        builder: (context, state) => const AttendanceScreen(),
      ),
      GoRoute(
        path: '/tests',
        builder: (context, state) => const TestsScreen(),
      ),
      GoRoute(
        path: '/test/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return TestWindowScreen(assessmentId: id);
        },
      ),
    ];
  },
);
