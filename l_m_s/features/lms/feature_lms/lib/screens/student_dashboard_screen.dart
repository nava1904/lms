import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StudentDashboardScreen extends StatefulWidget {
  final String studentName;
  final String rollNumber;
  final String studentId;

  const StudentDashboardScreen({
    super.key,
    required this.studentName,
    required this.rollNumber,
    required this.studentId,
  });

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  int _selectedIndex = 0;
  List<dynamic> _subjects = [];
  List<dynamic> _upcomingTests = [];
  List<dynamic> _recentMaterials = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    // TODO: Fetch data from Sanity for this student
    setState(() { _loading = false; });
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
          'Welcome, ${widget.studentName}',
          style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.grey),
            onPressed: () => GoRouter.of(context).go('/'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Student Info Card
                Card(
                  elevation: 0,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Roll Number', style: theme.textTheme.labelSmall),
                        Text(widget.rollNumber, style: theme.textTheme.headlineSmall),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // My Subjects
                Text('My Subjects', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                if (_subjects.isEmpty)
                  const Text('No subjects assigned yet.')
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.2),
                    itemCount: _subjects.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 0,
                        color: Colors.white,
                        child: InkWell(
                          onTap: () => GoRouter.of(context).go('/content', extra: _subjects[index]),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.book, size: 32, color: theme.colorScheme.primary),
                                const SizedBox(height: 8),
                                Text(_subjects[index]['title'] ?? 'Subject', textAlign: TextAlign.center, style: theme.textTheme.bodySmall),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 20),
                // Upcoming Tests
                Text('Upcoming Tests', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                if (_upcomingTests.isEmpty)
                  const Text('No upcoming tests.')
                else
                  ...List.generate(_upcomingTests.length, (index) {
                    return Card(
                      elevation: 0,
                      color: Colors.white,
                      child: ListTile(
                        leading: Icon(Icons.quiz, color: theme.colorScheme.secondary),
                        title: Text(_upcomingTests[index]['title'] ?? 'Test'),
                        subtitle: Text('${_upcomingTests[index]['durationMinutes'] ?? 0} min'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      ),
                    );
                  }),
                const SizedBox(height: 20),
                // Recent Materials
                Text('Recent Materials', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                if (_recentMaterials.isEmpty)
                  const Text('No recent materials.')
                else
                  ...List.generate(_recentMaterials.length, (index) {
                    return Card(
                      elevation: 0,
                      color: Colors.white,
                      child: ListTile(
                        leading: Icon(Icons.article, color: theme.colorScheme.tertiary),
                        title: Text(_recentMaterials[index]['title'] ?? 'Material'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      ),
                    );
                  }),
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.library_books), label: 'Library'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
