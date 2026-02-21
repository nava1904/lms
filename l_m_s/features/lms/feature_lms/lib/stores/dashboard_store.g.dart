// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$DashboardStore on _DashboardStore, Store {
  Computed<int>? _$enrolledCountComputed;

  @override
  int get enrolledCount =>
      (_$enrolledCountComputed ??= Computed<int>(() => super.enrolledCount,
              name: '_DashboardStore.enrolledCount'))
          .value;

  late final _$loadingAtom =
      Atom(name: '_DashboardStore.loading', context: context);

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

  late final _$errorAtom =
      Atom(name: '_DashboardStore.error', context: context);

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

  late final _$currentStudentAtom =
      Atom(name: '_DashboardStore.currentStudent', context: context);

  @override
  Student? get currentStudent {
    _$currentStudentAtom.reportRead();
    return super.currentStudent;
  }

  @override
  set currentStudent(Student? value) {
    _$currentStudentAtom.reportWrite(value, super.currentStudent, () {
      super.currentStudent = value;
    });
  }

  late final _$enrolledCoursesAtom =
      Atom(name: '_DashboardStore.enrolledCourses', context: context);

  @override
  ObservableList<Course> get enrolledCourses {
    _$enrolledCoursesAtom.reportRead();
    return super.enrolledCourses;
  }

  @override
  set enrolledCourses(ObservableList<Course> value) {
    _$enrolledCoursesAtom.reportWrite(value, super.enrolledCourses, () {
      super.enrolledCourses = value;
    });
  }

  late final _$streakAtom =
      Atom(name: '_DashboardStore.streak', context: context);

  @override
  int get streak {
    _$streakAtom.reportRead();
    return super.streak;
  }

  @override
  set streak(int value) {
    _$streakAtom.reportWrite(value, super.streak, () {
      super.streak = value;
    });
  }

  late final _$currentCourseProgressAtom =
      Atom(name: '_DashboardStore.currentCourseProgress', context: context);

  @override
  double get currentCourseProgress {
    _$currentCourseProgressAtom.reportRead();
    return super.currentCourseProgress;
  }

  @override
  set currentCourseProgress(double value) {
    _$currentCourseProgressAtom.reportWrite(value, super.currentCourseProgress,
        () {
      super.currentCourseProgress = value;
    });
  }

  late final _$loadDashboardAsyncAction =
      AsyncAction('_DashboardStore.loadDashboard', context: context);

  @override
  Future<void> loadDashboard(String? studentId) {
    return _$loadDashboardAsyncAction.run(() => super.loadDashboard(studentId));
  }

  late final _$_DashboardStoreActionController =
      ActionController(name: '_DashboardStore', context: context);

  @override
  void clear() {
    final _$actionInfo = _$_DashboardStoreActionController.startAction(
        name: '_DashboardStore.clear');
    try {
      return super.clear();
    } finally {
      _$_DashboardStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
loading: ${loading},
error: ${error},
currentStudent: ${currentStudent},
enrolledCourses: ${enrolledCourses},
streak: ${streak},
currentCourseProgress: ${currentCourseProgress},
enrolledCount: ${enrolledCount}
    ''';
  }
}
