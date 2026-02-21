import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';
import '../core/current_student_holder.dart';
import '../models/test_attempt.dart';
import '../stores/analytics_store.dart';
import '../theme/lms_theme.dart';

/// Student analytics: donut (accuracy), time-per-question bar chart,
/// score trend, summary cards. Uses AnalyticsStore only (no direct Sanity).
class StudentAnalyticsScreen extends StatefulWidget {
  /// When used as student analytics, this is the student id (route may pass as subjectId).
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
  final AnalyticsStore _store = AnalyticsStore();
  TestAttempt? _selectedAttempt;
  bool _weakAreasExpanded = false;
  bool _topicAccuracyExpanded = false;
  static const int _initialListCount = 5;

  @override
  void initState() {
    super.initState();
    _store.loadTestAttemptsForStudent(widget.subjectId);
  }

  /// Compute total correct and incorrect from test attempts (for donut).
  void _accuracyFromAttempts(List<TestAttempt> attempts, void Function(int correct, int incorrect) out) {
    int correct = 0, incorrect = 0;
    for (final t in attempts) {
      final answers = t.answers;
      if (answers != null && answers.isNotEmpty) {
        for (final a in answers) {
          if (a['isCorrect'] == true || a['correct'] == true) {
            correct++;
          } else {
            incorrect++;
          }
        }
      } else {
        final s = t.score ?? 0;
        final total = t.timeSpentPerQuestion.length;
        if (total > 0) {
          correct += s;
          incorrect += total - s;
        } else if (t.percentage != null && t.percentage! > 0) {
          final totalMarks = ((s / t.percentage!) * 100).round();
          correct += s;
          incorrect += (totalMarks - s).clamp(0, 999);
        }
      }
    }
    out(correct, incorrect);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LMSTheme.surfaceColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: LMSTheme.surfaceColor,
        title: Text(
          'Analytics',
          style: TextStyle(color: LMSTheme.onSurfaceColor, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              final studentId = widget.subjectId.isNotEmpty
                  ? widget.subjectId
                  : CurrentStudentHolder.studentId ?? '';
              if (studentId.isNotEmpty) {
                context.go('/student-dashboard/$studentId', extra: {
                  'studentName': CurrentStudentHolder.studentName ?? 'Student',
                  'rollNumber': CurrentStudentHolder.rollNumber ?? '',
                });
              } else {
                context.go('/');
              }
            }
          },
        ),
      ),
      body: Observer(
        builder: (_) {
          if (_store.loading) {
            return const Center(child: CircularProgressIndicator(color: LMSTheme.primaryColor));
          }
          if (_store.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_store.error!, style: TextStyle(color: LMSTheme.errorColor)),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => _store.loadTestAttemptsForStudent(widget.subjectId),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => _store.loadTestAttemptsForStudent(widget.subjectId),
            color: LMSTheme.primaryColor,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCards(),
                const SizedBox(height: 24),
                _buildTestsAttemptedCard(),
                const SizedBox(height: 24),
                _buildPerQuestionBreakdownCard(),
                const SizedBox(height: 24),
                _buildDonutCard(),
                const SizedBox(height: 24),
                _buildScoreTrendCard(),
                const SizedBox(height: 24),
                _buildTimePerQuestionCard(),
                const SizedBox(height: 24),
                _buildTopicAccuracyCard(),
                const SizedBox(height: 24),
                _buildWeakAreasCard(),
              ],
            ),
          ),
          );
        },
      ),
    );
  }

  Widget _buildPerQuestionBreakdownCard() {
    return Observer(
      builder: (_) {
        final attempts = _store.testAttempts;
        if (attempts.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'No per-question data yet. Take tests to see question-by-question results.',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Per-test breakdown', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                ...attempts.map((attempt) {
                  final answers = attempt.answers ?? [];
                  if (answers.isEmpty) return const SizedBox.shrink();
                  final title = attempt.testTitle ?? attempt.testId;
                  final dateTime = attempt.submittedAt != null
                      ? '${attempt.submittedAt!.day}/${attempt.submittedAt!.month}/${attempt.submittedAt!.year} ${attempt.submittedAt!.hour.toString().padLeft(2, '0')}:${attempt.submittedAt!.minute.toString().padLeft(2, '0')}'
                      : '';
                  final timeSpent = attempt.timeSpentPerQuestion.isNotEmpty
                      ? ' • ${_formatTimeSpent(attempt.timeSpentPerQuestion)}'
                      : '';
                  return ExpansionTile(
                    initiallyExpanded: attempts.indexOf(attempt) == 0,
                    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Text('$dateTime$timeSpent', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
                    children: answers.asMap().entries.map((e) {
                      final a = e.value;
                      final correct = a['isCorrect'] == true || a['correct'] == true;
                      final marks = (a['marksObtained'] as num?)?.toInt() ?? 0;
                      return Padding(
                        padding: const EdgeInsets.only(left: 16, bottom: 8),
                        child: Row(
                          children: [
                            Icon(correct ? Icons.check_circle : Icons.cancel, color: correct ? LMSTheme.successColor : LMSTheme.errorColor, size: 18),
                            const SizedBox(width: 8),
                            Text('Q${e.key + 1}', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                            const SizedBox(width: 8),
                            Text('$marks marks', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopicAccuracyCard() {
    return Observer(
      builder: (_) {
        final byType = _store.accuracyByQuestionType;
        if (byType.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'No topic-wise accuracy data yet.',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }
        final entries = byType.entries.toList();
        final showCount = _topicAccuracyExpanded ? entries.length : _initialListCount;
        final remaining = entries.length - _initialListCount;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Accuracy by question type', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                ...entries.take(showCount).map((e) {
                  final pct = (e.value * 100).toStringAsFixed(0);
                  final label = _questionTypeLabel(e.key);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        SizedBox(width: 80, child: Text(label, style: const TextStyle(fontSize: 13))),
                        Expanded(
                          child: LinearProgressIndicator(
                            value: e.value,
                            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation<Color>(LMSTheme.primaryColor),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('$pct%', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      ],
                    ),
                  );
                }),
                if (remaining > 0)
                  InkWell(
                    onTap: () => setState(() => _topicAccuracyExpanded = !_topicAccuracyExpanded),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 4),
                      child: SizedBox(
                        width: double.infinity,
                        child: Text(
                          _topicAccuracyExpanded ? 'Show less' : '$remaining more',
                          style: TextStyle(color: LMSTheme.primaryColor, fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatTimeSpent(Map<String, int> tpq) {
    final total = tpq.values.fold<int>(0, (s, v) => s + v);
    final m = total ~/ 60;
    final s = total % 60;
    return '${m}m ${s}s';
  }

  String _questionTypeLabel(String type) {
    switch (type) {
      case 'mcq': return 'MCQ';
      case 'short': return 'Short';
      case 'long': return 'Long';
      case 'truefalse': return 'T/F';
      case 'fillblank': return 'Fill';
      default: return type;
    }
  }

  Widget _buildWeakAreasCard() {
    return Observer(
      builder: (_) {
        final weak = _store.weakTopics;
        if (weak.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'No weak areas identified. Keep practicing!',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }
        final showCount = _weakAreasExpanded ? weak.length : _initialListCount;
        final remaining = weak.length - _initialListCount;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Areas to improve', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                ...weak.take(showCount).map((item) {
                  final topic = item['topic'] as String? ?? 'Unknown';
                  final pct = (item['accuracyPercent'] as num?)?.toStringAsFixed(0) ?? '0';
                  final attempts = item['attempts'] as int? ?? 0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: LMSTheme.warningColor, size: 20),
                        const SizedBox(width: 8),
                        Expanded(child: Text(topic, style: const TextStyle(fontSize: 13))),
                        Text('$pct% ($attempts)', style: TextStyle(color: LMSTheme.warningColor, fontSize: 12, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  );
                }),
                if (remaining > 0)
                  InkWell(
                    onTap: () => setState(() => _weakAreasExpanded = !_weakAreasExpanded),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 4),
                      child: SizedBox(
                        width: double.infinity,
                        child: Text(
                          _weakAreasExpanded ? 'Show less' : '$remaining more',
                          style: TextStyle(color: LMSTheme.primaryColor, fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTestsAttemptedCard() {
    return Observer(
      builder: (_) {
        final attempts = _store.testAttempts;
        if (attempts.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'No tests attempted yet. Take a test to see your results here.',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }
        final byTest = <String, TestAttempt>{};
        for (final a in attempts) {
          final key = a.testId;
          if (!byTest.containsKey(key) || (a.submittedAt ?? a.startedAt ?? DateTime(0)).isAfter(byTest[key]!.submittedAt ?? DateTime(0))) {
            byTest[key] = a;
          }
        }
        final list = byTest.values.toList()
          ..sort((a, b) => (b.submittedAt ?? b.startedAt ?? DateTime(0)).compareTo(a.submittedAt ?? a.startedAt ?? DateTime(0)));
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tests attempted', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                ...list.map((a) {
                  final pct = a.percentage?.toStringAsFixed(0) ?? '-';
                  final passed = a.passed == true;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Icon(passed ? Icons.check_circle : Icons.cancel, color: passed ? LMSTheme.successColor : LMSTheme.errorColor, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(a.testTitle ?? a.testId, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: LMSTheme.successColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: LMSTheme.successColor, width: 1),
                          ),
                          child: Text('Attempted • $pct%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: LMSTheme.successColor)),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryCards() {
    return Observer(
      builder: (_) {
        return Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Tests taken',
                value: '${_store.testsTaken}',
                color: LMSTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'Average score',
                value: _store.testAttempts.isEmpty ? '-' : '${_store.averageScore.toStringAsFixed(1)}%',
                color: LMSTheme.successColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'Pass rate',
                value: _store.testAttempts.isEmpty ? '-' : '${(_store.passRate * 100).toStringAsFixed(0)}%',
                color: LMSTheme.warningColor,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDonutCard() {
    return Observer(
      builder: (_) {
        int correct = 0, incorrect = 0;
        _accuracyFromAttempts(_store.testAttempts, (c, i) { correct = c; incorrect = i; });
        final total = correct + incorrect;
        if (total == 0) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'No accuracy data yet. Take tests to see correct vs incorrect.',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }
        final sections = [
          PieChartSectionData(
            value: correct.toDouble(),
            color: LMSTheme.successColor,
            title: '$correct',
            radius: 40,
            titleStyle: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.w600, fontSize: 14),
          ),
          PieChartSectionData(
            value: incorrect.toDouble(),
            color: LMSTheme.errorColor,
            title: '$incorrect',
            radius: 40,
            titleStyle: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Accuracy', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 160,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 160,
                        height: 160,
                        child: PieChart(
                          PieChartData(
                            sections: sections,
                            sectionsSpace: 2,
                            centerSpaceRadius: 36,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(width: 12, height: 12, color: LMSTheme.successColor),
                              const SizedBox(width: 8),
                              Text('Correct: $correct'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(width: 12, height: 12, color: LMSTheme.errorColor),
                              const SizedBox(width: 8),
                              Text('Incorrect: $incorrect'),
                            ],
                          ),
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
    );
  }

  Widget _buildTimePerQuestionCard() {
    return Observer(
      builder: (_) {
        final attempts = _store.testAttempts;
        final attempt = _selectedAttempt ?? (attempts.isNotEmpty ? attempts.first : null);
        if (attempt == null || attempt.timeSpentPerQuestion.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'No time-per-question data yet. Submit a test with timer to see it here.',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }
        final entries = attempt.timeSpentPerQuestion.entries.toList()
          ..sort((a, b) {
            final ai = int.tryParse(a.key);
            final bi = int.tryParse(b.key);
            if (ai != null && bi != null) return ai.compareTo(bi);
            if (ai != null) return 1;
            if (bi != null) return -1;
            return a.key.compareTo(b.key);
          });
        final barGroups = entries.asMap().entries.map((e) {
          final i = e.key;
          final kv = e.value;
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: (kv.value).toDouble(),
                color: LMSTheme.primaryColor,
                width: 14,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
            showingTooltipIndicators: [0],
          );
        }).toList();
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Time per question', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                    if (attempts.length > 1) ...[
                      const SizedBox(width: 12),
                      DropdownButton<TestAttempt>(
                        value: attempt,
                        isDense: true,
                        items: attempts.map((a) => DropdownMenuItem(value: a, child: Text(a.testTitle ?? a.testId))).toList(),
                        onChanged: (v) => setState(() => _selectedAttempt = v),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 220,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: (entries.map((e) => e.value).fold<int>(0, (a, b) => a > b ? a : b) + 10).toDouble(),
                      barTouchData: BarTouchData(enabled: true),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 32, getTitlesWidget: (v, _) => Text('${v.toInt()}s'))),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            getTitlesWidget: (v, _) => Transform.rotate(
                              angle: -0.5,
                              child: Text('Q${v.toInt() + 1}', style: const TextStyle(fontSize: 11)),
                            ),
                          ),
                        ),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(show: true, drawVerticalLine: false),
                      borderData: FlBorderData(show: false),
                      barGroups: barGroups,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildScoreTrendCard() {
    return Observer(
      builder: (_) {
        final list = _store.testAttempts;
        if (list.isEmpty) return const SizedBox.shrink();
        final sorted = List<TestAttempt>.from(list)..sort((a, b) => (a.submittedAt ?? a.startedAt ?? DateTime(0)).compareTo(b.submittedAt ?? b.startedAt ?? DateTime(0)));
        final spots = sorted.asMap().entries.map((e) => FlSpot(e.key.toDouble(), (e.value.percentage ?? 0).toDouble())).toList();
        if (spots.isEmpty) return const SizedBox.shrink();
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Score trend', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 180,
                  child: LineChart(
                    LineChartData(
                      lineTouchData: LineTouchData(enabled: true),
                      gridData: FlGridData(show: true, drawVerticalLine: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 36, getTitlesWidget: (v, _) => Text('${v.toInt()}%'))),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            getTitlesWidget: (v, _) => Transform.rotate(
                              angle: -0.5,
                              child: Text('Test ${v.toInt() + 1}', style: const TextStyle(fontSize: 11)),
                            ),
                          ),
                        ),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      minX: 0,
                      maxX: (spots.length - 1).toDouble(),
                      minY: 0,
                      maxY: 100,
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: LMSTheme.primaryColor,
                          barWidth: 2,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(show: true, color: LMSTheme.primaryColor.withValues(alpha: 0.15)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 4),
            Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}
