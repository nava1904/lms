import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../models/test_attempt.dart';
import '../theme/lms_theme.dart';
import '../services/lms_sanity_service.dart';
import '../services/sanity_service.dart';

/// Teacher analytics: class performance trend, student ranking, weak topics, per-student marking.
class TeacherAnalyticsScreen extends StatefulWidget {
  const TeacherAnalyticsScreen({super.key});

  @override
  State<TeacherAnalyticsScreen> createState() => _TeacherAnalyticsScreenState();
}

class _TeacherAnalyticsScreenState extends State<TeacherAnalyticsScreen> {
  final LmsSanityService _lmsService = LmsSanityService();
  final SanityService _sanity = SanityService();
  List<TestAttempt> _attempts = [];
  List<Map<String, dynamic>> _students = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final attempts = await _lmsService.getTestAttemptsForAnalytics();
      final students = await _sanity.fetchStudents();
      if (mounted) setState(() {
        _attempts = attempts;
        _students = students;
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = e.toString(); });
    }
  }

  List<Map<String, dynamic>> get _leaderboard {
    final byStudent = <String, List<TestAttempt>>{};
    for (final a in _attempts) {
      final id = a.studentId;
      if (id.isEmpty) continue;
      byStudent.putIfAbsent(id, () => []).add(a);
    }
    return byStudent.entries.map((e) {
      final id = e.key;
      final attempts = e.value;
      final avg = attempts.fold<double>(0, (s, a) => s + (a.percentage ?? 0)) / attempts.length;
      final st = _students.where((s) => s['_id'] == id);
      final name = st.isEmpty ? 'Student' : (st.first['name'] as String? ?? 'Student');
      return {'studentId': id, 'name': name, 'attempts': attempts, 'attemptCount': attempts.length, 'avgScore': avg};
    }).toList()
      ..sort((a, b) => (b['avgScore'] as double).compareTo(a['avgScore'] as double));
  }

  List<Map<String, dynamic>> get _weakTopics {
    final byTopic = <String, List<bool>>{};
    for (final t in _attempts) {
      final answers = t.answers;
      if (answers != null) {
        for (final a in answers) {
          final q = a['question'];
          final qMap = q is Map ? q as Map<String, dynamic> : null;
          final sub = (qMap?['subjectName'] as String?) ?? 'Unknown';
          final ch = (qMap?['chapterName'] as String?) ?? 'Unknown';
          final key = '$sub / $ch';
          final correct = a['isCorrect'] == true || a['correct'] == true;
          byTopic.putIfAbsent(key, () => []).add(correct);
        }
      }
    }
    final weak = <Map<String, dynamic>>[];
    byTopic.forEach((key, results) {
      if (results.isEmpty) return;
      final pct = (results.where((b) => b).length / results.length) * 100;
      if (pct < 60) weak.add({'topic': key, 'accuracyPercent': pct, 'attempts': results.length});
    });
    weak.sort((a, b) => (a['accuracyPercent'] as num).compareTo(b['accuracyPercent'] as num));
    return weak;
  }

  double get _classAvgScore {
    if (_attempts.isEmpty) return 0;
    return _attempts.fold<double>(0, (s, a) => s + (a.percentage ?? 0)) / _attempts.length;
  }

  double get _passRate {
    if (_attempts.isEmpty) return 0;
    return _attempts.where((a) => a.passed == true).length / _attempts.length;
  }

  void _exportWithMarks() {
    final buffer = StringBuffer();
    buffer.writeln('Student,Test,Score,Percentage,Passed,Marks breakdown');
    for (final a in _attempts) {
      final st = _students.where((s) => s['_id'] == a.studentId);
      final name = st.isEmpty ? 'Unknown' : (st.first['name'] as String? ?? 'Unknown');
      final answers = a.answers;
      final marksStr = answers != null
          ? answers.map((x) => '${x['marksObtained'] ?? 0}').join(';')
          : '';
      buffer.writeln('"$name","${a.testTitle ?? a.testId}",${a.score ?? 0},${a.percentage?.toStringAsFixed(1) ?? 0},${a.passed ?? false},"$marksStr"');
    }
    final csv = buffer.toString();
    Clipboard.setData(ClipboardData(text: csv));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exported ${_attempts.length} attempts to clipboard (CSV with marks)'),
        backgroundColor: LMSTheme.successColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: LMSTheme.surfaceColor,
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/teacher-dashboard'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _attempts.isEmpty ? null : _exportWithMarks,
            tooltip: 'Export with marks',
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: LMSTheme.primaryColor))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, style: const TextStyle(color: LMSTheme.errorColor), textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      FilledButton(onPressed: _load, child: const Text('Retry')),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _statCard('Class avg score', '${_classAvgScore.toStringAsFixed(1)}%', LMSTheme.primaryColor),
                          const SizedBox(width: 16),
                          _statCard('Pass rate', '${(_passRate * 100).toStringAsFixed(0)}%', LMSTheme.successColor),
                          const SizedBox(width: 16),
                          _statCard('Total attempts', '${_attempts.length}', LMSTheme.warningColor),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Student ranking',
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, color: LMSTheme.onSurfaceColor),
                      ),
                      const SizedBox(height: 16),
                      _leaderboard.isEmpty
                          ? Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(LMSTheme.radiusMd),
                                side: const BorderSide(color: LMSTheme.borderColor),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(32),
                                child: Center(child: Text('No test attempts yet. Students will appear here after taking tests.')),
                              ),
                            )
                          : Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(LMSTheme.radiusMd),
                                side: const BorderSide(color: LMSTheme.borderColor),
                              ),
                              child: ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _leaderboard.length,
                                separatorBuilder: (_, __) => const Divider(height: 1),
                                itemBuilder: (context, i) {
                                  final e = _leaderboard[i];
                                  return ListTile(
                                    leading: CircleAvatar(
                                      child: Text('${i + 1}'),
                                    ),
                                    title: Text(e['name'] as String? ?? 'Student'),
                                    subtitle: Text('${e['attemptCount']} tests'),
                                    trailing: Text(
                                      '${(e['avgScore'] as double).toStringAsFixed(0)}%',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        color: LMSTheme.primaryColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    onTap: () {
                                      final st = _students.where((s) => s['_id'] == e['studentId']).toList();
                                      context.push('/teacher/students/${e['studentId']}', extra: st.isNotEmpty ? st.first : null);
                                    },
                                  );
                                },
                              ),
                            ),
                      if (_weakTopics.isNotEmpty) ...[
                        const SizedBox(height: 32),
                        Text(
                          'Class weak topics',
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, color: LMSTheme.onSurfaceColor),
                        ),
                        const SizedBox(height: 16),
                        Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(LMSTheme.radiusMd),
                            side: const BorderSide(color: LMSTheme.borderColor),
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _weakTopics.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, i) {
                              final w = _weakTopics[i];
                              return ListTile(
                                leading: Icon(Icons.warning_amber_rounded, color: LMSTheme.warningColor, size: 24),
                                title: Text(w['topic'] as String? ?? 'Unknown'),
                                trailing: Text(
                                  '${(w['accuracyPercent'] as num).toStringAsFixed(0)}%',
                                  style: theme.textTheme.titleMedium?.copyWith(color: LMSTheme.warningColor, fontWeight: FontWeight.w600),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),
                      Text(
                        'Performance trend (by test)',
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, color: LMSTheme.onSurfaceColor),
                      ),
                      const SizedBox(height: 16),
                      _attempts.isEmpty
                          ? const SizedBox(height: 120)
                          : SizedBox(
                              height: 200,
                              child: BarChart(
                                BarChartData(
                                  alignment: BarChartAlignment.spaceAround,
                                  maxY: 100,
                                  barTouchData: BarTouchData(enabled: false),
                                  titlesData: FlTitlesData(
                                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 32, getTitlesWidget: (v, _) => Text('${v.toInt()}%'))),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (v, _) {
                                          final i = v.toInt();
                                          if (i >= 0 && i < _attempts.length) {
                                            final t = _attempts[i].testTitle ?? _attempts[i].testId;
                                            return Padding(
                                              padding: const EdgeInsets.only(top: 8),
                                              child: Text(t.length > 12 ? '${t.substring(0, 12)}..' : t, style: const TextStyle(fontSize: 10)),
                                            );
                                          }
                                          return const Text('');
                                        },
                                      ),
                                    ),
                                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  ),
                                  gridData: const FlGridData(show: true, drawVerticalLine: false),
                                  borderData: FlBorderData(show: false),
                                  barGroups: List.generate(
                                    _attempts.length.clamp(0, 10),
                                    (i) => BarChartGroupData(
                                      x: i,
                                      barRods: [
                                        BarChartRodData(
                                          toY: _attempts[i].percentage?.toDouble() ?? 0,
                                          color: LMSTheme.primaryColor,
                                          width: 16,
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                        ),
                                      ],
                                      showingTooltipIndicators: [],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
    );
  }

  Widget _statCard(String title, String value, Color color) {
    return Expanded(
      child: Card(
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
              Text(title, style: TextStyle(color: LMSTheme.mutedForeground, fontSize: 13)),
              const SizedBox(height: 8),
              Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
