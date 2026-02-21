// filepath: /Users/navadeepreddy/learning mangement system/l_m_s/features/lms/feature_lms/lib/plugins/analytics_plugin.dart

import 'package:flutter/foundation.dart';
import 'plugin_base.dart';

/// Analytics event types
enum AnalyticsEvent {
  login,
  logout,
  viewCourse,
  viewLesson,
  completeLesson,
  startTest,
  submitTest,
  viewResults,
  downloadResource,
  custom,
}

/// Analytics plugin for tracking user behavior.
/// **Deprecated**: Prefer Vyuh TelemetryPlugin (registered in main) for test/course/login events.
@Deprecated('Use Vyuh TelemetryPlugin from main instead')
class AnalyticsPlugin extends LmsPlugin {
  static final AnalyticsPlugin _instance = AnalyticsPlugin._internal();
  factory AnalyticsPlugin() => _instance;
  AnalyticsPlugin._internal();

  bool _initialized = false;
  bool _enabled = true;
  
  final List<Map<String, dynamic>> _eventQueue = [];

  @override
  String get id => 'analytics';

  @override
  String get name => 'Analytics Plugin';

  @override
  String get version => '1.0.0';

  @override
  bool get isEnabled => _enabled;
  
  set isEnabled(bool value) => _enabled = value;

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    debugPrint('📊 Analytics Plugin initialized');
  }

  @override
  Future<void> dispose() async {
    await _flushEvents();
    _initialized = false;
    debugPrint('📊 Analytics Plugin disposed');
  }

  /// Track an event
  void trackEvent(AnalyticsEvent event, {Map<String, dynamic>? properties}) {
    if (!_enabled) return;
    
    final eventData = {
      'event': event.name,
      'timestamp': DateTime.now().toIso8601String(),
      'properties': properties ?? {},
    };
    
    _eventQueue.add(eventData);
    debugPrint('📊 Event tracked: ${event.name}');
    
    // Flush if queue gets large
    if (_eventQueue.length >= 10) {
      _flushEvents();
    }
  }

  /// Track a screen view
  void trackScreen(String screenName, {Map<String, dynamic>? properties}) {
    trackEvent(AnalyticsEvent.custom, properties: {
      'type': 'screen_view',
      'screen': screenName,
      ...?properties,
    });
  }

  /// Track user login
  void trackLogin(String userId, String role) {
    trackEvent(AnalyticsEvent.login, properties: {
      'userId': userId,
      'role': role,
    });
  }

  /// Track lesson completion
  void trackLessonComplete(String lessonId, String lessonTitle, int timeSpent) {
    trackEvent(AnalyticsEvent.completeLesson, properties: {
      'lessonId': lessonId,
      'lessonTitle': lessonTitle,
      'timeSpent': timeSpent,
    });
  }

  /// Track test submission
  void trackTestSubmit(String testId, int score, double percentage, bool passed) {
    trackEvent(AnalyticsEvent.submitTest, properties: {
      'testId': testId,
      'score': score,
      'percentage': percentage,
      'passed': passed,
    });
  }

  /// Flush events to backend
  Future<void> _flushEvents() async {
    if (_eventQueue.isEmpty) return;
    
    // In production, send to analytics backend
    debugPrint('📊 Flushing ${_eventQueue.length} events');
    _eventQueue.clear();
  }

  /// Get event count
  int get eventCount => _eventQueue.length;
}

/// LMS Analytics Plugin
/// Tracks analytics events for the LMS feature.
class LmsAnalyticsPlugin extends AnalyticsPlugin {
  LmsAnalyticsPlugin() : super();
}
  @override
  Future<void> initialize() async {
    // Initialize analytics (e.g., Firebase, Amplitude, etc.)
    debugPrint('LMS Analytics Plugin initialized.');
  }

  @override
void trackEvent(AnalyticsEvent event, {Map<String, dynamic>? properties}) {
    // Track analytics event
    debugPrint('Event: $event, Properties: $properties');
  }
}
