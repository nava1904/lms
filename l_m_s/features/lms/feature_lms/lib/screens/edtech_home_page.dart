import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/lms_theme.dart';

/// Professional EdTech LMS v2 Home: gradient, logo, 3 role cards, "Access Portal" buttons.
/// Matches ingestion _pipe_lines/Professional EdTech LMS version 2/src/app/pages/Home.tsx
class EdTechHomePage extends StatelessWidget {
  const EdTechHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [LMSTheme.gradientStart, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 64),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1280),
                  child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 64),
                    _buildRoleCards(context),
                    const SizedBox(height: 48),
                    _buildDemoNotice(),
                  ],
                ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: LMSTheme.primaryColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.menu_book_rounded, size: 40, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Text(
              'LearnHub',
              style: GoogleFonts.outfit(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: LMSTheme.onSurfaceColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Professional Learning Management System',
          style: GoogleFonts.outfit(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: LMSTheme.onSurfaceColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Choose your role to access the platform with tailored features for students, teachers, and administrators',
          style: GoogleFonts.inter(
            fontSize: 18,
            color: LMSTheme.mutedForeground,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRoleCards(BuildContext context) {
    final roles = [
      _RoleData(
        title: 'Student Portal',
        description: 'Access your courses, track progress, and take tests',
        icon: Icons.school_rounded,
        colorStart: const Color(0xFF3B82F6),
        colorEnd: const Color(0xFF2563EB),
        features: const ['Course Library', 'Progress Tracking', 'Test & Assessments', 'Performance Analytics'],
        path: '/login',
      ),
      _RoleData(
        title: 'Teacher Dashboard',
        description: 'Manage courses, students, and track their performance',
        icon: Icons.people_rounded,
        colorStart: const Color(0xFF22C55E),
        colorEnd: const Color(0xFF059669),
        features: const ['Course Management', 'Student Analytics', 'Content Creation', 'Grade Management'],
        path: '/login?role=teacher',
      ),
      _RoleData(
        title: 'Admin Panel',
        description: 'Complete system management and administration',
        icon: Icons.shield_rounded,
        colorStart: const Color(0xFFA855F7),
        colorEnd: const Color(0xFF6366F1),
        features: const ['User Management', 'Attendance Tracking', 'Test Scheduling', 'System Reports'],
        path: '/login?role=admin',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossCount = constraints.maxWidth > 900 ? 3 : 1;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossCount,
          mainAxisSpacing: 32,
          crossAxisSpacing: 32,
          childAspectRatio: 0.58,
          children: roles.map((r) => _RoleCard(data: r, onTap: () => context.go(r.path))).toList(),
        );
      },
    );
  }

  Widget _buildDemoNotice() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Demo Mode: Sign in with your role (Student: Roll Number, Teacher/Admin: Email) to access the platform.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF1E3A8A),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleData {
  final String title;
  final String description;
  final IconData icon;
  final Color colorStart;
  final Color colorEnd;
  final List<String> features;
  final String path;
  _RoleData({
    required this.title,
    required this.description,
    required this.icon,
    required this.colorStart,
    required this.colorEnd,
    required this.features,
    required this.path,
  });
}

class _RoleCard extends StatelessWidget {
  final _RoleData data;
  final VoidCallback onTap;

  const _RoleCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: LMSTheme.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 40,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [data.colorStart, data.colorEnd],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(data.icon, size: 36, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            data.title,
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: LMSTheme.onSurfaceColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data.description,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: LMSTheme.mutedForeground,
            ),
          ),
          const SizedBox(height: 16),
          ...data.features.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: LMSTheme.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.east, size: 12, color: LMSTheme.primaryColor),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    f,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: LMSTheme.onSurfaceColor,
                    ),
                  ),
                ),
              ],
            ),
          )),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                backgroundColor: LMSTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Access ${data.title.split(' ').first} Portal'),
            ),
          ),
        ],
      ),
    );
  }
}
