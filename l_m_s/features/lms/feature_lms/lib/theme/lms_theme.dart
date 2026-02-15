import 'package:flutter/material.dart';

class LMSTheme {
  static const Color primaryColor = Color(0xFF6366F1);
  static const Color secondaryColor = Color(0xFF8B5CF6);
  static const Color accentColor = Color(0xFF06B6D4);
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color dangerColor = Color(0xFFEF4444);
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}

// Mock data models
class MockDataService {
  static final List<Map<String, dynamic>> courses = [
    {
      'id': '1',
      'title': 'JEE Advanced 2024',
      'description': 'Complete course for JEE Advanced preparation',
      'image': 'https://images.unsplash.com/photo-1633356122544-f134324ef6db?w=500&h=300&fit=crop',
      'students': 1250,
      'progress': 65,
    },
    {
      'id': '2',
      'title': 'NEET Biology Mastery',
      'description': 'In-depth NEET biology preparation with live classes',
      'image': 'https://images.unsplash.com/photo-1530531741066-8eb676b01af1?w=500&h=300&fit=crop',
      'students': 980,
      'progress': 42,
    },
    {
      'id': '3',
      'title': 'Class 12 Physics',
      'description': 'Complete CBSE physics curriculum',
      'image': 'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?w=500&h=300&fit=crop',
      'students': 2100,
      'progress': 78,
    },
  ];

  static final List<Map<String, dynamic>> subjects = [
    {
      'id': '1',
      'title': 'Physics',
      'icon': '📚',
      'chapters': 15,
      'students': 450,
      'tests': 8,
    },
    {
      'id': '2',
      'title': 'Chemistry',
      'icon': '🧪',
      'chapters': 18,
      'students': 420,
      'tests': 10,
    },
    {
      'id': '3',
      'title': 'Mathematics',
      'icon': '∑',
      'chapters': 20,
      'students': 480,
      'tests': 12,
    },
  ];

  static final List<Map<String, dynamic>> students = [
    {
      'id': '1',
      'name': 'Arjun Kumar',
      'email': 'arjun.kumar@email.com',
      'rollNumber': '001',
      'class': 'JEE Batch 2024',
      'avatar': 'https://i.pravatar.cc/150?img=1',
      'attendance': 92,
      'totalTests': 15,
      'avgScore': 78.5,
    },
    {
      'id': '2',
      'name': 'Priya Singh',
      'email': 'priya.singh@email.com',
      'rollNumber': '002',
      'class': 'JEE Batch 2024',
      'avatar': 'https://i.pravatar.cc/150?img=2',
      'attendance': 88,
      'totalTests': 15,
      'avgScore': 85.2,
    },
    {
      'id': '3',
      'name': 'Rahul Patel',
      'email': 'rahul.patel@email.com',
      'rollNumber': '003',
      'class': 'JEE Batch 2024',
      'avatar': 'https://i.pravatar.cc/150?img=3',
      'attendance': 95,
      'totalTests': 15,
      'avgScore': 92.1,
    },
  ];

  static final List<Map<String, dynamic>> testResults = [
    {
      'id': '1',
      'studentName': 'Arjun Kumar',
      'testName': 'Physics Mock Test 1',
      'score': 78,
      'total': 100,
      'percentage': 78,
      'date': '2024-01-15',
      'rank': 45,
      'totalAttempts': 1250,
    },
    {
      'id': '2',
      'studentName': 'Priya Singh',
      'testName': 'Chemistry Mock Test 2',
      'score': 92,
      'total': 100,
      'percentage': 92,
      'date': '2024-01-14',
      'rank': 12,
      'totalAttempts': 980,
    },
  ];

  static final List<Map<String, dynamic>> attendanceRecords = [
    {'date': '2024-01-15', 'present': 240, 'absent': 10, 'leave': 5},
    {'date': '2024-01-14', 'present': 238, 'absent': 12, 'leave': 5},
    {'date': '2024-01-13', 'present': 245, 'absent': 8, 'leave': 2},
  ];
}
