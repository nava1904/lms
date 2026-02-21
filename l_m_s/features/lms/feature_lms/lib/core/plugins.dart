// filepath: /Users/navadeepreddy/learning mangement system/l_m_s/features/lms/feature_lms/lib/core/plugins.dart
import 'package:flutter/foundation.dart';
import 'feature_descriptor.dart';

/// Analytics Plugin - Tracks user actions and page views
class AnalyticsPlugin extends Plugin {
  static final AnalyticsPlugin _instance = AnalyticsPlugin._internal();
  factory AnalyticsPlugin() => _instance;
  AnalyticsPlugin._internal();
  
  @override
  String get name => 'analytics';
  
  final List<AnalyticsEvent> _events = [];
  
  @override
  Future<void> init() async {
    debugPrint('📊 Analytics Plugin initialized');
  }
  
  @override
  Future<void> dispose() async {
    debugPrint('📊 Analytics Plugin disposed');
  }
  
  /// Track a page view
  void trackPageView(String pageName, {Map<String, dynamic>? properties}) {
    final event = AnalyticsEvent(
      type: 'page_view',
      name: pageName,
      properties: properties ?? {},
      timestamp: DateTime.now(),
    );
    _events.add(event);
    debugPrint('📊 Page View: $pageName');
  }
  
  /// Track a custom event
  void trackEvent(String eventName, {Map<String, dynamic>? properties}) {
    final event = AnalyticsEvent(
      type: 'event',
      name: eventName,
      properties: properties ?? {},
      timestamp: DateTime.now(),
    );
    _events.add(event);
    debugPrint('📊 Event: $eventName');
  }
  
  /// Track test started
  void trackTestStarted(String testId, String testName) {
    trackEvent('test_started', properties: {'testId': testId, 'testName': testName});
  }
  
  /// Track test completed
  void trackTestCompleted(String testId, int score, bool passed) {
    trackEvent('test_completed', properties: {
      'testId': testId,
      'score': score,
      'passed': passed,
    });
  }
  
  /// Track lesson completed
  void trackLessonCompleted(String lessonId, String lessonName) {
    trackEvent('lesson_completed', properties: {
      'lessonId': lessonId,
      'lessonName': lessonName,
    });
  }
  
  /// Get all events
  List<AnalyticsEvent> get events => List.unmodifiable(_events);
}

class AnalyticsEvent {
  final String type;
  final String name;
  final Map<String, dynamic> properties;
  final DateTime timestamp;
  
  AnalyticsEvent({
    required this.type,
    required this.name,
    required this.properties,
    required this.timestamp,
  });
}

/// Auth Plugin - Manages authentication state and tokens
class AuthPlugin extends Plugin {
  static final AuthPlugin _instance = AuthPlugin._internal();
  factory AuthPlugin() => _instance;
  AuthPlugin._internal();
  
  @override
  String get name => 'auth';
  
  String? _currentUserId;
  String? _currentUserRole;
  String? _authToken;
  
  @override
  Future<void> init() async {
    debugPrint('🔐 Auth Plugin initialized');
    // Load saved auth state from storage
  }
  
  @override
  Future<void> dispose() async {
    debugPrint('🔐 Auth Plugin disposed');
  }
  
  bool get isAuthenticated => _currentUserId != null;
  String? get currentUserId => _currentUserId;
  String? get currentUserRole => _currentUserRole;
  
  Future<void> setAuthState({
    required String userId,
    required String role,
    String? token,
  }) async {
    _currentUserId = userId;
    _currentUserRole = role;
    _authToken = token;
    debugPrint('🔐 Auth state set: $role');
  }
  
  Future<void> clearAuthState() async {
    _currentUserId = null;
    _currentUserRole = null;
    _authToken = null;
    debugPrint('🔐 Auth state cleared');
  }
  
  /// Check if user has permission
  bool hasPermission(String permission) {
    // Role-based permission check
    final rolePermissions = {
      'admin': ['manage_users', 'manage_content', 'manage_tests', 'view_analytics', 'all'],
      'teacher': ['manage_content', 'manage_tests', 'view_students', 'mark_attendance'],
      'student': ['view_content', 'take_tests', 'view_progress'],
    };
    
    final permissions = rolePermissions[_currentUserRole] ?? [];
    return permissions.contains(permission) || permissions.contains('all');
  }
}

/// Notification Plugin - Manages push notifications and in-app notifications
class NotificationPlugin extends Plugin {
  static final NotificationPlugin _instance = NotificationPlugin._internal();
  factory NotificationPlugin() => _instance;
  NotificationPlugin._internal();
  
  @override
  String get name => 'notifications';
  
  final List<AppNotification> _notifications = [];
  
  @override
  Future<void> init() async {
    debugPrint('🔔 Notification Plugin initialized');
  }
  
  @override
  Future<void> dispose() async {
    debugPrint('🔔 Notification Plugin disposed');
  }
  
  /// Add a notification
  void addNotification({
    required String title,
    required String message,
    String? actionRoute,
  }) {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      actionRoute: actionRoute,
      timestamp: DateTime.now(),
      isRead: false,
    );
    _notifications.insert(0, notification);
    debugPrint('🔔 Notification: $title');
  }
  
  /// Get unread count
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  
  /// Get all notifications
  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  
  /// Mark as read
  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
    }
  }
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final String? actionRoute;
  final DateTime timestamp;
  final bool isRead;
  
  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    this.actionRoute,
    required this.timestamp,
    required this.isRead,
  });
  
  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      title: title,
      message: message,
      actionRoute: actionRoute,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}

/// Cache Plugin - Manages local data caching
class CachePlugin extends Plugin {
  static final CachePlugin _instance = CachePlugin._internal();
  factory CachePlugin() => _instance;
  CachePlugin._internal();
  
  @override
  String get name => 'cache';
  
  final Map<String, CacheEntry> _cache = {};
  
  @override
  Future<void> init() async {
    debugPrint('💾 Cache Plugin initialized');
  }
  
  @override
  Future<void> dispose() async {
    _cache.clear();
    debugPrint('💾 Cache Plugin disposed');
  }
  
  /// Get cached data
  T? get<T>(String key) {
    final entry = _cache[key];
    if (entry == null) return null;
    
    // Check if expired
    if (entry.expiresAt != null && DateTime.now().isAfter(entry.expiresAt!)) {
      _cache.remove(key);
      return null;
    }
    
    return entry.data as T?;
  }
  
  /// Set cached data
  void set(String key, dynamic data, {Duration? ttl}) {
    _cache[key] = CacheEntry(
      data: data,
      createdAt: DateTime.now(),
      expiresAt: ttl != null ? DateTime.now().add(ttl) : null,
    );
  }
  
  /// Remove cached data
  void remove(String key) {
    _cache.remove(key);
  }
  
  /// Clear all cache
  void clear() {
    _cache.clear();
  }
}

class CacheEntry {
  final dynamic data;
  final DateTime createdAt;
  final DateTime? expiresAt;
  
  CacheEntry({
    required this.data,
    required this.createdAt,
    this.expiresAt,
  });
}

/// Plugin Manager - Easy access to all plugins
class PluginManager {
  static AnalyticsPlugin get analytics => AnalyticsPlugin();
  static AuthPlugin get auth => AuthPlugin();
  static NotificationPlugin get notifications => NotificationPlugin();
  static CachePlugin get cache => CachePlugin();
  
  /// Register all plugins with the feature registry
  static void registerAll(FeatureRegistry registry) {
    registry.registerPlugin(AnalyticsPlugin());
    registry.registerPlugin(AuthPlugin());
    registry.registerPlugin(NotificationPlugin());
    registry.registerPlugin(CachePlugin());
  }
}
