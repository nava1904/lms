import 'current_admin_holder.dart';
import 'current_student_holder.dart';
import 'current_teacher_holder.dart';

/// Clears all session holders on logout.
/// Call this before navigating to home so a different user doesn't see previous data.
/// MobX stores are created per-screen and are disposed when navigating away.
void clearAllSessionData() {
  CurrentStudentHolder.clear();
  CurrentAdminHolder.clear();
  CurrentTeacherHolder.clear();
}
