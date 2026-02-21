import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:sanity_client/sanity_client.dart' as sanity;

import '../sanity_client_helper.dart';

/// Sanity Configuration
class LmsSanityConfig {
  static const String projectId = 'w18438cu';
  static const String dataset = 'production';
  static const String apiVersion = '2024-01-01';
  
  static String writeToken = const String.fromEnvironment(
    'SANITY_WRITE_TOKEN',
    defaultValue: '',
  );
  
  static void setWriteToken(String token) {
    writeToken = token;
  }
  
  static String get mutationUrl => 
    'https://$projectId.api.sanity.io/v$apiVersion/data/mutate/$dataset';
  
  static String get queryUrl =>
    'https://$projectId.api.sanity.io/v$apiVersion/data/query/$dataset';
  
  /// Token for API calls: use shared override (from .env) first, then writeToken.
  static String? get apiToken => SanityClientHelper.effectiveToken ?? (writeToken.isNotEmpty ? writeToken : null);
}

/// GROQ Queries for LMS
class LmsQueries {
  // Learning Content
  static const String allCourses = '''
    *[_type == "course"] | order(order asc) { 
      _id, title, slug, description, thumbnail, duration, level, order,
      "subjectCount": count(*[_type == "subject" && references(^._id)])
    }
  ''';
  
  static const String allSubjects = '''
    *[_type == "subject"] | order(order asc) { 
      _id, title, slug, description, order,
      "course": course->{ _id, title },
      "chapters": chapters[]->{ _id, title, slug, order },
      "chapterCount": count(*[_type == "chapter" && subject._ref == ^._id]),
      "lessonCount": count(*[_type == "concept" && chapter->subject._ref == ^._id])
    }
  ''';
  
  static const String subjectsByCourse = '''
    *[_type == "subject" && course._ref == \$courseId] | order(order asc) { 
      _id, title, slug, description,
      "chapters": chapters[]->{ _id, title, slug }
    }
  ''';
  
  static const String allChapters = '''
    *[_type == "chapter"] | order(order asc) { 
      _id, title, slug, description, order,
      "subject": subject->{ _id, title },
      "concepts": concepts[]->{ _id, title, slug },
      "conceptCount": count(*[_type == "concept" && chapter._ref == ^._id])
    }
  ''';
  
  static const String chaptersBySubject = '''
    *[_type == "chapter" && subject._ref == \$subjectId] | order(order asc) { 
      _id, title, slug, description, order,
      "concepts": concepts[]->{ _id, title, slug, videoUrl }
    }
  ''';
  
  static const String allConcepts = '''
    *[_type == "concept"] | order(order asc) { 
      _id, title, slug, content, videoUrl, duration, order,
      "chapter": chapter->{ _id, title }
    }
  ''';
  
  static const String conceptsByChapter = '''
    *[_type == "concept" && chapter._ref == \$chapterId] | order(order asc) { 
      _id, title, slug, content, videoUrl, duration
    }
  ''';
  
  // Tests & Assessments
  static const String allTests = '''
    *[_type == "test"] | order(_createdAt desc) { 
      _id, title, description, duration, totalMarks, passingMarks, isPublished, scheduledFor,
      "subject": subject->{ _id, title },
      "questionCount": count(questions),
      "questions": questions[]->{ _id, questionText, questionType, options, correctAnswer, marks }
    }
  ''';
  
  static const String publishedTests = '''
    *[_type == "test" && isPublished == true] | order(_createdAt desc) { 
      _id, title, description, duration, totalMarks, passingMarks, scheduledFor,
      "subject": subject->{ _id, title },
      "questionCount": count(questions)
    }
  ''';
  
  static const String allQuestions = '''
    *[_type == "question"] { 
      _id, questionText, questionType, options, correctAnswer, marks, explanation, difficulty,
      "subject": subject->{ _id, title },
      "chapter": chapter->{ _id, title }
    }
  ''';
  
  static const String testAttemptsByStudent = '''
    *[_type == "testAttempt" && student._ref == \$studentId] | order(submittedAt desc) { 
      _id, score, percentage, passed, startedAt, submittedAt, timeSpent,
      "test": test->{ _id, title, totalMarks, passingMarks }
    }
  ''';
  
  static const String testAttemptsByTest = '''
    *[_type == "testAttempt" && test._ref == \$testId] | order(submittedAt desc) { 
      _id, score, percentage, passed, submittedAt,
      "student": student->{ _id, name, rollNumber }
    }
  ''';
  
  // Users
  static const String allStudents = '''
    *[_type == "student"] | order(name asc) { 
      _id, name, email, rollNumber, phone, dateOfBirth, address, profileImage, isActive,
      "enrolledCourses": enrolledCourses[]->{ _id, title }
    }
  ''';
  
  static const String studentById = '''
    *[_type == "student" && _id == \$studentId][0] { 
      _id, name, email, rollNumber, phone,
      "enrolledCourses": enrolledCourses[]->{ _id, title },
      "completedConcepts": count(*[_type == "progress" && student._ref == ^._id && completed == true]),
      "testsTaken": count(*[_type == "testAttempt" && student._ref == ^._id])
    }
  ''';
  
  static const String allTeachers = '''
    *[_type == "teacher"] | order(name asc) { 
      _id, name, email, phone, specialization, qualification, bio, profileImage, isActive,
      "subjects": subjects[]->{ _id, title }
    }
  ''';
  
  static const String allAdmins = '''
    *[_type == "admin"] | order(name asc) { 
      _id, name, email, role, permissions, profileImage, isActive
    }
  ''';
  
  // Enrollments & Progress
  static const String allEnrollments = '''
    *[_type == "enrollment"] | order(enrolledAt desc) { 
      _id, enrolledAt, status, completedAt,
      "student": student->{ _id, name, rollNumber },
      "course": course->{ _id, title }
    }
  ''';
  
  static const String enrollmentsByStudent = '''
    *[_type == "enrollment" && student._ref == \$studentId] { 
      _id, enrolledAt, status,
      "course": course->{ _id, title, description }
    }
  ''';
  
  static const String progressByStudent = '''
    *[_type == "progress" && student._ref == \$studentId] { 
      _id, completed, completedAt, score, timeSpent,
      "concept": concept->{ _id, title, "chapter": chapter->{ _id, title } }
    }
  ''';
  
  // Attendance
  static const String attendanceByStudent = '''
    *[_type == "attendance" && student._ref == \$studentId] | order(date desc) { 
      _id, date, status, remarks,
      "subject": subject->{ _id, title }
    }
  ''';
  
  static const String attendanceByDate = '''
    *[_type == "attendance" && date == \$date] { 
      _id, status, remarks,
      "student": student->{ _id, name, rollNumber }
    }
  ''';
  
  // Assignments
  static const String allAssignments = '''
    *[_type == "assignment"] | order(dueDate desc) { 
      _id, title, description, dueDate, maxScore, isPublished,
      "subject": subject->{ _id, title },
      "chapter": chapter->{ _id, title }
    }
  ''';
  
  // Dashboard Stats
  static const String dashboardStats = '''
    {
      "totalStudents": count(*[_type == "student"]),
      "totalTeachers": count(*[_type == "teacher"]),
      "totalCourses": count(*[_type == "course"]),
      "totalSubjects": count(*[_type == "subject"]),
      "totalChapters": count(*[_type == "chapter"]),
      "totalConcepts": count(*[_type == "concept"]),
      "totalTests": count(*[_type == "test"]),
      "totalQuestions": count(*[_type == "question"]),
      "activeEnrollments": count(*[_type == "enrollment" && status == "active"])
    }
  ''';
}

/// Main Sanity Service with Read & Write Operations.
/// Uses token from SanityClientHelper (set in main from .env) so auth works after startup.
class SanityService {
  static final SanityService _instance = SanityService._internal();
  factory SanityService() => _instance;
  SanityService._internal();

  sanity.SanityClient? _client;

  sanity.SanityClient get _clientOrCreate {
    _client ??= sanity.SanityClient(
      sanity.SanityConfig(
        projectId: LmsSanityConfig.projectId,
        dataset: LmsSanityConfig.dataset,
        perspective: sanity.Perspective.published,
        useCdn: true,
        apiVersion: 'v2024-01-01',
        token: LmsSanityConfig.apiToken,
      ),
    );
    return _client!;
  }

  // ═══════════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════════════════════════════

  dynamic _extractResult(dynamic response) {
    if (response is sanity.SanityQueryResponse) {
      return response.result;
    }
    return response;
  }

  Future<List<Map<String, dynamic>>> _fetchList(String query, {Map<String, String>? params}) async {
    try {
      final response = await _clientOrCreate.fetch(query, params: params);
      final result = _extractResult(response);
      if (result == null || (result is List && result.isEmpty)) return [];
      final list = result as List;
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (e) {
      debugPrint('❌ Fetch error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> _fetchOne(String query, {Map<String, String>? params}) async {
    try {
      final response = await _clientOrCreate.fetch(query, params: params);
      final result = _extractResult(response);
      if (result == null) return null;
      return Map<String, dynamic>.from(result as Map);
    } catch (e) {
      debugPrint('❌ Fetch error: $e');
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // MUTATIONS (CREATE, UPDATE, DELETE)
  // ═══════════════════════════════════════════════════════════════════

  /// Execute a Sanity mutation
  Future<Map<String, dynamic>?> _mutate(List<Map<String, dynamic>> mutations) async {
    final token = LmsSanityConfig.apiToken;
    if (token == null || token.isEmpty) {
      debugPrint('⚠️ No Sanity token. Set SANITY_API_TOKEN in .env (run from apps/l_m_s).');
      debugPrint('Get your token from: https://www.sanity.io/manage/project/${LmsSanityConfig.projectId}/api#tokens');
      return null;
    }

    try {
      final response = await http.post(
        Uri.parse(LmsSanityConfig.mutationUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'mutations': mutations}),
      );

      if (response.statusCode == 200) {
        debugPrint('✅ Mutation successful');
        return jsonDecode(response.body);
      } else {
        debugPrint('❌ Mutation failed: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Mutation error: $e');
      return null;
    }
  }

  /// Generate a unique ID for new documents
  String _generateId(String prefix) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '$prefix-$timestamp';
  }

  // ═══════════════════════════════════════════════════════════════════
  // AUTHENTICATION
  // ═══════════════════════════════════════════════════════════════════

  Future<Map<String, dynamic>?> authenticateUser(String email, String password, String role) async {
    debugPrint('🔐 Authenticating: $email as $role');
    
    // Demo credentials
    if (_isDemoUser(email, password, role)) {
      return _getDemoUserData(role);
    }

    // Fetch from Sanity
    try {
      final query = '*[_type == \$role && email == \$email][0]{ _id, name, email, rollNumber, role, specialization }';
      final result = await _fetchOne(query, params: {'email': email, 'role': role});
      
      if (result != null) {
        debugPrint('✅ User authenticated from Sanity');
        return result;
      }
    } catch (e) {
      debugPrint('❌ Auth error: $e');
    }

    return null;
  }

  bool _isDemoUser(String email, String password, String role) {
    final creds = {
      'student': {'email': 'student@demo.com', 'password': 'demo123'},
      'teacher': {'email': 'teacher@demo.com', 'password': 'demo123'},
      'admin': {'email': 'admin@demo.com', 'password': 'demo123'},
    };
    return creds[role]?['email'] == email && creds[role]?['password'] == password;
  }

  Map<String, dynamic> _getDemoUserData(String role) {
    final data = {
      'student': {'_id': 'demo-student', 'name': 'Demo Student', 'email': 'student@demo.com', 'rollNumber': 'DEMO001'},
      'teacher': {'_id': 'demo-teacher', 'name': 'Demo Teacher', 'email': 'teacher@demo.com', 'specialization': 'Mathematics'},
      'admin': {'_id': 'demo-admin', 'name': 'Demo Admin', 'email': 'admin@demo.com', 'role': 'super_admin'},
    };
    return data[role] ?? {};
  }

  // ═══════════════════════════════════════════════════════════════════
  // DASHBOARD STATS
  // ═══════════════════════════════════════════════════════════════════

  Future<Map<String, dynamic>> getDashboardStats() async {
    debugPrint('📊 Fetching dashboard stats...');
    final result = await _fetchOne(LmsQueries.dashboardStats);
    return result ?? {
      'totalStudents': 0,
      'totalTeachers': 0,
      'totalCourses': 0,
      'totalSubjects': 0,
      'totalChapters': 0,
      'totalConcepts': 0,
      'totalTests': 0,
      'totalQuestions': 0,
      'activeEnrollments': 0,
    };
  }

  // ═══════════════════════════════════════════════════════════════════
  // COURSES
  // ═══════════════════════════════════════════════════════════════════

  Future<List<Map<String, dynamic>>> fetchCourses() async {
    debugPrint('📚 Fetching courses...');
    return await _fetchList(LmsQueries.allCourses);
  }

  Future<Map<String, dynamic>?> createCourse({
    required String title,
    String? description,
    String? level,
    int? duration,
    int order = 0,
  }) async {
    debugPrint('➕ Creating course: $title');
    final id = _generateId('course');
    
    return await _mutate([{
      'create': {
        '_id': id,
        '_type': 'course',
        'title': title,
        'slug': {'_type': 'slug', 'current': title.toLowerCase().replaceAll(' ', '-')},
        'description': description,
        'level': level ?? 'beginner',
        'duration': duration,
        'order': order,
      }
    }]);
  }

  Future<Map<String, dynamic>?> updateCourse(String id, Map<String, dynamic> updates) async {
    debugPrint('✏️ Updating course: $id');
    return await _mutate([{
      'patch': {
        'id': id,
        'set': updates,
      }
    }]);
  }

  Future<Map<String, dynamic>?> deleteCourse(String id) async {
    debugPrint('🗑️ Deleting course: $id');
    return await _mutate([{'delete': {'id': id}}]);
  }

  // ═══════════════════════════════════════════════════════════════════
  // SUBJECTS
  // ═══════════════════════════════════════════════════════════════════

  Future<List<Map<String, dynamic>>> fetchSubjects({String? courseId}) async {
    debugPrint('📖 Fetching subjects...');
    if (courseId != null) {
      return await _fetchList(LmsQueries.subjectsByCourse, params: {'courseId': courseId});
    }
    return await _fetchList(LmsQueries.allSubjects);
  }

  Future<Map<String, dynamic>?> createSubject({
    required String title,
    String? description,
    String? courseId,
    int order = 0,
  }) async {
    debugPrint('➕ Creating subject: $title');
    final id = _generateId('subject');
    
    final doc = {
      '_id': id,
      '_type': 'subject',
      'title': title,
      'slug': {'_type': 'slug', 'current': title.toLowerCase().replaceAll(' ', '-')},
      'description': description,
      'order': order,
    };
    
    if (courseId != null) {
      doc['course'] = {'_type': 'reference', '_ref': courseId};
    }
    // Use createOrReplace to write directly to published (visible immediately)
    return await _mutate([{'createOrReplace': doc}]);
  }

  // ═══════════════════════════════════════════════════════════════════
  // CHAPTERS
  // ═══════════════════════════════════════════════════════════════════

  Future<List<Map<String, dynamic>>> fetchChapters({String? subjectId}) async {
    debugPrint('📑 Fetching chapters...');
    if (subjectId != null) {
      return await _fetchList(LmsQueries.chaptersBySubject, params: {'subjectId': subjectId});
    }
    return await _fetchList(LmsQueries.allChapters);
  }

  Future<Map<String, dynamic>?> createChapter({
    required String title,
    String? description,
    required String subjectId,
    int order = 0,
  }) async {
    debugPrint('➕ Creating chapter: $title');
    final id = _generateId('chapter');
    
    return await _mutate([{
      'create': {
        '_id': id,
        '_type': 'chapter',
        'title': title,
        'slug': {'_type': 'slug', 'current': title.toLowerCase().replaceAll(' ', '-')},
        'description': description,
        'subject': {'_type': 'reference', '_ref': subjectId},
        'order': order,
      }
    }]);
  }

  // ═══════════════════════════════════════════════════════════════════
  // CONCEPTS (LESSONS)
  // ═══════════════════════════════════════════════════════════════════

  Future<List<Map<String, dynamic>>> fetchConcepts({String? chapterId}) async {
    debugPrint('💡 Fetching concepts...');
    if (chapterId != null) {
      return await _fetchList(LmsQueries.conceptsByChapter, params: {'chapterId': chapterId});
    }
    return await _fetchList(LmsQueries.allConcepts);
  }

  Future<Map<String, dynamic>?> createConcept({
    required String title,
    String? content,
    String? videoUrl,
    required String chapterId,
    int? duration,
    int order = 0,
  }) async {
    debugPrint('➕ Creating concept: $title');
    final id = _generateId('concept');
    
    return await _mutate([{
      'create': {
        '_id': id,
        '_type': 'concept',
        'title': title,
        'slug': {'_type': 'slug', 'current': title.toLowerCase().replaceAll(' ', '-')},
        'content': content != null ? [{'_type': 'block', 'children': [{'_type': 'span', 'text': content}]}] : null,
        'videoUrl': videoUrl,
        'chapter': {'_type': 'reference', '_ref': chapterId},
        'duration': duration,
        'order': order,
      }
    }]);
  }

  // ═══════════════════════════════════════════════════════════════════
  // STUDENTS
  // ═══════════════════════════════════════════════════════════════════

  Future<List<Map<String, dynamic>>> fetchStudents() async {
    debugPrint('👨‍🎓 Fetching students...');
    return await _fetchList(LmsQueries.allStudents);
  }

  Future<Map<String, dynamic>?> getStudentById(String studentId) async {
    return await _fetchOne(LmsQueries.studentById, params: {'studentId': studentId});
  }

  Future<Map<String, dynamic>?> createStudent({
    required String name,
    required String email,
    required String rollNumber,
    String? phone,
    String? address,
    DateTime? dateOfBirth,
  }) async {
    debugPrint('➕ Creating student: $name');
    final id = _generateId('student');
    
    return await _mutate([{
      'create': {
        '_id': id,
        '_type': 'student',
        'name': name,
        'email': email,
        'rollNumber': rollNumber,
        'phone': phone,
        'address': address,
        'dateOfBirth': dateOfBirth?.toIso8601String().split('T')[0],
        'isActive': true,
      }
    }]);
  }

  Future<Map<String, dynamic>?> updateStudent(String id, Map<String, dynamic> updates) async {
    debugPrint('✏️ Updating student: $id');
    return await _mutate([{
      'patch': {
        'id': id,
        'set': updates,
      }
    }]);
  }

  Future<Map<String, dynamic>?> deleteStudent(String id) async {
    debugPrint('🗑️ Deleting student: $id');
    return await _mutate([{'delete': {'id': id}}]);
  }

  // ═══════════════════════════════════════════════════════════════════
  // TEACHERS
  // ═══════════════════════════════════════════════════════════════════

  Future<List<Map<String, dynamic>>> fetchTeachers() async {
    debugPrint('👨‍🏫 Fetching teachers...');
    return await _fetchList(LmsQueries.allTeachers);
  }

  Future<Map<String, dynamic>?> createTeacher({
    required String name,
    required String email,
    String? phone,
    String? specialization,
    String? qualification,
    String? bio,
  }) async {
    debugPrint('➕ Creating teacher: $name');
    final id = _generateId('teacher');
    
    return await _mutate([{
      'create': {
        '_id': id,
        '_type': 'teacher',
        'name': name,
        'email': email,
        'phone': phone,
        'specialization': specialization,
        'qualification': qualification,
        'bio': bio,
        'isActive': true,
      }
    }]);
  }

  Future<Map<String, dynamic>?> updateTeacher(String id, Map<String, dynamic> updates) async {
    return await _mutate([{'patch': {'id': id, 'set': updates}}]);
  }

  Future<Map<String, dynamic>?> deleteTeacher(String id) async {
    return await _mutate([{'delete': {'id': id}}]);
  }

  // ═══════════════════════════════════════════════════════════════════
  // ADMINS
  // ═══════════════════════════════════════════════════════════════════

  Future<List<Map<String, dynamic>>> fetchAdmins() async {
    return await _fetchList(LmsQueries.allAdmins);
  }

  Future<Map<String, dynamic>?> createAdmin({
    required String name,
    required String email,
    String role = 'content_manager',
    List<String>? permissions,
  }) async {
    debugPrint('➕ Creating admin: $name');
    final id = _generateId('admin');
    
    return await _mutate([{
      'create': {
        '_id': id,
        '_type': 'admin',
        'name': name,
        'email': email,
        'role': role,
        'permissions': permissions ?? ['manage_content'],
        'isActive': true,
      }
    }]);
  }

  /// Register a new user (student, teacher, or admin)
  Future<Map<String, dynamic>?> registerUser({
    required String name,
    required String email,
    required String password,
    required String role,
    String? rollNumber,
    String? phone,
    String? specialization,
  }) async {
    debugPrint('📝 Registering user: $name as $role');
    
    // Note: In a real app, you'd hash the password and store it securely
    // For demo purposes, we're not storing passwords in Sanity
    
    switch (role) {
      case 'student':
        return await createStudent(
          name: name,
          email: email,
          rollNumber: rollNumber ?? 'STU${DateTime.now().millisecondsSinceEpoch}',
          phone: phone,
        );
      case 'teacher':
        return await createTeacher(
          name: name,
          email: email,
          phone: phone,
          specialization: specialization,
        );
      case 'admin':
        return await createAdmin(
          name: name,
          email: email,
        );
      default:
        debugPrint('❌ Unknown role: $role');
        return null;
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // TESTS & QUESTIONS
  // ═══════════════════════════════════════════════════════════════════

  Future<List<Map<String, dynamic>>> fetchTests({bool publishedOnly = false}) async {
    debugPrint('📝 Fetching tests...');
    return await _fetchList(publishedOnly ? LmsQueries.publishedTests : LmsQueries.allTests);
  }

  Future<Map<String, dynamic>?> createTest({
    required String title,
    String? description,
    required int duration,
    required int totalMarks,
    required int passingMarks,
    String? subjectId,
    bool isPublished = false,
  }) async {
    debugPrint('➕ Creating test: $title');
    final id = _generateId('test');
    
    final doc = {
      '_id': id,
      '_type': 'test',
      'title': title,
      'description': description,
      'duration': duration,
      'totalMarks': totalMarks,
      'passingMarks': passingMarks,
      'isPublished': isPublished,
    };
    
    if (subjectId != null) {
      doc['subject'] = {'_type': 'reference', '_ref': subjectId};
    }
    
    final res = await _mutate([{'create': doc}]);
    if (res == null) return null;
    return {'_id': id, 'documentId': id};
  }

  Future<Map<String, dynamic>?> addQuestionToTest(String testId, String questionId) async {
    return await _mutate([{
      'patch': {
        'id': testId,
        'insert': {
          'after': 'questions[-1]',
          'items': [{'_type': 'reference', '_ref': questionId}]
        }
      }
    }]);
  }

  Future<List<Map<String, dynamic>>> fetchQuestions() async {
    debugPrint('❓ Fetching questions...');
    return await _fetchList(LmsQueries.allQuestions);
  }

  Future<Map<String, dynamic>?> createQuestion({
    required String questionText,
    required String questionType,
    required List<String> options,
    required String correctAnswer,
    required int marks,
    String? explanation,
    String? difficulty,
    String? subjectId,
    String? chapterId,
  }) async {
    debugPrint('➕ Creating question');
    final id = _generateId('question');
    
    final doc = {
      '_id': id,
      '_type': 'question',
      'questionText': questionText,
      'questionType': questionType,
      'options': options,
      'correctAnswer': correctAnswer,
      'marks': marks,
      'explanation': explanation,
      'difficulty': difficulty ?? 'medium',
    };
    
    if (subjectId != null) {
      doc['subject'] = {'_type': 'reference', '_ref': subjectId};
    }
    if (chapterId != null) {
      doc['chapter'] = {'_type': 'reference', '_ref': chapterId};
    }
    
    return await _mutate([{'create': doc}]);
  }

  // ═══════════════════════════════════════════════════════════════════
  // TEST ATTEMPTS
  // ═══════════════════════════════════════════════════════════════════

  Future<List<Map<String, dynamic>>> fetchTestAttempts({String? studentId, String? testId}) async {
    debugPrint('✅ Fetching test attempts...');
    if (studentId != null) {
      return await _fetchList(LmsQueries.testAttemptsByStudent, params: {'studentId': studentId});
    }
    if (testId != null) {
      return await _fetchList(LmsQueries.testAttemptsByTest, params: {'testId': testId});
    }
    return await _fetchList('*[_type == "testAttempt"] | order(submittedAt desc) { _id, score, percentage, passed, submittedAt, "test": test->{ _id, title, totalMarks }, "student": student->{ _id, name, rollNumber } }');
  }

  Future<Map<String, dynamic>?> submitTestAttempt({
    required String testId,
    required String studentId,
    required int score,
    required double percentage,
    required bool passed,
    required int timeSpent,
    List<Map<String, dynamic>>? answers,
  }) async {
    debugPrint('📤 Submitting test attempt');
    final id = _generateId('testAttempt');
    
    return await _mutate([{
      'create': {
        '_id': id,
        '_type': 'testAttempt',
        'test': {'_type': 'reference', '_ref': testId},
        'student': {'_type': 'reference', '_ref': studentId},
        'score': score,
        'percentage': percentage,
        'passed': passed,
        'timeSpent': timeSpent,
        'submittedAt': DateTime.now().toIso8601String(),
        'answers': answers,
      }
    }]);
  }

  // ═══════════════════════════════════════════════════════════════════
  // ENROLLMENTS
  // ═══════════════════════════════════════════════════════════════════

  Future<List<Map<String, dynamic>>> fetchEnrollments({String? studentId}) async {
    debugPrint('📝 Fetching enrollments...');
    if (studentId != null) {
      return await _fetchList(LmsQueries.enrollmentsByStudent, params: {'studentId': studentId});
    }
    return await _fetchList(LmsQueries.allEnrollments);
  }

  Future<Map<String, dynamic>?> enrollStudent({
    required String studentId,
    required String courseId,
  }) async {
    debugPrint('➕ Enrolling student in course');
    final id = _generateId('enrollment');
    
    return await _mutate([{
      'create': {
        '_id': id,
        '_type': 'enrollment',
        'student': {'_type': 'reference', '_ref': studentId},
        'course': {'_type': 'reference', '_ref': courseId},
        'enrolledAt': DateTime.now().toIso8601String(),
        'status': 'active',
      }
    }]);
  }

  // ═══════════════════════════════════════════════════════════════════
  // PROGRESS
  // ═══════════════════════════════════════════════════════════════════

  Future<List<Map<String, dynamic>>> fetchProgress({String? studentId}) async {
    debugPrint('📊 Fetching progress...');
    if (studentId != null) {
      return await _fetchList(LmsQueries.progressByStudent, params: {'studentId': studentId});
    }
    return await _fetchList('*[_type == "progress"] { _id, completed, score, "student": student->{ name }, "concept": concept->{ title } }');
  }

  Future<Map<String, dynamic>?> markConceptComplete({
    required String studentId,
    required String conceptId,
    int? score,
    int? timeSpent,
  }) async {
    debugPrint('✅ Marking concept complete');
    final id = _generateId('progress');
    
    return await _mutate([{
      'create': {
        '_id': id,
        '_type': 'progress',
        'student': {'_type': 'reference', '_ref': studentId},
        'concept': {'_type': 'reference', '_ref': conceptId},
        'completed': true,
        'completedAt': DateTime.now().toIso8601String(),
        'score': score,
        'timeSpent': timeSpent,
      }
    }]);
  }

  // ═══════════════════════════════════════════════════════════════════
  // ATTENDANCE
  // ═══════════════════════════════════════════════════════════════════

  Future<List<Map<String, dynamic>>> fetchAttendance({String? studentId, String? date}) async {
    debugPrint('📅 Fetching attendance...');
    if (studentId != null) {
      return await _fetchList(LmsQueries.attendanceByStudent, params: {'studentId': studentId});
    }
    if (date != null) {
      return await _fetchList(LmsQueries.attendanceByDate, params: {'date': date});
    }
    return await _fetchList('*[_type == "attendance"] | order(date desc) [0...2000] { _id, date, status, "student": student->{ _id, name } }');
  }

  Future<Map<String, dynamic>?> markAttendance({
    required String studentId,
    required String date,
    required String status,
    String? subjectId,
    String? remarks,
    String? teacherId,
  }) async {
    debugPrint('📝 Marking attendance');
    final id = _generateId('attendance');
    
    final doc = {
      '_id': id,
      '_type': 'attendance',
      'student': {'_type': 'reference', '_ref': studentId},
      'date': date,
      'status': status,
      'remarks': remarks,
    };
    
    if (subjectId != null) {
      doc['subject'] = {'_type': 'reference', '_ref': subjectId};
    }
    if (teacherId != null) {
      doc['markedBy'] = {'_type': 'reference', '_ref': teacherId};
    }
    
    return await _mutate([{'create': doc}]);
  }

  // ═══════════════════════════════════════════════════════════════════
  // ASSIGNMENTS
  // ═══════════════════════════════════════════════════════════════════

  Future<List<Map<String, dynamic>>> fetchAssignments() async {
    debugPrint('📋 Fetching assignments...');
    return await _fetchList(LmsQueries.allAssignments);
  }

  Future<Map<String, dynamic>?> createAssignment({
    required String title,
    String? description,
    required DateTime dueDate,
    int maxScore = 100,
    String? subjectId,
    String? chapterId,
  }) async {
    debugPrint('➕ Creating assignment: $title');
    final id = _generateId('assignment');
    
    final doc = {
      '_id': id,
      '_type': 'assignment',
      'title': title,
      'description': description != null ? [{'_type': 'block', 'children': [{'_type': 'span', 'text': description}]}] : null,
      'dueDate': dueDate.toIso8601String(),
      'maxScore': maxScore,
      'isPublished': true,
    };
    
    if (subjectId != null) {
      doc['subject'] = {'_type': 'reference', '_ref': subjectId};
    }
    if (chapterId != null) {
      doc['chapter'] = {'_type': 'reference', '_ref': chapterId};
    }
    
    return await _mutate([{'create': doc}]);
  }

  // ═══════════════════════════════════════════════════════════════════
  // ASSIGNMENTS - Add fetchAssessments alias for compatibility
  // ═══════════════════════════════════════════════════════════════════

  Future<List<Map<String, dynamic>>> fetchAssessments() async {
    debugPrint('📝 Fetching assessments (tests)...');
    return await fetchTests();
  }
}
