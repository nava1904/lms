import 'package:flutter/material.dart';

class CourseCurriculumWidget extends StatefulWidget {
  final List<Map<String, dynamic>> chapters;
  final Function(String chapterId, String conceptId) onConceptTap;
  final String? enrolledCourseId;

  const CourseCurriculumWidget({
    super.key,
    required this.chapters,
    required this.onConceptTap,
    this.enrolledCourseId,
  });

  @override
  State<CourseCurriculumWidget> createState() => _CourseCurriculumWidgetState();
}

class _CourseCurriculumWidgetState extends State<CourseCurriculumWidget> {
  late Map<int, bool> expandedStates;

  @override
  void initState() {
    super.initState();
    expandedStates = {for (var i = 0; i < widget.chapters.length; i++) i: i == 0};
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
          ...widget.chapters.asMap().entries.map((entry) {
            final index = entry.key;
            final chapter = entry.value;
            final isExpanded = expandedStates[index] ?? false;
            final isLocked = widget.enrolledCourseId == null && !(chapter['isFreePreview'] as bool? ?? false);

            return ExpansionTile(
              initiallyExpanded: isExpanded,
              onExpansionChanged: (expanded) {
                setState(() => expandedStates[index] = expanded);
              },
              title: Row(
                children: [
                  Icon(
                    isLocked ? Icons.lock : Icons.play_circle_outline,
                    size: 18,
                    color: isLocked ? Colors.red : Colors.blue,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chapter['title'] ?? 'Chapter ${index + 1}',
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        if (chapter['duration'] != null)
                          Text(
                            chapter['duration'],
                            style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey[600]),
                          ),
                      ],
                    ),
                  ),
                  if (isLocked)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
              children: [
                if (chapter['concepts'] != null)
                  ...(chapter['concepts'] as List).map((concept) {
                    return ListTile(
                      contentPadding: const EdgeInsets.only(left: 48, right: 16, top: 8, bottom: 8),
                      leading: Icon(
                        Icons.video_library_outlined,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      title: Text(
                        concept['title'] ?? 'Concept',
                        style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        concept['duration'] ?? '5 min',
                        style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey[600]),
                      ),
                      trailing: isLocked
                          ? const Icon(Icons.lock, size: 16, color: Colors.red)
                          : const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                      onTap: () {
                        if (!isLocked) {
                          widget.onConceptTap(chapter['_id'] ?? '', concept['_id'] ?? '');
                        }
                      },
                    );
                  }),
              ],
            );
          }),
        ],
      ),
    );
  }
}
