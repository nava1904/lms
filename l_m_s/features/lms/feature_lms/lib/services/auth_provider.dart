import 'package:flutter/foundation.dart';
import 'sanity_service.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final SanityService _sanityService = SanityService();
  
  AuthState _state = AuthState.initial;
  Map<String, dynamic>? _currentUser;
  String? _errorMessage;
  String _userRole = '';

  AuthState get state => _state;
  Map<String, dynamic>? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  String get userRole => _userRole;
  bool get isAuthenticated => _state == AuthState.authenticated;

  /// Sign in with email and password
  Future<bool> signIn({
    required String email,
    required String password,
    required String role,
  }) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _sanityService.authenticateUser(email, password, role);
      
      if (user != null) {
        _currentUser = user;
        _userRole = role;
        _state = AuthState.authenticated;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Invalid credentials';
        _state = AuthState.unauthenticated;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Authentication failed: $e';
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  /// Sign up a new user
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    required String role,
    String? rollNumber,
    String? phone,
  }) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _sanityService.registerUser(
        name: name,
        email: email,
        password: password,
        role: role,
        rollNumber: rollNumber,
        phone: phone,
      );
      
      if (result != null) {
        // Auto-login after signup
        _currentUser = result;
        _userRole = role;
        _state = AuthState.authenticated;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Registration failed. Please configure Sanity write token.';
        _state = AuthState.error;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Registration failed: $e';
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  /// Sign out the current user
  void signOut() {
    _currentUser = null;
    _userRole = '';
    _state = AuthState.unauthenticated;
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
