import 'package:flutter/material.dart';
import '../theme/lms_theme.dart';

class TestsModule extends StatefulWidget {
  const TestsModule({super.key});

  @override
  State<TestsModule> createState() => _TestsModuleState();
}

class _TestsModuleState extends State<TestsModule> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text('Tests & Assessments'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Upcoming Tests'),
              Tab(text: 'Test Results'),
              Tab(text: 'Analytics'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildUpcomingTests(theme),
            _buildTestResults(theme),
            _buildAnalytics(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingTests(ThemeData theme) {
    final tests = [
      {
        'title': 'Physics Full Mock Test',
        'subject': 'Physics',
        'date': '2024-01-20',
        'time': '2:00 PM - 5:00 PM',
        'questions': 90,
        'marks': 360,
        'icon': '📚',
      },
      {
        'title': 'Chemistry Chapter Test',
        'subject': 'Chemistry',
        'date': '2024-01-22',
        'time': '10:00 AM - 12:00 PM',
        'questions': 40,
        'marks': 100,
        'icon': '🧪',
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...tests.map((test) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(test['icon'] as String, style: const TextStyle(fontSize: 32)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              test['title'] as String,
                              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              test['subject'] as String,
                              style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${test['questions']} Qs',
                          style: theme.textTheme.labelSmall?.copyWith(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${test['date']} at ${test['time']}',
                        style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey),
                      ),
                      Text(
                        '${test['marks']} marks',
                        style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text('Start Test'),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTestResults(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...MockDataService.testResults.map((result) {
          final percentage = result['percentage'] as int;
          final color = percentage >= 80 ? Colors.green : percentage >= 60 ? Colors.orange : Colors.red;
          
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          result['testName'] as String,
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color.withOpacity(0.1),
                        ),
                        child: Center(
                          child: Text(
                            '${percentage}%',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Score: ${result['score']}/${result['total']}',
                            style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            'Rank: ${result['rank']} / ${result['totalAttempts']}',
                            style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            result['date'] as String,
                            style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      minHeight: 6,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildAnalytics(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Performance Overview', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildAnalyticItem(theme, 'Avg Score', '82.5%', Colors.blue),
                    _buildAnalyticItem(theme, 'Best Score', '95%', Colors.green),
                    _buildAnalyticItem(theme, 'Tests Taken', '28', Colors.purple),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Subject-wise Performance', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                _buildSubjectPerformance(theme, 'Physics', 78, Colors.blue),
                const SizedBox(height: 12),
                _buildSubjectPerformance(theme, 'Chemistry', 85, Colors.green),
                const SizedBox(height: 12),
                _buildSubjectPerformance(theme, 'Mathematics', 92, Colors.purple),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticItem(ThemeData theme, String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600, color: color)),
        const SizedBox(height: 8),
        Text(label, style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey)),
      ],
    );
  }

  Widget _buildSubjectPerformance(ThemeData theme, String subject, int percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(subject, style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600)),
            Text('$percentage%', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600, color: color)),
          ],
        ),
        const SizedBox(height: 8),
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
    );
  }
}
