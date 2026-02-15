import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vyuh_core/vyuh_core.dart';
import '../lms_routes.dart';
import '../sanity_client_helper.dart';
import 'package:feature_lms/screens/login_screen.dart';


class DashboardScreen extends StatefulWidget {
  final String studentName;
  final String rollNumber;
  final String studentId;
  const DashboardScreen({super.key, required this.studentName, required this.rollNumber, required this.studentId});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<dynamic>? _subjects;
  List<dynamic>? _tests;
  List<dynamic>? _materials;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final client = createLmsClient();
      // Fetch subjects assigned to this student
      final subjectRes = await client.fetch('''
        *[_type == "subject" && references("${widget.studentId}")] {
          _id,
          title,
          icon,
          classLevel,
          chapters[]-> { _id, title }
        }
      ''');
      // Fetch upcoming tests
      final testRes = await client.fetch(r'''
        *[_type == "assessment"] | order(_createdAt desc)[0...3] {
          _id,
          title,
          durationMinutes,
          "worksheet": worksheet->{ _id, title }
        }
      ''');
      // Fetch recent materials (concepts or chapters)
      final materialRes = await client.fetch(r'''
        *[_type == "concept"] | order(_createdAt desc)[0...3] {
          _id,
          title,
          "course": course->{ _id, title }
        }
      ''');
      if (mounted) {
        setState(() {
          _subjects = subjectRes.result as List<dynamic>?;
          _tests = testRes.result as List<dynamic>?;
          _materials = materialRes.result as List<dynamic>?;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Dashboard')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Dashboard')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline_rounded, size: 48, color: theme.colorScheme.error),
                const SizedBox(height: 16),
                Text('Could not load dashboard', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(_error!, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error)),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _loadDashboard,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    final subjects = _subjects ?? [];
    final tests = _tests ?? [];
    final materials = _materials ?? [];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadDashboard,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              // Use GoRouter for logout navigation
              GoRouter.of(context).go('/');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboard,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Welcome, ${widget.studentName}!', style: theme.textTheme.headlineSmall),
            Text('Roll Number: ${widget.rollNumber}', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 24),
            Text('My Subjects', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            if (subjects.isEmpty)
              Text('No subjects assigned.', style: theme.textTheme.bodyMedium)
            else
              ...subjects.map((s) => Card(
                    child: ListTile(
                      leading: s['icon'] != null ? const Icon(Icons.book) : null,
                      title: Text(s['title'] ?? 'Untitled'),
                      subtitle: Text('Class: ${s['classLevel'] ?? '-'}'),
                      onTap: () {
                        // Navigate to ContentScreen with subject
                        GoRouter.of(context).go('/content', extra: s);
                      },
                    ),
                  )),
            const SizedBox(height: 28),
            Text('Upcoming Tests', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            if (tests.isEmpty)
              Text('No upcoming tests.', style: theme.textTheme.bodyMedium)
            else
              ...tests.map((t) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.quiz_rounded),
                      title: Text(t['title'] ?? 'Untitled'),
                      subtitle: Text('Duration: ${t['durationMinutes'] ?? '-'} min'),
                    ),
                  )),
            const SizedBox(height: 28),
            Text('Recent Materials', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            if (materials.isEmpty)
              Text('No recent materials.', style: theme.textTheme.bodyMedium)
            else
              ...materials.map((m) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.menu_book_rounded),
                      title: Text(m['title'] ?? 'Untitled'),
                      subtitle: Text('Course: ${m['course']?['title'] ?? '-'}'),
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}
