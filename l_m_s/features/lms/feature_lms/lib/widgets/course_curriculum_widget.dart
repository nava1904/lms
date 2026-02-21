import 'package:flutter/material.dart';

/// Shows course content as Subject → Chapter → Lesson with expandable dropdowns (NTA-style hierarchy).
class CourseCurriculumWidget extends StatefulWidget {
  /// Subjects, each with "chapters" (list of maps with "concepts").
  final List<Map<String, dynamic>> subjects;
  final void Function(String? chapterId, String conceptId) onConceptTap;
  final String? enrolledCourseId;

  const CourseCurriculumWidget({
    super.key,
    required this.subjects,
    required this.onConceptTap,
    this.enrolledCourseId,
  });

  @override
  State<CourseCurriculumWidget> createState() => _CourseCurriculumWidgetState();
}

class _CourseCurriculumWidgetState extends State<CourseCurriculumWidget> {
  /// Key: "s$si" or "s${si}c$ci" for subject/chapter expansion.
  final Map<String, bool> _expanded = {};

  @override
  void initState() {
    super.initState();
    if (widget.subjects.isNotEmpty) {
      _expanded['s0'] = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Course Content',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          ...widget.subjects.asMap().entries.map((subjectEntry) {
            final si = subjectEntry.key;
            final subject = subjectEntry.value;
            final subjectTitle = subject['title'] as String? ?? 'Subject ${si + 1}';
            final chapters = subject['chapters'] as List? ?? [];
            final sk = 's$si';
            final isSubjectExpanded = _expanded[sk] ?? (si == 0);

            return ExpansionTile(
              key: ValueKey('subject-$si'),
              initiallyExpanded: isSubjectExpanded,
              onExpansionChanged: (expanded) {
                setState(() => _expanded[sk] = expanded);
              },
              controlAffinity: ListTileControlAffinity.leading,
              leading: Icon(
                isSubjectExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                size: 28,
                color: theme.colorScheme.primary,
              ),
              title: Row(
                children: [
                  Icon(Icons.subject_outlined, size: 22, color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      subjectTitle,
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  if (chapters.isNotEmpty)
                    Text(
                      '${chapters.length} chapter${chapters.length == 1 ? '' : 's'}',
                      style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey[600]),
                    ),
                ],
              ),
              children: chapters.isEmpty
                  ? [
                      Padding(
                        padding: const EdgeInsets.only(left: 48, right: 16, bottom: 12),
                        child: Text(
                          'No chapters yet',
                          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                        ),
                      ),
                    ]
                  : chapters.asMap().entries.map((chapterEntry) {
                      final ci = chapterEntry.key;
                      final chapter = chapterEntry.value;
                      final chapterTitle = chapter['title'] as String? ?? 'Chapter ${ci + 1}';
                      final concepts = chapter['concepts'] as List? ?? [];
                      final ck = 's${si}c$ci';
                      final isChapterExpanded = _expanded[ck] ?? (si == 0 && ci == 0);
                      final isLocked = widget.enrolledCourseId == null &&
                          !(chapter['isFreePreview'] as bool? ?? false);

                      return ExpansionTile(
                        key: ValueKey('chapter-$si-$ci'),
                        initiallyExpanded: isChapterExpanded,
                        onExpansionChanged: (expanded) {
                          setState(() => _expanded[ck] = expanded);
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        leading: Icon(
                          isChapterExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                          size: 24,
                          color: Colors.grey[700],
                        ),
                        title: Row(
                          children: [
                            Icon(
                              isLocked ? Icons.lock : Icons.play_circle_outline,
                              size: 18,
                              color: isLocked ? Colors.red : Colors.blue,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    chapterTitle,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (chapter['duration'] != null)
                                    Text(
                                      chapter['duration'].toString(),
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (isLocked)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Locked',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        children: concepts.isEmpty
                            ? [
                                Padding(
                                  padding: const EdgeInsets.only(left: 72, right: 16, bottom: 8),
                                  child: Text(
                                    'No lessons yet',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ]
                            : concepts.map((concept) {
                                final conceptMap = concept is Map
                                    ? Map<String, dynamic>.from(concept as Map)
                                    : <String, dynamic>{};
                                final conceptId = conceptMap['_id'] as String? ?? '';
                                final conceptTitle =
                                    conceptMap['title'] as String? ?? 'Lesson';
                                final duration =
                                    conceptMap['duration'] as String? ?? '5 min';
                                return ListTile(
                                  contentPadding: const EdgeInsets.only(
                                    left: 72,
                                    right: 16,
                                    top: 4,
                                    bottom: 4,
                                  ),
                                  leading: Icon(
                                    Icons.video_library_outlined,
                                    size: 18,
                                    color: Colors.grey[600],
                                  ),
                                  title: Text(
                                    conceptTitle,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: Text(
                                    duration,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  trailing: isLocked
                                      ? const Icon(Icons.lock, size: 16, color: Colors.red)
                                      : const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
                                  onTap: () {
                                    if (!isLocked) {
                                      widget.onConceptTap(
                                        chapter['_id'] as String?,
                                        conceptId,
                                      );
                                    }
                                  },
                                );
                              }).toList(),
                      );
                    }).toList(),
            );
          }),
        ],
      ),
    );
  }
}
