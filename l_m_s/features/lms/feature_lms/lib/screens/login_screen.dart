import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:vyuh_core/vyuh_core.dart';
import '../sanity_client_helper.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  // Login fields
  final _loginFormKey = GlobalKey<FormState>();
  String _loginName = '';
  String _loginRollNumber = '';
  String _loginRole = 'student'; // student or teacher
  bool _loggingIn = false;
  // Enroll fields
  final _enrollFormKey = GlobalKey<FormState>();
  String _enrollName = '';
  String? _enrollClass;
  String? _enrollCourseId;
  String _enrollRole = 'student'; // student or teacher
  bool _enrolling = false;
  String? _enrollResult;
  // Teacher fields
  final _teacherLoginFormKey = GlobalKey<FormState>();
  String _teacherLoginEmail = '';
  String _teacherLoginPassword = '';
  bool _teacherLoggingIn = false;
  final _teacherEnrollFormKey = GlobalKey<FormState>();
  String _teacherName = '';
  String _teacherEmail = '';
  String _teacherEmployeeId = '';
  bool _teacherEnrolling = false;
  String? _teacherEnrollResult;
  // Data
  List<dynamic> _classes = ['JEE', 'NEET', 'Class 12', 'Class 11'];
  List<dynamic> _courses = [];
  String? _error;
  bool _loading = true;
  Map<String, dynamic>? _adBanner;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _loading = true; _error = null; });
    try {
      final client = createLmsClient();
      final courseRes = await client.fetch(r'''*[_type == "course"]{_id, title}''');
      final adRes = await client.fetch(LmsQueries.adBanner);
      setState(() {
        _courses = courseRes.result as List<dynamic>? ?? [];
        _adBanner = (adRes.result as List<dynamic>?)?.first as Map<String, dynamic>?;
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<String> _createStudent(String name, String classLevel, String? courseId, List<String> subjectIds) async {
    const projectId = 'w18438cu';
    const dataset = 'production';
    final token = dotenv.env['SANITY_TOKEN'] ?? '';
    final rollNumber = (Random().nextInt(9000) + 1000).toString();
    final Map<String, dynamic> studentData = {
      '_type': 'student',
      'name': name,
      'rollNumber': rollNumber,
      'classLevel': classLevel,
      if (courseId != null) 'course': {'_type': 'reference', '_ref': courseId},
      if (subjectIds.isNotEmpty) 'enrolledSubjects': subjectIds.map((id) => {'_type': 'reference', '_ref': id}).toList(),
    };
    final url = Uri.https('$projectId.api.sanity.io', '/v2023-05-30/data/mutate/$dataset');
    final body = jsonEncode({
      'mutations': [
        {'create': studentData}
      ]
    });
    final headers = {
      'Content-Type': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
    final response = await http.post(url, body: body, headers: headers);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final studentId = data['results'][0]['id'] as String;
      return '$rollNumber|$studentId';
    } else {
      throw Exception('Failed to create student: ${response.body}');
    }
  }

  Future<void> _onEnroll() async {
    if (!(_enrollFormKey.currentState?.validate() ?? false)) return;
    _enrollFormKey.currentState?.save();
    setState(() { _enrolling = true; _enrollResult = null; });
    try {
      final result = await _createStudent(_enrollName, _enrollClass!, _enrollCourseId, []);
      final parts = result.split('|');
      final rollNumber = parts[0];
      final studentId = parts[1];
      setState(() {
        _enrollResult = 'Enrolled! Your roll number is $rollNumber. Please use it to login.';
      });
      // Auto-login after enrollment
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        GoRouter.of(context).go('/student-dashboard', extra: {
          'studentName': _enrollName,
          'rollNumber': rollNumber,
          'studentId': studentId,
        });
      }
    } catch (e) {
      setState(() { _enrollResult = 'Enroll failed: $e'; });
    } finally {
      setState(() { _enrolling = false; });
    }
  }

  Future<void> _onLogin() async {
    if (!(_loginFormKey.currentState?.validate() ?? false)) return;
    _loginFormKey.currentState?.save();
    setState(() { _loggingIn = true; });
    try {
      final client = createLmsClient();
      final res = await client.fetch('''*[_type == "student" && name == "$_loginName" && rollNumber == "$_loginRollNumber"][0]{_id, name, rollNumber}''');
      final student = res.result;
      if (student != null && student['_id'] != null) {
        // Route to student dashboard
        GoRouter.of(context).go('/student-dashboard', extra: {
          'studentName': student['name'],
          'rollNumber': student['rollNumber'],
          'studentId': student['_id'],
        });
      } else {
        setState(() { _error = 'No student found with that name and roll number.'; });
      }
    } catch (e) {
      setState(() { _error = 'Login failed: $e'; });
    } finally {
      setState(() { _loggingIn = false; });
    }
  }

  Future<String> _createTeacher(String name, String email, String employeeId) async {
    const projectId = 'w18438cu';
    const dataset = 'production';
    final token = dotenv.env['SANITY_TOKEN'] ?? '';
    final url = Uri.https('$projectId.api.sanity.io', '/v2023-05-30/data/mutate/$dataset');
    final Map<String, dynamic> teacherData = {
      '_type': 'teacher',
      'name': name,
      'email': email,
      'employeeId': employeeId,
    };
    final body = jsonEncode({
      'mutations': [
        {'create': teacherData}
      ]
    });
    final headers = {
      'Content-Type': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
    final response = await http.post(url, body: body, headers: headers);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final teacherId = data['results'][0]['id'] as String;
      return teacherId;
    } else {
      throw Exception('Failed to create teacher: ${response.body}');
    }
  }

  Future<void> _onTeacherEnroll() async {
    if (!(_teacherEnrollFormKey.currentState?.validate() ?? false)) return;
    _teacherEnrollFormKey.currentState?.save();
    setState(() { _teacherEnrolling = true; _teacherEnrollResult = null; });
    try {
      final teacherId = await _createTeacher(_teacherName, _teacherEmail, _teacherEmployeeId);
      setState(() {
        _teacherEnrollResult = 'Teacher account created! You can now login with your email.';
      });
    } catch (e) {
      setState(() { _teacherEnrollResult = 'Enrollment failed: $e'; });
    } finally {
      setState(() { _teacherEnrolling = false; });
    }
  }

  Future<void> _onTeacherLogin() async {
    if (!(_teacherLoginFormKey.currentState?.validate() ?? false)) return;
    _teacherLoginFormKey.currentState?.save();
    setState(() { _teacherLoggingIn = true; });
    try {
      final client = createLmsClient();
      final res = await client.fetch('''*[_type == "teacher" && email == "$_teacherLoginEmail"][0]{_id, name, email}''');
      final teacher = res.result;
      if (teacher != null && teacher['_id'] != null) {
        // Route to teacher dashboard
        GoRouter.of(context).go('/teacher-dashboard', extra: {
          'teacherName': teacher['name'],
          'teacherId': teacher['_id'],
        });
      } else {
        setState(() { _error = 'No teacher found with that email.'; });
      }
    } catch (e) {
      setState(() { _error = 'Login failed: $e'; });
    } finally {
      setState(() { _teacherLoggingIn = false; });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('LMS Login / Enroll'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Student Login'),
            Tab(text: 'Student Enroll'),
            Tab(text: 'Teacher Login'),
            Tab(text: 'Teacher Enroll'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // Tab 0: Student Login
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Form(
                    key: _loginFormKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextFormField(
                          decoration: const InputDecoration(labelText: 'Name'),
                          validator: (v) => v == null || v.isEmpty ? 'Enter your name' : null,
                          onSaved: (v) => _loginName = v ?? '',
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          decoration: const InputDecoration(labelText: 'Roll Number'),
                          validator: (v) => v == null || v.isEmpty ? 'Enter your roll number' : null,
                          onSaved: (v) => _loginRollNumber = v ?? '',
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _loggingIn ? null : _onLogin,
                          child: _loggingIn ? const CircularProgressIndicator() : const Text('Login'),
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 16),
                          Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
                        ],
                      ],
                    ),
                  ),
                ),
                // Tab 1: Student Enroll
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Form(
                    key: _enrollFormKey,
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        TextFormField(
                          decoration: const InputDecoration(labelText: 'Name'),
                          validator: (v) => v == null || v.isEmpty ? 'Enter your name' : null,
                          onSaved: (v) => _enrollName = v ?? '',
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(labelText: 'Class'),
                          value: _enrollClass,
                          items: _classes.map((c) => DropdownMenuItem<String>(value: c, child: Text(c))).toList(),
                          onChanged: (v) => setState(() => _enrollClass = v),
                          validator: (v) => v == null ? 'Select class' : null,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(labelText: 'Course'),
                          value: _enrollCourseId,
                          items: _courses.map((c) => DropdownMenuItem<String>(value: c['_id'] as String, child: Text(c['title'] as String))).toList(),
                          onChanged: (v) => setState(() => _enrollCourseId = v),
                          validator: (v) => v == null ? 'Select course' : null,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _enrolling ? null : _onEnroll,
                          child: _enrolling ? const CircularProgressIndicator() : const Text('Enroll'),
                        ),
                        if (_enrollResult != null) ...[
                          const SizedBox(height: 16),
                          Text(_enrollResult!, style: TextStyle(color: theme.colorScheme.primary)),
                        ],
                      ],
                    ),
                  ),
                ),
                // Tab 2: Teacher Login
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Form(
                    key: _teacherLoginFormKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextFormField(
                          decoration: const InputDecoration(labelText: 'Email'),
                          validator: (v) => v == null || v.isEmpty ? 'Enter your email' : null,
                          onSaved: (v) => _teacherLoginEmail = v ?? '',
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _teacherLoggingIn ? null : _onTeacherLogin,
                          child: _teacherLoggingIn ? const CircularProgressIndicator() : const Text('Login'),
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 16),
                          Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
                        ],
                      ],
                    ),
                  ),
                ),
                // Tab 3: Teacher Enroll
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Form(
                    key: _teacherEnrollFormKey,
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        TextFormField(
                          decoration: const InputDecoration(labelText: 'Name'),
                          validator: (v) => v == null || v.isEmpty ? 'Enter your name' : null,
                          onSaved: (v) => _teacherName = v ?? '',
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          decoration: const InputDecoration(labelText: 'Email'),
                          validator: (v) => v == null || v.isEmpty ? 'Enter your email' : null,
                          onSaved: (v) => _teacherEmail = v ?? '',
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          decoration: const InputDecoration(labelText: 'Employee ID'),
                          validator: (v) => v == null || v.isEmpty ? 'Enter your employee ID' : null,
                          onSaved: (v) => _teacherEmployeeId = v ?? '',
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _teacherEnrolling ? null : _onTeacherEnroll,
                          child: _teacherEnrolling ? const CircularProgressIndicator() : const Text('Enroll'),
                        ),
                        if (_teacherEnrollResult != null) ...[
                          const SizedBox(height: 16),
                          Text(_teacherEnrollResult!, style: TextStyle(color: theme.colorScheme.primary)),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: _adBanner != null
          ? Padding(
              padding: const EdgeInsets.all(8),
              child: _AdBannerWidget(adBanner: _adBanner!),
            )
          : null,
    );
  }
}

class _AdBannerWidget extends StatelessWidget {
  final Map<String, dynamic> adBanner;
  const _AdBannerWidget({required this.adBanner});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageUrl = adBanner['image']?['asset']?['_ref'] ?? '';
    final headline = adBanner['headline'] ?? '';
    final callToAction = adBanner['callToAction'] ?? '';
    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl.isNotEmpty)
              Image.network('https://cdn.sanity.io/images/YOUR_PROJECT_ID/production/$imageUrl', height: 120, fit: BoxFit.cover),
            if (headline.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(headline, style: theme.textTheme.titleMedium),
            ],
            if (callToAction.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(callToAction, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary)),
            ],
          ],
        ),
      ),
    );
  }
}
