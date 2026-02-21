import 'package:mobx/mobx.dart';

import '../models/models.dart';
import '../services/lms_sanity_service.dart';

part 'test_store.g.dart';

class TestStore = _TestStore with _$TestStore;

abstract class _TestStore with Store {
  _TestStore() : _service = LmsSanityService();

  final LmsSanityService _service;

  @observable
  bool loading = false;

  @observable
  String? error;

  @observable
  Assessment? currentAssessment;

  @observable
  int currentIndex = 0;

  @observable
  ObservableMap<int, String> answers = ObservableMap<int, String>();

  @observable
  ObservableSet<int> answered = ObservableSet<int>();

  @observable
  ObservableSet<int> marked = ObservableSet<int>();

  @observable
  ObservableSet<int> skipped = ObservableSet<int>();

  @observable
  ObservableMap<int, int> timeSpentPerQuestion = ObservableMap<int, int>();

  @observable
  DateTime? startedAt;

  @computed
  int get totalQuestions => currentAssessment?.questions.length ?? 0;

  @action
  Future<void> loadAssessment(String id) async {
    loading = true;
    error = null;
    try {
      currentAssessment = await _service.getTestOrAssessment(id);
      currentIndex = 0;
      answers.clear();
      answered.clear();
      marked.clear();
      skipped.clear();
      timeSpentPerQuestion.clear();
      startedAt = DateTime.now();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
    }
  }

  @action
  void setAnswer(int index, String value) {
    answers[index] = value;
    answered.add(index);
  }

  @action
  void toggleMarked(int index) {
    if (marked.contains(index)) {
      marked.remove(index);
    } else {
      marked.add(index);
    }
  }

  @action
  void setSkipped(int index) { skipped.add(index); }

  @action
  void setCurrentIndex(int index) { currentIndex = index; }

  @action
  void recordTime(int index, int seconds) {
    timeSpentPerQuestion[index] = seconds;
  }

  @action
  Future<bool> submitTest(String studentId) async {
    if (currentAssessment == null || startedAt == null) return false;
    final submittedAt = DateTime.now();
    final timeSpentMinutes = submittedAt.difference(startedAt!).inMinutes;
    int score = 0;
    int total = 0;
    final qs = currentAssessment!.questions;
    for (int i = 0; i < qs.length; i++) {
      total += qs[i].marks;
      final ans = answers[i];
      if (ans != null && ans == qs[i].correctAnswer) score += qs[i].marks;
    }
    final percentage = total > 0 ? (score / total) * 100.0 : 0.0;
    final passed = currentAssessment!.passingMarksPercent == null ||
        percentage >= currentAssessment!.passingMarksPercent!;
    final tpq = timeSpentPerQuestion.map((k, v) => MapEntry(k.toString(), v));
    final answersPayload = <Map<String, dynamic>>[];
    for (var i = 0; i < qs.length; i++) {
      final q = qs[i];
      final ans = answers[i];
      final isCorrect = ans != null && ans == q.correctAnswer;
      final marksObtained = isCorrect ? q.marks : 0;
      answersPayload.add({
        'question': {'_type': 'reference', '_ref': q.id},
        'answer': ans ?? '',
        'isCorrect': isCorrect,
        'marksObtained': marksObtained,
      });
    }
    final result = await _service.createTestAttempt(
      testId: currentAssessment!.id,
      studentId: studentId,
      score: score,
      percentage: percentage,
      passed: passed,
      startedAt: startedAt!,
      submittedAt: submittedAt,
      timeSpentMinutes: timeSpentMinutes,
      timeSpentPerQuestion: tpq.isNotEmpty ? tpq : null,
      answers: answersPayload,
    );
    return result != null;
  }

  @action
  void reset() {
    currentAssessment = null;
    currentIndex = 0;
    answers.clear();
    answered.clear();
    marked.clear();
    skipped.clear();
    timeSpentPerQuestion.clear();
    startedAt = null;
  }
}
