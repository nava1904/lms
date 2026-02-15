import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  String? _currentUser;
  String? _userRole; // 'student', 'teacher', 'admin'
  bool _isAuthenticated = false;

  String? get currentUser => _currentUser;
  String? get userRole => _userRole;
  bool get isAuthenticated => _isAuthenticated;

  // Mock users for demo
  final Map<String, Map<String, String>> mockUsers = {
    'student@example.com': {'password': 'student123', 'role': 'student', 'name': 'Rahul Kumar'},
    'teacher@example.com': {'password': 'teacher123', 'role': 'teacher', 'name': 'Prof. Amit Kumar'},
    'admin@example.com': {'password': 'admin123', 'role': 'admin', 'name': 'Admin User'},
  };

  Future<bool> login(String email, String password, String role) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 800));

      final user = mockUsers[email];
      if (user != null && user['password'] == password && user['role'] == role) {
        _currentUser = email;
        _userRole = role;
        _isAuthenticated = true;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> signup(String email, String password, String name, String role) async {
    try {
      await Future.delayed(const Duration(milliseconds: 800));

      if (!mockUsers.containsKey(email)) {
        mockUsers[email] = {
          'password': password,
          'role': role,
          'name': name,
        };
        _currentUser = email;
        _userRole = role;
        _isAuthenticated = true;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  void logout() {
    _currentUser = null;
    _userRole = null;
    _isAuthenticated = false;
    notifyListeners();
  }
}
