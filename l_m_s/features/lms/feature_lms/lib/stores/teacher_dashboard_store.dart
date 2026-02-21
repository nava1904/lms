import 'package:mobx/mobx.dart';

import '../services/lms_sanity_service.dart';

part 'teacher_dashboard_store.g.dart';

class TeacherDashboardStore = _TeacherDashboardStore with _$TeacherDashboardStore;

abstract class _TeacherDashboardStore with Store {
  _TeacherDashboardStore() : _service = LmsSanityService();

  final LmsSanityService _service;

  @observable
  bool loading = false;

  @observable
  String? error;

  @observable
  double lastTestAverageScore = 0;

  @observable
  List<Map<String, dynamic>> batchStudents = [];

  @action
  Future<void> loadClassMetrics() async {
    loading = true;
    error = null;
    try {
      final attempts = await _service.getTestAttemptsForAnalytics();
      if (attempts.isNotEmpty) {
        final byTest = <String, List<double>>{};
        for (final a in attempts) {
          final id = a.testId;
          if (a.percentage != null) {
            byTest.putIfAbsent(id, () => []).add(a.percentage!);
          }
        }
        if (byTest.isNotEmpty) {
          final first = byTest.values.first;
          lastTestAverageScore = first.fold(0.0, (s, v) => s + v) / first.length;
        }
      }
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
      batchStudents = await _service.getStudentsByBatch(batchId);
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
    }
  }

  @action
  void clear() {
    batchStudents = [];
    lastTestAverageScore = 0;
    error = null;
  }
}
