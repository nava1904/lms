import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vyuh_core/vyuh_core.dart';

import 'core/current_student_holder.dart';
import 'theme/theme_mode_holder.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/admin_login_screen.dart';
import 'screens/attendance_screen.dart';
import 'screens/content_editor_screen.dart';
import 'screens/content_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/edtech_home_page.dart';
import 'screens/login_screen.dart';
import 'screens/premium_home_dashboard.dart';
import 'screens/student_analytics_screen.dart';
import 'screens/teacher_dashboard_screen.dart';
import 'screens/teacher_placeholder_screen.dart';
import 'screens/teacher_question_add_screen.dart';
import 'screens/teacher_question_bank_screen.dart';
import 'screens/teacher_paper_builder_screen.dart';
import 'screens/teacher_students_screen.dart';
import 'screens/teacher_student_detail_screen.dart';
import 'screens/teacher_analytics_screen.dart';
import 'screens/teacher_content_studio_screen.dart';
import 'screens/teacher_worksheets_screen.dart';
import 'screens/teacher_settings_screen.dart';
import 'screens/test_window_screen.dart';
import 'screens/tests_screen.dart';
import 'widgets/lms_shell.dart';

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
        pageBuilder: (context, state) => const NoTransitionPage(
          child: EdTechHomePage(),
        ),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: LoginScreen(),
        ),
      ),
      GoRoute(
        path: '/admin-login',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: AdminLoginScreen(),
        ),
      ),
      ShellRoute(
        builder: (context, state, child) => ThemeModeScope(
          notifier: ThemeModeHolder.notifier,
          child: LmsShell(child: child),
        ),
        routes: [
          GoRoute(
            path: '/student-dashboard/:studentId',
            pageBuilder: (context, state) {
              final studentId = state.pathParameters['studentId'] ?? '';
              final extra = state.extra as Map<String, dynamic>?;
              final studentName = extra?['studentName'] as String? ?? 'Student';
              final rollNumber = extra?['rollNumber'] as String? ?? '';
              if (studentId.isNotEmpty) {
                CurrentStudentHolder.set(studentId, name: studentName, roll: rollNumber);
              }
              return NoTransitionPage(
                child: DashboardScreen(studentName: studentName, rollNumber: rollNumber, studentId: studentId),
              );
            },
          ),
          // Fallback when /student-dashboard is used without studentId (e.g. from sidebar when not logged in)
          GoRoute(
            path: '/student-dashboard',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: EdTechHomePage(),
            ),
          ),
          GoRoute(
            path: '/analytics',
            pageBuilder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              final studentId = extra?['studentId'] as String? ?? CurrentStudentHolder.studentId ?? '';
              return NoTransitionPage(
                child: StudentAnalyticsScreen(subjectId: studentId, subjectTitle: 'Analytics'),
              );
            },
          ),
          GoRoute(
            path: '/teacher-dashboard',
            redirect: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              final teacherId = extra?['teacherId'] as String? ?? '';
              if (teacherId.isEmpty) return '/login';
              return null;
            },
            pageBuilder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              final teacherName = extra?['teacherName'] as String? ?? 'Teacher';
              final teacherId = extra?['teacherId'] as String? ?? '';
              return NoTransitionPage(
                child: TeacherDashboardScreen(teacherName: teacherName, teacherId: teacherId),
              );
            },
          ),
          GoRoute(
            path: '/teacher/question-bank',
            pageBuilder: (_, __) => const NoTransitionPage(
              child: TeacherQuestionBankScreen(),
            ),
            routes: [
              GoRoute(
                path: 'add',
                pageBuilder: (_, __) => const NoTransitionPage(
                  child: TeacherQuestionAddScreen(),
                ),
              ),
              GoRoute(
                path: 'edit/:id',
                pageBuilder: (context, state) {
                  final id = state.pathParameters['id'] ?? '';
                  return NoTransitionPage(
                    child: TeacherQuestionAddScreen(editQuestionId: id.isEmpty ? null : id),
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: '/teacher/paper-builder',
            pageBuilder: (_, __) => const NoTransitionPage(
              child: TeacherPaperBuilderScreen(),
            ),
          ),
          GoRoute(
            path: '/teacher/worksheets',
            pageBuilder: (_, __) => const NoTransitionPage(
              child: TeacherWorksheetsScreen(),
            ),
          ),
          GoRoute(
            path: '/teacher/students',
            pageBuilder: (_, __) => const NoTransitionPage(
              child: TeacherStudentsScreen(),
            ),
            routes: [
              GoRoute(
                path: ':id',
                pageBuilder: (context, state) {
                  final id = state.pathParameters['id'] ?? '';
                  final extra = state.extra as Map<String, dynamic>?;
                  return NoTransitionPage(
                    child: TeacherStudentDetailScreen(studentId: id, student: extra),
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: '/teacher/analytics',
            pageBuilder: (_, __) => const NoTransitionPage(
              child: TeacherAnalyticsScreen(),
            ),
          ),
          GoRoute(
            path: '/teacher/content-studio',
            pageBuilder: (_, __) => const NoTransitionPage(
              child: TeacherContentStudioScreen(),
            ),
          ),
          GoRoute(
            path: '/teacher/settings',
            pageBuilder: (_, __) => const NoTransitionPage(
              child: TeacherSettingsScreen(),
            ),
          ),
          GoRoute(
            path: '/content-editor',
            pageBuilder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              final chapterId = extra?['chapterId'] as String? ?? '';
              final chapterTitle = extra?['chapterTitle'] as String? ?? 'Chapter';
              final subjectTitle = extra?['subjectTitle'] as String? ?? 'Subject';
              return NoTransitionPage(
                child: ContentEditorScreen(
                  chapterId: chapterId,
                  chapterTitle: chapterTitle,
                  subjectTitle: subjectTitle,
                ),
              );
            },
          ),
          GoRoute(
            path: '/admin-dashboard',
            pageBuilder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              final adminId = extra?['adminId'] as String? ?? '';
              final adminName = extra?['adminName'] as String? ?? 'Admin';
              final adminEmail = extra?['adminEmail'] as String? ?? '';
              final adminRole = extra?['adminRole'] as String? ?? '';
              if (adminId.isEmpty) {
                return NoTransitionPage(
                  child: _RedirectToLogin(loginPath: '/admin-login'),
                );
              }
              return NoTransitionPage(
                child: AdminDashboardScreen(
                  adminId: adminId,
                  adminName: adminName,
                  adminEmail: adminEmail,
                  adminRole: adminRole,
                ),
              );
            },
          ),
          GoRoute(
            path: '/premium-home',
            pageBuilder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              final userName = extra?['userName'] as String? ?? 'Student';
              final userRole = extra?['userRole'] as String? ?? 'student';
              return NoTransitionPage(
                child: PremiumHomeDashboard(
                  userName: userName,
                  userRole: userRole,
                ),
              );
            },
          ),
          GoRoute(
            path: '/content',
            pageBuilder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return NoTransitionPage(
                child: ContentScreen(
                  courseId: extra?['courseId'] as String?,
                  subjectId: extra?['subjectId'] as String?,
                  chapterId: extra?['chapterId'] as String?,
                ),
              );
            },
          ),
          GoRoute(
            path: '/attendance',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AttendanceScreen(),
            ),
          ),
          GoRoute(
            path: '/tests',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: TestsScreen(),
            ),
          ),
          GoRoute(
            path: '/test/:id',
            redirect: (context, state) {
              final studentId = CurrentStudentHolder.studentId ?? '';
              if (studentId.isEmpty) {
                return '/login';
              }
              return null;
            },
            pageBuilder: (context, state) {
              final id = state.pathParameters['id']!;
              final extra = state.extra as Map<String, dynamic>?;
              final studentId = extra?['studentId'] as String? ?? CurrentStudentHolder.studentId ?? '';
              return NoTransitionPage(
                child: TestWindowScreen(assessmentId: id, studentId: studentId),
              );
            },
          ),
        ],
      ),
    ];
  },
);

/// Redirects to [loginPath] on first frame. Used when protected route is opened without auth (e.g. direct URL).
class _RedirectToLogin extends StatefulWidget {
  final String loginPath;

  const _RedirectToLogin({required this.loginPath});

  @override
  State<_RedirectToLogin> createState() => _RedirectToLoginState();
}

class _RedirectToLoginState extends State<_RedirectToLogin> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.go(widget.loginPath);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
