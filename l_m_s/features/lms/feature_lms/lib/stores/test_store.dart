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

  /// Check if answer matches correctAnswer. Compares option VALUE (text), not only index.
  /// Handles: option text, option index, case insensitivity, true/false variants.
  bool _isAnswerCorrect(String? ans, Question q) {
    if (ans == null || ans.isEmpty) return false;
    final correct = q.correctAnswer;
    if (correct == null || correct.isEmpty) return false;

    final a = ans.trim();
    final c = correct.trim();
    if (a.isEmpty || c.isEmpty) return false;

    // Direct string match
    if (a == c) return true;
    if (a.toLowerCase() == c.toLowerCase()) return true;

    final selectedIdx = int.tryParse(a);
    final correctIdx = int.tryParse(c);

    // Resolve selected option value (text) when answer is an index
    String? selectedOptionText;
    if (selectedIdx != null && q.options.isNotEmpty && selectedIdx >= 0 && selectedIdx < q.options.length) {
      selectedOptionText = (q.options[selectedIdx] ?? '').toString().trim();
    }

    // Compare by option VALUE: selected option text vs correctAnswer
    if (selectedOptionText != null) {
      if (selectedOptionText == c || selectedOptionText.toLowerCase() == c.toLowerCase()) return true;
      // correctAnswer might be index: resolve correct option text and compare
      if (correctIdx != null && correctIdx >= 0 && correctIdx < q.options.length) {
        final correctOptionText = (q.options[correctIdx] ?? '').toString().trim();
        if (selectedOptionText == correctOptionText ||
            selectedOptionText.toLowerCase() == correctOptionText.toLowerCase()) return true;
      }
    }

    // Index-to-index match (when both stored as indices)
    if (correctIdx != null && selectedIdx != null && selectedIdx == correctIdx) return true;

    // True/False: handle 'true', 'false', '0', '1', 't', 'f' and option text
    if ((q.questionType == 'truefalse' || q.questionType == 'true false') && q.options.length >= 2 && selectedIdx != null) {
      final correctLower = c.toLowerCase();
      if (selectedIdx == 0 && (correctLower == 'true' || correctLower == '0' || correctLower == 't')) return true;
      if (selectedIdx == 1 && (correctLower == 'false' || correctLower == '1' || correctLower == 'f')) return true;
      final opt0 = (q.options[0] ?? '').toString().trim().toLowerCase();
      final opt1 = (q.options[1] ?? '').toString().trim().toLowerCase();
      if (selectedIdx == 0 && opt0 == correctLower) return true;
      if (selectedIdx == 1 && opt1 == correctLower) return true;
    }

    return false;
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
      if (_isAnswerCorrect(ans, qs[i])) score += qs[i].marks;
    }
    final percentage = total > 0 ? (score / total) * 100.0 : 0.0;
    final passed = currentAssessment!.passingMarksPercent == null ||
        percentage >= currentAssessment!.passingMarksPercent!;
    final tpq = timeSpentPerQuestion.map((k, v) => MapEntry(k.toString(), v));
    final answersPayload = <Map<String, dynamic>>[];
    for (var i = 0; i < qs.length; i++) {
      final q = qs[i];
      final ans = answers[i];
      final isCorrect = _isAnswerCorrect(ans, q);
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
