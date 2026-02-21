// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_dashboard_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$AdminDashboardStore on _AdminDashboardStore, Store {
  late final _$loadingAtom =
      Atom(name: '_AdminDashboardStore.loading', context: context);

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
      Atom(name: '_AdminDashboardStore.error', context: context);

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

  late final _$totalStudentsAtom =
      Atom(name: '_AdminDashboardStore.totalStudents', context: context);

  @override
  int get totalStudents {
    _$totalStudentsAtom.reportRead();
    return super.totalStudents;
  }

  @override
  set totalStudents(int value) {
    _$totalStudentsAtom.reportWrite(value, super.totalStudents, () {
      super.totalStudents = value;
    });
  }

  late final _$totalTeachersAtom =
      Atom(name: '_AdminDashboardStore.totalTeachers', context: context);

  @override
  int get totalTeachers {
    _$totalTeachersAtom.reportRead();
    return super.totalTeachers;
  }

  @override
  set totalTeachers(int value) {
    _$totalTeachersAtom.reportWrite(value, super.totalTeachers, () {
      super.totalTeachers = value;
    });
  }

  late final _$activeEnrollmentsAtom =
      Atom(name: '_AdminDashboardStore.activeEnrollments', context: context);

  @override
  int get activeEnrollments {
    _$activeEnrollmentsAtom.reportRead();
    return super.activeEnrollments;
  }

  @override
  set activeEnrollments(int value) {
    _$activeEnrollmentsAtom.reportWrite(value, super.activeEnrollments, () {
      super.activeEnrollments = value;
    });
  }

  late final _$loadDashboardStatsAsyncAction =
      AsyncAction('_AdminDashboardStore.loadDashboardStats', context: context);

  @override
  Future<void> loadDashboardStats() {
    return _$loadDashboardStatsAsyncAction
        .run(() => super.loadDashboardStats());
  }

  @override
  String toString() {
    return '''
loading: ${loading},
error: ${error},
totalStudents: ${totalStudents},
totalTeachers: ${totalTeachers},
activeEnrollments: ${activeEnrollments}
    ''';
  }
}
