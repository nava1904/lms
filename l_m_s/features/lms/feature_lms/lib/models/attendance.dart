/// Domain model for attendance (Sanity attendance type).
class AttendanceRecord {
  final String id;
  final String studentId;
  final String? studentName;
  final DateTime? date;
  final String status; // present, absent, late, excused
  final String? remarks;
  final String? subjectId;
  final String? batchId;

  const AttendanceRecord({
    required this.id,
    required this.studentId,
    this.studentName,
    this.date,
    this.status = 'present',
    this.remarks,
    this.subjectId,
    this.batchId,
  });

  factory AttendanceRecord.fromMap(Map<String, dynamic> map) {
    String studentId = '';
    if (map['student'] is Map) studentId = (map['student']['_ref'] ?? map['student']['_id'] ?? '').toString();
    if (studentId.isEmpty) studentId = map['studentId'] as String? ?? '';
    String? studentName;
    if (map['student'] is Map && map['student']['name'] != null) studentName = map['student']['name'] as String?;

    DateTime? date;
    final d = map['date'];
    if (d != null) {
      if (d is DateTime) {
        date = d;
      } else if (d is String) date = DateTime.tryParse(d);
    }

    return AttendanceRecord(
      id: map['_id'] as String? ?? '',
      studentId: studentId,
      studentName: studentName,
      date: date,
      status: map['status'] as String? ?? 'present',
      remarks: map['remarks'] as String?,
      subjectId: map['subject'] is Map ? (map['subject']['_ref'] ?? map['subject']['_id']) as String? : map['subjectId'] as String?,
      batchId: map['batchId'] as String?,
    );
  }
}
