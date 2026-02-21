/// Domain model for a test attempt (Sanity testAttempt type).
class TestAttempt {
  final String id;
  final String studentId;
  final String testId;
  final String? testTitle;
  final int? score;
  final double? percentage;
  final bool? passed;
  final DateTime? startedAt;
  final DateTime? submittedAt;
  final int? timeSpentMinutes;
  /// Per-question time in seconds (index or questionId -> seconds).
  final Map<String, int> timeSpentPerQuestion;
  final List<Map<String, dynamic>>? answers;

  const TestAttempt({
    required this.id,
    required this.studentId,
    required this.testId,
    this.testTitle,
    this.score,
    this.percentage,
    this.passed,
    this.startedAt,
    this.submittedAt,
    this.timeSpentMinutes,
    this.timeSpentPerQuestion = const {},
    this.answers,
  });

  factory TestAttempt.fromMap(Map<String, dynamic> map) {
    String studentId = '';
    if (map['student'] is Map) studentId = (map['student']['_ref'] ?? map['student']['_id'] ?? '').toString();
    if (studentId.isEmpty) studentId = map['studentId'] as String? ?? '';

    String testId = '';
    if (map['test'] is Map) testId = (map['test']['_ref'] ?? map['test']['_id'] ?? '').toString();
    if (map['assessment'] is Map) testId = (map['assessment']['_ref'] ?? map['assessment']['_id'] ?? '').toString();
    if (testId.isEmpty) testId = map['testId'] as String? ?? '';

    String? testTitle;
    if (map['test'] is Map && map['test']['title'] != null) testTitle = map['test']['title'] as String?;
    if (map['assessment'] is Map && map['assessment']['title'] != null) testTitle = map['assessment']['title'] as String?;
    if (testTitle == null && map['testTitle'] != null) testTitle = map['testTitle'] as String?;

    Map<String, int> perQuestion = {};
    final tpq = map['timeSpentPerQuestion'];
    if (tpq is Map) {
      tpq.forEach((k, v) {
        if (v is num) perQuestion[k.toString()] = v.toInt();
      });
    }
    if (tpq is List) {
      for (int i = 0; i < tpq.length; i++) {
        if (tpq[i] is num) perQuestion[i.toString()] = (tpq[i] as num).toInt();
      }
    }

    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      if (v is String) return DateTime.tryParse(v);
      return null;
    }

    return TestAttempt(
      id: map['_id'] as String? ?? '',
      studentId: studentId,
      testId: testId,
      testTitle: testTitle,
      score: (map['score'] as num?)?.toInt(),
      percentage: (map['percentage'] as num?)?.toDouble(),
      passed: map['passed'] as bool?,
      startedAt: parseDate(map['startedAt']),
      submittedAt: parseDate(map['submittedAt']),
      timeSpentMinutes: (map['timeSpent'] as num?)?.toInt() ?? (map['timeSpentMinutes'] as num?)?.toInt(),
      timeSpentPerQuestion: perQuestion,
      answers: map['answers'] is List ? List<Map<String, dynamic>>.from((map['answers'] as List).map((e) => e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{})) : null,
    );
  }
}
