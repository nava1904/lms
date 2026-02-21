import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/current_student_holder.dart';
import '../services/lms_sanity_service.dart';
import '../theme/lms_theme.dart';
import '../theme/theme_mode_holder.dart';

/// Student settings: name, email, roll number, theme toggle.
class StudentSettingsScreen extends StatefulWidget {
  final String studentId;

  const StudentSettingsScreen({super.key, required this.studentId});

  @override
  State<StudentSettingsScreen> createState() => _StudentSettingsScreenState();
}

class _StudentSettingsScreenState extends State<StudentSettingsScreen> {
  final LmsSanityService _service = LmsSanityService();
  String? _email;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStudent();
  }

  Future<void> _loadStudent() async {
    if (widget.studentId.isEmpty) {
      setState(() => _loading = false);
      return;
    }
    try {
      final student = await _service.getStudent(widget.studentId);
      if (mounted) {
        setState(() {
          _email = student?.email;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _goBack() {
    final id = CurrentStudentHolder.studentId ?? widget.studentId;
    if (id.isNotEmpty) {
      context.go('/student-dashboard/$id', extra: {
        'studentName': CurrentStudentHolder.studentName ?? 'Student',
        'rollNumber': CurrentStudentHolder.rollNumber ?? '',
      });
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = CurrentStudentHolder.studentName ?? 'Student';
    final roll = CurrentStudentHolder.rollNumber ?? '';

    return Scaffold(
      backgroundColor: LMSTheme.surfaceColor,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goBack,
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: LMSTheme.primaryColor))
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(LMSTheme.radiusMd),
                    side: const BorderSide(color: LMSTheme.borderColor),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Profile',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: LMSTheme.primaryColor.withValues(alpha: 0.2),
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : '?',
                              style: const TextStyle(
                                color: LMSTheme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          title: Text(name),
                          subtitle: Text(
                            'Student account',
                            style: theme.textTheme.bodySmall?.copyWith(color: LMSTheme.mutedForeground),
                          ),
                        ),
                        const Divider(height: 1),
                        _buildReadOnlyField(theme, 'Name', name),
                        _buildReadOnlyField(theme, 'Roll Number', roll),
                        if (_email != null && _email!.isNotEmpty)
                          _buildReadOnlyField(theme, 'Email', _email!),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(LMSTheme.radiusMd),
                    side: const BorderSide(color: LMSTheme.borderColor),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Privacy',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.visibility_outlined, size: 20),
                          title: const Text('Progress visibility'),
                          subtitle: Text(
                            'Your progress is visible only to you and your teachers.',
                            style: theme.textTheme.bodySmall?.copyWith(color: LMSTheme.mutedForeground),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(LMSTheme.radiusMd),
                    side: const BorderSide(color: LMSTheme.borderColor),
                  ),
                  child: Column(
                    children: [
                      ValueListenableBuilder<ThemeMode>(
                        valueListenable: ThemeModeHolder.notifier,
                        builder: (context, mode, _) => SwitchListTile(
                          title: const Text('Dark mode'),
                          subtitle: const Text('Use dark theme across the app'),
                          value: mode == ThemeMode.dark,
                          onChanged: (_) => ThemeModeHolder.toggle(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildReadOnlyField(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(color: LMSTheme.mutedForeground),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
