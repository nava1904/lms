import 'package:flutter/material.dart';

/// Vyuh-inspired Auth Plugin
/// Abstract authentication architecture following Vyuh design patterns

/// Abstract base class for all auth providers
abstract class AuthProvider {
  Future<AuthResult> authenticate(String email, String password);
  Future<AuthResult> register(String email, String password, String name, String role);
  Future<void> logout();
  Future<bool> isAuthenticated();
}

/// Auth result model
class AuthResult {
  final bool success;
  final String? userId;
  final String? email;
  final String? name;
  final String? role;
  final String? error;
  final String? token;

  AuthResult({
    required this.success,
    this.userId,
    this.email,
    this.name,
    this.role,
    this.error,
    this.token,
  });
}

/// User model
class AuthUser {
  final String id;
  final String email;
  final String name;
  final String role;
  final String? avatar;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  AuthUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.avatar,
    this.createdAt,
    this.lastLoginAt,
  });
}

/// Email/Password auth provider (mock for demo)
class EmailPasswordAuthProvider extends AuthProvider {
  final mockUsers = {
    'student@example.com': {
      'id': 'student_001',
      'password': 'student123',
      'name': 'Rahul Kumar',
      'role': 'student',
      'email': 'student@example.com',
      'avatar': 'https://i.pravatar.cc/150?img=1',
    },
    'teacher@example.com': {
      'id': 'teacher_001',
      'password': 'teacher123',
      'name': 'Prof. Amit Kumar',
      'role': 'teacher',
      'email': 'teacher@example.com',
      'avatar': 'https://i.pravatar.cc/150?img=2',
    },
    'admin@example.com': {
      'id': 'admin_001',
      'password': 'admin123',
      'name': 'Admin User',
      'role': 'admin',
      'email': 'admin@example.com',
      'avatar': 'https://i.pravatar.cc/150?img=3',
    },
  };

  @override
  Future<AuthResult> authenticate(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final user = mockUsers[email];
    if (user != null && user['password'] == password) {
      return AuthResult(
        success: true,
        userId: user['id'] as String,
        email: user['email'] as String,
        name: user['name'] as String,
        role: user['role'] as String,
        token: 'mock_token_${user['id']}',
      );
    }

    return AuthResult(
      success: false,
      error: 'Invalid email or password',
    );
  }

  @override
  Future<AuthResult> register(String email, String password, String name, String role) async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (mockUsers.containsKey(email)) {
      return AuthResult(
        success: false,
        error: 'Email already registered',
      );
    }

    final newUserId = '${role}_${DateTime.now().millisecondsSinceEpoch}';
    mockUsers[email] = {
      'id': newUserId,
      'password': password,
      'name': name,
      'role': role,
      'email': email,
      'avatar': 'https://i.pravatar.cc/150?img=${DateTime.now().millisecond % 50}',
    };

    return AuthResult(
      success: true,
      userId: newUserId,
      email: email,
      name: name,
      role: role,
      token: 'mock_token_$newUserId',
    );
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<bool> isAuthenticated() async {
    return false;
  }
}

/// Auth service following Vyuh pattern
class VyuhAuthService extends ChangeNotifier {
  AuthProvider? _provider;
  AuthUser? _currentUser;
  String? _token;
  bool _isLoading = false;

  AuthUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get token => _token;

  VyuhAuthService({AuthProvider? provider}) {
    _provider = provider ?? EmailPasswordAuthProvider();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _provider!.authenticate(email, password);

      if (result.success) {
        _currentUser = AuthUser(
          id: result.userId!,
          email: result.email!,
          name: result.name!,
          role: result.role!,
          avatar: null,
          lastLoginAt: DateTime.now(),
        );
        _token = result.token;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String password, String name, String role) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _provider!.register(email, password, name, role);

      if (result.success) {
        _currentUser = AuthUser(
          id: result.userId!,
          email: result.email!,
          name: result.name!,
          role: result.role!,
          avatar: null,
          createdAt: DateTime.now(),
        );
        _token = result.token;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _provider!.logout();
    _currentUser = null;
    _token = null;
    notifyListeners();
  }

  void setProvider(AuthProvider provider) {
    _provider = provider;
  }
}
