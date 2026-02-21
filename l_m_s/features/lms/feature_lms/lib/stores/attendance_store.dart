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
      records = ObservableList<AttendanceRecord>.of(
        list.map((e) {
          final sid = e['_id'] as String? ?? '';
          return AttendanceRecord(
            id: '',
            studentId: sid,
            studentName: e['name'] as String?,
            date: DateTime.tryParse(dateStr),
            status: statusOverrides[sid] ?? 'present',
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
  Future<bool> saveAttendance(String studentId, String date, String status) async {
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
    return result != null;
  }
}
