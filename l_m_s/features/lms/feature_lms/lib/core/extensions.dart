// filepath: /Users/navadeepreddy/learning mangement system/l_m_s/features/lms/feature_lms/lib/core/extensions.dart

import 'package:flutter/material.dart';
import 'types.dart';

/// Extension methods following Vyuh patterns

extension StringExtensions on String {
  /// Convert to slug format
  String toSlug() => toLowerCase().replaceAll(' ', '-').replaceAll(RegExp(r'[^a-z0-9-]'), '');
  
  /// Capitalize first letter
  String capitalize() => isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
  
  /// Get initials (e.g., "John Doe" -> "JD")
  String get initials {
    final words = trim().split(' ');
    if (words.isEmpty) return '';
    if (words.length == 1) return words[0].isNotEmpty ? words[0][0].toUpperCase() : '';
    return '${words[0][0]}${words[words.length - 1][0]}'.toUpperCase();
  }
}

extension DateTimeExtensions on DateTime {
  /// Format as date string (YYYY-MM-DD)
  String toDateString() => toString().split(' ')[0];
  
  /// Format as time string (HH:MM)
  String toTimeString() => '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  
  /// Format as readable date
  String toReadableDate() => '$day/${month.toString().padLeft(2, '0')}/$year';
  
  /// Check if today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
}

extension IntExtensions on int {
  /// Format seconds as MM:SS
  String toTimerFormat() {
    final minutes = this ~/ 60;
    final seconds = this % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  
  /// Format as percentage
  String toPercentage() => '$this%';
}

extension ContextExtensions on BuildContext {
  /// Get theme
  ThemeData get theme => Theme.of(this);
  
  /// Get text theme
  TextTheme get textTheme => Theme.of(this).textTheme;
  
  /// Get color scheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  
  /// Get screen size
  Size get screenSize => MediaQuery.of(this).size;
  
  /// Check if mobile
  bool get isMobile => screenSize.width < 600;
  
  /// Check if tablet
  bool get isTablet => screenSize.width >= 600 && screenSize.width < 1200;
  
  /// Check if desktop
  bool get isDesktop => screenSize.width >= 1200;
  
  /// Show snackbar
  void showSnackBar(String message, {Color? backgroundColor}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: backgroundColor),
    );
  }
  
  /// Show success snackbar
  void showSuccess(String message) => showSnackBar(message, backgroundColor: Colors.green);
  
  /// Show error snackbar
  void showError(String message) => showSnackBar(message, backgroundColor: Colors.red);
}

extension UserRoleExtensions on UserRole {
  /// Get color for role
  Color get color {
    switch (this) {
      case UserRole.student: return Colors.blue;
      case UserRole.teacher: return Colors.green;
      case UserRole.admin: return Colors.purple;
      case UserRole.guest: return Colors.grey;
    }
  }
  
  /// Get icon for role
  IconData get icon {
    switch (this) {
      case UserRole.student: return Icons.school;
      case UserRole.teacher: return Icons.person;
      case UserRole.admin: return Icons.admin_panel_settings;
      case UserRole.guest: return Icons.person_outline;
    }
  }
}
