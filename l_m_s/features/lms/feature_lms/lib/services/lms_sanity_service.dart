import 'package:sanity_client/sanity_client.dart';

import '../models/models.dart';
import '../sanity_client_helper.dart';

/// Single Sanity service for LMS: uses createLmsClient and LmsQueries only.
/// Returns domain models; mutations via mutateLms.
class LmsSanityService {
  LmsSanityService() : _client = createLmsClient(useCdn: true);

  final SanityClient _client;

  dynamic _result(dynamic response) {
    if (response is SanityQueryResponse) return response.result;
    return response;
  }

  Future<List<Map<String, dynamic>>> _fetchList(String query, {Map<String, String>? params}) async {
    final response = await _client.fetch(query, params: params);
    final result = _result(response);
    if (result == null || (result is List && result.isEmpty)) return [];
    return (result as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<Map<String, dynamic>?> _fetchOne(String query, {Map<String, String>? params}) async {
    final response = await _client.fetch(query, params: params);
    final result = _result(response);
    if (result == null) return null;
    return Map<String, dynamic>.from(result as Map);
  }

  // ─── Courses ─────────────────────────────────────────────────────────────

  Future<List<Course>> getCourses() async {
    final list = await _fetchList(LmsQueries.courseList);
    return list.map((e) => Course.fromMap(e)).toList();
  }

  // ─── Student & dashboard ─────────────────────────────────────────────────

  Future<Student?> getStudent(String id) async {
    final map = await _fetchOne(LmsQueries.studentByIdWithCourses(id), params: {'id': id});
    if (map == null) return null;
    return Student.fromMap(map);
  }

  Future<List<Course>> getEnrolledCoursesForStudent(String studentId) async {
    final student = await getStudent(studentId);
    if (student == null) return [];
    if (student.enrolledCourseIds.isEmpty) return [];
    final list = await _fetchList(LmsQueries.courseList);
    final ids = student.enrolledCourseIds.toSet();
    return list.where((e) => ids.contains(e['_id'])).map((e) => Course.fromMap(e)).toList();
  }

  /// Single course by id (for header / detail).
  Future<Map<String, dynamic>?> getCourseById(String courseId) async {
    return _fetchOne(LmsQueries.courseByIdWithCurriculum, params: {'courseId': courseId});
  }

  /// Course with full hierarchy: subjects -> chapters -> concepts (for content screen dropdown).
  Future<Map<String, dynamic>?> getCourseWithFullCurriculum(String courseId) async {
    return _fetchOne(LmsQueries.courseWithFullCurriculum, params: {'courseId': courseId});
  }

  /// Chapters with concepts for a course (for curriculum tab). Uses subject->course ref.
  Future<List<Map<String, dynamic>>> getChaptersWithConceptsForCourse(String courseId) async {
    final list = await _fetchList(
      LmsQueries.chaptersWithConceptsByCourseId,
      params: {'courseId': courseId},
    );
    return list;
  }

  // ─── Worksheets ───────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getWorksheets() async {
    return _fetchList(LmsQueries.worksheetList);
  }

  // ─── Assessments & tests ─────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getAssessmentList() async {
    return _fetchList(LmsQueries.assessmentList);
  }

  Future<Assessment?> getAssessment(String id) async {
    final map = await _fetchOne(LmsQueries.assessmentById(id), params: {'id': id});
    if (map == null) return null;
    return Assessment.fromMap(map);
  }

  /// Fetch Sanity "test" type by id; returns map compatible with Assessment.fromMap.
  Future<Assessment?> getTest(String id) async {
    final map = await _fetchOne(LmsQueries.testById, params: {'id': id});
    if (map == null) return null;
    // test type uses: duration, totalMarks, passingMarks; Assessment uses durationMinutes, passingMarksPercent
    final totalMarks = (map['totalMarks'] as num?)?.toInt() ?? 100;
    final passingMarks = (map['passingMarks'] as num?)?.toDouble() ?? 40;
    final passingMarksPercent = totalMarks > 0 ? (passingMarks / totalMarks * 100) : 40.0;
    final normalized = {
      ...map,
      'durationMinutes': (map['duration'] as num?)?.toInt(),
      'totalMarks': totalMarks,
      'passingMarksPercent': passingMarksPercent,
      'questions': (map['questions'] as List?)
          ?.map((q) {
            if (q is! Map) return q;
            final m = Map<String, dynamic>.from(q);
            if (m['queText'] == null && m['questionText'] != null) m['queText'] = m['questionText'];
            if (m['type'] == null && m['questionType'] != null) m['type'] = m['questionType'];
            return m;
          })
          .toList(),
    };
    return Assessment.fromMap(normalized);
  }

  /// Load assessment or test by id (for NTA-style test window).
  Future<Assessment?> getTestOrAssessment(String id) async {
    final assessment = await getAssessment(id);
    if (assessment != null) return assessment;
    return getTest(id);
  }

  // ─── Test attempts & analytics ──────────────────────────────────────────

  Future<List<TestAttempt>> getTestAttemptsForStudent(String studentId) async {
    final list = await _fetchList(LmsQueries.testAttemptsForStudent, params: {'studentId': studentId});
    return list.map((e) => TestAttempt.fromMap(e)).toList();
  }

  Future<List<TestAttempt>> getTestAttemptsForAnalytics() async {
    final list = await _fetchList(LmsQueries.testAttemptsForAnalytics);
    return list.map((e) => TestAttempt.fromMap(e)).toList();
  }

  // ─── Ad banner ──────────────────────────────────────────────────────────

  Future<AdBanner?> getActiveAdBanner() async {
    final one = await _fetchOne(LmsQueries.adBanner);
    if (one == null) return null;
    return AdBanner.fromMap(one);
  }

  Future<List<Map<String, dynamic>>> getAllAdBanners() async {
    return _fetchList(LmsQueries.adBannerList);
  }

  Future<String?> createAdBanner({
    required String headline,
    String? description,
    String? callToAction,
    String? imageAssetId,
    bool active = true,
  }) async {
    final id = 'adBanner-${DateTime.now().millisecondsSinceEpoch}';
    final doc = <String, dynamic>{
      '_type': 'adBanner',
      '_id': id,
      'headline': headline,
      'callToAction': callToAction,
      'active': active,
    };
    if (description != null && description.isNotEmpty) doc['description'] = description;
    if (imageAssetId != null && imageAssetId.isNotEmpty) {
      doc['image'] = {'_type': 'image', 'asset': {'_type': 'reference', '_ref': imageAssetId}};
    }
    final res = await mutateLms([{'create': doc}]);
    return res != null ? id : null;
  }

  Future<String?> updateAdBanner(String id, {String? headline, String? description, String? callToAction, String? imageAssetId, bool? active}) async {
    final set = <String, dynamic>{};
    if (headline != null) set['headline'] = headline;
    if (description != null) set['description'] = description;
    if (callToAction != null) set['callToAction'] = callToAction;
    if (active != null) set['active'] = active;
    if (imageAssetId != null) {
      set['image'] = {'_type': 'image', 'asset': {'_type': 'reference', '_ref': imageAssetId}};
    }
    if (set.isEmpty) return id;
    final res = await mutateLms([{'patch': {'id': id, 'set': set}}]);
    return res != null ? id : null;
  }

  Future<bool> deleteAdBanner(String id) async {
    final baseId = id.replaceFirst(RegExp(r'^drafts\.'), '');
    final res = await mutateLms([{'delete': {'id': baseId}}]);
    return res != null;
  }

  // ─── Attendance ─────────────────────────────────────────────────────────

  Future<List<AttendanceRecord>> getAttendanceList() async {
    final list = await _fetchList(LmsQueries.attendanceList);
    return list.map((e) => AttendanceRecord.fromMap(e)).toList();
  }

  /// Fetch attendance for a specific date (used when loading batch to merge existing).
  Future<List<AttendanceRecord>> getAttendanceForDate(String date) async {
    final list = await _fetchList(LmsQueries.attendanceByDate, params: {'date': date});
    return list.map((e) => AttendanceRecord.fromMap(e)).toList();
  }

  /// Fetch all attendance for computing percentages (used by teacher dashboard).
  Future<List<AttendanceRecord>> getAttendanceForPercentages() async {
    final list = await _fetchList(LmsQueries.attendanceForPercentages);
    return list.map((e) => AttendanceRecord.fromMap(e)).toList();
  }

  /// Fetch attendance for a specific student (used by student detail screen).
  Future<List<AttendanceRecord>> getAttendanceForStudent(String studentId) async {
    final list = await _fetchList(LmsQueries.attendanceByStudent, params: {'studentId': studentId});
    return list.map((e) => AttendanceRecord.fromMap(e)).toList();
  }

  // ─── Admin / teacher ────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> getDashboardStats() async {
    return _fetchOne(LmsQueries.dashboardStats);
  }

  Future<List<Map<String, dynamic>>> getBatches() async {
    return _fetchList(LmsQueries.batchList);
  }

  Future<List<Map<String, dynamic>>> getStudentsByBatch(String batchId) async {
    return _fetchList(LmsQueries.studentsByBatch(batchId), params: {'batchId': batchId});
  }

  // ─── Mutations (via single helper) ───────────────────────────────────────

  /// Create a test attempt document.
  Future<String?> createTestAttempt({
    required String testId,
    required String studentId,
    required int score,
    required double percentage,
    required bool passed,
    required DateTime startedAt,
    required DateTime submittedAt,
    required int timeSpentMinutes,
    Map<String, int>? timeSpentPerQuestion,
    List<Map<String, dynamic>>? answers,
  }) async {
    final doc = {
      '_type': 'testAttempt',
      'test': {'_type': 'reference', '_ref': testId},
      'student': {'_type': 'reference', '_ref': studentId},
      'score': score,
      'percentage': percentage,
      'passed': passed,
      'startedAt': startedAt.toIso8601String(),
      'submittedAt': submittedAt.toIso8601String(),
      'timeSpent': timeSpentMinutes,
      if (timeSpentPerQuestion != null && timeSpentPerQuestion.isNotEmpty) 'timeSpentPerQuestion': timeSpentPerQuestion,
      if (answers != null && answers.isNotEmpty) 'answers': answers,
    };
    final id = 'testAttempt-${DateTime.now().millisecondsSinceEpoch}';
    final mutations = [
      {'create': {...doc, '_id': id}},
    ];
    return mutateLms(mutations);
  }

  /// Create or patch attendance.
  Future<String?> setAttendance({
    required String studentId,
    required String date,
    required String status,
    String? id,
  }) async {
    if (id != null && id.isNotEmpty) {
      final mutations = [
        {'patch': {'id': id, 'set': {'status': status}}},
      ];
      return mutateLms(mutations);
    }
    final createId = 'attendance-${DateTime.now().millisecondsSinceEpoch}';
    final mutations = [
      {
        'createOrReplace': {
          '_type': 'attendance',
          '_id': createId,
          'student': {'_type': 'reference', '_ref': studentId},
          'date': date,
          'status': status,
        },
      },
    ];
    return mutateLms(mutations);
  }

  /// Delete an attendance record (for unmarking).
  Future<String?> deleteAttendance(String id) async {
    if (id.isEmpty) return null;
    // Strip drafts. prefix so we delete the published doc (or use base id)
    final baseId = id.replaceFirst(RegExp(r'^drafts\.'), '');
    return mutateLms([{'delete': {'id': baseId}}]);
  }
}
