import 'package:mobx/mobx.dart';

import '../services/lms_sanity_service.dart';

part 'admin_dashboard_store.g.dart';

class AdminDashboardStore = _AdminDashboardStore with _$AdminDashboardStore;

abstract class _AdminDashboardStore with Store {
  _AdminDashboardStore() : _service = LmsSanityService();

  final LmsSanityService _service;

  @observable
  bool loading = false;

  @observable
  String? error;

  @observable
  int totalStudents = 0;

  @observable
  int totalTeachers = 0;

  @observable
  int activeEnrollments = 0;

  @action
  Future<void> loadDashboardStats() async {
    loading = true;
    error = null;
    try {
      final stats = await _service.getDashboardStats();
      if (stats != null) {
        totalStudents = (stats['totalStudents'] as num?)?.toInt() ?? 0;
        totalTeachers = (stats['totalTeachers'] as num?)?.toInt() ?? 0;
        activeEnrollments = (stats['activeEnrollments'] as num?)?.toInt() ?? 0;
      }
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
    }
  }

  @action
  void clear() {
    totalStudents = 0;
    totalTeachers = 0;
    activeEnrollments = 0;
    error = null;
  }
}
