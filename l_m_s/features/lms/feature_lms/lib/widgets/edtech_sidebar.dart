import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/lms_theme.dart';
import '../theme/theme_mode_holder.dart';
import '../core/current_student_holder.dart';

/// Professional EdTech LMS v2 sidebar: fixed 256px, logo, nav, user profile.
/// Student/Teacher: white bg. Admin: dark slate.
enum SidebarRole { student, teacher, admin }

class EdTechSidebar extends StatelessWidget {
  final SidebarRole role;
  final String userName;
  final String userSubtitle;

  const EdTechSidebar({
    super.key,
    required this.role,
    required this.userName,
    this.userSubtitle = '',
  });

  static const double width = 256;

  @override
  Widget build(BuildContext context) {
    final isAdmin = role == SidebarRole.admin;
    final navItems = _navItems(context);
    final initials = userName.isNotEmpty
        ? userName.trim().split(RegExp(r'\s+')).map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
        : '?';

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: isAdmin ? LMSTheme.sidebarDarkBg : Colors.white,
        border: Border(right: BorderSide(color: isAdmin ? LMSTheme.sidebarDarkBorder : LMSTheme.borderColor)),
        boxShadow: isAdmin ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(2, 0))],
      ),
      child: Column(
        children: [
          _Logo(isAdmin: isAdmin, isAdminPanel: role == SidebarRole.admin),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: ThemeModeHolder.notifier,
            builder: (_, mode, __) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: [
                  Icon(
                    mode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
                    size: 18,
                    color: isAdmin ? LMSTheme.sidebarDarkMuted : LMSTheme.mutedForeground,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    mode == ThemeMode.dark ? 'Dark' : 'Light',
                    style: TextStyle(
                      fontSize: 12,
                      color: isAdmin ? LMSTheme.sidebarDarkMuted : LMSTheme.mutedForeground,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    iconSize: 20,
                    icon: Icon(mode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
                    onPressed: () => ThemeModeHolder.toggle(),
                    color: isAdmin ? LMSTheme.sidebarDarkText : LMSTheme.primaryColor,
                    tooltip: mode == ThemeMode.dark ? 'Switch to light' : 'Switch to dark',
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
              children: navItems.map((e) => _NavTile(
                isActive: _isActive(context, e.path),
                icon: e.icon,
                label: e.label,
                isAdmin: isAdmin,
                onTap: () => _goTo(context, e.path),
              )).toList(),
            ),
          ),
          _UserProfile(
            initials: initials,
            userName: userName,
            subtitle: userSubtitle.isEmpty ? _defaultSubtitle : userSubtitle,
            isAdmin: isAdmin,
            role: role,
          ),
        ],
      ),
    );
  }

  String get _defaultSubtitle {
    switch (role) {
      case SidebarRole.student: return 'Student';
      case SidebarRole.teacher: return 'Teacher';
      case SidebarRole.admin: return 'Administrator';
    }
  }

  List<_NavItem> _navItems(BuildContext context) {
    final studentId = CurrentStudentHolder.studentId ?? '';
    final baseStudent = studentId.isNotEmpty ? '/student-dashboard/$studentId' : '/student-dashboard';
    switch (role) {
      case SidebarRole.student:
        return [
          _NavItem(Icons.dashboard_outlined, 'Dashboard', baseStudent),
          _NavItem(Icons.menu_book_outlined, 'My Courses', baseStudent),
          _NavItem(Icons.analytics_outlined, 'Analytics', '/analytics'),
          _NavItem(Icons.quiz_outlined, 'Tests', '/tests'),
          _NavItem(Icons.settings_outlined, 'Settings', baseStudent),
          _NavItem(Icons.logout, 'Logout', '/logout'),
        ];
      case SidebarRole.teacher:
        return [
          _NavItem(Icons.dashboard_outlined, 'Dashboard', '/teacher-dashboard'),
          _NavItem(Icons.quiz_outlined, 'Question Bank', '/teacher/question-bank'),
          _NavItem(Icons.description_outlined, 'Paper Builder', '/teacher/paper-builder'),
          _NavItem(Icons.assignment_outlined, 'Worksheets', '/teacher/worksheets'),
          _NavItem(Icons.people_outline, 'Students', '/teacher/students'),
          _NavItem(Icons.analytics_outlined, 'Analytics', '/teacher/analytics'),
          _NavItem(Icons.video_library_outlined, 'Content Studio', '/teacher/content-studio'),
          _NavItem(Icons.settings_outlined, 'Settings', '/teacher/settings'),
          _NavItem(Icons.logout, 'Logout', '/logout'),
        ];
      case SidebarRole.admin:
        return [
          _NavItem(Icons.dashboard_outlined, 'Dashboard', '/admin-dashboard'),
          _NavItem(Icons.school_outlined, 'Teachers', '/admin-dashboard'),
          _NavItem(Icons.people_outline, 'Students', '/admin-dashboard'),
          _NavItem(Icons.folder_outlined, 'Documents', '/admin-dashboard'),
          _NavItem(Icons.check_circle_outline, 'Attendance', '/attendance'),
          _NavItem(Icons.calendar_today_outlined, 'Test Schedule', '/admin-dashboard'),
          _NavItem(Icons.settings_outlined, 'Settings', '/admin-dashboard'),
          _NavItem(Icons.logout, 'Logout', '/logout'),
        ];
    }
  }

  bool _isActive(BuildContext context, String path) {
    if (path == '/logout') return false;
    final loc = GoRouterState.of(context).uri.path;
    if (path.contains('student-dashboard') && loc.contains('student-dashboard')) return true;
    if (path == '/analytics' && loc == '/analytics') return true;
    if (path == '/tests' && loc.startsWith('/tests')) return true;
    if (path == '/teacher-dashboard' && loc == '/teacher-dashboard') return true;
    if (path.startsWith('/teacher/') && loc.startsWith(path)) return true;
    if (path == '/admin-dashboard' && loc.contains('admin')) return true;
    if (path == '/attendance' && loc == '/attendance') return true;
    return loc == path || loc.startsWith('$path/');
  }

  void _goTo(BuildContext context, String path) {
    if (path == '/logout') {
      CurrentStudentHolder.clear();
      context.go('/');
      return;
    }
    final state = GoRouterState.of(context);
    if (path.contains('student-dashboard') && path != '/student-dashboard') {
      final id = CurrentStudentHolder.studentId ?? state.pathParameters['studentId'] ?? '';
      if (id.isNotEmpty) {
        context.go('/student-dashboard/$id', extra: {
          'studentName': CurrentStudentHolder.studentName ?? 'Student',
          'rollNumber': CurrentStudentHolder.rollNumber ?? '',
        });
        return;
      }
      context.go('/');
      return;
    }
    if (path == '/student-dashboard') {
      final id = CurrentStudentHolder.studentId ?? state.pathParameters['studentId'] ?? '';
      if (id.isNotEmpty) {
        context.go('/student-dashboard/$id', extra: {
          'studentName': CurrentStudentHolder.studentName ?? 'Student',
          'rollNumber': CurrentStudentHolder.rollNumber ?? '',
        });
        return;
      }
      context.go('/');
      return;
    }
    if (path == '/analytics' || path == '/tests') {
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

class _Logo extends StatelessWidget {
  final bool isAdmin;
  final bool isAdminPanel;

  const _Logo({required this.isAdmin, required this.isAdminPanel});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: isAdmin ? LMSTheme.sidebarDarkBorder : LMSTheme.borderColor)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: LMSTheme.primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isAdminPanel ? Icons.shield_outlined : Icons.menu_book_rounded,
              size: 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isAdminPanel ? 'Admin Panel' : 'LearnHub',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: isAdmin ? LMSTheme.sidebarDarkText : LMSTheme.onSurfaceColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String path;
  _NavItem(this.icon, this.label, this.path);
}

class _NavTile extends StatelessWidget {
  final bool isActive;
  final IconData icon;
  final String label;
  final bool isAdmin;
  final VoidCallback onTap;

  const _NavTile({
    required this.isActive,
    required this.icon,
    required this.label,
    required this.isAdmin,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: isActive
            ? (isAdmin ? LMSTheme.primaryColor : LMSTheme.primaryColor)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isActive
                      ? Colors.white
                      : (isAdmin ? LMSTheme.sidebarDarkMuted : LMSTheme.mutedForeground),
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isActive
                        ? Colors.white
                        : (isAdmin ? LMSTheme.sidebarDarkMuted : LMSTheme.mutedForeground),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UserProfile extends StatelessWidget {
  final String initials;
  final String userName;
  final String subtitle;
  final bool isAdmin;
  final SidebarRole role;

  const _UserProfile({
    required this.initials,
    required this.userName,
    required this.subtitle,
    required this.isAdmin,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    Color gradientStart = LMSTheme.primaryColor;
    Color gradientEnd = const Color(0xFF2563EB);
    if (role == SidebarRole.teacher) {
      gradientStart = const Color(0xFF22C55E);
      gradientEnd = const Color(0xFF059669);
    } else if (role == SidebarRole.admin) {
      gradientStart = const Color(0xFFA855F7);
      gradientEnd = const Color(0xFF6366F1);
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: isAdmin ? LMSTheme.sidebarDarkBorder : LMSTheme.borderColor)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [gradientStart, gradientEnd],
              ),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              initials.length >= 2 ? initials.substring(0, 2) : (initials.isEmpty ? '?' : initials),
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  userName,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isAdmin ? LMSTheme.sidebarDarkText : LMSTheme.onSurfaceColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: isAdmin ? LMSTheme.sidebarDarkMuted : LMSTheme.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
