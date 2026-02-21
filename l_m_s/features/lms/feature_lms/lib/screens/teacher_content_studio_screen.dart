import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/lms_theme.dart';
import '../models/course.dart';
import '../services/lms_sanity_service.dart';

/// Content Studio: Course → Subject → Chapter → Lecture (concept) tree; create lecture via Content Editor.
class TeacherContentStudioScreen extends StatefulWidget {
  const TeacherContentStudioScreen({super.key});

  @override
  State<TeacherContentStudioScreen> createState() => _TeacherContentStudioScreenState();
}

class _TeacherContentStudioScreenState extends State<TeacherContentStudioScreen> {
  final LmsSanityService _service = LmsSanityService();
  List<Course> _courses = [];
  final Map<String, Map<String, dynamic>> _courseCurriculum = {};
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    setState(() { _loading = true; _error = null; });
    try {
      final list = await _service.getCourses();
      if (mounted) {
        setState(() {
          _courses = list;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = e.toString(); });
    }
  }

  Future<void> _loadCurriculum(String courseId) async {
    if (_courseCurriculum.containsKey(courseId)) return;
    try {
      final full = await _service.getCourseWithFullCurriculum(courseId);
      if (mounted) setState(() {
        if (full != null) _courseCurriculum[courseId] = full;
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: LMSTheme.surfaceColor,
      appBar: AppBar(
        title: const Text('Content Studio'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/teacher-dashboard'),
        ),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _loadCourses)],
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
                      FilledButton(onPressed: _loadCourses, child: const Text('Retry')),
                    ],
                  ),
                )
              : _courses.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.video_library_outlined, size: 64, color: LMSTheme.mutedForeground),
                          const SizedBox(height: 16),
                          Text('No courses yet', style: theme.textTheme.titleMedium?.copyWith(color: LMSTheme.mutedForeground)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(24),
                      itemCount: _courses.length,
                      itemBuilder: (context, i) {
                        final course = _courses[i];
                        return _CourseTile(
                          courseId: course.id,
                          courseTitle: course.title,
                          curriculum: _courseCurriculum[course.id],
                          loadCurriculum: () => _loadCurriculum(course.id),
                          onOpenEditor: (chapterId, chapterTitle, subjectTitle) {
                            context.push('/content-editor', extra: {
                              'chapterId': chapterId,
                              'chapterTitle': chapterTitle,
                              'subjectTitle': subjectTitle,
                            });
                          },
                        );
                      },
                    ),
    );
  }
}

class _CourseTile extends StatefulWidget {
  final String courseId;
  final String courseTitle;
  final Map<String, dynamic>? curriculum;
  final VoidCallback loadCurriculum;
  final void Function(String chapterId, String chapterTitle, String subjectTitle) onOpenEditor;

  const _CourseTile({
    required this.courseId,
    required this.courseTitle,
    required this.curriculum,
    required this.loadCurriculum,
    required this.onOpenEditor,
  });

  @override
  State<_CourseTile> createState() => _CourseTileState();
}

class _CourseTileState extends State<_CourseTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subjects = (widget.curriculum?['subjects'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(LMSTheme.radiusMd),
        side: const BorderSide(color: LMSTheme.borderColor),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              widget.loadCurriculum();
              setState(() => _expanded = !_expanded);
            },
            borderRadius: BorderRadius.circular(LMSTheme.radiusMd),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(_expanded ? Icons.expand_more : Icons.chevron_right),
                  const SizedBox(width: 8),
                  Icon(Icons.school, color: LMSTheme.primaryColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.courseTitle,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    '${subjects.length} subjects',
                    style: theme.textTheme.bodySmall?.copyWith(color: LMSTheme.mutedForeground),
                  ),
                ],
              ),
            ),
          ),
          if (_expanded && subjects.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 24, right: 16, bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: subjects.map((subj) {
                  final chapters = (subj['chapters'] as List?)?.cast<Map<String, dynamic>>() ?? [];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subj['title'] as String? ?? 'Subject',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: LMSTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      ...chapters.map((ch) {
                        final concepts = (ch['concepts'] as List?) ?? [];
                        return Padding(
                          padding: const EdgeInsets.only(left: 16, top: 8),
                          child: Row(
                            children: [
                              Icon(Icons.article, size: 18, color: LMSTheme.mutedForeground),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  ch['title'] as String? ?? 'Chapter',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                              Text(
                                '${concepts.length} lessons',
                                style: theme.textTheme.labelSmall?.copyWith(color: LMSTheme.mutedForeground),
                              ),
                              const SizedBox(width: 8),
                              FilledButton.tonal(
                                onPressed: () => widget.onOpenEditor(
                                  ch['_id'] as String? ?? '',
                                  ch['title'] as String? ?? 'Chapter',
                                  subj['title'] as String? ?? 'Subject',
                                ),
                                child: const Text('Content Studio'),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 12),
                    ],
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
