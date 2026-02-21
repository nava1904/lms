import 'package:mobx/mobx.dart';

import '../models/models.dart';
import '../services/lms_sanity_service.dart';

part 'attendance_store.g.dart';

class AttendanceStore = _AttendanceStore with _$AttendanceStore;

abstract class _AttendanceStore with Store {
  _AttendanceStore() : _service = LmsSanityService();

  final LmsSanityService _service;

  @observable
  bool loading = false;

  @observable
  String? error;

  @observable
  ObservableList<AttendanceRecord> records = ObservableList<AttendanceRecord>();

  @observable
  ObservableMap<String, String> statusOverrides = ObservableMap<String, String>();

  @observable
  List<Map<String, dynamic>> batches = [];

  @action
  Future<void> loadBatches() async {
    loading = true;
    error = null;
    try {
      batches = await _service.getBatches();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
    }
  }

  @action
  Future<void> loadAttendance() async {
    loading = true;
    error = null;
    try {
      records = ObservableList<AttendanceRecord>.of(await _service.getAttendanceList());
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
    }
  }

  @action
  Future<void> loadBatchStudents(String batchId) async {
    loading = true;
    error = null;
    try {
      final list = await _service.getStudentsByBatch(batchId);
      final dateStr = DateTime.now().toIso8601String().split('T').first;
      final existingAttendance = await _service.getAttendanceForDate(dateStr);
      final existingByStudent = {for (final a in existingAttendance) a.studentId: a};
      // Clear overrides for students who now have server records (avoid stale overrides)
      for (final a in existingAttendance) {
        statusOverrides.remove(a.studentId);
      }
      records = ObservableList<AttendanceRecord>.of(
        list.map((e) {
          final sid = e['_id'] as String? ?? '';
          final existing = existingByStudent[sid];
          return AttendanceRecord(
            id: existing?.id ?? '',
            studentId: sid,
            studentName: e['name'] as String? ?? existing?.studentName,
            date: DateTime.tryParse(dateStr) ?? existing?.date,
            status: statusOverrides[sid] ?? existing?.status ?? 'present',
          );
        }),
      );
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
    }
  }

  @action
  void setStatus(String studentId, String status) {
    statusOverrides[studentId] = status;
  }

  @action
  void clearStatus(String studentId) {
    statusOverrides[studentId] = 'unmarked';
  }

  @action
  Future<bool> saveAttendance(String studentId, String date, String status) async {
    if (status == 'unmarked') {
      AttendanceRecord? existing;
      for (final r in records) {
        if (r.studentId == studentId) { existing = r; break; }
      }
      if (existing != null && existing.id.isNotEmpty) {
        final result = await _service.deleteAttendance(existing.id);
        if (result != null) {
          _updateRecordStatus(studentId, status);
          return true;
        }
        return false;
      }
      return true; // nothing to save or delete
    }
    AttendanceRecord? existing;
    for (final r in records) {
      if (r.studentId == studentId) { existing = r; break; }
    }
    final id = existing?.id.isEmpty == true ? null : existing?.id;
    final result = await _service.setAttendance(
      studentId: studentId,
      date: date,
      status: status,
      id: id,
    );
    if (result != null) {
      _updateRecordStatus(studentId, status);
      return true;
    }
    return false;
  }

  @action
  void clearSession() {
    records.clear();
    statusOverrides.clear();
    batches = [];
    error = null;
  }

  @action
  void _updateRecordStatus(String studentId, String status) {
    if (status != 'unmarked') statusOverrides.remove(studentId);
    final idx = records.indexWhere((r) => r.studentId == studentId);
    if (idx >= 0) {
      final r = records[idx];
      records[idx] = AttendanceRecord(
        id: r.id,
        studentId: r.studentId,
        studentName: r.studentName,
        date: r.date,
        status: status,
        remarks: r.remarks,
        subjectId: r.subjectId,
        batchId: r.batchId,
      );
    }
  }
}
