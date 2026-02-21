// filepath: /Users/navadeepreddy/learning mangement system/l_m_s/features/lms/feature_lms/lib/core/config.dart

/// LMS Configuration following Vyuh patterns
library;


class LmsConfig {
  /// Sanity CMS Configuration
  static const String sanityProjectId = 'w18438cu';
  static const String sanityDataset = 'production';
  static const String sanityApiVersion = '2024-01-01';
  
  /// Write token for mutations (set via environment or runtime)
  static String _writeToken = const String.fromEnvironment('SANITY_WRITE_TOKEN', defaultValue: '');
  
  static String get writeToken => _writeToken;
  static set writeToken(String token) => _writeToken = token;
  
  static bool get hasWriteToken => _writeToken.isNotEmpty;
  
  /// API URLs
  static String get sanityMutationUrl => 
    'https://$sanityProjectId.api.sanity.io/v$sanityApiVersion/data/mutate/$sanityDataset';
  
  static String get sanityQueryUrl =>
    'https://$sanityProjectId.api.sanity.io/v$sanityApiVersion/data/query/$sanityDataset';

  /// Feature flags
  static const bool enableAnalytics = true;
  static const bool enableOfflineMode = false;
  static const bool enablePushNotifications = false;
  
  /// Demo/Test Configuration
  static const bool enableDemoMode = true;
  static const Map<String, Map<String, String>> demoCredentials = {
    'student': {'email': 'student@demo.com', 'password': 'demo123'},
    'teacher': {'email': 'teacher@demo.com', 'password': 'demo123'},
    'admin': {'email': 'admin@demo.com', 'password': 'demo123'},
  };

  /// App Configuration
  static const String appName = 'LMS';
  static const String appVersion = '1.0.0';
  static const int testTimerWarningSeconds = 300; // 5 minutes warning
}
