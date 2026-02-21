import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../models/attendance.dart';
import '../stores/attendance_store.dart';
import '../theme/lms_theme.dart';

/// Attendance: select batch, list students with Present/Absent/Late toggles.
/// Saves to Sanity via AttendanceStore (mutations).
class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final AttendanceStore _store = AttendanceStore();
  String? _selectedBatchId;

  @override
  void initState() {
    super.initState();
    _store.loadBatches();
  }

  String _dateStr() => DateTime.now().toIso8601String().split('T').first;

  String _statusFor(AttendanceRecord r) {
    final override = _store.statusOverrides[r.studentId];
    if (override == 'unmarked') return 'unmarked';
    return override ?? r.status;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LMSTheme.surfaceColor,
      appBar: AppBar(
        title: const Text('Attendance'),
        backgroundColor: LMSTheme.surfaceColor,
        foregroundColor: LMSTheme.onSurfaceColor,
      ),
      body: Observer(
        builder: (_) {
          if (_store.loading && _store.batches.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: LMSTheme.primaryColor),
            );
          }
          if (_store.error != null && _store.batches.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_store.error!, style: TextStyle(color: LMSTheme.errorColor)),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => _store.loadBatches(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Date: ${_dateStr()}', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Batch', style: Theme.of(context).textTheme.labelLarge),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _store.batches.any((b) => (b['_id'] as String? ?? '') == _selectedBatchId)
                              ? _selectedBatchId
                              : null,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          hint: Text(_store.batches.isEmpty ? 'No batches found' : 'Select batch'),
                          items: _store.batches.map((b) {
                            final id = b['_id'] as String? ?? '';
                            final name = b['name'] as String? ?? id;
                            final count = b['studentCount'];
                            return DropdownMenuItem<String>(
                              value: id,
                              child: Text('$name${count != null ? ' ($count students)' : ''}'),
                            );
                          }).toList(),
                          onChanged: (id) {
                            setState(() {
                              _selectedBatchId = id;
                              _store.statusOverrides.clear();
                              if (id != null) _store.loadBatchStudents(id);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                if (_selectedBatchId != null) ...[
                  const SizedBox(height: 16),
                  Observer(
                    builder: (_) {
                      if (_store.loading && _store.records.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: CircularProgressIndicator(color: LMSTheme.primaryColor),
                          ),
                        );
                      }
                      if (_store.records.isEmpty) {
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Center(
                              child: Text(
                                'No students in this batch',
                                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                              ),
                            ),
                          ),
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Mark attendance',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              FilledButton.icon(
                                onPressed: _saveAll,
                                icon: const Icon(Icons.save, size: 18),
                                label: const Text('Save all'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ..._store.records.map((r) => Observer(
                            builder: (_) => _buildRow(r),
                          )),
                        ],
                      );
                    },
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRow(AttendanceRecord r) {
    final status = _statusFor(r);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: LMSTheme.primaryColor.withValues(alpha: 0.2),
              child: Text(
                (r.studentName ?? r.studentId).isNotEmpty
                    ? (r.studentName ?? r.studentId).substring(0, 1).toUpperCase()
                    : '?',
                style: const TextStyle(color: LMSTheme.primaryColor, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r.studentName ?? 'Student', style: const TextStyle(fontWeight: FontWeight.w500)),
                  if (r.studentId.isNotEmpty) Text(r.studentId, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'present', label: Text('Present'), icon: Icon(Icons.check_circle, size: 18)),
                ButtonSegment(value: 'absent', label: Text('Absent'), icon: Icon(Icons.cancel, size: 18)),
                ButtonSegment(value: 'late', label: Text('Late'), icon: Icon(Icons.schedule, size: 18)),
              ],
              selected: status == 'unmarked' ? <String>{} : {status},
              emptySelectionAllowed: true,
              onSelectionChanged: (Set<String> sel) {
                if (sel.isEmpty) {
                  _store.clearStatus(r.studentId);
                } else if (sel.first == status) {
                  // Tap same segment = unselect (fallback when emptySelectionAllowed doesn't fire)
                  _store.clearStatus(r.studentId);
                } else {
                  _store.setStatus(r.studentId, sel.first);
                }
                setState(() {}); // Force rebuild so SegmentedButton reflects change
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveAll() async {
    final date = _dateStr();
    int saved = 0;
    for (final r in _store.records) {
      final status = _statusFor(r);
      final ok = await _store.saveAttendance(r.studentId, date, status);
      if (ok) saved++;
    }
    if (mounted) {
      // Reload to get new document ids for created records (needed for future unmark)
      if (_selectedBatchId != null) {
        await _store.loadBatchStudents(_selectedBatchId!);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved $saved attendance record(s)'),
          backgroundColor: LMSTheme.successColor,
        ),
      );
    }
  }
}
