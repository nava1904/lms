import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/lms_sanity_service.dart';
import '../theme/lms_theme.dart';
import '../utils/error_utils.dart';
import '../widgets/course_curriculum_widget.dart';
import '../widgets/empty_state_widget.dart';

/// Shows course curriculum (subjects -> chapters -> concepts) from Sanity.
/// Pass courseId via route extra; optionally subjectId, chapterId for deep link.
class ContentScreen extends StatefulWidget {
  final String? courseId;
  final String? subjectId;
  final String? chapterId;

  const ContentScreen({
    super.key,
    this.courseId,
    this.subjectId,
    this.chapterId,
  });

  @override
  State<ContentScreen> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  final LmsSanityService _service = LmsSanityService();
  Map<String, dynamic>? _course;
  List<Map<String, dynamic>> _subjects = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.courseId != null && widget.courseId!.isNotEmpty) {
      _load();
    } else {
      setState(() => _loading = false);
    }
  }

  Future<void> _load() async {
    final courseId = widget.courseId;
    if (courseId == null || courseId.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final full = await _service.getCourseWithFullCurriculum(courseId);
      if (mounted) {
        final subjects = _normalizeSubjects((full?['subjects'] as List?)?.cast<Map<String, dynamic>>() ?? []);
        setState(() {
          _course = full;
          _subjects = subjects;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        final msg = userFriendlyError(e);
        setState(() {
          _error = msg;
          _loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: LMSTheme.errorColor),
        );
      }
    }
  }


  List<Map<String, dynamic>> _normalizeSubjects(List<Map<String, dynamic>> raw) {
    return raw.map((subj) {
      final chaptersRaw = subj['chapters'] as List? ?? [];
      final chapters = chaptersRaw.map((ch) {
        final chMap = ch is Map ? Map<String, dynamic>.from(ch as Map) : <String, dynamic>{};
        final concepts = chMap['concepts'] as List? ?? [];
        return {
          '_id': chMap['_id'],
          'title': chMap['title'] ?? 'Chapter',
          'order': chMap['order'],
          'duration': chMap['duration'] != null ? '${chMap['duration']} min' : null,
          'concepts': concepts.map((c) {
            final cm = c is Map ? Map<String, dynamic>.from(c as Map) : <String, dynamic>{};
            final d = cm['duration'];
            return {
              '_id': cm['_id'],
              'title': cm['title'] ?? 'Lesson',
              'duration': d != null ? '$d min' : '5 min',
            };
          }).toList(),
        };
      }).toList();
      return {
        '_id': subj['_id'],
        'title': subj['title'] ?? 'Subject',
        'order': subj['order'],
        'chapters': chapters,
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.courseId == null || widget.courseId!.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Content')),
        body: const Center(child: Text('No course selected')),
      );
    }
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Content')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Content')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_error!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(onPressed: _load, child: const Text('Retry')),
              ],
            ),
          ),
        ),
      );
    }
    final courseTitle = _course?['title'] as String? ?? 'Course';
    return Scaffold(
      backgroundColor: LMSTheme.surfaceColor,
      appBar: AppBar(
        title: Text(courseTitle),
        backgroundColor: Colors.white,
        foregroundColor: LMSTheme.onSurfaceColor,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: _subjects.isEmpty
          ? EmptyStateWidget(
              icon: Icons.menu_book_outlined,
              title: 'No content yet',
              subtitle: 'This course has no subjects or chapters. Check back later.',
              ctaLabel: 'Refresh',
              onCtaPressed: _load,
            )
          : CourseCurriculumWidget(
              subjects: _subjects,
              enrolledCourseId: widget.courseId,
              onConceptTap: _onConceptTap,
            ),
    );
  }

  void _onConceptTap(String? chapterId, String conceptId) {
    // Could push a concept/lesson viewer; for now show a snackbar and optional dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening concept $conceptId'),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }
}
