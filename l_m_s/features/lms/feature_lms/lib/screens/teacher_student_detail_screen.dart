import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/lms_theme.dart';
import '../services/sanity_service.dart';

/// Student detail: tabs Test Results, Weak Topics, Attendance, Time Spent, Assigned Worksheets.
class TeacherStudentDetailScreen extends StatefulWidget {
  final String studentId;
  final Map<String, dynamic>? student;

  const TeacherStudentDetailScreen({super.key, required this.studentId, this.student});

  @override
  State<TeacherStudentDetailScreen> createState() => _TeacherStudentDetailScreenState();
}

class _TeacherStudentDetailScreenState extends State<TeacherStudentDetailScreen> with SingleTickerProviderStateMixin {
  final SanityService _sanity = SanityService();
  late TabController _tabController;
  List<Map<String, dynamic>> _attempts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadAttempts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAttempts() async {
    setState(() => _loading = true);
    try {
      final list = await _sanity.fetchTestAttempts(studentId: widget.studentId);
      if (mounted) setState(() { _attempts = list; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = widget.student?['name'] as String? ?? 'Student';
    return Scaffold(
      backgroundColor: LMSTheme.surfaceColor,
      appBar: AppBar(
        title: Text(name),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/teacher/students'),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Test results'),
            Tab(text: 'Weak topics'),
            Tab(text: 'Attendance'),
            Tab(text: 'Time spent'),
            Tab(text: 'Worksheets'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: LMSTheme.primaryColor))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildTestResults(theme),
                _buildWeakTopics(theme),
                _buildAttendance(theme),
                _buildTimeSpent(theme),
                _buildWorksheets(theme),
              ],
            ),
    );
  }

  Widget _buildTestResults(ThemeData theme) {
    if (_attempts.isEmpty) {
      return Center(child: Text('No test attempts', style: theme.textTheme.bodyMedium?.copyWith(color: LMSTheme.mutedForeground)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _attempts.length,
      itemBuilder: (context, i) {
        final a = _attempts[i];
        final passed = a['passed'] == true;
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(LMSTheme.radiusMd),
            side: const BorderSide(color: LMSTheme.borderColor),
          ),
          child: ListTile(
            title: Text(a['test']?['title'] as String? ?? 'Test'),
            subtitle: Text('${a['score'] ?? 0} / ${a['test']?['totalMarks'] ?? 100} • ${a['percentage']?.round() ?? 0}%'),
            trailing: Chip(
              label: Text(passed ? 'Passed' : 'Failed'),
              backgroundColor: passed ? LMSTheme.successColor.withValues(alpha: 0.2) : LMSTheme.errorColor.withValues(alpha: 0.2),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeakTopics(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.trending_down, size: 48, color: LMSTheme.mutedForeground),
          const SizedBox(height: 16),
          Text('Weak topics (from wrong answers)', style: theme.textTheme.bodyMedium?.copyWith(color: LMSTheme.mutedForeground)),
          const SizedBox(height: 8),
          const Text('Requires per-question result data.', style: TextStyle(color: LMSTheme.mutedForeground, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildAttendance(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today, size: 48, color: LMSTheme.mutedForeground),
          const SizedBox(height: 16),
          Text('Attendance records', style: theme.textTheme.bodyMedium?.copyWith(color: LMSTheme.mutedForeground)),
          const SizedBox(height: 8),
          const Text('Fetch from Sanity attendance by student.', style: TextStyle(color: LMSTheme.mutedForeground, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildTimeSpent(ThemeData theme) {
    final totalMins = _attempts.fold<int>(0, (s, a) => s + ((a['timeSpent'] as num?)?.toInt() ?? 0));
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.timer, size: 48, color: LMSTheme.mutedForeground),
          const SizedBox(height: 16),
          Text('Total time on tests: $totalMins min', style: theme.textTheme.titleMedium),
        ],
      ),
    );
  }

  Widget _buildWorksheets(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment, size: 48, color: LMSTheme.mutedForeground),
          const SizedBox(height: 16),
          Text('Assigned worksheets', style: theme.textTheme.bodyMedium?.copyWith(color: LMSTheme.mutedForeground)),
          const SizedBox(height: 8),
          const Text('Coming soon.', style: TextStyle(color: LMSTheme.mutedForeground, fontSize: 12)),
        ],
      ),
    );
  }
}
