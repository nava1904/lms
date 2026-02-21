import 'package:mobx/mobx.dart';

import '../models/models.dart';
import '../services/lms_sanity_service.dart';

part 'analytics_store.g.dart';

class AnalyticsStore = _AnalyticsStore with _$AnalyticsStore;

abstract class _AnalyticsStore with Store {
  _AnalyticsStore() : _service = LmsSanityService();

  final LmsSanityService _service;

  @observable
  bool loading = false;

  @observable
  String? error;

  @observable
  ObservableList<TestAttempt> testAttempts = ObservableList<TestAttempt>();

  @computed
  double get averageScore {
    if (testAttempts.isEmpty) return 0;
    final sum = testAttempts.fold<double>(0, (s, t) => s + (t.percentage ?? 0));
    return sum / testAttempts.length;
  }

  @computed
  int get testsTaken => testAttempts.length;

  @computed
  double get passRate {
    if (testAttempts.isEmpty) return 0;
    final passed = testAttempts.where((t) => t.passed == true).length;
    return passed / testAttempts.length;
  }

  /// Last 5 attempt percentages (most recent first).
  @computed
  List<double> get recentScores {
    return testAttempts.take(5).map((t) => t.percentage ?? 0).toList();
  }

  /// Per-question breakdown: list of {questionIndex, isCorrect, marksObtained, questionType, subjectName, chapterName} for analytics UI.
  @computed
  List<Map<String, dynamic>> get perQuestionBreakdown {
    final list = <Map<String, dynamic>>[];
    for (final t in testAttempts) {
      final answers = t.answers;
      if (answers != null) {
        for (var i = 0; i < answers.length; i++) {
          final a = answers[i];
          final q = a['question'];
          final qMap = q is Map ? q as Map<String, dynamic> : null;
          list.add({
            'attemptId': t.id,
            'index': i,
            'isCorrect': a['isCorrect'] == true || a['correct'] == true,
            'marksObtained': (a['marksObtained'] as num?)?.toInt() ?? 0,
            'questionType': qMap?['questionType'] as String? ?? 'mcq',
            'subjectName': qMap?['subjectName'] as String? ?? 'Unknown',
            'chapterName': qMap?['chapterName'] as String? ?? 'Unknown',
          });
        }
      }
    }
    return list;
  }

  /// Accuracy by question type (mcq, short, long, etc.).
  @computed
  Map<String, double> get accuracyByQuestionType {
    final byType = <String, List<bool>>{};
    for (final item in perQuestionBreakdown) {
      final type = (item['questionType'] as String?) ?? 'mcq';
      byType.putIfAbsent(type, () => []).add(item['isCorrect'] as bool);
    }
    return byType.map((type, list) {
      if (list.isEmpty) return MapEntry(type, 0.0);
      return MapEntry(type, list.where((b) => b).length / list.length);
    });
  }

  /// Topics with accuracy < 50% (subject/chapter or questionType fallback).
  @computed
  List<Map<String, dynamic>> get weakTopics {
    final byTopic = <String, List<bool>>{};
    for (final item in perQuestionBreakdown) {
      final sub = (item['subjectName'] as String?) ?? (item['questionType'] as String?) ?? 'General';
      final ch = (item['chapterName'] as String?) ?? 'General';
      final key = '$sub / $ch';
      final correct = item['isCorrect'] as bool? ?? false;
      byTopic.putIfAbsent(key, () => []).add(correct);
    }
    final weak = <Map<String, dynamic>>[];
    byTopic.forEach((key, results) {
      if (results.isEmpty) return;
      final correctCount = results.where((b) => b).length;
      final pct = (correctCount / results.length) * 100;
      if (pct < 50) {
        weak.add({
          'topic': key,
          'accuracyPercent': pct,
          'attempts': results.length,
        });
      }
    });
    weak.sort((a, b) => (a['accuracyPercent'] as num).compareTo(b['accuracyPercent'] as num));
    return weak;
  }

  @action
  Future<void> loadTestAttemptsForStudent(String studentId) async {
    loading = true;
    error = null;
    try {
      testAttempts = ObservableList<TestAttempt>.of(
        await _service.getTestAttemptsForStudent(studentId),
      );
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
    }
  }

  @action
  Future<void> loadTestAttemptsForAnalytics() async {
    loading = true;
    error = null;
    try {
      testAttempts = ObservableList<TestAttempt>.of(
        await _service.getTestAttemptsForAnalytics(),
      );
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
    }
  }

  @action
  void clear() {
    testAttempts.clear();
    error = null;
  }
}
