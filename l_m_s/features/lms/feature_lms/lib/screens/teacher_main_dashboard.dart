import 'package:flutter/material.dart';

class TeacherMainDashboard extends StatefulWidget {
  final String teacherName;
  final String teacherId;

  const TeacherMainDashboard({
    super.key,
    required this.teacherName,
    required this.teacherId,
  });

  @override
  State<TeacherMainDashboard> createState() => _TeacherMainDashboardState();
}

class _TeacherMainDashboardState extends State<TeacherMainDashboard> {
  int _selectedNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome, ${widget.teacherName}', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            Text('Teacher Dashboard', style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey[600])),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
          IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
        ],
      ),
      body: _buildContent(theme),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedNavIndex,
        onTap: (index) => setState(() => _selectedNavIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.class_), label: 'My Classes'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Assignments'),
          BottomNavigationBarItem(icon: Icon(Icons.assessment), label: 'Grades'),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Stats Cards
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: [
            _buildStatCard(theme, 'Total Students', '450', Icons.people, Colors.blue),
            _buildStatCard(theme, 'Active Classes', '5', Icons.class_, Colors.green),
            _buildStatCard(theme, 'Assignments', '12', Icons.assignment, Colors.orange),
            _buildStatCard(theme, 'Avg Rating', '4.8★', Icons.star, Colors.amber),
          ],
        ),
        const SizedBox(height: 24),
        // Recent Activities
        Text('Recent Activities', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildActivityItem(theme, 'New assignment submitted', 'Physics Class - 5 min ago', Icons.task_alt),
                const Divider(),
                _buildActivityItem(theme, 'Discussion posted', 'Chemistry Forum - 1 hour ago', Icons.comment),
                const Divider(),
                _buildActivityItem(theme, 'Test graded', 'Physics Mock Test - 3 hours ago', Icons.done),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Upcoming Classes
        Text('Upcoming Classes', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        _buildClassCard(theme, 'Physics - Class 11', 'Today at 2:00 PM', 35),
        _buildClassCard(theme, 'Chemistry - Class 12', 'Tomorrow at 10:00 AM', 28),
      ],
    );
  }

  Widget _buildStatCard(ThemeData theme, String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 28),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700, color: color)),
                Text(label, style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey[600])),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(ThemeData theme, String title, String subtitle, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF1A73E8), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600)),
              Text(subtitle, style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey[600])),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClassCard(ThemeData theme, String className, String time, int studentCount) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(className, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(time, style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey[600])),
                      const SizedBox(width: 12),
                      const Icon(Icons.people, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('$studentCount students', style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey[600])),
                    ],
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Start'),
            ),
          ],
        ),
      ),
    );
  }
}
