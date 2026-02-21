import 'package:mobx/mobx.dart';

import '../models/models.dart';
import '../services/lms_sanity_service.dart';

part 'course_store.g.dart';

class CourseStore = _CourseStore with _$CourseStore;

abstract class _CourseStore with Store {
  _CourseStore() : _service = LmsSanityService();

  final LmsSanityService _service;

  @observable
  bool loading = false;

  @observable
  String? error;

  @observable
  ObservableList<Course> courses = ObservableList<Course>();

  @observable
  Course? currentCourse;

  @observable
  Assessment? currentAssessment;

  @action
  Future<void> loadCourses() async {
    loading = true;
    error = null;
    try {
      courses = ObservableList<Course>.of(await _service.getCourses());
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
    }
  }

  @action
  Future<void> loadAssessment(String id) async {
    loading = true;
    error = null;
    try {
      currentAssessment = await _service.getAssessment(id);
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
    }
  }

  @action
  void setCurrentCourse(Course? course) {
    currentCourse = course;
  }

  @action
  void clearAssessment() {
    currentAssessment = null;
  }
}
