/// Domain model for a course (Sanity course type).
class Course {
  final String id;
  final String title;
  final String? description;
  final String? thumbnailUrl;
  final String? level;
  final double? durationHours;
  final String? instructor;
  final List<String>? subjectIds;
  final List<String>? subjectTitles;

  const Course({
    required this.id,
    required this.title,
    this.description,
    this.thumbnailUrl,
    this.level,
    this.durationHours,
    this.instructor,
    this.subjectIds,
    this.subjectTitles,
  });

  factory Course.fromMap(Map<String, dynamic> map) {
    final thumb = map['thumbnail'];
    String? thumbUrl;
    if (thumb is Map && thumb['asset'] != null) {
      final asset = thumb['asset'];
      if (asset is Map && asset['url'] != null) thumbUrl = asset['url'] as String?;
    }
    if (thumbUrl == null && map['thumbnailUrl'] != null) thumbUrl = map['thumbnailUrl'] as String?;

    List<String>? ids;
    List<String>? titles;
    final subs = map['subjects'];
    if (subs is List) {
      ids = subs.map((e) => e is Map ? (e['_id'] ?? e['_ref'] ?? '').toString() : e.toString()).where((s) => s.isNotEmpty).toList();
      titles = subs.map((e) => e is Map ? (e['title'] ?? '').toString() : '').where((s) => s.isNotEmpty).toList();
    }
    if (ids == null && map['enrolledCourseIds'] != null && map['enrolledCourseIds'] is List) {
      ids = (map['enrolledCourseIds'] as List).cast<String>();
    }

    return Course(
      id: map['_id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String?,
      thumbnailUrl: thumbUrl,
      level: map['level'] as String?,
      durationHours: (map['duration'] as num?)?.toDouble(),
      instructor: map['instructor'] as String?,
      subjectIds: ids,
      subjectTitles: titles,
    );
  }
}
