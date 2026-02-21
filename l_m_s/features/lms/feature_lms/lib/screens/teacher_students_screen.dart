import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/lms_theme.dart';
import '../services/sanity_service.dart';

/// Student management: table (Name, Email, Enrolled Course, Last Active, Avg Score, Completion %), click for detail.
class TeacherStudentsScreen extends StatefulWidget {
  const TeacherStudentsScreen({super.key});

  @override
  State<TeacherStudentsScreen> createState() => _TeacherStudentsScreenState();
}

class _TeacherStudentsScreenState extends State<TeacherStudentsScreen> {
  final SanityService _sanity = SanityService();
  List<Map<String, dynamic>> _students = [];
  List<Map<String, dynamic>> _testAttempts = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final students = await _sanity.fetchStudents();
      final attempts = await _sanity.fetchTestAttempts();
      if (mounted) setState(() {
        _students = students;
        _testAttempts = attempts;
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = e.toString(); });
    }
  }

  String _lastActive(String? studentId) {
    if (studentId == null) return '—';
    final byStudent = _testAttempts.where((a) => a['student']?['_id'] == studentId).toList();
    if (byStudent.isEmpty) return '—';
    final dates = byStudent.map((a) => a['submittedAt'] as String?).whereType<String>().toList();
    dates.sort((a, b) => b.compareTo(a));
    final d = dates.first;
    if (d.length >= 10) return d.substring(0, 10);
    return d;
  }

  int _avgScore(String? studentId) {
    if (studentId == null) return 0;
    final byStudent = _testAttempts.where((a) => a['student']?['_id'] == studentId).toList();
    if (byStudent.isEmpty) return 0;
    final sum = byStudent.fold<double>(0, (s, a) => s + ((a['percentage'] as num?)?.toDouble() ?? 0));
    return (sum / byStudent.length).round();
  }

  String _enrolledCourseNames(dynamic enrolled) {
    if (enrolled == null) return '—';
    if (enrolled is List) {
      final titles = enrolled.map((e) => e is Map ? (e['title'] as String?) : null).whereType<String>().toList();
      if (titles.isEmpty) return '—';
      return titles.take(2).join(', ') + (titles.length > 2 ? '...' : '');
    }
    return '—';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: LMSTheme.surfaceColor,
      appBar: AppBar(
        title: const Text('Students'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/teacher-dashboard'),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: LMSTheme.primaryColor))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, style: const TextStyle(color: LMSTheme.errorColor), textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      FilledButton(onPressed: _load, child: const Text('Retry')),
                    ],
                  ),
                )
              : _students.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline, size: 64, color: LMSTheme.mutedForeground),
                          const SizedBox(height: 16),
                          Text('No students yet', style: theme.textTheme.titleMedium?.copyWith(color: LMSTheme.mutedForeground)),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Name')),
                            DataColumn(label: Text('Email')),
                            DataColumn(label: Text('Enrolled course')),
                            DataColumn(label: Text('Last active')),
                            DataColumn(label: Text('Avg score')),
                            DataColumn(label: Text('Completion %')),
                          ],
                          rows: _students.map((s) {
                            final id = s['_id'] as String?;
                            return DataRow(
                              onSelectChanged: (_) => id != null ? context.push('/teacher/students/$id', extra: s) : null,
                              cells: [
                                DataCell(Text(s['name'] as String? ?? '—')),
                                DataCell(Text(s['email'] as String? ?? '—')),
                                DataCell(Text(_enrolledCourseNames(s['enrolledCourses']))),
                                DataCell(Text(_lastActive(id))),
                                DataCell(Text('${_avgScore(id)}%')),
                                DataCell(Text('—')),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
    );
  }
}
