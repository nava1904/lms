// filepath: /Users/navadeepreddy/learning mangement system/l_m_s/features/lms/feature_lms/lib/models/test_model.dart

/// Test and assessment models for LMS
library;


/// Question model
class QuestionModel {
  final String id;
  final String questionText;
  final String questionType;
  final List<String> options;
  final String correctAnswer;
  final int marks;
  final String? explanation;
  final String difficulty;
  final String? subjectId;
  final String? chapterId;

  const QuestionModel({
    required this.id,
    required this.questionText,
    this.questionType = 'mcq',
    this.options = const [],
    required this.correctAnswer,
    this.marks = 1,
    this.explanation,
    this.difficulty = 'medium',
    this.subjectId,
    this.chapterId,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['_id'] ?? '',
      questionText: json['questionText'] ?? '',
      questionType: json['questionType'] ?? 'mcq',
      options: (json['options'] as List?)?.cast<String>() ?? [],
      correctAnswer: json['correctAnswer'] ?? '',
      marks: json['marks'] ?? 1,
      explanation: json['explanation'],
      difficulty: json['difficulty'] ?? 'medium',
      subjectId: json['subject']?['_id'],
      chapterId: json['chapter']?['_id'],
    );
  }

  Map<String, dynamic> toJson() => {
    '_type': 'question',
    'questionText': questionText,
    'questionType': questionType,
    'options': options,
    'correctAnswer': correctAnswer,
    'marks': marks,
    'explanation': explanation,
    'difficulty': difficulty,
    if (subjectId != null) 'subject': {'_type': 'reference', '_ref': subjectId},
    if (chapterId != null) 'chapter': {'_type': 'reference', '_ref': chapterId},
  };

  bool isCorrect(String answer) => answer == correctAnswer;
}

/// Test model
class TestModel {
  final String id;
  final String title;
  final String? description;
  final int duration; // in minutes
  final int totalMarks;
  final int passingMarks;
  final bool isPublished;
  final DateTime? scheduledFor;
  final String? subjectId;
  final String? subjectTitle;
  final int questionCount;
  final List<QuestionModel> questions;

  const TestModel({
    required this.id,
    required this.title,
    this.description,
    this.duration = 30,
    this.totalMarks = 100,
    this.passingMarks = 40,
    this.isPublished = false,
    this.scheduledFor,
    this.subjectId,
    this.subjectTitle,
    this.questionCount = 0,
    this.questions = const [],
  });

  factory TestModel.fromJson(Map<String, dynamic> json) {
    return TestModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      duration: json['duration'] ?? 30,
      totalMarks: json['totalMarks'] ?? 100,
      passingMarks: json['passingMarks'] ?? 40,
      isPublished: json['isPublished'] ?? false,
      scheduledFor: json['scheduledFor'] != null ? DateTime.tryParse(json['scheduledFor']) : null,
      subjectId: json['subject']?['_id'],
      subjectTitle: json['subject']?['title'],
      questionCount: json['questionCount'] ?? (json['questions'] as List?)?.length ?? 0,
      questions: (json['questions'] as List?)
          ?.map((q) => QuestionModel.fromJson(q))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    '_type': 'test',
    'title': title,
    'description': description,
    'duration': duration,
    'totalMarks': totalMarks,
    'passingMarks': passingMarks,
    'isPublished': isPublished,
    if (scheduledFor != null) 'scheduledFor': scheduledFor!.toIso8601String(),
    if (subjectId != null) 'subject': {'_type': 'reference', '_ref': subjectId},
  };

  bool get isPassing => passingMarks > 0;
  double get passingPercentage => totalMarks > 0 ? (passingMarks / totalMarks * 100) : 0;
}

/// Test attempt model
class TestAttemptModel {
  final String id;
  final String testId;
  final String? testTitle;
  final String studentId;
  final String? studentName;
  final int score;
  final double percentage;
  final bool passed;
  final int timeSpent; // in minutes
  final DateTime? startedAt;
  final DateTime? submittedAt;
  final List<AnswerModel> answers;

  const TestAttemptModel({
    required this.id,
    required this.testId,
    this.testTitle,
    required this.studentId,
    this.studentName,
    this.score = 0,
    this.percentage = 0,
    this.passed = false,
    this.timeSpent = 0,
    this.startedAt,
    this.submittedAt,
    this.answers = const [],
  });

  factory TestAttemptModel.fromJson(Map<String, dynamic> json) {
    return TestAttemptModel(
      id: json['_id'] ?? '',
      testId: json['test']?['_id'] ?? '',
      testTitle: json['test']?['title'],
      studentId: json['student']?['_id'] ?? '',
      studentName: json['student']?['name'],
      score: json['score'] ?? 0,
      percentage: (json['percentage'] ?? 0).toDouble(),
      passed: json['passed'] ?? false,
      timeSpent: json['timeSpent'] ?? 0,
      startedAt: json['startedAt'] != null ? DateTime.tryParse(json['startedAt']) : null,
      submittedAt: json['submittedAt'] != null ? DateTime.tryParse(json['submittedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    '_type': 'testAttempt',
    'test': {'_type': 'reference', '_ref': testId},
    'student': {'_type': 'reference', '_ref': studentId},
    'score': score,
    'percentage': percentage,
    'passed': passed,
    'timeSpent': timeSpent,
    'submittedAt': submittedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
  };
}

/// Individual answer model
class AnswerModel {
  final String questionId;
  final String answer;
  final bool isCorrect;
  final int marksObtained;

  const AnswerModel({
    required this.questionId,
    required this.answer,
    this.isCorrect = false,
    this.marksObtained = 0,
  });

  Map<String, dynamic> toJson() => {
    'question': {'_type': 'reference', '_ref': questionId},
    'answer': answer,
    'isCorrect': isCorrect,
    'marksObtained': marksObtained,
  };
}
