import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';

/// Wrapper widget that provides AuthProvider to all child widgets
/// Use this to wrap your app or feature widgets that need auth state
class AuthProviderWrapper extends StatelessWidget {
  final Widget child;
  final AuthProvider? authProvider;

  const AuthProviderWrapper({
    super.key,
    required this.child,
    this.authProvider,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthProvider>.value(
      value: authProvider ?? AuthProvider(),
      child: child,
    );
  }
}

/// Extension to easily access AuthProvider from BuildContext
extension AuthProviderExtension on BuildContext {
  /// Get AuthProvider (throws if not found)
  AuthProvider get authProvider => read<AuthProvider>();
  
  /// Watch AuthProvider for changes (rebuilds on change)
  AuthProvider get watchAuthProvider => watch<AuthProvider>();
  
  /// Try to get AuthProvider (returns null if not found)
  AuthProvider? get maybeAuthProvider {
    try {
      return read<AuthProvider>();
    } catch (e) {
      return null;
    }
  }
  
  /// Check if user is authenticated
  bool get isAuthenticated => maybeAuthProvider?.isAuthenticated ?? false;
  
  /// Get current user role
  String? get userRole => maybeAuthProvider?.userRole;
  
  /// Get current user name
  String get userName => maybeAuthProvider?.currentUser?['name'] ?? 'Guest';
}

/// Mixin for screens that need auth state
mixin AuthStateMixin<T extends StatefulWidget> on State<T> {
  AuthProvider? _authProvider;
  
  AuthProvider get authProvider {
    _authProvider ??= context.read<AuthProvider>();
    return _authProvider!;
  }
  
  bool get isAuthenticated => authProvider.isAuthenticated;
  String? get userRole => authProvider.userRole;
  String get userName => authProvider.currentUser?['name'] ?? 'Guest';
  
  /// Call this to sign out and navigate to home
  Future<void> handleSignOut() async {
    authProvider.signOut();
    if (mounted) {
      // Use GoRouter navigation
      // context.go('/');
    }
  }
}
