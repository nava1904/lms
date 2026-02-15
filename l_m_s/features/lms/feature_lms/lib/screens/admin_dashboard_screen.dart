import 'package:flutter/material.dart';
import '../sanity_client_helper.dart';

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
  late TabController _tabController;
  int _totalStudents = 0;
  int _totalTeachers = 0;
  double _avgAttendance = 0;
  int _totalTests = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _loadDashboardStats();
  }

  Future<void> _loadDashboardStats() async {
    try {
      final client = createLmsClient();
      
      // Get students count
      final studentsRes = await client.fetch(r'''count(*[_type == "student"])''');
      // Get teachers count
      final teachersRes = await client.fetch(r'''count(*[_type == "teacher"])''');
      // Get tests count
      final testsRes = await client.fetch(r'''count(*[_type == "test"])''');

      if (mounted) {
        setState(() {
          _totalStudents = (studentsRes.result as int?) ?? 0;
          _totalTeachers = (teachersRes.result as int?) ?? 0;
          _totalTests = (testsRes.result as int?) ?? 0;
          _avgAttendance = 85.5; // TODO: Calculate from actual data
        });
      }
    } catch (e) {
      print('Error loading stats: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Admin Dashboard', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
            Text('${widget.adminName} (${widget.adminRole})', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
          IconButton(icon: const Icon(Icons.logout), onPressed: () => Navigator.pop(context)),
        ],
      ),
      body: Column(
        children: [
          // Stats Cards
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildStatCard(theme, 'Total Students', _totalStudents.toString(), Icons.person, Colors.blue),
                const SizedBox(width: 12),
                _buildStatCard(theme, 'Total Teachers', _totalTeachers.toString(), Icons.school, Colors.green),
                const SizedBox(width: 12),
                _buildStatCard(theme, 'Avg Attendance', '${_avgAttendance.toStringAsFixed(1)}%', Icons.check_circle, Colors.orange),
                const SizedBox(width: 12),
                _buildStatCard(theme, 'Tests Scheduled', _totalTests.toString(), Icons.quiz, Colors.purple),
              ],
            ),
          ),
          // Tabs
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Dashboard'),
              Tab(text: 'Students'),
              Tab(text: 'Teachers'),
              Tab(text: 'Attendance'),
              Tab(text: 'Tests'),
              Tab(text: 'Content'),
            ],
          ),
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(theme),
                _buildStudentsTab(theme),
                _buildTeachersTab(theme),
                _buildAttendanceTab(theme),
                _buildTestsTab(theme),
                _buildContentTab(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(ThemeData theme, String title, String value, IconData icon, Color color) {
    return Container(
      width: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: theme.textTheme.labelSmall),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 0,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('System Overview', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                _buildOverviewRow('Total Users', '${_totalStudents + _totalTeachers}'),
                _buildOverviewRow('Active Courses', '12'),
                _buildOverviewRow('Total Subjects', '45'),
                _buildOverviewRow('Content Posted', '128'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildStudentsTab(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 0,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Manage Students', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                    ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Show enroll student dialog
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Enroll'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Feature: Bulk enroll students, manage enrollment, view student performance', style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTeachersTab(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 0,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Manage Teachers', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                    ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Show create teacher dialog
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Teacher'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Feature: Create teacher IDs, assign subjects, manage teaching assignments', style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceTab(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 0,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Attendance Management', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                Text('Feature: Mark attendance, view reports, track patterns', style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTestsTab(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 0,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Schedule Tests', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                    ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Show schedule test dialog
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Schedule'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Feature: Schedule tests, set dates, view scores, analyze performance', style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContentTab(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 0,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Content Monitor', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                Text('Feature: Monitor content streak, view posts by teachers, check quality', style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
