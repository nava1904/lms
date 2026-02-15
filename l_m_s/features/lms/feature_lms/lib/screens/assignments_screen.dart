import 'package:flutter/material.dart';

class AssignmentsScreen extends StatefulWidget {
  const AssignmentsScreen({super.key});

  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> {
  String _filterStatus = 'All';
  final List<String> statuses = ['All', 'Pending', 'Submitted', 'Graded'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text('Assignments', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: statuses.map((status) {
                final isSelected = _filterStatus == status;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(status),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _filterStatus = status);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildAssignmentCard(theme, 'Physics Assignment 1', 'Physics', 'Pending', 5, 'Jan 20, 2024'),
                _buildAssignmentCard(theme, 'Chemistry Lab Report', 'Chemistry', 'Submitted', 0, 'Jan 18, 2024'),
                _buildAssignmentCard(theme, 'Mathematics Problem Set', 'Mathematics', 'Graded', 0, 'Jan 15, 2024', grade: '92/100'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentCard(
    ThemeData theme,
    String title,
    String subject,
    String status,
    int daysLeft,
    String dueDate, {
    String? grade,
  }) {
    Color statusColor = Colors.orange;
    IconData statusIcon = Icons.schedule;

    if (status == 'Submitted') {
      statusColor = Colors.blue;
      statusIcon = Icons.check;
    } else if (status == 'Graded') {
      statusColor = Colors.green;
      statusIcon = Icons.done_all;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(subject, style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey[600])),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        status,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (grade != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Grade', style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey[600])),
                    Text(grade, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: Colors.green)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Due Date', style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey[600])),
                    Text(dueDate, style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600)),
                  ],
                ),
                if (daysLeft > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '$daysLeft days left',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (status == 'Pending')
              ElevatedButton(
                onPressed: () {},
                child: const Text('Submit Assignment'),
              ),
          ],
        ),
      ),
    );
  }
}
