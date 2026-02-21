// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$AttendanceStore on _AttendanceStore, Store {
  late final _$loadingAtom =
      Atom(name: '_AttendanceStore.loading', context: context);

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
      Atom(name: '_AttendanceStore.error', context: context);

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

  late final _$recordsAtom =
      Atom(name: '_AttendanceStore.records', context: context);

  @override
  ObservableList<AttendanceRecord> get records {
    _$recordsAtom.reportRead();
    return super.records;
  }

  @override
  set records(ObservableList<AttendanceRecord> value) {
    _$recordsAtom.reportWrite(value, super.records, () {
      super.records = value;
    });
  }

  late final _$statusOverridesAtom =
      Atom(name: '_AttendanceStore.statusOverrides', context: context);

  @override
  ObservableMap<String, String> get statusOverrides {
    _$statusOverridesAtom.reportRead();
    return super.statusOverrides;
  }

  @override
  set statusOverrides(ObservableMap<String, String> value) {
    _$statusOverridesAtom.reportWrite(value, super.statusOverrides, () {
      super.statusOverrides = value;
    });
  }

  late final _$batchesAtom =
      Atom(name: '_AttendanceStore.batches', context: context);

  @override
  List<Map<String, dynamic>> get batches {
    _$batchesAtom.reportRead();
    return super.batches;
  }

  @override
  set batches(List<Map<String, dynamic>> value) {
    _$batchesAtom.reportWrite(value, super.batches, () {
      super.batches = value;
    });
  }

  late final _$loadBatchesAsyncAction =
      AsyncAction('_AttendanceStore.loadBatches', context: context);

  @override
  Future<void> loadBatches() {
    return _$loadBatchesAsyncAction.run(() => super.loadBatches());
  }

  late final _$loadAttendanceAsyncAction =
      AsyncAction('_AttendanceStore.loadAttendance', context: context);

  @override
  Future<void> loadAttendance() {
    return _$loadAttendanceAsyncAction.run(() => super.loadAttendance());
  }

  late final _$loadBatchStudentsAsyncAction =
      AsyncAction('_AttendanceStore.loadBatchStudents', context: context);

  @override
  Future<void> loadBatchStudents(String batchId) {
    return _$loadBatchStudentsAsyncAction
        .run(() => super.loadBatchStudents(batchId));
  }

  late final _$saveAttendanceAsyncAction =
      AsyncAction('_AttendanceStore.saveAttendance', context: context);

  @override
  Future<bool> saveAttendance(String studentId, String date, String status) {
    return _$saveAttendanceAsyncAction
        .run(() => super.saveAttendance(studentId, date, status));
  }

  late final _$_AttendanceStoreActionController =
      ActionController(name: '_AttendanceStore', context: context);

  @override
  void setStatus(String studentId, String status) {
    final _$actionInfo = _$_AttendanceStoreActionController.startAction(
        name: '_AttendanceStore.setStatus');
    try {
      return super.setStatus(studentId, status);
    } finally {
      _$_AttendanceStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
loading: ${loading},
error: ${error},
records: ${records},
statusOverrides: ${statusOverrides},
batches: ${batches}
    ''';
  }
}
