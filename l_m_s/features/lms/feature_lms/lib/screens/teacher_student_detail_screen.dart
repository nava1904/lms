import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/attendance.dart';
import '../services/lms_sanity_service.dart';
import '../services/sanity_service.dart';
import '../theme/lms_theme.dart';

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
  List<AttendanceRecord> _attendance = [];
  bool _loading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final results = await Future.wait([
        _sanity.fetchTestAttempts(studentId: widget.studentId),
        LmsSanityService().getAttendanceForStudent(widget.studentId),
      ]);
      if (mounted) {
        setState(() {
          _attempts = results[0] as List<Map<String, dynamic>>;
          _attendance = results[1] as List<AttendanceRecord>;
          _loading = false;
          _loadError = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _loadError = e.toString();
        });
      }
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
    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: LMSTheme.errorColor),
              const SizedBox(height: 16),
              Text(_loadError!, style: theme.textTheme.bodyMedium?.copyWith(color: LMSTheme.errorColor), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    if (_attendance.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 48, color: LMSTheme.mutedForeground),
            const SizedBox(height: 16),
            Text('No attendance records', style: theme.textTheme.bodyMedium?.copyWith(color: LMSTheme.mutedForeground)),
          ],
        ),
      );
    }
    final attended = _attendance.where((a) => a.status == 'present' || a.status == 'late').length;
    final percent = _attendance.isEmpty ? 0 : ((attended / _attendance.length) * 100).round();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text('$percent%', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: LMSTheme.primaryColor)),
                    Text('Attendance', style: theme.textTheme.bodySmall?.copyWith(color: LMSTheme.mutedForeground)),
                  ],
                ),
                Column(
                  children: [
                    Text('${_attendance.length}', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    Text('Days marked', style: theme.textTheme.bodySmall?.copyWith(color: LMSTheme.mutedForeground)),
                  ],
                ),
              ],
            ),
          ),
        ),
        ..._attendance.map((a) {
          final isPresent = a.status == 'present' || a.status == 'late';
          final dateStr = a.date != null
              ? '${a.date!.year}-${a.date!.month.toString().padLeft(2, '0')}-${a.date!.day.toString().padLeft(2, '0')}'
              : '';
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Icon(
                isPresent ? Icons.check_circle : Icons.cancel,
                color: isPresent ? LMSTheme.successColor : LMSTheme.errorColor,
              ),
              title: Text(dateStr),
              subtitle: Text(a.status),
            ),
          );
        }),
      ],
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
