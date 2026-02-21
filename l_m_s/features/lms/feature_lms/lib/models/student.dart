/// Domain model for a student (Sanity student type).
class Student {
  final String id;
  final String name;
  final String? email;
  final String? rollNumber;
  final String? profileImageUrl;
  final List<String> enrolledCourseIds;
  final String? batchId;
  final bool isActive;

  const Student({
    required this.id,
    required this.name,
    this.email,
    this.rollNumber,
    this.profileImageUrl,
    this.enrolledCourseIds = const [],
    this.batchId,
    this.isActive = true,
  });

  factory Student.fromMap(Map<String, dynamic> map) {
    String? profileUrl;
    final img = map['profileImage'];
    if (img is Map && img['asset'] != null) {
      final asset = img['asset'];
      if (asset is Map && asset['url'] != null) profileUrl = asset['url'] as String?;
    }
    if (profileUrl == null && map['profileImageUrl'] != null) profileUrl = map['profileImageUrl'] as String?;

    List<String> ids = [];
    final enrolled = map['enrolledCourses'];
    if (enrolled is List) {
      for (final e in enrolled) {
        if (e is Map) {
          final ref = e['_id'] ?? e['_ref'];
          if (ref != null) ids.add(ref.toString());
        }
      }
    }
    if (ids.isEmpty && map['enrolledCourseIds'] is List) ids = List<String>.from(map['enrolledCourseIds'] as List);

    return Student(
      id: map['_id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      email: map['email'] as String?,
      rollNumber: map['rollNumber'] as String?,
      profileImageUrl: profileUrl,
      enrolledCourseIds: ids,
      batchId: map['batch'] is Map ? (map['batch']['_ref'] ?? map['batch']['_id']) as String? : map['batchId'] as String?,
      isActive: map['isActive'] as bool? ?? true,
    );
  }
}
