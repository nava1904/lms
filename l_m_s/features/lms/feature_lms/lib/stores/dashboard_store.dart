import 'package:mobx/mobx.dart';

import '../models/models.dart';
import '../services/lms_sanity_service.dart';
import '../utils/error_utils.dart';

part 'dashboard_store.g.dart';

class DashboardStore = _DashboardStore with _$DashboardStore;

abstract class _DashboardStore with Store {
  _DashboardStore() : _service = LmsSanityService();

  final LmsSanityService _service;

  @observable
  bool loading = false;

  @observable
  String? error;

  @observable
  Student? currentStudent;

  @observable
  ObservableList<Course> enrolledCourses = ObservableList<Course>();

  @observable
  int streak = 0;

  @observable
  double currentCourseProgress = 0.0;

  @computed
  int get enrolledCount => enrolledCourses.length;

  @action
  Future<void> loadDashboard(String? studentId) async {
    if (studentId == null || studentId.isEmpty) {
      error = 'No student id';
      return;
    }
    loading = true;
    error = null;
    try {
      currentStudent = await _service.getStudent(studentId);
      if (currentStudent == null) {
        error = 'Student not found';
        enrolledCourses.clear();
        return;
      }
      enrolledCourses = ObservableList<Course>.of(
        await _service.getEnrolledCoursesForStudent(studentId),
      );
      streak = 0;
      currentCourseProgress = enrolledCourses.isNotEmpty ? 0.5 : 0.0;
    } catch (e) {
      error = userFriendlyError(e);
    } finally {
      loading = false;
    }
  }

  @action
  void clear() {
    currentStudent = null;
    enrolledCourses.clear();
    streak = 0;
    currentCourseProgress = 0.0;
    error = null;
  }
}
