/// Holds the current teacher session so the shell and routes can preserve it when navigating.
class CurrentTeacherHolder {
  CurrentTeacherHolder._();

  static String? teacherId;
  static String? teacherName;

  static void set(String id, {String? name}) {
    teacherId = id;
    if (name != null) teacherName = name;
  }

  static void clear() {
    teacherId = null;
    teacherName = null;
  }
}
