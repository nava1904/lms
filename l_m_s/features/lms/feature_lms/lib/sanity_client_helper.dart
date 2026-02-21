import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:sanity_client/sanity_client.dart';

/// Default Sanity project ID (override with --dart-define=SANITY_PROJECT_ID=xxx).
const String lmsSanityProjectId = String.fromEnvironment(
  'SANITY_PROJECT_ID',
  defaultValue: 'w18438cu',
);

/// Default Sanity dataset (override with --dart-define=SANITY_DATASET=xxx).
const String lmsSanityDataset = String.fromEnvironment(
  'SANITY_DATASET',
  defaultValue: 'production',
);

/// Creates a Sanity client for LMS GROQ queries.
/// Uses [lmsSanityProjectId], [lmsSanityDataset], and token from [SanityClientHelper] when set.
SanityClient createLmsClient({
  String? projectId,
  String? dataset,
  bool useCdn = true,
}) {
  return SanityClient(
    SanityConfig(
      projectId: projectId ?? lmsSanityProjectId,
      dataset: dataset ?? lmsSanityDataset,
      useCdn: useCdn,
      apiVersion: 'v2024-01-01',
      token: SanityClientHelper.effectiveToken,
    ),
  );
}

/// GROQ fragments and queries for LMS content.
class LmsQueries {
  static const String courseList = r'''
    *[_type == "course"] | order(order asc) {
      _id,
      title,
      "slug": slug.current,
      description,
      thumbnail,
      duration,
      level,
      order,
      "subjects": *[_type == "subject" && course._ref == ^._id] | order(order asc) { _id, title }
    }
  ''';

  /// Single course by id with full curriculum: subjects -> chapters -> concepts.
  /// Use params: {"courseId": "<id>"}
  static const String courseByIdWithCurriculum = r'''
    *[_type == "course" && _id == $courseId][0] {
      _id,
      title,
      "slug": slug.current,
      description,
      thumbnail,
      duration,
      level,
      order,
      "subjects": *[_type == "subject" && course._ref == ^._id] | order(order asc) {
        _id,
        title,
        order,
        "chapters": chapters[]->{ _id, title, "slug": slug.current, order, duration } | order(order asc)
      }
    }
  ''';

  /// All chapters for a course (from all its subjects), each with concepts. For curriculum view.
  /// Use params: {"courseId": "<id>"}
  static const String chaptersWithConceptsByCourseId = r'''
    *[_type == "chapter" && subject->course._ref == $courseId] | order(subject->order asc, order asc) {
      _id,
      title,
      order,
      "concepts": concepts[]->{ _id, title, duration, "slug": slug.current } | order(order asc)
    }
  ''';

  /// Course by id with full hierarchy: subjects -> chapters -> concepts (for content dropdown).
  /// Use params: {"courseId": "<id>"}
  static const String courseWithFullCurriculum = r'''
    *[_type == "course" && _id == $courseId][0] {
      _id,
      title,
      "slug": slug.current,
      description,
      thumbnail,
      duration,
      level,
      order,
      "subjects": *[_type == "subject" && course._ref == ^._id] | order(order asc) {
        _id,
        title,
        order,
        "chapters": chapters[]-> | order(order asc) {
          _id,
          title,
          "slug": slug.current,
          order,
          "concepts": concepts[]->{ _id, title, duration, "slug": slug.current } | order(order asc)
        }
      }
    }
  ''';

  /// Test by id (Sanity "test" type with direct questions refs). Use params: {"id": "<id>"}
  static const String testById = r'''
    *[_type == "test" && _id == $id][0] {
      _id,
      title,
      description,
      duration,
      totalMarks,
      passingMarks,
      "questions": questions[]->{
        _id,
        questionText,
        questionType,
        options,
        correctAnswer,
        marks
      }
    }
  ''';

  static const String worksheetList = r'''
    *[_type == "worksheet"] | order(order asc) {
      _id,
      title,
      "slug": slug.current,
      "course": course->{ _id, title },
      "questionCount": count(questions),
      order
    }
  ''';

  static const String assessmentList = r'''
    *[_type == "assessment"] {
      _id,
      title,
      "slug": slug.current,
      "worksheet": worksheet->{ _id, title },
      durationMinutes,
      openInSeparateWindow,
      passingMarksPercent
    }
  ''';

  static String assessmentById(String id) => '''
    *[_type == "assessment" && _id == \$id][0] {
      _id,
      title,
      durationMinutes,
      "worksheet": worksheet->{
        _id,
        "questions": questions[]->{
          _id,
          queText,
          type,
          options,
          solution,
          imageInQue,
          imageInSol,
          marks
        }
      }
    }
  ''';

  static const String conceptList = r'''
    *[_type == "concept"] | order(order asc) {
      _id,
      title,
      "slug": slug.current,
      "course": course->{ _id, title },
      order
    }
  ''';

  static const String attendanceList = r'''
    *[_type == "attendance"] | order(date desc) [0...50] {
      _id,
      date,
      status,
      "student": student->{ _id, name },
      notes
    }
  ''';

  static const String adBanner = r'''
    *[_type == "adBanner"] | order(_createdAt desc)[0] {
      _id,
      headline,
      image,
      callToAction,
      active
    }
  ''';

  /// Student by id with enrolled courses expanded (for dashboard).
  static String studentByIdWithCourses(String id) => '''
    *[_type == "student" && _id == \$id][0] {
      _id,
      name,
      email,
      rollNumber,
      profileImage,
      "enrolledCourses": enrolledCourses[]->{ _id, title, thumbnail, description, level, duration }
    }
  ''';

  /// Test attempts for a student (for analytics), with optional timeSpentPerQuestion.
  /// Pass params: {"studentId": "<studentId>"}
  static const String testAttemptsForStudent = r'''
    *[_type == "testAttempt" && student._ref == $studentId] | order(submittedAt desc) {
      _id,
      score,
      percentage,
      passed,
      startedAt,
      submittedAt,
      timeSpent,
      timeSpentPerQuestion,
      "answers": answers[] {
        ...,
        "question": question->{
          _id,
          questionType,
          "subjectName": subject->name,
          "chapterName": chapter->name
        }
      },
      "test": test->{ _id, title },
      "student": student._ref
    }
  ''';

  /// Test attempts for analytics (admin/teacher aggregate), with answers for weak-topics.
  static const String testAttemptsForAnalytics = r'''
    *[_type == "testAttempt"] | order(submittedAt desc) {
      _id,
      score,
      percentage,
      passed,
      submittedAt,
      timeSpent,
      timeSpentPerQuestion,
      "answers": answers[] {
        ...,
        "question": question->{
          _id,
          questionType,
          "subjectName": subject->name,
          "chapterName": chapter->name
        }
      },
      "test": test->{ _id, title },
      "student": student->{ _id, name, rollNumber }
    }
  ''';

  /// List batches (for attendance screen).
  static const String batchList = r'''
    *[_type == "batch"] | order(name asc) {
      _id,
      name,
      "studentCount": count(*[_type == "student" && references(^._id)])
    }
  ''';

  /// Students in a batch (for attendance).
  static String studentsByBatch(String batchId) => '''
    *[_type == "student" && batch._ref == \$batchId] | order(rollNumber asc) {
      _id,
      name,
      rollNumber,
      profileImage
    }
  ''';

  /// Class metrics: average score by test (for teacher dashboard).
  static const String classMetricsByTest = r'''
    *[_type == "testAttempt"] {
      "testId": test._ref,
      "testTitle": test->title,
      score,
      percentage
    }
  ''';

  /// Dashboard stats (admin).
  static const String dashboardStats = r'''
    {
      "totalStudents": count(*[_type == "student"]),
      "totalTeachers": count(*[_type == "teacher"]),
      "activeEnrollments": count(*[_type == "enrollment" && status == "active"])
    }
  ''';
}

/// Token for mutations: use SanityClientHelper.effectiveToken (from .env) first,
/// then SANITY_WRITE_TOKEN / SANITY_TOKEN from dart-define.
String get _lmsMutationToken => const String.fromEnvironment(
  'SANITY_WRITE_TOKEN',
  defaultValue: '',
);
String get _lmsToken => const String.fromEnvironment(
  'SANITY_TOKEN',
  defaultValue: '',
);
String? get _effectiveMutationToken {
  final override = SanityClientHelper.effectiveToken;
  if (override != null && override.isNotEmpty) return override;
  if (_lmsMutationToken.isNotEmpty) return _lmsMutationToken;
  if (_lmsToken.isNotEmpty) return _lmsToken;
  return null;
}

/// Single mutation helper for LMS. Uses HTTP mutate API with token.
/// Returns the transaction ID on success, null on failure.
Future<String?> mutateLms(List<Map<String, dynamic>> mutations) async {
  final token = _effectiveMutationToken;
  if (token == null || token.isEmpty) {
    debugPrint('LMS mutate: no SANITY_WRITE_TOKEN or SANITY_TOKEN set (set SANITY_API_TOKEN in .env and run from apps/l_m_s)');
    return null;
  }
  final url = 'https://$lmsSanityProjectId.api.sanity.io/v2024-01-01/data/mutate/$lmsSanityDataset';
  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'mutations': mutations}),
    );
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['transactionId'] as String?;
    }
    debugPrint('LMS mutate failed: ${response.statusCode} ${response.body}');
    return null;
  } catch (e) {
    debugPrint('LMS mutate error: $e');
    return null;
  }
}

/// Sanity client configuration for LMS
class SanityClientHelper {
  static SanityClient? _client;

  static String? _tokenOverride;

  /// Set by the app from .env so the LMS client gets the token at runtime.
  /// Call this in main() after dotenv.load().
  static set tokenOverride(String? value) {
    if (_tokenOverride != value) {
      _tokenOverride = value;
      _client = null; // force client to be recreated with new token
    }
  }

  static String? get tokenOverride => _tokenOverride;

  /// Token used for API requests (from tokenOverride or dart-define). Set in main() from .env.
  static String? get effectiveToken {
    final t = _effectiveToken();
    return t != null && t.isNotEmpty ? t : null;
  }

  static String? _effectiveToken() {
    const apiEnv = String.fromEnvironment('SANITY_API_TOKEN', defaultValue: '');
    const tokenEnv = String.fromEnvironment('SANITY_TOKEN', defaultValue: '');
    final t = tokenOverride ?? (apiEnv.isNotEmpty ? apiEnv : tokenEnv);
    final normalized = t?.replaceAll(RegExp(r'\s+'), '').trim() ?? '';
    return normalized.isEmpty ? null : normalized;
  }

  static SanityClient get client {
    _client ??= SanityClient(
      SanityConfig(
        projectId: 'w18438cu',
        dataset: 'production',
        perspective: Perspective.published,
        useCdn: true, // Must be true when using Perspective.published
        apiVersion: 'v2024-01-01', // Fixed version; default (current date) can cause 400 from CDN
        token: _effectiveToken(),
      ),
    );
    return _client!;
  }

  /// For fetching draft content (requires token)
  static SanityClient get draftClient {
    return SanityClient(
      SanityConfig(
        projectId: 'w18438cu',
        dataset: 'production',
        perspective: Perspective.raw,
        useCdn: false, // Must be false for raw/drafts
        apiVersion: 'v2024-01-01',
        token: _effectiveToken(),
      ),
    );
  }
}
