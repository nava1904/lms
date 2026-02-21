/// Centralized user-friendly error messages for API/network failures.
String userFriendlyError(Object e) {
  final s = e.toString().toLowerCase();
  if (s.contains('authorization') || s.contains('token') || s.contains('401')) {
    return 'API token missing or invalid. Check .env configuration.';
  }
  if (s.contains('connection') || s.contains('socket') || s.contains('network')) {
    return 'Connection failed. Check your network and try again.';
  }
  if (s.contains('timeout')) return 'Request timed out. Please retry.';
  return 'Something went wrong. Please retry.';
}
