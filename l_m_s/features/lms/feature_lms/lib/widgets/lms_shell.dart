import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/current_student_holder.dart';
import '../theme/lms_theme.dart';
import '../theme/theme_mode_holder.dart';
import 'edtech_sidebar.dart';

/// Professional EdTech LMS v2 shell: fixed sidebar (256px) on desktop, bottom nav on mobile.
/// Applies light/dark theme from [ThemeModeScope].
class LmsShell extends StatefulWidget {
  final Widget child;

  const LmsShell({super.key, required this.child});

  @override
  State<LmsShell> createState() => _LmsShellState();
}

class _LmsShellState extends State<LmsShell> {
  static const double _sidebarBreakpoint = 700;

  bool _isAdmin(BuildContext context) =>
      GoRouterState.of(context).uri.path.contains('admin');
  bool _isTeacher(BuildContext context) =>
      GoRouterState.of(context).uri.path.contains('teacher');

  @override
  void initState() {
    super.initState();
    ThemeModeHolder.notifier.addListener(_onThemeChanged);
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    ThemeModeHolder.notifier.removeListener(_onThemeChanged);
    super.dispose();
  }

  Widget _wrapWithTheme(BuildContext context, Widget child) {
    final mode = ThemeModeHolder.value;
    if (mode == ThemeMode.dark) {
      return Theme(data: LMSTheme.darkTheme, child: child);
    }
    return child;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final useSidebar = width >= _sidebarBreakpoint;

    if (useSidebar) {
      final role = _isAdmin(context) ? SidebarRole.admin
          : _isTeacher(context) ? SidebarRole.teacher
          : SidebarRole.student;
      final userName = role == SidebarRole.student
          ? (CurrentStudentHolder.studentName ?? 'Student')
          : (role == SidebarRole.teacher ? 'Teacher' : 'Admin');
      final subtitle = role == SidebarRole.student
          ? (CurrentStudentHolder.rollNumber?.isNotEmpty == true
              ? 'Roll: ${CurrentStudentHolder.rollNumber}'
              : 'Student')
          : (role == SidebarRole.teacher ? 'Teacher' : 'Administrator');

      return _wrapWithTheme(
        context,
        Scaffold(
          backgroundColor: ThemeModeHolder.value == ThemeMode.dark
              ? LMSTheme.darkSurfaceColor
              : LMSTheme.surfaceColor,
          body: Row(
            children: [
              EdTechSidebar(
                role: role,
                userName: userName,
                userSubtitle: subtitle,
              ),
              Expanded(child: widget.child),
            ],
          ),
        ),
      );
    }

    // Mobile: bottom nav (keep existing nav items and logic)
    final items = _navItems(context);
    final currentIndex = _currentIndex(context, items);
    return _wrapWithTheme(
      context,
      Scaffold(
        backgroundColor: ThemeModeHolder.value == ThemeMode.dark
            ? LMSTheme.darkSurfaceColor
            : LMSTheme.surfaceColor,
        body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex >= 0 ? currentIndex : 0,
        onTap: (i) => _goTo(context, items[i].path),
        items: items.map((e) => BottomNavigationBarItem(
          icon: Icon(e.icon),
          label: e.label,
        )).toList(),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: LMSTheme.primaryColor,
      ),
    ),
    );
  }

  List<_NavItem> _navItems(BuildContext context) {
    if (_isAdmin(context)) {
      return const [
        _NavItem(Icons.dashboard, 'Dashboard', '/admin-dashboard'),
        _NavItem(Icons.person, 'Teachers', '/admin-dashboard'),
        _NavItem(Icons.school, 'Students', '/admin-dashboard'),
        _NavItem(Icons.folder, 'Documents', '/admin-dashboard'),
      ];
    }
    if (_isTeacher(context)) {
      return const [
        _NavItem(Icons.dashboard, 'Dashboard', '/teacher-dashboard'),
        _NavItem(Icons.quiz, 'Question Bank', '/teacher/question-bank'),
        _NavItem(Icons.people, 'Students', '/teacher/students'),
        _NavItem(Icons.analytics, 'Analytics', '/teacher/analytics'),
      ];
    }
    return const [
      _NavItem(Icons.dashboard, 'Dashboard', '/student-dashboard'),
      _NavItem(Icons.menu_book, 'Courses', '/student-courses'),
      _NavItem(Icons.quiz, 'Tests', '/tests'),
      _NavItem(Icons.analytics, 'Analytics', '/analytics'),
    ];
  }

  int _currentIndex(BuildContext context, List<_NavItem> items) {
    final loc = GoRouterState.of(context).uri.path;
    for (int i = 0; i < items.length; i++) {
      final p = items[i].path;
      if (loc == p || loc.startsWith('$p/')) return i;
      if (p == '/student-dashboard' && loc.startsWith('/student-dashboard') && !loc.startsWith('/student-courses')) return i;
      if (p == '/student-courses' && loc == '/student-courses') return i;
    }
    return 0;
  }

  void _goTo(BuildContext context, String path) {
    final state = GoRouterState.of(context);
    final isStudent = !_isAdmin(context) && !_isTeacher(context);
    if (isStudent && path == '/student-dashboard') {
      final id = CurrentStudentHolder.studentId ?? state.pathParameters['studentId'] ?? '';
      if (id.isNotEmpty) {
        context.go('/student-dashboard/$id', extra: {
          'studentName': CurrentStudentHolder.studentName ?? 'Student',
          'rollNumber': CurrentStudentHolder.rollNumber ?? '',
        });
        return;
      }
      // No student id: go to home so user can log in
      context.go('/');
      return;
    }
    if (isStudent && path == '/student-courses') {
      final id = CurrentStudentHolder.studentId ?? '';
      if (id.isNotEmpty) {
        context.go('/student-courses');
        return;
      }
      context.go('/');
      return;
    }
    if (isStudent && (path == '/analytics' || path == '/tests')) {
      final id = CurrentStudentHolder.studentId ?? state.pathParameters['studentId'] ?? '';
      if (id.isNotEmpty) {
        context.go(path, extra: {'studentId': id});
        return;
      }
      context.go('/');
      return;
    }
    context.go(path);
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String path;
  const _NavItem(this.icon, this.label, this.path);
}
