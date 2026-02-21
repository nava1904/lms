import 'question.dart';

/// Domain model for an assessment/test (Sanity assessment or test type).
class Assessment {
  final String id;
  final String title;
  final String? description;
  final int? durationMinutes;
  final int? totalMarks;
  final double? passingMarksPercent;
  final List<Question> questions;
  final String? worksheetId;
  final String? subjectId;

  const Assessment({
    required this.id,
    required this.title,
    this.description,
    this.durationMinutes,
    this.totalMarks,
    this.passingMarksPercent,
    this.questions = const [],
    this.worksheetId,
    this.subjectId,
  });

  factory Assessment.fromMap(Map<String, dynamic> map) {
    List<Question> questions = [];
    final qList = map['questions'] ?? map['worksheet']?['questions'];
    if (qList is List) {
      for (final q in qList) {
        if (q is Map) questions.add(Question.fromMap(Map<String, dynamic>.from(q)));
      }
    }
    String? worksheetId;
    if (map['worksheet'] is Map) worksheetId = (map['worksheet']['_id'] ?? map['worksheet']['_ref'])?.toString();
    String? subjectId;
    if (map['subject'] is Map) subjectId = (map['subject']['_id'] ?? map['subject']['_ref'])?.toString();

    return Assessment(
      id: map['_id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String?,
      durationMinutes: (map['durationMinutes'] ?? map['duration'] as num?)?.toInt(),
      totalMarks: (map['totalMarks'] as num?)?.toInt(),
      passingMarksPercent: (map['passingMarksPercent'] ?? map['passingMarks'] as num?)?.toDouble(),
      questions: questions,
      worksheetId: worksheetId,
      subjectId: subjectId,
    );
  }
}
