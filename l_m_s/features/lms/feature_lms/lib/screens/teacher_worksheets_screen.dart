import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/lms_theme.dart';
import '../services/lms_sanity_service.dart';

/// Worksheets: list from Sanity, filter by course; create/edit placeholder.
class TeacherWorksheetsScreen extends StatefulWidget {
  const TeacherWorksheetsScreen({super.key});

  @override
  State<TeacherWorksheetsScreen> createState() => _TeacherWorksheetsScreenState();
}

class _TeacherWorksheetsScreenState extends State<TeacherWorksheetsScreen> {
  final LmsSanityService _service = LmsSanityService();
  List<Map<String, dynamic>> _worksheets = [];
  List<Map<String, dynamic>> _filtered = [];
  String? _selectedCourseId;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final list = await _service.getWorksheets();
      if (mounted) {
        setState(() {
          _worksheets = list;
          _applyFilter();
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = e.toString(); });
    }
  }

  void _applyFilter() {
    if (_selectedCourseId == null || _selectedCourseId!.isEmpty) {
      _filtered = List.from(_worksheets);
    } else {
      _filtered = _worksheets.where((w) {
        final course = w['course'];
        if (course is! Map) return false;
        return (course['_id'] as String? ?? '') == _selectedCourseId;
      }).toList();
    }
  }

  List<Map<String, dynamic>> get _courseOptions {
    final seen = <String>{};
    final out = <Map<String, dynamic>>[];
    for (final w in _worksheets) {
      final course = w['course'];
      if (course is Map) {
        final id = course['_id'] as String? ?? '';
        if (id.isNotEmpty && !seen.contains(id)) {
          seen.add(id);
          out.add({'id': id, 'title': course['title'] as String? ?? 'Course'});
        }
      }
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: LMSTheme.surfaceColor,
      appBar: AppBar(
        title: const Text('Worksheets'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/teacher-dashboard'),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Create worksheet – coming soon. Use Sanity Studio for now.')),
              );
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: LMSTheme.primaryColor))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, style: const TextStyle(color: LMSTheme.errorColor), textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      FilledButton(onPressed: _load, child: const Text('Retry')),
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                      child: Row(
                        children: [
                          Text('Course:', style: theme.textTheme.labelLarge),
                          const SizedBox(width: 12),
                          DropdownButton<String>(
                            value: _selectedCourseId,
                            hint: const Text('All courses'),
                            items: [
                              const DropdownMenuItem(value: null, child: Text('All courses')),
                              ..._courseOptions.map((c) => DropdownMenuItem(
                                    value: c['id'] as String?,
                                    child: Text(c['title'] as String? ?? ''),
                                  )),
                            ],
                            onChanged: (v) {
                              setState(() {
                                _selectedCourseId = v;
                                _applyFilter();
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _filtered.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.assignment_outlined, size: 64, color: LMSTheme.mutedForeground),
                                  const SizedBox(height: 16),
                                  Text(
                                    _worksheets.isEmpty ? 'No worksheets yet' : 'No worksheets match the filter',
                                    style: theme.textTheme.titleMedium?.copyWith(color: LMSTheme.mutedForeground),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              itemCount: _filtered.length,
                              itemBuilder: (context, i) {
                                final w = _filtered[i];
                                final course = w['course'] is Map ? w['course'] as Map : null;
                                final courseTitle = course?['title'] as String? ?? '—';
                                final title = w['title'] as String? ?? 'Worksheet';
                                final count = w['questionCount'] as int? ?? 0;
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(LMSTheme.radiusMd),
                                    side: const BorderSide(color: LMSTheme.borderColor),
                                  ),
                                  child: ListTile(
                                    leading: const CircleAvatar(
                                      backgroundColor: LMSTheme.primaryColor,
                                      child: Icon(Icons.assignment, color: Colors.white),
                                    ),
                                    title: Text(title),
                                    subtitle: Text('$courseTitle · $count questions'),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.open_in_new),
                                      onPressed: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Edit worksheet – use Sanity Studio.')),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }
}
