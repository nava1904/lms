// filepath: /Users/navadeepreddy/learning mangement system/l_m_s/features/lms/feature_lms/lib/models/content_model.dart

/// Content models for LMS
library;


/// Course model
class CourseModel {
  final String id;
  final String title;
  final String? slug;
  final String? description;
  final String? thumbnailUrl;
  final int? duration;
  final String level;
  final int order;
  final int subjectCount;

  const CourseModel({
    required this.id,
    required this.title,
    this.slug,
    this.description,
    this.thumbnailUrl,
    this.duration,
    this.level = 'beginner',
    this.order = 0,
    this.subjectCount = 0,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      slug: json['slug']?['current'],
      description: json['description'],
      thumbnailUrl: json['thumbnail']?['asset']?['url'],
      duration: json['duration'],
      level: json['level'] ?? 'beginner',
      order: json['order'] ?? 0,
      subjectCount: json['subjectCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    '_type': 'course',
    'title': title,
    'slug': {'_type': 'slug', 'current': slug ?? title.toLowerCase().replaceAll(' ', '-')},
    'description': description,
    'level': level,
    'duration': duration,
    'order': order,
  };
}

/// Subject model
class SubjectModel {
  final String id;
  final String title;
  final String? slug;
  final String? description;
  final String? courseId;
  final String? courseTitle;
  final int order;
  final int chapterCount;
  final List<ChapterModel> chapters;

  const SubjectModel({
    required this.id,
    required this.title,
    this.slug,
    this.description,
    this.courseId,
    this.courseTitle,
    this.order = 0,
    this.chapterCount = 0,
    this.chapters = const [],
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      slug: json['slug']?['current'],
      description: json['description'],
      courseId: json['course']?['_id'],
      courseTitle: json['course']?['title'],
      order: json['order'] ?? 0,
      chapterCount: json['chapterCount'] ?? 0,
      chapters: (json['chapters'] as List?)
          ?.map((c) => ChapterModel.fromJson(c))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    '_type': 'subject',
    'title': title,
    'slug': {'_type': 'slug', 'current': slug ?? title.toLowerCase().replaceAll(' ', '-')},
    'description': description,
    'order': order,
    if (courseId != null) 'course': {'_type': 'reference', '_ref': courseId},
  };
}

/// Chapter model
class ChapterModel {
  final String id;
  final String title;
  final String? slug;
  final String? description;
  final String? subjectId;
  final String? subjectTitle;
  final int order;
  final int conceptCount;
  final List<ConceptModel> concepts;

  const ChapterModel({
    required this.id,
    required this.title,
    this.slug,
    this.description,
    this.subjectId,
    this.subjectTitle,
    this.order = 0,
    this.conceptCount = 0,
    this.concepts = const [],
  });

  factory ChapterModel.fromJson(Map<String, dynamic> json) {
    return ChapterModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      slug: json['slug']?['current'],
      description: json['description'],
      subjectId: json['subject']?['_id'],
      subjectTitle: json['subject']?['title'],
      order: json['order'] ?? 0,
      conceptCount: json['conceptCount'] ?? 0,
      concepts: (json['concepts'] as List?)
          ?.map((c) => ConceptModel.fromJson(c))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    '_type': 'chapter',
    'title': title,
    'slug': {'_type': 'slug', 'current': slug ?? title.toLowerCase().replaceAll(' ', '-')},
    'description': description,
    'order': order,
    if (subjectId != null) 'subject': {'_type': 'reference', '_ref': subjectId},
  };
}

/// Concept/Lesson model
class ConceptModel {
  final String id;
  final String title;
  final String? slug;
  final String? content;
  final String? videoUrl;
  final String? chapterId;
  final String? chapterTitle;
  final int? duration;
  final int order;

  const ConceptModel({
    required this.id,
    required this.title,
    this.slug,
    this.content,
    this.videoUrl,
    this.chapterId,
    this.chapterTitle,
    this.duration,
    this.order = 0,
  });

  factory ConceptModel.fromJson(Map<String, dynamic> json) {
    // Extract content from block array if present
    String? contentText;
    if (json['content'] is List) {
      contentText = (json['content'] as List)
          .map((block) => block['children']?[0]?['text'] ?? '')
          .join('\n');
    }
    
    return ConceptModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      slug: json['slug']?['current'],
      content: contentText ?? json['content']?.toString(),
      videoUrl: json['videoUrl'],
      chapterId: json['chapter']?['_id'],
      chapterTitle: json['chapter']?['title'],
      duration: json['duration'],
      order: json['order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    '_type': 'concept',
    'title': title,
    'slug': {'_type': 'slug', 'current': slug ?? title.toLowerCase().replaceAll(' ', '-')},
    'videoUrl': videoUrl,
    'duration': duration,
    'order': order,
    if (content != null) 'content': [
      {'_type': 'block', 'children': [{'_type': 'span', 'text': content}]}
    ],
    if (chapterId != null) 'chapter': {'_type': 'reference', '_ref': chapterId},
  };

  bool get hasVideo => videoUrl != null && videoUrl!.isNotEmpty;
}
