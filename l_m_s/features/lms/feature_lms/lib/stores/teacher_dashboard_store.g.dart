// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teacher_dashboard_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$TeacherDashboardStore on _TeacherDashboardStore, Store {
  late final _$loadingAtom =
      Atom(name: '_TeacherDashboardStore.loading', context: context);

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
      Atom(name: '_TeacherDashboardStore.error', context: context);

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

  late final _$lastTestAverageScoreAtom = Atom(
      name: '_TeacherDashboardStore.lastTestAverageScore', context: context);

  @override
  double get lastTestAverageScore {
    _$lastTestAverageScoreAtom.reportRead();
    return super.lastTestAverageScore;
  }

  @override
  set lastTestAverageScore(double value) {
    _$lastTestAverageScoreAtom.reportWrite(value, super.lastTestAverageScore,
        () {
      super.lastTestAverageScore = value;
    });
  }

  late final _$batchStudentsAtom =
      Atom(name: '_TeacherDashboardStore.batchStudents', context: context);

  @override
  List<Map<String, dynamic>> get batchStudents {
    _$batchStudentsAtom.reportRead();
    return super.batchStudents;
  }

  @override
  set batchStudents(List<Map<String, dynamic>> value) {
    _$batchStudentsAtom.reportWrite(value, super.batchStudents, () {
      super.batchStudents = value;
    });
  }

  late final _$loadClassMetricsAsyncAction =
      AsyncAction('_TeacherDashboardStore.loadClassMetrics', context: context);

  @override
  Future<void> loadClassMetrics() {
    return _$loadClassMetricsAsyncAction.run(() => super.loadClassMetrics());
  }

  late final _$loadBatchStudentsAsyncAction =
      AsyncAction('_TeacherDashboardStore.loadBatchStudents', context: context);

  @override
  Future<void> loadBatchStudents(String batchId) {
    return _$loadBatchStudentsAsyncAction
        .run(() => super.loadBatchStudents(batchId));
  }

  late final _$_TeacherDashboardStoreActionController =
      ActionController(name: '_TeacherDashboardStore', context: context);

  @override
  void clear() {
    final _$actionInfo = _$_TeacherDashboardStoreActionController.startAction(
        name: '_TeacherDashboardStore.clear');
    try {
      return super.clear();
    } finally {
      _$_TeacherDashboardStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
loading: ${loading},
error: ${error},
lastTestAverageScore: ${lastTestAverageScore},
batchStudents: ${batchStudents}
    ''';
  }
}
