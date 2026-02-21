import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/sanity_service.dart';
import 'dart:async';

class StudentDashboardScreen extends StatefulWidget {
  final String studentName;
  final String studentId;
  final String? studentRollNumber;

  const StudentDashboardScreen({
    super.key,
    required this.studentName,
    required this.studentId,
    this.studentRollNumber,
  });

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  final SanityService _sanityService = SanityService();
  int _selectedIndex = 0;
  
  // Data
  List<Map<String, dynamic>> _courses = [];
  List<Map<String, dynamic>> _subjects = [];
  final List<Map<String, dynamic>> _chapters = [];
  final List<Map<String, dynamic>> _concepts = [];
  final List<Map<String, dynamic>> _tests = [];
  final List<Map<String, dynamic>> _myTestAttempts = [];
  final List<Map<String, dynamic>> _assignments = [];
  final List<Map<String, dynamic>> _progress = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final studentProfile = await _sanityService.getStudentById(widget.studentId);
      if (studentProfile == null) {
        setState(() => _isLoading = false);
        return;
      }
      final courses = studentProfile['enrolledCourses'] as List? ?? [];
      final subjects = courses.expand((course) => (course is Map ? (course['subjects'] as List? ?? []) : [])).toList();

      setState(() {
        _courses = List<Map<String, dynamic>>.from(courses.map((e) => e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{}));
        _subjects = List<Map<String, dynamic>>.from(subjects.map((e) => e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{}));
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading data: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${widget.studentName}'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
          IconButton(icon: const Icon(Icons.logout), onPressed: () => _showLogoutDialog()),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) => setState(() => _selectedIndex = index),
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(icon: Icon(Icons.dashboard), label: Text('Home')),
              NavigationRailDestination(icon: Icon(Icons.book), label: Text('Courses')),
              NavigationRailDestination(icon: Icon(Icons.quiz), label: Text('Tests')),
              NavigationRailDestination(icon: Icon(Icons.assignment), label: Text('Assignments')),
              NavigationRailDestination(icon: Icon(Icons.analytics), label: Text('My Progress')),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0: return _buildHomeTab();
      case 1: return _buildCoursesTab();
      case 2: return _buildTestsTab();
      case 3: return _buildAssignmentsTab();
      case 4: return _buildProgressTab();
      default: return _buildHomeTab();
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // HOME TAB
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Card
          Card(
            color: Colors.indigo[50],
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.indigo,
                    child: Text(widget.studentName.substring(0, 1).toUpperCase(), style: const TextStyle(fontSize: 32, color: Colors.white)),
                  ),
                  const SizedBox(width: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hello, ${widget.studentName}!', style: Theme.of(context).textTheme.headlineSmall),
                      Text('Roll Number: ${widget.studentRollNumber ?? 'N/A'}', style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Quick Stats
          Row(
            children: [
              _buildStatCard('Courses', _courses.length, Icons.book, Colors.blue),
              const SizedBox(width: 16),
              _buildStatCard('Tests Taken', _myTestAttempts.length, Icons.quiz, Colors.green),
              const SizedBox(width: 16),
              _buildStatCard('Completed', _progress.where((p) => p['completed'] == true).length, Icons.check_circle, Colors.orange),
              const SizedBox(width: 16),
              _buildStatCard('Pending', _assignments.length, Icons.assignment, Colors.red),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Upcoming Tests
          Text('Available Tests', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          _tests.isEmpty
            ? const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('No tests available right now')))
            : SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _tests.take(5).length,
                  itemBuilder: (context, index) {
                    final test = _tests[index];
                    final hasAttempted = _myTestAttempts.any((a) => a['test']?['_id'] == test['_id']);
                    return _buildTestCard(test, hasAttempted);
                  },
                ),
              ),
          
          const SizedBox(height: 32),
          
          // Recent Test Results
          if (_myTestAttempts.isNotEmpty) ...[
            Text('My Recent Results', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ..._myTestAttempts.take(3).map((attempt) => Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: attempt['passed'] == true ? Colors.green : Colors.red,
                  child: Icon(attempt['passed'] == true ? Icons.check : Icons.close, color: Colors.white),
                ),
                title: Text(attempt['test']?['title'] ?? 'Test'),
                subtitle: Text('Score: ${attempt['score']}/${attempt['test']?['totalMarks'] ?? 100} (${attempt['percentage']}%)'),
                trailing: Chip(
                  label: Text(attempt['passed'] == true ? 'PASSED' : 'FAILED'),
                  backgroundColor: attempt['passed'] == true ? Colors.green[100] : Colors.red[100],
                ),
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, int value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text('$value', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              Text(title, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestCard(Map<String, dynamic> test, bool hasAttempted) {
    return SizedBox(
      width: 280,
      child: Card(
        margin: const EdgeInsets.only(right: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.quiz, color: Colors.indigo),
                  const SizedBox(width: 8),
                  Expanded(child: Text(test['title'] ?? 'Test', style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)),
                ],
              ),
              const SizedBox(height: 8),
              Text('Duration: ${test['duration'] ?? 0} min'),
              Text('Total Marks: ${test['totalMarks'] ?? 0}'),
              Text('Pass: ${test['passingMarks'] ?? 0} marks'),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: hasAttempted ? null : () => _startTest(test),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                  child: Text(hasAttempted ? 'Attempted' : 'Start Test'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // COURSES TAB
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildCoursesTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text('My Courses', style: Theme.of(context).textTheme.titleLarge),
        ),
        Expanded(
          child: _courses.isEmpty
            ? const Center(child: Text('No courses available'))
            : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _courses.length,
                itemBuilder: (context, index) {
                  final course = _courses[index];
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => _viewCourseContent(course),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 80,
                            color: Colors.primaries[index % Colors.primaries.length][200],
                            child: Center(child: Icon(Icons.book, size: 40, color: Colors.primaries[index % Colors.primaries.length][700])),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(course['title'] ?? 'Course', style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                Text(course['description'] ?? 'No description', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Chip(label: Text(course['level'] ?? 'beginner', style: const TextStyle(fontSize: 10))),
                                    const Spacer(),
                                    Text('${course['subjectCount'] ?? 0} subjects', style: const TextStyle(fontSize: 11)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
        ),
      ],
    );
  }

  void _viewCourseContent(Map<String, dynamic> course) {
    final courseSubjects = _subjects.where((s) => s['course']?['_id'] == course['_id']).toList();
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: 800,
          height: 600,
          child: Column(
            children: [
              AppBar(
                title: Text(course['title'] ?? 'Course'),
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                automaticallyImplyLeading: false,
                actions: [IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context))],
              ),
              Expanded(
                child: courseSubjects.isEmpty
                  ? const Center(child: Text('No subjects in this course yet'))
                  : ListView.builder(
                      itemCount: courseSubjects.length,
                      itemBuilder: (context, index) {
                        final subject = courseSubjects[index];
                        final subjectChapters = _chapters.where((c) => c['subject']?['_id'] == subject['_id']).toList();
                        
                        return ExpansionTile(
                          leading: const Icon(Icons.book),
                          title: Text(subject['title'] ?? 'Subject'),
                          subtitle: Text('${subjectChapters.length} chapters'),
                          children: subjectChapters.map((chapter) {
                            final chapterConcepts = _concepts.where((c) => c['chapter']?['_id'] == chapter['_id']).toList();
                            
                            return ExpansionTile(
                              leading: const Icon(Icons.article, color: Colors.orange),
                              title: Text(chapter['title'] ?? 'Chapter'),
                              subtitle: Text('${chapterConcepts.length} lessons'),
                              children: chapterConcepts.map((concept) => ListTile(
                                leading: const Icon(Icons.play_circle, color: Colors.green),
                                title: Text(concept['title'] ?? 'Lesson'),
                                subtitle: concept['videoUrl'] != null ? const Text('Video lesson') : null,
                                onTap: () => _viewLesson(concept),
                              )).toList(),
                            );
                          }).toList(),
                        );
                      },
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _viewLesson(Map<String, dynamic> concept) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(concept['title'] ?? 'Lesson'),
        content: SizedBox(
          width: 600,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (concept['videoUrl'] != null) ...[
                  Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.play_circle, size: 64, color: Colors.indigo),
                          const SizedBox(height: 8),
                          Text('Video: ${concept['videoUrl']}', style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                const Text('Content:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(concept['content'] is List 
                  ? (concept['content'] as List).map((b) => b['children']?[0]?['text'] ?? '').join('\n')
                  : concept['content']?.toString() ?? 'No content available'),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await _sanityService.markConceptComplete(
                studentId: widget.studentId,
                conceptId: concept['_id'],
              );
              Navigator.pop(context);
              _showSnackBar('Lesson marked as complete!', Colors.green);
              _loadData();
            },
            child: const Text('Mark Complete'),
          ),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // TESTS TAB - NTA STYLE
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildTestsTab() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Available Tests'),
              Tab(text: 'My Results'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildAvailableTests(),
                _buildMyResults(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableTests() {
    return _tests.isEmpty
      ? const Center(child: Text('No tests available'))
      : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _tests.length,
          itemBuilder: (context, index) {
            final test = _tests[index];
            final hasAttempted = _myTestAttempts.any((a) => a['test']?['_id'] == test['_id']);
            
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.indigo[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.quiz, color: Colors.indigo, size: 32),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(test['title'] ?? 'Test', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(test['description'] ?? 'No description', style: const TextStyle(color: Colors.grey)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 16,
                            children: [
                              _buildTestInfo(Icons.timer, '${test['duration'] ?? 0} min'),
                              _buildTestInfo(Icons.score, '${test['totalMarks'] ?? 0} marks'),
                              _buildTestInfo(Icons.check, 'Pass: ${test['passingMarks'] ?? 0}'),
                              _buildTestInfo(Icons.quiz, '${test['questionCount'] ?? 0} questions'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Column(
                      children: [
                        if (hasAttempted)
                          const Chip(label: Text('Completed'), backgroundColor: Colors.green)
                        else
                          ElevatedButton.icon(
                            onPressed: () => _startTest(test),
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Start Test'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
  }

  Widget _buildTestInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildMyResults() {
    return _myTestAttempts.isEmpty
      ? const Center(child: Text('No test attempts yet'))
      : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _myTestAttempts.length,
          itemBuilder: (context, index) {
            final attempt = _myTestAttempts[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  radius: 25,
                  backgroundColor: attempt['passed'] == true ? Colors.green : Colors.red,
                  child: Text('${attempt['percentage']?.round() ?? 0}%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                title: Text(attempt['test']?['title'] ?? 'Test'),
                subtitle: Text('Score: ${attempt['score']}/${attempt['test']?['totalMarks'] ?? 100} • Time: ${attempt['timeSpent'] ?? 0} min'),
                trailing: Chip(
                  label: Text(attempt['passed'] == true ? 'PASSED' : 'FAILED'),
                  backgroundColor: attempt['passed'] == true ? Colors.green[100] : Colors.red[100],
                ),
              ),
            );
          },
        );
  }

  // ═══════════════════════════════════════════════════════════════════
  // NTA STYLE TEST INTERFACE
  // ═══════════════════════════════════════════════════════════════════

  void _startTest(Map<String, dynamic> test) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start Test'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Test: ${test['title']}'),
            Text('Duration: ${test['duration']} minutes'),
            Text('Total Marks: ${test['totalMarks']}'),
            Text('Passing Marks: ${test['passingMarks']}'),
            Text('Questions: ${test['questionCount'] ?? test['questions']?.length ?? 0}'),
            const SizedBox(height: 16),
            const Text('Instructions:', style: TextStyle(fontWeight: FontWeight.bold)),
            const Text('• Do not refresh the page during the test'),
            const Text('• All questions are mandatory'),
            const Text('• You can navigate between questions'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _openTestWindow(test);
            },
            child: const Text('Start Now'),
          ),
        ],
      ),
    );
  }

  void _openTestWindow(Map<String, dynamic> test) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => NTAStyleTestScreen(
          test: test,
          studentId: widget.studentId,
          studentName: widget.studentName,
          onComplete: (score, percentage, passed, timeSpent) async {
            await _sanityService.submitTestAttempt(
              testId: test['_id'],
              studentId: widget.studentId,
              score: score,
              percentage: percentage,
              passed: passed,
              timeSpent: timeSpent,
            );
            _loadData();
          },
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // ASSIGNMENTS TAB
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildAssignmentsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Assignments', style: Theme.of(context).textTheme.titleLarge),
        ),
        Expanded(
          child: _assignments.isEmpty
            ? const Center(child: Text('No assignments yet'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _assignments.length,
                itemBuilder: (context, index) {
                  final assignment = _assignments[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.assignment, color: Colors.orange),
                      title: Text(assignment['title'] ?? 'Assignment'),
                      subtitle: Text('Due: ${assignment['dueDate']?.toString().split('T')[0] ?? 'N/A'} • Max: ${assignment['maxScore'] ?? 100} marks'),
                      trailing: ElevatedButton(
                        onPressed: () {},
                        child: const Text('Submit'),
                      ),
                    ),
                  );
                },
              ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // PROGRESS TAB
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildProgressTab() {
    final completedCount = _progress.where((p) => p['completed'] == true).length;
    final totalConcepts = _concepts.length;
    final progressPercent = totalConcepts > 0 ? (completedCount / totalConcepts * 100).round() : 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('My Progress', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 24),
          
          // Overall Progress Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text('$progressPercent%', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.indigo)),
                            const Text('Overall Progress'),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text('$completedCount / $totalConcepts', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                            const Text('Lessons Completed'),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text('${_myTestAttempts.length}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                            const Text('Tests Taken'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(value: progressPercent / 100, minHeight: 10, backgroundColor: Colors.grey[200]),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          Text('Completed Lessons', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          
          ..._progress.where((p) => p['completed'] == true).map((p) => Card(
            child: ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: Text(p['concept']?['title'] ?? 'Lesson'),
              subtitle: Text('Completed on: ${p['completedAt']?.toString().split('T')[0] ?? 'N/A'}'),
            ),
          )),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () { Navigator.pop(context); context.go('/'); }, child: const Text('Logout')),
        ],
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// NTA STYLE TEST SCREEN
// ═══════════════════════════════════════════════════════════════════════════

class NTAStyleTestScreen extends StatefulWidget {
  final Map<String, dynamic> test;
  final String studentId;
  final String studentName;
  final Function(int score, double percentage, bool passed, int timeSpent) onComplete;

  const NTAStyleTestScreen({
    super.key,
    required this.test,
    required this.studentId,
    required this.studentName,
    required this.onComplete,
  });

  @override
  State<NTAStyleTestScreen> createState() => _NTAStyleTestScreenState();
}

class _NTAStyleTestScreenState extends State<NTAStyleTestScreen> {
  int _currentQuestion = 0;
  final Map<int, String> _answers = {};
  final Map<int, bool> _markedForReview = {};
  late Timer _timer;
  int _remainingSeconds = 0;
  bool _isSubmitting = false;

  List<Map<String, dynamic>> get _questions => 
    (widget.test['questions'] as List?)?.cast<Map<String, dynamic>>() ?? [];

  @override
  void initState() {
    super.initState();
    _remainingSeconds = (widget.test['duration'] ?? 30) * 60;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _submitTest();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.test['title'] ?? 'Test')),
        body: const Center(child: Text('No questions in this test')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Row(
        children: [
          // Main Test Area
          Expanded(
            flex: 3,
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.indigo,
                  child: Row(
                    children: [
                      const Icon(Icons.quiz, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(widget.test['title'] ?? 'Test', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: _remainingSeconds < 300 ? Colors.red : Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.timer, color: _remainingSeconds < 300 ? Colors.white : Colors.indigo),
                            const SizedBox(width: 8),
                            Text(_formattedTime, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _remainingSeconds < 300 ? Colors.white : Colors.indigo)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Question Area
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(color: Colors.indigo, borderRadius: BorderRadius.circular(4)),
                                  child: Text('Question ${_currentQuestion + 1}/${_questions.length}', style: const TextStyle(color: Colors.white)),
                                ),
                                const SizedBox(width: 12),
                                Text('Marks: ${_questions[_currentQuestion]['marks'] ?? 1}', style: const TextStyle(color: Colors.grey)),
                              ],
                            ),
                            const Divider(height: 32),
                            
                            // Question Text
                            Text(
                              _questions[_currentQuestion]['questionText'] ?? 'Question',
                              style: const TextStyle(fontSize: 18),
                            ),
                            const SizedBox(height: 24),
                            
                            // Options
                            ...(_questions[_currentQuestion]['options'] as List? ?? []).asMap().entries.map((entry) {
                              final index = entry.key;
                              final option = entry.value.toString();
                              final isSelected = _answers[_currentQuestion] == option;
                              final optionLabel = String.fromCharCode(65 + index); // A, B, C, D
                              
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: InkWell(
                                  onTap: () => setState(() => _answers[_currentQuestion] = option),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: isSelected ? Colors.indigo : Colors.grey[300]!, width: 2),
                                      borderRadius: BorderRadius.circular(8),
                                      color: isSelected ? Colors.indigo[50] : Colors.white,
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: isSelected ? Colors.indigo : Colors.grey[200],
                                          ),
                                          child: Center(child: Text(optionLabel, style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold))),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(child: Text(option)),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Navigation Buttons
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Row(
                    children: [
                      OutlinedButton(
                        onPressed: () => setState(() => _markedForReview[_currentQuestion] = !(_markedForReview[_currentQuestion] ?? false)),
                        child: Text(_markedForReview[_currentQuestion] == true ? 'Unmark Review' : 'Mark for Review'),
                      ),
                      const Spacer(),
                      if (_currentQuestion > 0)
                        ElevatedButton(
                          onPressed: () => setState(() => _currentQuestion--),
                          child: const Text('Previous'),
                        ),
                      const SizedBox(width: 12),
                      if (_currentQuestion < _questions.length - 1)
                        ElevatedButton(
                          onPressed: () => setState(() => _currentQuestion++),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                          child: const Text('Save & Next'),
                        ),
                      if (_currentQuestion == _questions.length - 1)
                        ElevatedButton(
                          onPressed: _submitTest,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          child: const Text('Submit Test'),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Question Palette (Right Sidebar)
          Container(
            width: 280,
            color: Colors.white,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey[100],
                  child: Column(
                    children: [
                      Text(widget.studentName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildLegendItem(Colors.green, 'Answered'),
                          _buildLegendItem(Colors.orange, 'Review'),
                          _buildLegendItem(Colors.grey, 'Not Answered'),
                        ],
                      ),
                    ],
                  ),
                ),
                
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(_questions.length, (index) {
                        final isAnswered = _answers.containsKey(index);
                        final isMarked = _markedForReview[index] == true;
                        final isCurrent = index == _currentQuestion;
                        
                        Color bgColor;
                        if (isMarked) {
                          bgColor = Colors.orange;
                        } else if (isAnswered) {
                          bgColor = Colors.green;
                        } else {
                          bgColor = Colors.grey[300]!;
                        }
                        
                        return InkWell(
                          onTap: () => setState(() => _currentQuestion = index),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: bgColor,
                              border: isCurrent ? Border.all(color: Colors.indigo, width: 3) : null,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Center(
                              child: Text('${index + 1}', style: TextStyle(color: isAnswered || isMarked ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitTest,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.all(16)),
                      child: const Text('SUBMIT TEST', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 16, height: 16, color: color),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10)),
      ],
    );
  }

  void _submitTest() {
    if (_isSubmitting) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Test?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Answered: ${_answers.length}/${_questions.length}'),
            Text('Marked for Review: ${_markedForReview.values.where((v) => v).length}'),
            Text('Not Answered: ${_questions.length - _answers.length}'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _doSubmit();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _doSubmit() {
    setState(() => _isSubmitting = true);
    _timer.cancel();
    
    // Calculate score
    int score = 0;
    int totalMarks = widget.test['totalMarks'] ?? 100;
    
    for (int i = 0; i < _questions.length; i++) {
      if (_answers.containsKey(i)) {
        final correctAnswer = _questions[i]['correctAnswer'];
        if (_answers[i] == correctAnswer) {
          score += (_questions[i]['marks'] ?? 1) as int;
        }
      }
    }
    
    final percentage = totalMarks > 0 ? (score / totalMarks * 100) : 0.0;
    final passed = score >= (widget.test['passingMarks'] ?? 40);
    final timeSpent = ((widget.test['duration'] ?? 30) * 60 - _remainingSeconds) ~/ 60;
    
    // Show result
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(passed ? Icons.check_circle : Icons.cancel, color: passed ? Colors.green : Colors.red, size: 32),
            const SizedBox(width: 12),
            Text(passed ? 'Congratulations!' : 'Test Completed'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Score: $score / $totalMarks', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text('Percentage: ${percentage.round()}%', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Chip(
              label: Text(passed ? 'PASSED' : 'FAILED'),
              backgroundColor: passed ? Colors.green[100] : Colors.red[100],
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              widget.onComplete(score, percentage, passed, timeSpent);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
