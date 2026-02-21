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
                _buildDonutCard(),
                const SizedBox(height: 24),
                _buildTimePerQuestionCard(),
                const SizedBox(height: 24),
                _buildScoreTrendCard(),
                const SizedBox(height: 24),
                _buildPerQuestionBreakdownCard(),
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
        final breakdown = _store.perQuestionBreakdown;
        if (breakdown.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'No per-question data yet. Take tests to see question-by-question results.',
                  style: TextStyle(color: Colors.grey.shade600),
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
                Text('Per-question breakdown', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                ...breakdown.take(20).map((item) {
                  final correct = item['isCorrect'] as bool? ?? false;
                  final marks = item['marksObtained'] as int? ?? 0;
                  final idx = (item['index'] as int?) ?? 0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(correct ? Icons.check_circle : Icons.cancel, color: correct ? LMSTheme.successColor : LMSTheme.errorColor, size: 20),
                        const SizedBox(width: 8),
                        Text('Q${idx + 1}', style: const TextStyle(fontWeight: FontWeight.w500)),
                        const SizedBox(width: 8),
                        Text('${marks} marks', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                      ],
                    ),
                  );
                }),
                if (breakdown.length > 20) Text('... and ${breakdown.length - 20} more', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
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
                  style: TextStyle(color: Colors.grey.shade600),
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
                Text('Accuracy by question type', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                ...byType.entries.map((e) {
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
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(LMSTheme.primaryColor),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('$pct%', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
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
                  style: TextStyle(color: Colors.grey.shade600),
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
                Text('Areas to improve', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                ...weak.map((item) {
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
                  style: TextStyle(color: Colors.grey.shade600),
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
            titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
          ),
          PieChartSectionData(
            value: incorrect.toDouble(),
            color: LMSTheme.errorColor,
            title: '$incorrect',
            radius: 40,
            titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
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
                  style: TextStyle(color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }
        final entries = attempt.timeSpentPerQuestion.entries.toList()
          ..sort((a, b) => int.tryParse(a.key)?.compareTo(int.tryParse(b.key) ?? 0) ?? 0);
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
                        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) => Text('Q${v.toInt() + 1}'))),
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
                        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) => Text('Test ${v.toInt() + 1}'))),
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
            Text(title, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600)),
            const SizedBox(height: 4),
            Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}
