// filepath: /Users/navadeepreddy/learning mangement system/l_m_s/features/lms/feature_lms/lib/plugins/auth_plugin.dart

import 'package:flutter/foundation.dart';

import '../core/config.dart';
import '../core/types.dart';
import 'plugin_base.dart';

/// Auth state for the plugin
class AuthSession {
  final String? userId;
  final String? userName;
  final String? email;
  final UserRole? role;
  final DateTime? loginTime;
  final bool isAuthenticated;

  const AuthSession({
    this.userId,
    this.userName,
    this.email,
    this.role,
    this.loginTime,
    this.isAuthenticated = false,
  });

  const AuthSession.empty() : this();

  AuthSession copyWith({
    String? userId,
    String? userName,
    String? email,
    UserRole? role,
    DateTime? loginTime,
    bool? isAuthenticated,
  }) {
    return AuthSession(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      email: email ?? this.email,
      role: role ?? this.role,
      loginTime: loginTime ?? this.loginTime,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

/// Auth plugin for managing authentication
class AuthPlugin extends LmsPlugin {
  static final AuthPlugin _instance = AuthPlugin._internal();
  factory AuthPlugin() => _instance;
  AuthPlugin._internal();

  bool _initialized = false;
  AuthSession _session = const AuthSession.empty();
  
  final List<void Function(AuthSession)> _listeners = [];

  @override
  String get id => 'auth';

  @override
  String get name => 'Authentication Plugin';

  @override
  String get version => '1.0.0';

  @override
  bool get isEnabled => true;

  /// Current session
  AuthSession get session => _session;
  
  /// Check if authenticated
  bool get isAuthenticated => _session.isAuthenticated;
  
  /// Current user role
  UserRole? get userRole => _session.role;

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    debugPrint('🔐 Auth Plugin initialized');
    
    // Try to restore session from storage
    await _restoreSession();
  }

  @override
  Future<void> dispose() async {
    _listeners.clear();
    _initialized = false;
    debugPrint('🔐 Auth Plugin disposed');
  }

  /// Add auth state listener
  void addListener(void Function(AuthSession) listener) {
    _listeners.add(listener);
  }

  /// Remove auth state listener
  void removeListener(void Function(AuthSession) listener) {
    _listeners.remove(listener);
  }

  /// Notify all listeners
  void _notifyListeners() {
    for (final listener in _listeners) {
      listener(_session);
    }
  }

  /// Login with email and password
  Future<Result<AuthSession>> login(String email, String password, String role) async {
    debugPrint('🔐 Attempting login: $email as $role');
    
    // Check demo credentials
    final demoCredentials = LmsConfig.demoCredentials[role];
    if (demoCredentials != null &&
        demoCredentials['email'] == email &&
        demoCredentials['password'] == password) {
      
      _session = AuthSession(
        userId: 'demo-$role',
        userName: 'Demo ${role.substring(0, 1).toUpperCase()}${role.substring(1)}',
        email: email,
        role: UserRole.values.firstWhere((r) => r.name == role),
        loginTime: DateTime.now(),
        isAuthenticated: true,
      );
      
      _notifyListeners();
      debugPrint('✅ Demo login successful');
      return Result.success(_session);
    }
    
    // In production, validate against Sanity
    return const Result.failure('Invalid credentials');
  }

  /// Logout
  Future<void> logout() async {
    debugPrint('🔐 Logging out');
    _session = const AuthSession.empty();
    _notifyListeners();
  }

  /// Restore session from storage
  Future<void> _restoreSession() async {
    // In production, restore from secure storage
    debugPrint('🔐 Checking for existing session...');
  }

  /// Update session with user data
  void updateSession({
    String? userId,
    String? userName,
    String? email,
    UserRole? role,
  }) {
    _session = _session.copyWith(
      userId: userId,
      userName: userName,
      email: email,
      role: role,
      isAuthenticated: true,
    );
    _notifyListeners();
  }
}
