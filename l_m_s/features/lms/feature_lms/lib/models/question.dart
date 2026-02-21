/// Domain model for a question (Sanity question type).
class Question {
  final String id;
  final String questionText;
  final String questionType;
  final List<String> options;
  final String? correctAnswer;
  final int marks;
  final String? imageUrl;
  final String? solutionImageUrl;

  const Question({
    required this.id,
    required this.questionText,
    this.questionType = 'mcq',
    this.options = const [],
    this.correctAnswer,
    this.marks = 1,
    this.imageUrl,
    this.solutionImageUrl,
  });

  factory Question.fromMap(Map<String, dynamic> map) {
    List<String> opts = [];
    final o = map['options'];
    if (o is List) opts = o.map((e) => e.toString()).toList();

    String? imgUrl;
    final img = map['imageInQue'] ?? map['image'];
    if (img is Map && img['asset'] != null && img['asset']['url'] != null) imgUrl = img['asset']['url'] as String?;
    String? solUrl;
    final sol = map['imageInSol'] ?? map['solutionImage'];
    if (sol is Map && sol['asset'] != null && sol['asset']['url'] != null) solUrl = sol['asset']['url'] as String?;

    return Question(
      id: map['_id'] as String? ?? '',
      questionText: map['queText'] as String? ?? map['questionText'] as String? ?? '',
      questionType: map['type'] as String? ?? map['questionType'] as String? ?? 'mcq',
      options: opts,
      correctAnswer: map['correctAnswer'] as String?,
      marks: (map['marks'] as num?)?.toInt() ?? 1,
      imageUrl: imgUrl,
      solutionImageUrl: solUrl,
    );
  }
}
