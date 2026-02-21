// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$CourseStore on _CourseStore, Store {
  late final _$loadingAtom =
      Atom(name: '_CourseStore.loading', context: context);

  @override
  bool get loading {
    _$loadingAtom.reportRead();
    return super.loading;
  }

  @override
  set loading(bool value) {
    _$loadingAtom.reportWrite(value, super.loading, () {
      super.loading = value;
    });
  }

  late final _$errorAtom = Atom(name: '_CourseStore.error', context: context);

  @override
  String? get error {
    _$errorAtom.reportRead();
    return super.error;
  }

  @override
  set error(String? value) {
    _$errorAtom.reportWrite(value, super.error, () {
      super.error = value;
    });
  }

  late final _$coursesAtom =
      Atom(name: '_CourseStore.courses', context: context);

  @override
  ObservableList<Course> get courses {
    _$coursesAtom.reportRead();
    return super.courses;
  }

  @override
  set courses(ObservableList<Course> value) {
    _$coursesAtom.reportWrite(value, super.courses, () {
      super.courses = value;
    });
  }

  late final _$currentCourseAtom =
      Atom(name: '_CourseStore.currentCourse', context: context);

  @override
  Course? get currentCourse {
    _$currentCourseAtom.reportRead();
    return super.currentCourse;
  }

  @override
  set currentCourse(Course? value) {
    _$currentCourseAtom.reportWrite(value, super.currentCourse, () {
      super.currentCourse = value;
    });
  }

  late final _$currentAssessmentAtom =
      Atom(name: '_CourseStore.currentAssessment', context: context);

  @override
  Assessment? get currentAssessment {
    _$currentAssessmentAtom.reportRead();
    return super.currentAssessment;
  }

  @override
  set currentAssessment(Assessment? value) {
    _$currentAssessmentAtom.reportWrite(value, super.currentAssessment, () {
      super.currentAssessment = value;
    });
  }

  late final _$loadCoursesAsyncAction =
      AsyncAction('_CourseStore.loadCourses', context: context);

  @override
  Future<void> loadCourses() {
    return _$loadCoursesAsyncAction.run(() => super.loadCourses());
  }

  late final _$loadAssessmentAsyncAction =
      AsyncAction('_CourseStore.loadAssessment', context: context);

  @override
  Future<void> loadAssessment(String id) {
    return _$loadAssessmentAsyncAction.run(() => super.loadAssessment(id));
  }

  late final _$_CourseStoreActionController =
      ActionController(name: '_CourseStore', context: context);

  @override
  void setCurrentCourse(Course? course) {
    final _$actionInfo = _$_CourseStoreActionController.startAction(
        name: '_CourseStore.setCurrentCourse');
    try {
      return super.setCurrentCourse(course);
    } finally {
      _$_CourseStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearAssessment() {
    final _$actionInfo = _$_CourseStoreActionController.startAction(
        name: '_CourseStore.clearAssessment');
    try {
      return super.clearAssessment();
    } finally {
      _$_CourseStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
loading: ${loading},
error: ${error},
courses: ${courses},
currentCourse: ${currentCourse},
currentAssessment: ${currentAssessment}
    ''';
  }
}
