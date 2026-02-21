// filepath: /Users/navadeepreddy/learning mangement system/l_m_s/features/lms/feature_lms/lib/blocks/block_base.dart

import 'package:flutter/material.dart';

/// Base class for all content blocks following Vyuh patterns
/// Content blocks are modular UI components that can be composed
abstract class ContentBlock {
  /// Unique block type identifier
  String get blockType;
  
  /// Build the widget for this block
  Widget build(BuildContext context);
  
  /// Create from JSON data
  factory ContentBlock.fromJson(Map<String, dynamic> json) {
    final type = json['_type'] ?? json['blockType'] ?? 'unknown';
    
    switch (type) {
      case 'videoBlock':
        return VideoBlock.fromJson(json);
      case 'textBlock':
        return TextBlock.fromJson(json);
      case 'quizBlock':
        return QuizBlock.fromJson(json);
      case 'imageBlock':
        return ImageBlock.fromJson(json);
      case 'codeBlock':
        return CodeBlock.fromJson(json);
      default:
        return UnknownBlock(type: type);
    }
  }
}

/// Registry for content block builders
class BlockRegistry {
  static final BlockRegistry _instance = BlockRegistry._internal();
  factory BlockRegistry() => _instance;
  BlockRegistry._internal();

  final Map<String, ContentBlock Function(Map<String, dynamic>)> _builders = {};

  /// Register a block builder
  void register(String type, ContentBlock Function(Map<String, dynamic>) builder) {
    _builders[type] = builder;
  }

  /// Build a block from JSON
  ContentBlock? build(Map<String, dynamic> json) {
    final type = json['_type'] ?? json['blockType'];
    final builder = _builders[type];
    return builder?.call(json);
  }
}

/// Video content block
class VideoBlock implements ContentBlock {
  final String? title;
  final String videoUrl;
  final int? duration;

  const VideoBlock({
    this.title,
    required this.videoUrl,
    this.duration,
  });

  factory VideoBlock.fromJson(Map<String, dynamic> json) {
    return VideoBlock(
      title: json['title'],
      videoUrl: json['videoUrl'] ?? json['url'] ?? '',
      duration: json['duration'],
    );
  }

  @override
  String get blockType => 'videoBlock';

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 200,
            color: Colors.grey[300],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.play_circle_filled, size: 64, color: Colors.red),
                  const SizedBox(height: 8),
                  if (title != null) Text(title!, style: Theme.of(context).textTheme.titleMedium),
                  if (duration != null) Text('$duration minutes'),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(videoUrl, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}

/// Text content block
class TextBlock implements ContentBlock {
  final String content;
  final String? style;

  const TextBlock({
    required this.content,
    this.style,
  });

  factory TextBlock.fromJson(Map<String, dynamic> json) {
    return TextBlock(
      content: json['content'] ?? json['text'] ?? '',
      style: json['style'],
    );
  }

  @override
  String get blockType => 'textBlock';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        content,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}

/// Quiz content block
class QuizBlock implements ContentBlock {
  final String question;
  final List<String> options;
  final int correctIndex;

  const QuizBlock({
    required this.question,
    required this.options,
    required this.correctIndex,
  });

  factory QuizBlock.fromJson(Map<String, dynamic> json) {
    return QuizBlock(
      question: json['question'] ?? '',
      options: (json['options'] as List?)?.cast<String>() ?? [],
      correctIndex: json['correctIndex'] ?? 0,
    );
  }

  @override
  String get blockType => 'quizBlock';

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.quiz, color: Colors.blue),
                const SizedBox(width: 8),
                const Text('Quick Quiz', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Text(question, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            ...options.asMap().entries.map((entry) => RadioListTile<int>(
              title: Text(entry.value),
              value: entry.key,
              groupValue: null,
              onChanged: (value) {},
            )),
          ],
        ),
      ),
    );
  }
}

/// Image content block
class ImageBlock implements ContentBlock {
  final String imageUrl;
  final String? caption;
  final String? alt;

  const ImageBlock({
    required this.imageUrl,
    this.caption,
    this.alt,
  });

  factory ImageBlock.fromJson(Map<String, dynamic> json) {
    return ImageBlock(
      imageUrl: json['asset']?['url'] ?? json['imageUrl'] ?? json['url'] ?? '',
      caption: json['caption'],
      alt: json['alt'],
    );
  }

  @override
  String get blockType => 'imageBlock';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (imageUrl.isNotEmpty)
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              height: 200,
              color: Colors.grey[300],
              child: const Icon(Icons.broken_image, size: 48),
            ),
          )
        else
          Container(
            height: 200,
            color: Colors.grey[300],
            child: const Icon(Icons.image, size: 48),
          ),
        if (caption != null)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(caption!, style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
          ),
      ],
    );
  }
}

/// Code content block
class CodeBlock implements ContentBlock {
  final String code;
  final String language;

  const CodeBlock({
    required this.code,
    this.language = 'text',
  });

  factory CodeBlock.fromJson(Map<String, dynamic> json) {
    return CodeBlock(
      code: json['code'] ?? '',
      language: json['language'] ?? 'text',
    );
  }

  @override
  String get blockType => 'codeBlock';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(language.toUpperCase(), style: TextStyle(color: Colors.grey[400], fontSize: 10)),
          const SizedBox(height: 8),
          Text(
            code,
            style: const TextStyle(fontFamily: 'monospace', color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

/// Unknown block placeholder
class UnknownBlock implements ContentBlock {
  final String type;

  const UnknownBlock({required this.type});

  @override
  String get blockType => 'unknown';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.yellow[100],
      child: Text('Unknown block type: $type'),
    );
  }
}
