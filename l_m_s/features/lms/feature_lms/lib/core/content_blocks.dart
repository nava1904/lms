// filepath: /Users/navadeepreddy/learning mangement system/l_m_s/features/lms/feature_lms/lib/core/content_blocks.dart
import 'package:flutter/material.dart';

/// Base class for all CMS Content Blocks
/// Content blocks are modular UI components that can be configured from Sanity CMS
abstract class ContentBlock {
  /// The Sanity schema type this block handles
  String get schemaType;
  
  /// Build the widget from CMS content
  Widget build(BuildContext context, Map<String, dynamic> content);
}

/// Registry for content blocks
class ContentBlockRegistry {
  static final ContentBlockRegistry _instance = ContentBlockRegistry._internal();
  factory ContentBlockRegistry() => _instance;
  ContentBlockRegistry._internal();
  
  final Map<String, ContentBlock> _blocks = {};
  
  void register(ContentBlock block) {
    _blocks[block.schemaType] = block;
  }
  
  ContentBlock? get(String schemaType) => _blocks[schemaType];
  
  Widget build(BuildContext context, Map<String, dynamic> content) {
    final type = content['_type'] as String?;
    if (type == null) {
      return const SizedBox.shrink();
    }
    
    final block = _blocks[type];
    if (block == null) {
      return _UnknownContentBlock(type: type, content: content);
    }
    
    return block.build(context, content);
  }
}

class _UnknownContentBlock extends StatelessWidget {
  final String type;
  final Map<String, dynamic> content;
  
  const _UnknownContentBlock({required this.type, required this.content});
  
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Unknown content type: $type'),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// LMS CONTENT BLOCKS
// ═══════════════════════════════════════════════════════════════════════════

/// Course Card Block
class CourseCardBlock extends ContentBlock {
  @override
  String get schemaType => 'course';
  
  @override
  Widget build(BuildContext context, Map<String, dynamic> content) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            color: Colors.blue[100],
            child: Center(
              child: Icon(Icons.book, size: 48, color: Colors.blue[700]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  content['title'] ?? 'Untitled Course',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  content['description'] ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Chip(
                      label: Text(content['level'] ?? 'beginner'),
                      backgroundColor: Colors.blue[50],
                    ),
                    const Spacer(),
                    Text('${content['subjectCount'] ?? 0} subjects'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Subject Card Block
class SubjectCardBlock extends ContentBlock {
  @override
  String get schemaType => 'subject';
  
  @override
  Widget build(BuildContext context, Map<String, dynamic> content) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green[100],
          child: Icon(Icons.subject, color: Colors.green[700]),
        ),
        title: Text(content['title'] ?? 'Untitled Subject'),
        subtitle: Text('${content['chapterCount'] ?? 0} chapters'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

/// Chapter Card Block
class ChapterCardBlock extends ContentBlock {
  @override
  String get schemaType => 'chapter';
  
  @override
  Widget build(BuildContext context, Map<String, dynamic> content) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.orange[100],
          child: Icon(Icons.article, color: Colors.orange[700]),
        ),
        title: Text(content['title'] ?? 'Untitled Chapter'),
        subtitle: Text('${content['conceptCount'] ?? 0} lessons'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

/// Lesson/Concept Block
class LessonBlock extends ContentBlock {
  @override
  String get schemaType => 'concept';
  
  @override
  Widget build(BuildContext context, Map<String, dynamic> content) {
    final hasVideo = content['videoUrl'] != null;
    
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasVideo)
            Container(
              height: 200,
              color: Colors.grey[200],
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_circle, size: 64, color: Colors.indigo[400]),
                    const SizedBox(height: 8),
                    const Text('Video Lesson'),
                  ],
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  content['title'] ?? 'Untitled Lesson',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (content['duration'] != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.timer, size: 16),
                      const SizedBox(width: 4),
                      Text('${content['duration']} min'),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Test Card Block
class TestCardBlock extends ContentBlock {
  @override
  String get schemaType => 'test';
  
  @override
  Widget build(BuildContext context, Map<String, dynamic> content) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.quiz, color: Colors.purple[700]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    content['title'] ?? 'Untitled Test',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                if (content['isPublished'] == true)
                  Chip(label: const Text('Live'), backgroundColor: Colors.green[100]),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              children: [
                _InfoChip(icon: Icons.timer, text: '${content['duration'] ?? 0} min'),
                _InfoChip(icon: Icons.score, text: '${content['totalMarks'] ?? 0} marks'),
                _InfoChip(icon: Icons.quiz, text: '${content['questionCount'] ?? 0} questions'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  
  const _InfoChip({required this.icon, required this.text});
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}

/// Question Block
class QuestionBlock extends ContentBlock {
  @override
  String get schemaType => 'question';
  
  @override
  Widget build(BuildContext context, Map<String, dynamic> content) {
    final options = content['options'] as List? ?? [];
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              content['questionText'] ?? 'Question',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            ...options.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value.toString();
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.grey[200],
                      child: Text(String.fromCharCode(65 + index)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(option)),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

/// Student Profile Block
class StudentProfileBlock extends ContentBlock {
  @override
  String get schemaType => 'student';
  
  @override
  Widget build(BuildContext context, Map<String, dynamic> content) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Text(
            (content['name'] ?? 'S').substring(0, 1).toUpperCase(),
            style: TextStyle(color: Colors.blue[700]),
          ),
        ),
        title: Text(content['name'] ?? 'Unknown Student'),
        subtitle: Text('${content['email'] ?? ''} • Roll: ${content['rollNumber'] ?? 'N/A'}'),
        trailing: Chip(
          label: Text(content['isActive'] == true ? 'Active' : 'Inactive'),
          backgroundColor: content['isActive'] == true ? Colors.green[100] : Colors.grey[300],
        ),
      ),
    );
  }
}

/// Teacher Profile Block
class TeacherProfileBlock extends ContentBlock {
  @override
  String get schemaType => 'teacher';
  
  @override
  Widget build(BuildContext context, Map<String, dynamic> content) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.teal[100],
          child: Text(
            (content['name'] ?? 'T').substring(0, 1).toUpperCase(),
            style: TextStyle(color: Colors.teal[700]),
          ),
        ),
        title: Text(content['name'] ?? 'Unknown Teacher'),
        subtitle: Text('${content['specialization'] ?? 'General'} • ${content['email'] ?? ''}'),
      ),
    );
  }
}

/// Initialize all content blocks
void registerContentBlocks() {
  final registry = ContentBlockRegistry();
  registry.register(CourseCardBlock());
  registry.register(SubjectCardBlock());
  registry.register(ChapterCardBlock());
  registry.register(LessonBlock());
  registry.register(TestCardBlock());
  registry.register(QuestionBlock());
  registry.register(StudentProfileBlock());
  registry.register(TeacherProfileBlock());
}
