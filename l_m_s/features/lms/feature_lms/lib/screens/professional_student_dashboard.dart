import 'package:flutter/material.dart';
import '../theme/lms_theme.dart';

class ProfessionalStudentDashboard extends StatefulWidget {
  final String studentName;
  final String studentId;

  const ProfessionalStudentDashboard({
    super.key,
    required this.studentName,
    required this.studentId,
  });

  @override
  State<ProfessionalStudentDashboard> createState() => _ProfessionalStudentDashboardState();
}

class _ProfessionalStudentDashboardState extends State<ProfessionalStudentDashboard> {
  int _selectedTab = 0;
  final List<String> tabs = ['Dashboard', 'Courses', 'Tests', 'Assignments', 'Analytics'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey[50],
      // ... Header with student profile
      body: Column(
        children: [
          _buildHeader(theme),
          _buildStatCards(theme),
          Expanded(
            child: _buildTabContent(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [LMSTheme.primaryColor, LMSTheme.secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=1'),
                radius: 30,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, ${widget.studentName}',
                    style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'Keep up the great work! 🎯',
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards(ThemeData theme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildStatCard(theme, 'Courses', '12', '📚', Colors.blue),
          const SizedBox(width: 12),
          _buildStatCard(theme, 'Tests Taken', '28', '✅', Colors.green),
          const SizedBox(width: 12),
          _buildStatCard(theme, 'Avg Score', '82.5%', '📈', Colors.orange),
          const SizedBox(width: 12),
          _buildStatCard(theme, 'Attendance', '92%', '📅', Colors.purple),
        ],
      ),
    );
  }

  Widget _buildStatCard(ThemeData theme, String label, String value, String icon, Color color) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          Text(value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600, color: color)),
          const SizedBox(height: 4),
          Text(label, style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildTabContent(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionTitle(theme, 'Recommended Courses'),
        ..._buildCourseCards(theme),
        const SizedBox(height: 24),
        _buildSectionTitle(theme, 'Recent Tests'),
        ..._buildTestCards(theme),
        const SizedBox(height: 24),
        _buildSectionTitle(theme, 'Upcoming Classes'),
        ..._buildClassCards(theme),
      ],
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  List<Widget> _buildCourseCards(ThemeData theme) {
    return MockDataService.courses.map((course) {
      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              course['image'],
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course['title'],
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    course['description'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${course['students']} students', style: theme.textTheme.labelSmall),
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text('Continue'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  List<Widget> _buildTestCards(ThemeData theme) {
    return MockDataService.testResults.map((test) {
      final percentage = test['percentage'] as int;
      final color = percentage >= 80 ? Colors.green : percentage >= 60 ? Colors.orange : Colors.red;
      
      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '${percentage}%',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      test['testName'],
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rank: ${test['rank']} / ${test['totalAttempts']}',
                      style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward, color: Colors.grey[400]),
            ],
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildClassCards(ThemeData theme) {
    final classes = [
      {'subject': 'Physics', 'time': 'Today at 4:00 PM', 'teacher': 'Prof. Amit Kumar', 'icon': '📚'},
      {'subject': 'Chemistry', 'time': 'Tomorrow at 10:00 AM', 'teacher': 'Prof. Neha Singh', 'icon': '🧪'},
    ];

    return classes.map((cls) {
      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(cls['icon'] as String, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cls['subject'] as String,
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cls['teacher'] as String,
                      style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cls['time'] as String,
                      style: theme.textTheme.labelSmall?.copyWith(color: LMSTheme.primaryColor),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Join'),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
}
