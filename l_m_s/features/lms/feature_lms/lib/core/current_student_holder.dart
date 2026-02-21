/// Holds the current student id (and optional name/roll) so the shell and
/// other routes can preserve it when navigating (e.g. Dashboard → Tests → back to Dashboard).
class CurrentStudentHolder {
  CurrentStudentHolder._();

  static String? studentId;
  static String? studentName;
  static String? rollNumber;

  static void set(String id, {String? name, String? roll}) {
    studentId = id;
    if (name != null) studentName = name;
    if (roll != null) rollNumber = roll;
  }

  static void clear() {
    studentId = null;
    studentName = null;
    rollNumber = null;
  }
}
