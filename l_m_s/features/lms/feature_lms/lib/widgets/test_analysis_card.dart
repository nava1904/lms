import 'package:flutter/material.dart';

class TestAnalysisCard extends StatelessWidget {
  final String testName;
  final int correct;
  final int incorrect;
  final List<String> weakTopics;
  final int totalQuestions;

  const TestAnalysisCard({
    super.key,
    required this.testName,
    required this.correct,
    required this.incorrect,
    required this.weakTopics,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = correct + incorrect;
    final correctPercentage = (correct / total) * 100;

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              testName,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            
            // Simple Progress Visualization
            SizedBox(
              height: 100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[100],
                        ),
                        child: Center(
                          child: Text(
                            '${correctPercentage.toStringAsFixed(0)}%',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: correctPercentage >= 80 ? Colors.green : Colors.orange,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(theme, 'Correct', correct, Colors.green),
                _buildStatItem(theme, 'Incorrect', incorrect, Colors.red),
                _buildStatItem(theme, 'Total', totalQuestions, Colors.blue),
              ],
            ),

            const SizedBox(height: 24),

            // Weak Topics
            if (weakTopics.isNotEmpty) ...[
              Text(
                'Weak Topics',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: weakTopics.map((topic) {
                  return Chip(
                    label: Text(
                      topic,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    backgroundColor: Colors.red.withOpacity(0.7),
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(ThemeData theme, String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }
}
