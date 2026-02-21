import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/sanity_service.dart';

class TestsScreen extends StatefulWidget {
  const TestsScreen({super.key});

  @override
  State<TestsScreen> createState() => _TestsScreenState();
}

class _TestsScreenState extends State<TestsScreen> {
  final SanityService _sanityService = SanityService();
  List<Map<String, dynamic>> _assessments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAssessments();
  }

  Future<void> _loadAssessments() async {
    setState(() => _isLoading = true);
    try {
      final assessments = await _sanityService.fetchAssessments();
      setState(() {
        _assessments = assessments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading assessments: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tests & Assessments'),
        backgroundColor: const Color(0xFF1A73E8),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAssessments,
              child: _assessments.isEmpty
                  ? _buildEmptyState(theme)
                  : _buildAssessmentsList(theme),
            ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No tests available',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for new assessments',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadAssessments,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildAssessmentsList(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _assessments.length,
      itemBuilder: (context, index) {
        final assessment = _assessments[index];
        return _buildAssessmentCard(theme, assessment);
      },
    );
  }

  Widget _buildAssessmentCard(ThemeData theme, Map<String, dynamic> assessment) {
    final duration = (assessment['durationMinutes'] ?? assessment['duration']) ?? 60;
    final totalMarks = (assessment['totalMarks'] as num?)?.toInt() ?? 100;
    final passingMarks = (assessment['passingMarks'] as num?)?.toDouble() ?? 40;
    final passingPercent = assessment['passingMarksPercent'] ??
        (totalMarks > 0 ? (passingMarks / totalMarks * 100).round() : 40);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          _showStartTestDialog(assessment);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A73E8).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.assignment,
                      color: Color(0xFF1A73E8),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          assessment['title'] ?? 'Untitled Test',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          assessment['worksheet']?['title'] ??
                              assessment['subject']?['title'] ??
                              'General Assessment',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildInfoChip(Icons.timer, '$duration min', Colors.blue),
                  const SizedBox(width: 12),
                  _buildInfoChip(Icons.percent, '$passingPercent% to pass', Colors.green),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      _showStartTestDialog(assessment);
                    },
                    child: const Text('Start'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showStartTestDialog(Map<String, dynamic> assessment) {
    final duration = (assessment['durationMinutes'] ?? assessment['duration']) ?? 60;
    final totalMarks = (assessment['totalMarks'] as num?)?.toInt() ?? 100;
    final passingMarks = (assessment['passingMarks'] as num?)?.toDouble() ?? 40;
    final passingPercent = assessment['passingMarksPercent'] ??
        (totalMarks > 0 ? (passingMarks / totalMarks * 100).round() : 40);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start Test'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              assessment['title'] ?? 'Untitled Test',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.timer, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Text('Duration: $duration minutes'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.percent, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Text('Passing: $passingPercent%'),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Once you start, the timer will begin. Make sure you have a stable internet connection.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              final id = assessment['_id'];
              if (id != null) {
                context.go('/test/$id');
              }
            },
            child: const Text('Start Test'),
          ),
        ],
      ),
    );
  }
}
