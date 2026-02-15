import 'package:flutter/material.dart';
import '../theme/lms_theme.dart';

class AdminAnalyticsDashboard extends StatefulWidget {
  const AdminAnalyticsDashboard({super.key});

  @override
  State<AdminAnalyticsDashboard> createState() => _AdminAnalyticsDashboardState();
}

class _AdminAnalyticsDashboardState extends State<AdminAnalyticsDashboard> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        actions: [
          IconButton(icon: const Icon(Icons.download), onPressed: () {}),
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildKPICards(theme),
          const SizedBox(height: 24),
          _buildAttendanceChart(theme),
          const SizedBox(height: 24),
          _buildStudentPerformance(theme),
          const SizedBox(height: 24),
          _buildTeacherEngagement(theme),
        ],
      ),
    );
  }

  Widget _buildKPICards(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: _buildKPICard(theme, 'Total Students', '2,450', '↑ 12%', Colors.blue),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildKPICard(theme, 'Avg Attendance', '87.5%', '↑ 3%', Colors.green),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildKPICard(theme, 'Avg Score', '78.2%', '↑ 5%', Colors.orange),
        ),
      ],
    );
  }

  Widget _buildKPICard(ThemeData theme, String label, String value, String change, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey)),
            const SizedBox(height: 8),
            Text(value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600, color: color)),
            const SizedBox(height: 8),
            Text(change, style: theme.textTheme.labelSmall?.copyWith(color: Colors.green, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceChart(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Weekly Attendance', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAttendanceBar(theme, 'Monday', 240, 255, Colors.blue),
                  _buildAttendanceBar(theme, 'Tuesday', 238, 255, Colors.blue),
                  _buildAttendanceBar(theme, 'Wednesday', 245, 255, Colors.green),
                  _buildAttendanceBar(theme, 'Thursday', 230, 255, Colors.orange),
                  _buildAttendanceBar(theme, 'Friday', 250, 255, Colors.green),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceBar(ThemeData theme, String day, int present, int total, Color color) {
    final percentage = (present / total) * 100;
    return Row(
      children: [
        SizedBox(width: 80, child: Text(day, style: theme.textTheme.labelSmall)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: percentage / 100,
                  minHeight: 8,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 60,
          child: Text(
            '${percentage.toStringAsFixed(1)}%',
            textAlign: TextAlign.right,
            style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildStudentPerformance(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Top Performing Students', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            ...MockDataService.students.asMap().entries.map((entry) {
              final student = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(student['avatar'] as String),
                      radius: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student['name'] as String,
                            style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            'Roll #${student['rollNumber']}',
                            style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${student['avgScore']}%',
                        style: theme.textTheme.labelSmall?.copyWith(color: Colors.green, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTeacherEngagement(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Subject-wise Engagement', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            ...MockDataService.subjects.map((subject) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${subject['icon']} ${subject['title']}', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600)),
                        Text('${subject['students']} students', style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: (subject['students'] as int) / 500,
                              minHeight: 8,
                              backgroundColor: Colors.grey[200],
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('${subject['tests']} tests', style: theme.textTheme.labelSmall),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
