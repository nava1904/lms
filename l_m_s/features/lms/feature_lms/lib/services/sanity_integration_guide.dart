/// # LMS-Studio (Sanity CMS) Integration Guide
/// 
/// ## Setup Instructions
/// 
/// ### 1. Get Sanity Credentials
/// 
/// From your `lms-studio/sanity.config.ts`:
/// 
/// ```typescript
/// const config = {
///   projectId: 'YOUR_PROJECT_ID',
///   dataset: 'production',
///   // ...
/// }
/// ```
/// 
/// ### 2. Update Flutter Config
/// 
/// In `lib/services/sanity_service.dart`:
/// 
/// ```dart
/// class SanityConfig {
///   static const String projectId = 'YOUR_PROJECT_ID';
///   static const String dataset = 'production';
///   static const String apiVersion = '2023-01-01';
///   static const String token = 'YOUR_API_TOKEN'; // Public read token
/// }
/// ```
/// 
/// ### 3. API Token
/// 
/// Go to: https://manage.sanity.io/projects/YOUR_PROJECT_ID/settings/api
/// 
/// - Create new token with "Editor" or "Viewer" role
/// - Ensure CORS is configured:
///   - Allow origin: `http://localhost:3000` (dev)
///   - Allow origin: `https://yourdomain.com` (production)
/// 
/// ## Sanity Schema Structure
/// 
/// Your lms-studio should have these document types:
/// 
/// ```
/// ├── course
/// │   ├── title (string)
/// │   ├── description (text)
/// │   ├── thumbnail (image)
/// │   ├── instructor (reference)
/// │   ├── rating (number)
/// │   ├── price (number)
/// │   └── chapters (array of references)
/// │
/// ├── chapter
/// │   ├── title (string)
/// │   ├── description (text)
/// │   └── concepts (array of references)
/// │
/// ├── concept (lesson)
/// │   ├── title (string)
/// │   ├── videoUrl (file)
/// │   ├── duration (number)
/// │   └── description (text)
/// │
/// ├── assignment
/// │   ├── title (string)
/// │   ├── description (text)
/// │   ├── dueDate (date)
/// │   └── totalMarks (number)
/// │
/// ├── test
/// │   ├── title (string)
/// │   ├── duration (number)
/// │   ├── totalMarks (number)
/// │   └── questions (array of references)
/// │
/// ├── question
/// │   ├── question (text)
/// │   ├── options (array)
/// │   ├── correctAnswer (string)
/// │   └── explanation (text)
/// │
/// ├── enrollment
/// │   ├── student (reference)
/// │   ├── course (reference)
/// │   ├── status (string)
/// │   └── progressPercentage (number)
/// │
/// ├── progress
/// │   ├── student (reference)
/// │   ├── course (reference)
/// │   ├── overallProgress (number)
/// │   └── learningStreak (number)
/// │
/// ├── discussion
/// │   ├── title (string)
/// │   ├── content (text)
/// │   ├── course (reference)
/// │   ├── author (reference)
/// │   └── replies (array)
/// │
/// ├── student
/// │   ├── email (string)
/// │   ├── name (string)
/// │   ├── avatar (image)
/// │   └── role (string: "student")
/// │
/// ├── teacher
/// │   ├── email (string)
/// │   ├── name (string)
/// │   ├── avatar (image)
/// │   └── specialization (string)
/// │
/// └── admin
///     ├── email (string)
///     └── name (string)
/// ```
/// 
/// ## Usage Examples
/// 
/// ### Fetch All Courses
/// 
/// ```dart
/// import 'services/sanity_service.dart';
/// 
/// void loadCourses() async {
///   try {
///     final courses = await SanityService.fetchCourses();
///     print('Courses: $courses');
///   } catch (e) {
///     print('Error: $e');
///   }
/// }
/// ```
/// 
/// ### Fetch Single Course
/// 
/// ```dart
/// void loadCourse(String courseId) async {
///   try {
///     final course = await SanityService.fetchCourseById(courseId);
///     print('Course: $course');
///   } catch (e) {
///     print('Error: $e');
///   }
/// }
/// ```
/// 
/// ### Fetch Student Courses
/// 
/// ```dart
/// void loadStudentCourses(String studentId) async {
///   try {
///     final courses = await SanityService.fetchStudentCourses(studentId);
///     print('Student Courses: $courses');
///   } catch (e) {
///     print('Error: $e');
///   }
/// }
/// ```
/// 
/// ### Fetch Assignments
/// 
/// ```dart
/// void loadAssignments() async {
///   try {
///     final assignments = await SanityService.fetchAssignments();
///     print('Assignments: $assignments');
///   } catch (e) {
///     print('Error: $e');
///   }
/// }
/// ```
/// 
/// ### Fetch Tests
/// 
/// ```dart
/// void loadTests() async {
///   try {
///     final tests = await SanityService.fetchTests();
///     print('Tests: $tests');
///   } catch (e) {
///     print('Error: $e');
///   }
/// }
/// ```
/// 
/// ### Fetch Student Progress
/// 
/// ```dart
/// void loadProgress(String studentId) async {
///   try {
///     final progress = await SanityService.fetchStudentProgress(studentId);
///     print('Progress: $progress');
///   } catch (e) {
///     print('Error: $e');
///   }
/// }
/// ```
/// 
/// ### Fetch Discussions
/// 
/// ```dart
/// void loadDiscussions(String courseId) async {
///   try {
///     final discussions = await SanityService.fetchDiscussions(courseId);
///     print('Discussions: $discussions');
///   } catch (e) {
///     print('Error: $e');
///   }
/// }
/// ```
/// 
/// ## Integration with Widgets
/// 
/// ### Example: Course List Widget
/// 
/// ```dart
/// class CourseListWidget extends StatefulWidget {
///   @override
///   _CourseListWidgetState createState() => _CourseListWidgetState();
/// }
/// 
/// class _CourseListWidgetState extends State<CourseListWidget> {
///   late Future<List<dynamic>> coursesFuture;
/// 
///   @override
///   void initState() {
///     super.initState();
///     coursesFuture = SanityService.fetchCourses();
///   }
/// 
///   @override
///   Widget build(BuildContext context) {
///     return FutureBuilder(
///       future: coursesFuture,
///       builder: (context, snapshot) {
///         if (snapshot.hasData) {
///           final courses = snapshot.data as List;
///           return ListView.builder(
///             itemCount: courses.length,
///             itemBuilder: (context, index) {
///               final course = courses[index];
///               return ListTile(
///                 title: Text(course['title']),
///                 subtitle: Text(course['description']),
///               );
///             },
///           );
///         } else if (snapshot.hasError) {
///           return Text('Error: ${snapshot.error}');
///         } else {
///           return CircularProgressIndicator();
///         }
///       },
///     );
///   }
/// }
/// ```
/// 
/// ## GROQ Query Language
/// 
/// The service uses GROQ (Graph-Relational Object Queries).
/// 
/// ### Basic Queries
/// 
/// ```groq
/// // Get all documents of type
/// *[_type == "course"]
/// 
/// // Get specific fields
/// *[_type == "course"] { _id, title, price }
/// 
/// // Filter
/// *[_type == "course" && price < 100]
/// 
/// // Join references
/// *[_type == "course"] { title, "instructor": instructor->name }
/// 
/// // Count
/// *[_type == "course"] { title, "studentCount": count(students) }
/// 
/// // Sort
/// *[_type == "course"] | order(_createdAt desc)
/// 
/// // Limit
/// *[_type == "course"][0..10]
/// 
/// // Pipe operations
/// *[_type == "course"] | sort(rating desc) | select(title, rating)
/// ```
/// 
/// ## Error Handling
/// 
/// ```dart
/// try {
///   final courses = await SanityService.fetchCourses();
/// } catch (e) {
///   // Handle specific error types
///   if (e.toString().contains('Failed to fetch courses')) {
///     print('Course fetch failed');
///   } else if (e.toString().contains('Sanity query error')) {
///     print('Query execution error');
///   } else {
///     print('Unknown error: $e');
///   }
/// }
/// ```
/// 
/// ## Debugging
/// 
/// ### Enable Network Logs
/// 
/// Add to your main.dart:
/// 
/// ```dart
/// if (kDebugMode) {
///   HttpClient.enableTimelineLogging = true;
/// }
/// ```
/// 
/// ### Test Queries in Sanity Studio
/// 
/// Go to: https://YOUR_PROJECT_ID.sanity.io/vision
/// 
/// Test your GROQ queries directly in the Vision console.
/// 
/// ## Performance Tips
/// 
/// 1. **Use Projections**: Only fetch fields you need
/// 2. **Filter Early**: Filter in GROQ, not in Flutter
/// 3. **Cache Results**: Use local storage for frequently accessed data
/// 4. **Paginate**: Use `[0..10]` for large result sets
/// 5. **Monitor CDN**: Enable Sanity CDN for faster queries
/// 
/// ## Security
/// 
/// - ✅ Use public read tokens only for client-side
/// - ✅ Never expose write tokens in client apps
/// - ✅ Implement server-side validation
/// - ✅ Use CORS properly configured
/// - ⚠️ Implement row-level security on sensitive data
/// 
/// ## Environment Configuration
/// 
/// Create `.env` file:
/// ```
/// SANITY_PROJECT_ID=YOUR_PROJECT_ID
/// SANITY_DATASET=production
/// SANITY_API_TOKEN=YOUR_PUBLIC_TOKEN
/// ```
/// 
/// Load in code:
/// ```dart
/// import 'package:flutter_dotenv/flutter_dotenv.dart';
/// 
/// class SanityConfig {
///   static const String projectId = String.fromEnvironment('SANITY_PROJECT_ID');
///   static const String token = String.fromEnvironment('SANITY_API_TOKEN');
/// }
/// ```
/// 
library sanity_integration;
