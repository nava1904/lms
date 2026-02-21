import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';
import '../core/session_clearer.dart';
import '../models/attendance.dart';
import '../services/lms_sanity_service.dart';
import '../services/sanity_service.dart';
import '../stores/teacher_content_store.dart';
import '../stores/teacher_dashboard_store.dart';
import '../theme/lms_theme.dart';

class TeacherDashboardScreen extends StatefulWidget {
  final String teacherName;
  final String teacherId;

  const TeacherDashboardScreen({
    super.key,
    required this.teacherName,
    required this.teacherId,
  });

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  final TeacherDashboardStore _metricsStore = TeacherDashboardStore();
  final TeacherContentStore _contentStore = TeacherContentStore();
  final SanityService _sanityService = SanityService();
  int _selectedIndex = 0;
  
  // Data (legacy tabs still use SanityService)
  List<Map<String, dynamic>> _students = [];
  List<Map<String, dynamic>> _testAttempts = [];
  List<AttendanceRecord> _attendanceRecords = [];
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _metricsStore.loadClassMetrics();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final students = await _sanityService.fetchStudents();
      final subjects = await _sanityService.fetchSubjects();
      final chapters = await _sanityService.fetchChapters();
      final tests = await _sanityService.fetchTests();
      final testAttempts = await _sanityService.fetchTestAttempts();
      final questions = await _sanityService.fetchQuestions();
      final attendanceRecords = await LmsSanityService().getAttendanceForPercentages();
      await _sanityService.getDashboardStats();
      if (mounted) {
        setState(() {
          _students = students;
          _contentStore.setSubjects(subjects);
          _contentStore.setChapters(chapters);
          _contentStore.setTests(tests);
          _contentStore.setQuestions(questions);
          _testAttempts = testAttempts;
          _attendanceRecords = attendanceRecords;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading teacher dashboard data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadError = e.toString().contains('authorization') || e.toString().contains('token')
              ? 'Sanity API token missing or invalid. Set SANITY_API_TOKEN in apps/l_m_s/.env and run from apps/l_m_s.'
              : e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: LMSTheme.primaryColor))
          : _loadError != null
              ? _buildErrorState()
              : _buildContent(),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(LMSTheme.radiusMd),
            side: const BorderSide(color: LMSTheme.borderColor),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_off, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(height: 16),
                Text(
                  'Could not load dashboard',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _loadError!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _loadData,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: FilledButton.styleFrom(
                    backgroundColor: LMSTheme.primaryColor,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final isWide = MediaQuery.of(context).size.width >= 600;
    if (isWide) {
      return Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) => setState(() => _selectedIndex = index),
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: Text('Overview')),
              NavigationRailDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: Text('Students')),
              NavigationRailDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: Text('Content')),
              NavigationRailDestination(icon: Icon(Icons.quiz_outlined), selectedIcon: Icon(Icons.quiz), label: Text('Tests')),
              NavigationRailDestination(icon: Icon(Icons.analytics_outlined), selectedIcon: Icon(Icons.analytics), label: Text('Analytics')),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: _buildTabContent()),
        ],
      );
    }
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              _tabChip(0, Icons.dashboard_outlined, 'Overview'),
              _tabChip(1, Icons.people_outline, 'Students'),
              _tabChip(2, Icons.menu_book_outlined, 'Content'),
              _tabChip(3, Icons.quiz_outlined, 'Tests'),
              _tabChip(4, Icons.analytics_outlined, 'Analytics'),
            ],
          ),
        ),
        Expanded(child: _buildTabContent()),
      ],
    );
  }

  Widget _tabChip(int index, IconData icon, String label) {
    final selected = _selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: selected,
        avatar: Icon(icon, size: 18, color: selected ? LMSTheme.primaryColor : LMSTheme.mutedForeground),
        label: Text(label),
        onSelected: (_) => setState(() => _selectedIndex = index),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildOverviewTab();
      case 1:
        return _buildStudentsTab();
      case 2:
        return _buildContentTab();
      case 3:
        return _buildTestsTab();
      case 4:
        return _buildAnalyticsTab();
      default:
        return _buildOverviewTab();
    }
  }

  Widget? _buildFAB() {
    if (_selectedIndex == 2) {
      return FloatingActionButton.extended(
        onPressed: () => _showAddContentDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Content'),
        backgroundColor: LMSTheme.primaryColor,
      );
    } else if (_selectedIndex == 3) {
      return FloatingActionButton.extended(
        onPressed: () => _showCreateTestDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Create Test'),
        backgroundColor: LMSTheme.primaryColor,
      );
    }
    return null;
  }

  // ═══════════════════════════════════════════════════════════════════
  // OVERVIEW TAB
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildOverviewTab() {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome, ${widget.teacherName.isNotEmpty ? widget.teacherName : 'Teacher'}!',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          Observer(
            builder: (_) {
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(LMSTheme.radiusMd),
                  side: const BorderSide(color: LMSTheme.borderColor),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Class metrics',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      if (_metricsStore.loading)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator(color: LMSTheme.primaryColor)),
                        ),
                      if (!_metricsStore.loading && _metricsStore.error != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            _metricsStore.error!,
                            style: const TextStyle(color: LMSTheme.errorColor),
                          ),
                        ),
                      if (!_metricsStore.loading && _metricsStore.error == null) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildQuickStat(
                              'Last test avg score',
                              '${_metricsStore.lastTestAverageScore.toStringAsFixed(1)}%',
                              Icons.bar_chart,
                              LMSTheme.primaryColor,
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildQuickStat('My Students', _students.length, Icons.people, LMSTheme.primaryColor),
              const SizedBox(width: 16),
              _buildQuickStat('Subjects', _contentStore.subjects.length, Icons.book, LMSTheme.successColor),
              const SizedBox(width: 16),
              _buildQuickStat('Chapters', _contentStore.chapters.length, Icons.article, LMSTheme.warningColor),
              const SizedBox(width: 16),
              _buildQuickStat('Tests Created', _contentStore.tests.length, Icons.quiz, LMSTheme.primaryColor),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'Recent Test Results',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildRecentTestResults(),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String title, Object value, IconData icon, Color color) {
    final theme = Theme.of(context);
    return Expanded(
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LMSTheme.radiusMd),
          side: BorderSide(color: theme.dividerColor),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 8),
              Text(
                '$value',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentTestResults() {
    if (_testAttempts.isEmpty) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LMSTheme.radiusMd),
          side: const BorderSide(color: LMSTheme.borderColor),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'No test attempts yet',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ),
      );
    }
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(LMSTheme.radiusMd),
        side: const BorderSide(color: LMSTheme.borderColor),
      ),
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Student')),
          DataColumn(label: Text('Test')),
          DataColumn(label: Text('Score')),
          DataColumn(label: Text('Status')),
        ],
        rows: _testAttempts.take(5).map((attempt) {
          return DataRow(cells: [
            DataCell(Text(attempt['student']?['name'] ?? 'Unknown')),
            DataCell(Text(attempt['test']?['title'] ?? 'Unknown')),
            DataCell(Text('${attempt['score'] ?? 0}/${attempt['test']?['totalMarks'] ?? 100}')),
            DataCell(Chip(
              label: Text(attempt['passed'] == true ? 'Passed' : 'Failed'),
              backgroundColor: attempt['passed'] == true
                  ? LMSTheme.successColor.withValues(alpha: 0.2)
                  : LMSTheme.errorColor.withValues(alpha: 0.2),
            )),
          ]);
        }).toList(),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // STUDENTS TAB
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildStudentsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text('Enrolled Students (${_students.length})', style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showMarkAttendanceDialog(),
                icon: const Icon(Icons.check_circle),
                label: const Text('Mark Attendance'),
              ),
            ],
          ),
        ),
        Expanded(
          child: _students.isEmpty
            ? const Center(child: Text('No students enrolled yet'))
            : ListView.builder(
                itemCount: _students.length,
                itemBuilder: (context, index) {
                  final student = _students[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: ExpansionTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(student['name']?.substring(0, 1) ?? 'S'),
                      ),
                      title: Text(student['name'] ?? 'Unknown'),
                      subtitle: Text('Roll: ${student['rollNumber'] ?? 'N/A'} • ${student['email'] ?? ''}'),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStudentStat('Tests Taken', '${_getStudentTestCount(student['_id'])}'),
                              _buildStudentStat('Avg Score', '${_getStudentAvgScore(student['_id'])}%'),
                              _buildStudentStat('Attendance', '${_getStudentAttendance(student['_id'])}%'),
                              ElevatedButton(
                                onPressed: () => _viewStudentDetails(student),
                                child: const Text('View Details'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
        ),
      ],
    );
  }

  Widget _buildStudentStat(String label, String value) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
        Text(label, style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }

  int _getStudentTestCount(String? studentId) {
    if (studentId == null || studentId.isEmpty) return 0;
    return _testAttempts.where((a) {
      final sid = a['student']?['_id'] ?? a['student']?['_ref'];
      return sid == studentId;
    }).length;
  }

  int _getStudentAvgScore(String? studentId) {
    if (studentId == null || studentId.isEmpty) return 0;
    final attempts = _testAttempts.where((a) {
      final sid = a['student']?['_id'] ?? a['student']?['_ref'];
      return sid == studentId;
    }).toList();
    if (attempts.isEmpty) return 0;
    final total = attempts.fold<double>(0, (sum, a) => sum + (a['percentage'] ?? 0).toDouble());
    return (total / attempts.length).round();
  }

  int _getStudentAttendance(String? studentId) {
    if (studentId == null) return 0;
    final records = _attendanceRecords.where((a) => a.studentId == studentId).toList();
    if (records.isEmpty) return 0;
    final attended = records.where((a) => a.status == 'present' || a.status == 'late').length;
    return ((attended / records.length) * 100).round();
  }

  void _viewStudentDetails(Map<String, dynamic> student) {
    final studentId = student['_id'] as String? ?? '';
    if (studentId.isNotEmpty) {
      context.push('/teacher/students/$studentId', extra: student);
      return;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(student['name'] ?? 'Student'),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Email: ${student['email'] ?? 'N/A'}'),
              Text('Roll Number: ${student['rollNumber'] ?? 'N/A'}'),
              Text('Phone: ${student['phone'] ?? 'N/A'}'),
              const SizedBox(height: 16),
              const Text('Test History:', style: TextStyle(fontWeight: FontWeight.bold)),
              ..._testAttempts
                  .where((a) {
                    final sid = a['student']?['_id'] ?? a['student']?['_ref'];
                    return sid == student['_id'];
                  })
                  .map((a) => ListTile(
                        title: Text(a['test']?['title'] ?? 'Test'),
                        subtitle: Text('Score: ${a['score']} • ${a['passed'] == true ? 'Passed' : 'Failed'}'),
                      )),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // CONTENT TAB
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildContentTab() {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Subjects'),
              Tab(text: 'Chapters'),
              Tab(text: 'Questions'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildSubjectsList(),
                _buildChaptersList(),
                _buildQuestionsList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> get _sortedSubjects {
    final list = List<Map<String, dynamic>>.from(_contentStore.subjects);
    list.sort((a, b) {
      final ta = (a['title'] as String? ?? '').toLowerCase();
      final tb = (b['title'] as String? ?? '').toLowerCase();
      return ta.compareTo(tb);
    });
    return list;
  }

  Widget _buildSubjectsList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text('Subjects (${_contentStore.subjects.length})', style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showAddSubjectDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Add Subject'),
              ),
            ],
          ),
        ),
        Expanded(
          child: Observer(
            builder: (_) => _contentStore.subjects.isEmpty
            ? const Center(child: Text('No subjects yet. Create your first subject!'))
            : ListView.builder(
                itemCount: _sortedSubjects.length,
                itemBuilder: (context, index) {
                  final subject = _sortedSubjects[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: ListTile(
                      leading: const Icon(Icons.book, color: Colors.teal),
                      title: Text(subject['title'] ?? 'Untitled'),
                      subtitle: Text('${subject['chapterCount'] ?? 0} chapters • ${subject['lessonCount'] ?? 0} lessons'),
                      trailing: IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => _showAddChapterDialog(subject['_id'], subject['title']),
                        tooltip: 'Add Chapter',
                      ),
                    ),
                  );
                },
              ),
          ),
        ),
      ],
    );
  }

  Widget _buildChaptersList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Chapters (${_contentStore.chapters.length})', style: Theme.of(context).textTheme.titleMedium),
        ),
        Expanded(
          child: Observer(
            builder: (_) => _contentStore.chapters.isEmpty
            ? const Center(child: Text('No chapters yet'))
            : ListView.builder(
                itemCount: _contentStore.chapters.length,
                itemBuilder: (context, index) {
                  final chapter = _contentStore.chapters[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: ListTile(
                      leading: const Icon(Icons.article, color: Colors.orange),
                      title: Text(chapter['title'] ?? 'Untitled'),
                      subtitle: Text('Subject: ${chapter['subject']?['title'] ?? 'Unknown'} • ${chapter['conceptCount'] ?? 0} lessons'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_note),
                            onPressed: () => context.push('/content-editor', extra: {
                              'chapterId': chapter['_id'] ?? '',
                              'chapterTitle': chapter['title'] ?? 'Chapter',
                              'subjectTitle': chapter['subject']?['title'] ?? 'Subject',
                            }),
                            tooltip: 'Content Studio',
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () => _showAddConceptDialog(chapter['_id'], chapter['title']),
                            tooltip: 'Add Lesson',
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionsList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text('Question Bank (${_contentStore.questions.length})', style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showAddQuestionDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Add Question'),
              ),
            ],
          ),
        ),
        Expanded(
          child: Observer(
            builder: (_) => _contentStore.questions.isEmpty
            ? const Center(child: Text('No questions yet. Create your first question!'))
            : ListView.builder(
                itemCount: _contentStore.questions.length,
                itemBuilder: (context, index) {
                  final question = _contentStore.questions[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(child: Text('${index + 1}')),
                      title: Text(question['questionText'] ?? 'No question', maxLines: 2, overflow: TextOverflow.ellipsis),
                      subtitle: Text('${question['questionType'] ?? 'mcq'} • ${question['marks'] ?? 1} marks • ${question['difficulty'] ?? 'medium'}'),
                    ),
                  );
                },
              ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // TESTS TAB
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildTestsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text('Tests (${_contentStore.tests.length})', style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
            ],
          ),
        ),
        Expanded(
          child: Observer(
            builder: (_) => _contentStore.tests.isEmpty
            ? const Center(child: Text('No tests created yet. Create your first test!'))
            : ListView.builder(
                itemCount: _contentStore.tests.length,
                itemBuilder: (context, index) {
                  final test = _contentStore.tests[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(test['title'] ?? 'Untitled Test', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              ),
                              Chip(
                                label: Text(test['isPublished'] == true ? 'Published' : 'Draft'),
                                backgroundColor: test['isPublished'] == true
                                    ? LMSTheme.successColor.withValues(alpha: 0.2)
                                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(test['description'] ?? 'No description'),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildTestStat(Icons.timer, '${test['duration'] ?? 0} min'),
                              const SizedBox(width: 24),
                              _buildTestStat(Icons.score, '${test['totalMarks'] ?? 0} marks'),
                              const SizedBox(width: 24),
                              _buildTestStat(Icons.check_circle, 'Pass: ${test['passingMarks'] ?? 0}'),
                              const SizedBox(width: 24),
                              _buildTestStat(Icons.quiz, '${test['questionCount'] ?? 0} questions'),
                              const Spacer(),
                              TextButton(
                                onPressed: () => _viewTestResults(test),
                                child: const Text('View Results'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ),
        ),
      ],
    );
  }

  Widget _buildTestStat(IconData icon, String text) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(color: color)),
      ],
    );
  }

  void _viewTestResults(Map<String, dynamic> test) {
    final results = _testAttempts.where((a) => a['test']?['_id'] == test['_id']).toList();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Results: ${test['title']}'),
        content: SizedBox(
          width: 600,
          height: 400,
          child: results.isEmpty
            ? const Center(child: Text('No attempts yet'))
            : DataTable(
                columns: const [
                  DataColumn(label: Text('Student')),
                  DataColumn(label: Text('Roll No')),
                  DataColumn(label: Text('Score')),
                  DataColumn(label: Text('%')),
                  DataColumn(label: Text('Status')),
                ],
                rows: results.map((r) => DataRow(cells: [
                  DataCell(Text(r['student']?['name'] ?? 'Unknown')),
                  DataCell(Text(r['student']?['rollNumber'] ?? 'N/A')),
                  DataCell(Text('${r['score']}/${test['totalMarks']}')),
                  DataCell(Text('${r['percentage']}%')),
                  DataCell(Chip(
                    label: Text(r['passed'] == true ? 'Pass' : 'Fail'),
                    backgroundColor: r['passed'] == true
                        ? LMSTheme.successColor.withValues(alpha: 0.2)
                        : LMSTheme.errorColor.withValues(alpha: 0.2),
                  )),
                ])).toList(),
              ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // ANALYTICS TAB
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Analytics Overview', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 24),
          
          // Overall Stats
          Row(
            children: [
              _buildAnalyticCard('Total Test Attempts', '${_testAttempts.length}', Icons.assignment, Colors.blue),
              const SizedBox(width: 16),
              _buildAnalyticCard('Pass Rate', '${_calculatePassRate()}%', Icons.check_circle, Colors.green),
              const SizedBox(width: 16),
              _buildAnalyticCard('Avg Score', '${_calculateAvgScore()}%', Icons.score, Colors.orange),
            ],
          ),
          
          const SizedBox(height: 32),
          Text('Test Performance', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          
          // Performance by Test
          Card(
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Test')),
                DataColumn(label: Text('Attempts')),
                DataColumn(label: Text('Pass Rate')),
                DataColumn(label: Text('Avg Score')),
              ],
              rows: _contentStore.tests.map((test) {
                final attempts = _testAttempts.where((a) => a['test']?['_id'] == test['_id']).toList();
                final passCount = attempts.where((a) => a['passed'] == true).length;
                final passRate = attempts.isEmpty ? 0 : (passCount / attempts.length * 100).round();
                final avgScore = attempts.isEmpty ? 0 : (attempts.fold<double>(0, (s, a) => s + (a['percentage'] ?? 0).toDouble()) / attempts.length).round();
                
                return DataRow(cells: [
                  DataCell(Text(test['title'] ?? 'Unknown')),
                  DataCell(Text('${attempts.length}')),
                  DataCell(Text('$passRate%')),
                  DataCell(Text('$avgScore%')),
                ]);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticCard(String title, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 16),
              Text(value, style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
              Text(title, style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }

  int _calculatePassRate() {
    if (_testAttempts.isEmpty) return 0;
    final passCount = _testAttempts.where((a) => a['passed'] == true).length;
    return (passCount / _testAttempts.length * 100).round();
  }

  int _calculateAvgScore() {
    if (_testAttempts.isEmpty) return 0;
    final total = _testAttempts.fold<double>(0, (sum, a) => sum + (a['percentage'] ?? 0).toDouble());
    return (total / _testAttempts.length).round();
  }

  // ═══════════════════════════════════════════════════════════════════
  // DIALOGS
  // ═══════════════════════════════════════════════════════════════════

  void _showAddContentDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.book),
            title: const Text('Add Subject'),
            onTap: () { Navigator.pop(context); _showAddSubjectDialog(); },
          ),
          ListTile(
            leading: const Icon(Icons.article),
            title: const Text('Add Chapter'),
            onTap: () { Navigator.pop(context); _showSelectSubjectForChapter(); },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Add Question'),
            onTap: () { Navigator.pop(context); _showAddQuestionDialog(); },
          ),
        ],
      ),
    );
  }

  void _showAddSubjectDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Subject'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Subject Title *')),
            TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description'), maxLines: 2),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty) {
                Navigator.pop(context);
                final result = await _sanityService.createSubject(
                  title: titleController.text,
                  description: descController.text.isNotEmpty ? descController.text : null,
                );
                if (result != null) {
                  _contentStore.addSubject(result);
                  _showSnackBar('Subject created!', Colors.green);
                } else {
                  _showSnackBar('Failed to create subject. Configure write token.', Colors.red);
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showSelectSubjectForChapter() {
    if (_contentStore.subjects.isEmpty) {
      _showSnackBar('Create a subject first!', Colors.orange);
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Subject'),
        content: SizedBox(
          width: 300,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _contentStore.subjects.length,
            itemBuilder: (context, index) {
              final subject = _contentStore.subjects[index];
              return ListTile(
                title: Text(subject['title'] ?? 'Untitled'),
                onTap: () {
                  Navigator.pop(context);
                  _showAddChapterDialog(subject['_id'], subject['title']);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showAddChapterDialog(String? subjectId, String? subjectTitle) {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Chapter to ${subjectTitle ?? "Subject"}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Chapter Title *')),
            TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description'), maxLines: 2),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty && subjectId != null) {
                Navigator.pop(context);
                final result = await _sanityService.createChapter(
                  title: titleController.text,
                  description: descController.text.isNotEmpty ? descController.text : null,
                  subjectId: subjectId,
                );
                if (result != null) {
                  final chapterWithSubject = Map<String, dynamic>.from(result)
                    ..['subject'] = {'title': subjectTitle, '_id': subjectId};
                  _contentStore.addChapter(chapterWithSubject);
                  _showSnackBar('Chapter created!', Colors.green);
                } else {
                  _showSnackBar('Failed to create chapter', Colors.red);
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showAddConceptDialog(String? chapterId, String? chapterTitle) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final videoController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Lesson to ${chapterTitle ?? "Chapter"}'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Lesson Title *')),
              TextField(controller: contentController, decoration: const InputDecoration(labelText: 'Content'), maxLines: 4),
              TextField(controller: videoController, decoration: const InputDecoration(labelText: 'Video URL (YouTube)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty && chapterId != null) {
                Navigator.pop(context);
                final result = await _sanityService.createConcept(
                  title: titleController.text,
                  content: contentController.text.isNotEmpty ? contentController.text : null,
                  videoUrl: videoController.text.isNotEmpty ? videoController.text : null,
                  chapterId: chapterId,
                );
                if (result != null) {
                  _showSnackBar('Lesson created!', Colors.green);
                  _loadData();
                } else {
                  _showSnackBar('Failed to create lesson', Colors.red);
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showAddQuestionDialog() {
    final questionController = TextEditingController();
    final option1Controller = TextEditingController();
    final option2Controller = TextEditingController();
    final option3Controller = TextEditingController();
    final option4Controller = TextEditingController();
    String correctAnswer = '';
    int marks = 1;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Question'),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: questionController, decoration: const InputDecoration(labelText: 'Question *'), maxLines: 3),
                const SizedBox(height: 16),
                TextField(controller: option1Controller, decoration: const InputDecoration(labelText: 'Option A *')),
                TextField(controller: option2Controller, decoration: const InputDecoration(labelText: 'Option B *')),
                TextField(controller: option3Controller, decoration: const InputDecoration(labelText: 'Option C *')),
                TextField(controller: option4Controller, decoration: const InputDecoration(labelText: 'Option D *')),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Correct Answer *'),
                  items: ['A', 'B', 'C', 'D'].map((e) => DropdownMenuItem(value: e, child: Text('Option $e'))).toList(),
                  onChanged: (v) => correctAnswer = v ?? '',
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (questionController.text.isNotEmpty && correctAnswer.isNotEmpty) {
                Navigator.pop(context);
                final options = [option1Controller.text, option2Controller.text, option3Controller.text, option4Controller.text];
                final correctIndex = ['A', 'B', 'C', 'D'].indexOf(correctAnswer);
                
                final result = await _sanityService.createQuestion(
                  questionText: questionController.text,
                  questionType: 'mcq',
                  options: options,
                  correctAnswer: options[correctIndex],
                  marks: marks,
                );
                if (result != null) {
                  _contentStore.addQuestion(result);
                  _showSnackBar('Question created!', Colors.green);
                } else {
                  _showSnackBar('Failed to create question', Colors.red);
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showCreateTestDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final durationController = TextEditingController(text: '30');
    final totalMarksController = TextEditingController(text: '100');
    final passingMarksController = TextEditingController(text: '40');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Test'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Test Title *')),
              TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description'), maxLines: 2),
              Row(
                children: [
                  Expanded(child: TextField(controller: durationController, decoration: const InputDecoration(labelText: 'Duration (min)'), keyboardType: TextInputType.number)),
                  const SizedBox(width: 16),
                  Expanded(child: TextField(controller: totalMarksController, decoration: const InputDecoration(labelText: 'Total Marks'), keyboardType: TextInputType.number)),
                ],
              ),
              TextField(controller: passingMarksController, decoration: const InputDecoration(labelText: 'Passing Marks'), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty) {
                Navigator.pop(context);
                final result = await _sanityService.createTest(
                  title: titleController.text,
                  description: descController.text.isNotEmpty ? descController.text : null,
                  duration: int.tryParse(durationController.text) ?? 30,
                  totalMarks: int.tryParse(totalMarksController.text) ?? 100,
                  passingMarks: int.tryParse(passingMarksController.text) ?? 40,
                );
                if (result != null) {
                  _showSnackBar('Test created!', Colors.green);
                  _loadData();
                } else {
                  _showSnackBar('Failed to create test', Colors.red);
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showMarkAttendanceDialog() {
    final date = DateTime.now().toString().split(' ')[0];
    final todayRecords = _attendanceRecords.where((r) {
      if (r.date == null) return false;
      final rDate = r.date!.toIso8601String().split('T').first;
      return rDate == date;
    }).toList();
    final Map<String, bool> presentMap = {
      for (final s in _students) s['_id'] as String: false,
    };
    for (final r in todayRecords) {
      if (presentMap.containsKey(r.studentId)) {
        presentMap[r.studentId] = r.status == 'present';
      }
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Mark Attendance - $date'),
          content: SizedBox(
            width: 500,
            height: 400,
            child: ListView.builder(
              itemCount: _students.length,
              itemBuilder: (context, index) {
                final student = _students[index];
                final studentId = student['_id'] as String? ?? '';
                final isPresent = presentMap[studentId] ?? false;
                return CheckboxListTile(
                  title: Text(student['name'] ?? 'Unknown'),
                  subtitle: Text(student['rollNumber'] ?? ''),
                  value: isPresent,
                  onChanged: (value) async {
                    final newPresent = value == true;
                    setDialogState(() => presentMap[studentId] = newPresent);
                    await _sanityService.markAttendance(
                      studentId: studentId,
                      date: date,
                      status: newPresent ? 'present' : 'absent',
                      teacherId: widget.teacherId,
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _loadData();
                _showSnackBar('Attendance marked!', Colors.green);
              },
              child: const Text('Save'),
            ),
          ],
        ),
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
          ElevatedButton(onPressed: () { Navigator.pop(context); clearAllSessionData(); context.go('/'); }, child: const Text('Logout')),
        ],
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }
}
