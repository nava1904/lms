import 'package:http/http.dart' as http;
import 'dart:convert';

/// Sanity CMS Configuration
class SanityConfig {
  // Get these from your sanity.config.ts file
  static const String projectId = 'w18438cu';
  static const String dataset = 'production';
  static const String apiVersion = '2023-01-01';
  static const String token = 'YOUR_API_TOKEN'; // Use a read token for public queries

  static const String baseUrl = 'https://w18438cu.api.sanity.io/v2026-02-14/data/query/production?query=&perspective=drafts';
}

/// Sanity GROQ Queries
class SanityQueries {
  // Get all courses
  static String getAllCourses() => '''
    *[_type == "course"] {
      _id,
      title,
      description,
      "thumbnail": thumbnail.asset->url,
      "instructor": instructor->name,
      rating,
      reviews,
      price,
      "students": count(*[_type == "enrollment" && course._ref == ^._id]),
      duration,
      level,
      "category": category->title
    } | order(_createdAt desc)
  ''';

  // Get course by ID
  static String getCourseById(String courseId) => '''
    *[_type == "course" && _id == "$courseId"] {
      _id,
      title,
      description,
      "thumbnail": thumbnail.asset->url,
      "instructor": instructor->{name, email},
      rating,
      reviews,
      price,
      duration,
      level,
      "chapters": chapters[]->{
        _id,
        title,
        description,
        "concepts": concepts[]->{
          _id,
          title,
          "videoUrl": videoUrl.asset->url,
          duration,
          description
        }
      }
    }[0]
  ''';

  // Get student's enrolled courses
  static String getStudentCourses(String studentId) => '''
    *[_type == "enrollment" && student._ref == "$studentId"] {
      "course": course->{_id, title, "thumbnail": thumbnail.asset->url},
      enrollmentDate,
      completionDate,
      status,
      progressPercentage
    }
  ''';

  // Get assignments
  static String getAssignments() => '''
    *[_type == "assignment"] | order(dueDate asc) {
      _id,
      title,
      description,
      "chapter": chapter->title,
      "subject": subject->title,
      dueDate,
      totalMarks,
      status
    }
  ''';

  // Get tests
  static String getTests() => '''
    *[_type == "test"] | order(_createdAt desc) {
      _id,
      title,
      description,
      totalMarks,
      duration,
      passingMarks,
      "questionCount": count(questions[])
    }
  ''';

  // Get student progress
  static String getStudentProgress(String studentId) => '''
    *[_type == "progress" && student._ref == "$studentId"][0] {
      _id,
      chaptersCompleted,
      videosWatched,
      assignmentsSubmitted,
      testsTaken,
      averageScore,
      overallProgress,
      lastAccessedAt,
      learningStreak
    }
  ''';

  // Get discussions for a course
  static String getDiscussions(String courseId) => '''
    *[_type == "discussion" && course._ref == "$courseId"] | order(_createdAt desc) {
      _id,
      title,
      content,
      "author": author->{name, "avatar": avatar.asset->url},
      "replyCount": count(replies),
      isPinned,
      likes,
      _createdAt
    }
  ''';
}

/// Sanity API Service
class SanityService {
  static const String _baseUrl = '${SanityConfig.baseUrl}/data/query/${SanityConfig.dataset}';

  /// Fetch data from Sanity using GROQ query
  static Future<Map<String, dynamic>> query(String groqQuery) async {
    try {
      final uri = Uri.parse(_baseUrl).replace(
        queryParameters: {'query': groqQuery},
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch from Sanity: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Sanity query error: $e');
    }
  }

  /// Fetch all courses
  static Future<List<dynamic>> fetchCourses() async {
    try {
      final result = await query(SanityQueries.getAllCourses());
      return result['result'] ?? [];
    } catch (e) {
      throw Exception('Failed to fetch courses: $e');
    }
  }

  /// Fetch course by ID
  static Future<Map<String, dynamic>> fetchCourseById(String courseId) async {
    try {
      final result = await query(SanityQueries.getCourseById(courseId));
      return (result['result'] as List).isNotEmpty ? result['result'][0] : {};
    } catch (e) {
      throw Exception('Failed to fetch course: $e');
    }
  }

  /// Fetch student's courses
  static Future<List<dynamic>> fetchStudentCourses(String studentId) async {
    try {
      final result = await query(SanityQueries.getStudentCourses(studentId));
      return result['result'] ?? [];
    } catch (e) {
      throw Exception('Failed to fetch student courses: $e');
    }
  }

  /// Fetch assignments
  static Future<List<dynamic>> fetchAssignments() async {
    try {
      final result = await query(SanityQueries.getAssignments());
      return result['result'] ?? [];
    } catch (e) {
      throw Exception('Failed to fetch assignments: $e');
    }
  }

  /// Fetch tests
  static Future<List<dynamic>> fetchTests() async {
    try {
      final result = await query(SanityQueries.getTests());
      return result['result'] ?? [];
    } catch (e) {
      throw Exception('Failed to fetch tests: $e');
    }
  }

  /// Fetch student progress
  static Future<Map<String, dynamic>> fetchStudentProgress(String studentId) async {
    try {
      final result = await query(SanityQueries.getStudentProgress(studentId));
      return (result['result'] as List).isNotEmpty ? result['result'][0] : {};
    } catch (e) {
      throw Exception('Failed to fetch progress: $e');
    }
  }

  /// Fetch discussions
  static Future<List<dynamic>> fetchDiscussions(String courseId) async {
    try {
      final result = await query(SanityQueries.getDiscussions(courseId));
      return result['result'] ?? [];
    } catch (e) {
      throw Exception('Failed to fetch discussions: $e');
    }
  }
}
