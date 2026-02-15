/// Route paths for LMS feature.
class LmsRoutes {
  static const String dashboard = '/';
  static const String content = '/content';
  static const String attendance = '/attendance';
  static const String tests = '/tests';

  static String testWindow(String assessmentId) => '/test/$assessmentId';
}
