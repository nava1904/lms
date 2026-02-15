import 'package:flutter/material.dart';
import '../sanity_client_helper.dart';

class StudentAnalyticsScreen extends StatefulWidget {
  final String subjectId;
  final String subjectTitle;

  const StudentAnalyticsScreen({
    super.key,
    required this.subjectId,
    required this.subjectTitle,
  });

  @override
  State<StudentAnalyticsScreen> createState() => _StudentAnalyticsScreenState();
}

class _StudentAnalyticsScreenState extends State<StudentAnalyticsScreen> {
  List<dynamic> _enrolledStudents = [];
  List<dynamic> _testResults = [];
  List<dynamic> _attendanceRecords = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAnalyticsData();
  }

  Future<void> _loadAnalyticsData() async {
    try {
      final client = createLmsClient();
      // Fetch enrolled students
      final studentsRes = await client.fetch(
        r'''*[_type == "student"]{_id, name, rollNumber}[0...50]'''
      );
      // Fetch test results
      final testRes = await client.fetch(
        r'''*[_type == "testAttempt"]{_id, student->{name}, score, totalMarks, completedAt}[0...50]'''
      );
      // Fetch attendance records
      final attendanceRes = await client.fetch(
        r'''*[_type == "attendance"]{_id, student->{name, rollNumber}, date, status}[0...50]'''
      );
      
      setState(() {
        _enrolledStudents = studentsRes.result as List<dynamic>? ?? [];
        _testResults = testRes.result as List<dynamic>? ?? [];
        _attendanceRecords = attendanceRes.result as List<dynamic>? ?? [];
        _loading = false;
      });
    } catch (e) {
      print('Error loading analytics: $e');
      setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Analytics - ${widget.subjectTitle}',
          style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.grey),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  TabBar(
                    tabs: const [
                      Tab(text: 'Students'),
                      Tab(text: 'Test Results'),
                      Tab(text: 'Attendance'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Students Tab
                        ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            if (_enrolledStudents.isEmpty)
                              Card(
                                elevation: 0,
                                color: Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.all(32),
                                  child: Center(
                                    child: Text(
                                      'No students enrolled',
                                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                                    ),
                                  ),
                                ),
                              )
                            else
                              ..._enrolledStudents.map((student) {
                                return Card(
                                  elevation: 0,
                                  color: Colors.white,
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: theme.colorScheme.primary,
                                      child: Text(
                                        (student['name'] as String).characters.first.toUpperCase(),
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    title: Text(student['name'] ?? 'Unknown'),
                                    subtitle: Text('Roll: ${student['rollNumber'] ?? '-'}'),
                                  ),
                                );
                              }),
                          ],
                        ),
                        // Test Results Tab
                        ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            if (_testResults.isEmpty)
                              Card(
                                elevation: 0,
                                color: Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.all(32),
                                  child: Center(
                                    child: Text(
                                      'No test results yet',
                                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                                    ),
                                  ),
                                ),
                              )
                            else
                              ..._testResults.map((result) {
                                final score = result['score'] ?? 0;
                                final total = result['totalMarks'] ?? 100;
                                final percentage = ((score / total) * 100).toStringAsFixed(1);
                                return Card(
                                  elevation: 0,
                                  color: Colors.white,
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              result['student']?['name'] ?? 'Unknown',
                                              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: double.parse(percentage) >= 75 ? Colors.green : Colors.orange,
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                '$percentage%',
                                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Score: $score / $total',
                                          style: theme.textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                          ],
                        ),
                        // Attendance Tab
                        ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            if (_attendanceRecords.isEmpty)
                              Card(
                                elevation: 0,
                                color: Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.all(32),
                                  child: Center(
                                    child: Text(
                                      'No attendance records yet',
                                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                                    ),
                                  ),
                                ),
                              )
                            else
                              ..._attendanceRecords.map((record) {
                                final isPresent = record['status'] == 'present';
                                return Card(
                                  elevation: 0,
                                  color: Colors.white,
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    leading: Icon(
                                      isPresent ? Icons.check_circle : Icons.cancel,
                                      color: isPresent ? Colors.green : Colors.red,
                                    ),
                                    title: Text(record['student']?['name'] ?? 'Unknown'),
                                    subtitle: Text(record['date'] ?? 'Date unknown'),
                                    trailing: Text(
                                      isPresent ? 'Present' : 'Absent',
                                      style: TextStyle(
                                        color: isPresent ? Colors.green : Colors.red,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
