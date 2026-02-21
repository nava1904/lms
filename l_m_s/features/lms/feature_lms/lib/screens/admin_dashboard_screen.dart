import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';
import '../stores/admin_dashboard_store.dart';
import '../stores/analytics_store.dart';
import '../theme/lms_theme.dart';

/// Zimyo-style admin dashboard: enrollments, teachers, fees snapshot;
/// teacher management, student onboarding, banner management, document management, export report.
class AdminDashboardScreen extends StatefulWidget {
  final String adminId;
  final String adminName;
  final String adminEmail;
  final String adminRole;

  const AdminDashboardScreen({
    super.key,
    required this.adminId,
    required this.adminName,
    required this.adminEmail,
    required this.adminRole,
  });

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  final AdminDashboardStore _store = AdminDashboardStore();
  final AnalyticsStore _analyticsStore = AnalyticsStore();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _store.loadDashboardStats();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LMSTheme.surfaceColor,
      appBar: AppBar(
        title: Text('Admin Dashboard', style: TextStyle(color: LMSTheme.onSurfaceColor, fontWeight: FontWeight.w600)),
        backgroundColor: LMSTheme.surfaceColor,
        foregroundColor: LMSTheme.onSurfaceColor,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: LMSTheme.primaryColor,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Teachers'),
            Tab(text: 'Students'),
            Tab(text: 'Banners'),
            Tab(text: 'Documents'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildTeachersTab(),
          _buildStudentsTab(),
          _buildBannersTab(),
          _buildDocumentsTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return Observer(
      builder: (_) {
        if (_store.loading && _store.totalStudents == 0 && _store.totalTeachers == 0) {
          return const Center(child: CircularProgressIndicator(color: LMSTheme.primaryColor));
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_store.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(_store.error!, style: TextStyle(color: LMSTheme.errorColor)),
                ),
              Text('Institute snapshot', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _MetricCard(title: 'Total students', value: '${_store.totalStudents}', icon: Icons.school, color: LMSTheme.primaryColor)),
                  const SizedBox(width: 16),
                  Expanded(child: _MetricCard(title: 'Active teachers', value: '${_store.totalTeachers}', icon: Icons.person, color: LMSTheme.successColor)),
                  const SizedBox(width: 16),
                  Expanded(child: _MetricCard(title: 'Active enrollments', value: '${_store.activeEnrollments}', icon: Icons.how_to_reg, color: LMSTheme.warningColor)),
                ],
              ),
              const SizedBox(height: 32),
              Text('Monthly performance report', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _exportReport,
                icon: const Icon(Icons.download),
                label: const Text('Export report (test attempts aggregate)'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTeachersTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_add, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text('Teacher management', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Create profile, assign role (e.g. Physics), link to batches.', style: TextStyle(color: Colors.grey.shade600), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Create teacher (configure Sanity mutation)'))),
              icon: const Icon(Icons.add),
              label: const Text('Add teacher'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentsTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.school, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text('Student onboarding', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Bulk create students, generate unique 4-digit roll numbers.', style: TextStyle(color: Colors.grey.shade600), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bulk create students (configure Sanity mutation)'))),
              icon: const Icon(Icons.add),
              label: const Text('Bulk add students'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannersTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.campaign, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text('Marketing banners', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Update login screen banner (e.g. New Scholarship Batch). Edit in Sanity Studio.', style: TextStyle(color: Colors.grey.shade600), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentsTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.folder_open, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text('Document management', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('OCR/Cengage content – categorize and assign to subjects. Edit in Sanity Studio.', style: TextStyle(color: Colors.grey.shade600), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Future<void> _exportReport() async {
    await _analyticsStore.loadTestAttemptsForAnalytics();
    if (!mounted) return;
    final attempts = _analyticsStore.testAttempts;
    final buffer = StringBuffer();
    buffer.writeln('Test,Student,Score,Percentage,Passed,SubmittedAt');
    for (final a in attempts) {
      buffer.writeln('${a.testTitle ?? a.testId},${a.studentId},${a.score ?? ""},${a.percentage ?? ""},${a.passed ?? false},${a.submittedAt ?? ""}');
    }
    final csv = buffer.toString();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Report: ${attempts.length} attempts. Copy from dialog.'),
        action: SnackBarAction(
          label: 'Copy',
          onPressed: () => _copyToClipboard(csv),
        ),
      ),
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Monthly performance (test attempts)'),
        content: SingleChildScrollView(
          child: SelectableText(csv.isEmpty ? 'No data' : csv),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          FilledButton(onPressed: () { _copyToClipboard(csv); Navigator.pop(ctx); }, child: const Text('Copy')),
        ],
      ),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 12),
            Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}
