// filepath: /Users/navadeepreddy/learning mangement system/l_m_s/features/lms/feature_lms/lib/core/route_builder.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'feature_descriptor.dart';
import 'plugins.dart';

/// Vyuh-style Route Builder
/// Provides a declarative way to define routes with analytics tracking
class VyuhRouteBuilder {
  /// Build a GoRoute with analytics tracking
  static GoRoute route({
    required String path,
    required String name,
    required Widget Function(BuildContext, GoRouterState) builder,
    List<RouteBase>? routes,
    GlobalKey<NavigatorState>? parentNavigatorKey,
  }) {
    return GoRoute(
      path: path,
      name: name,
      parentNavigatorKey: parentNavigatorKey,
      routes: routes ?? [],
      pageBuilder: (context, state) {
        // Track page view
        PluginManager.analytics.trackPageView(name, properties: {
          'path': state.uri.toString(),
          'params': state.pathParameters,
        });
        
        return CustomTransitionPage(
          key: state.pageKey,
          child: builder(context, state),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );
      },
    );
  }
  
  /// Build a shell route for nested navigation
  static ShellRoute shellRoute({
    required Widget Function(BuildContext, GoRouterState, Widget) builder,
    required List<RouteBase> routes,
    GlobalKey<NavigatorState>? navigatorKey,
  }) {
    return ShellRoute(
      navigatorKey: navigatorKey,
      builder: builder,
      routes: routes,
    );
  }
  
  /// Build routes from feature registry
  static GoRouter buildRouter({
    required FeatureRegistry registry,
    String initialLocation = '/',
    Widget Function(BuildContext, GoRouterState)? errorBuilder,
  }) {
    return GoRouter(
      initialLocation: initialLocation,
      debugLogDiagnostics: true,
      routes: registry.allRoutes,
      errorBuilder: errorBuilder ?? (context, state) => _ErrorScreen(error: state.error),
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  final Exception? error;
  
  const _ErrorScreen({this.error});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Page not found', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(error?.toString() ?? 'Unknown error'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Route Guard - Protects routes based on authentication and permissions
class RouteGuard {
  /// Check if user can access route
  static bool canAccess(String routeName, {List<String>? requiredPermissions}) {
    final auth = PluginManager.auth;
    
    // Check if authenticated
    if (!auth.isAuthenticated) {
      return false;
    }
    
    // Check permissions
    if (requiredPermissions != null) {
      for (final permission in requiredPermissions) {
        if (!auth.hasPermission(permission)) {
          return false;
        }
      }
    }
    
    return true;
  }
  
  /// Redirect path for unauthorized access
  static String? redirect(BuildContext context, GoRouterState state) {
    final auth = PluginManager.auth;
    final isLoginRoute = state.uri.path == '/' || state.uri.path == '/login';
    
    if (!auth.isAuthenticated && !isLoginRoute) {
      return '/';
    }
    
    return null;
  }
}

/// Route Extensions
extension GoRouterStateExtension on GoRouterState {
  /// Get a path parameter with type conversion
  T? param<T>(String name) {
    final value = pathParameters[name];
    if (value == null) return null;
    
    if (T == int) return int.tryParse(value) as T?;
    if (T == double) return double.tryParse(value) as T?;
    if (T == bool) return (value == 'true') as T?;
    
    return value as T?;
  }
  
  /// Get a query parameter
  String? query(String name) => uri.queryParameters[name];
}
