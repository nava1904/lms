import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../sanity_client_helper.dart';
import '../theme/lms_theme.dart';

class ContentEditorScreen extends StatefulWidget {
  final String chapterId;
  final String chapterTitle;
  final String subjectTitle;

  const ContentEditorScreen({
    super.key,
    required this.chapterId,
    required this.chapterTitle,
    required this.subjectTitle,
  });

  @override
  State<ContentEditorScreen> createState() => _ContentEditorScreenState();
}

class _ContentEditorScreenState extends State<ContentEditorScreen> {
  final _contentTitleController = TextEditingController();
  final _contentBodyController = TextEditingController();
  final _videoUrlController = TextEditingController();
  List<dynamic> _contents = [];
  bool _loading = true;
  String? _videoUrlError;

  @override
  void initState() {
    super.initState();
    _loadContents();
  }

  Future<void> _loadContents() async {
    if (widget.chapterId.isEmpty) {
      setState(() => _loading = false);
      return;
    }
    try {
      final client = createLmsClient();
      final res = await client.fetch(
        r'''*[_type == "concept" && chapter._ref == $chapterId]{ _id, title, content, videoUrl }''',
        params: {'chapterId': widget.chapterId},
      );
      final result = res is dynamic && res.result != null ? res.result : res;
      setState(() {
        _contents = result is List ? List.from(result) : [];
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error loading contents: $e');
      setState(() { _loading = false; });
    }
  }

  /// Generate URL-safe slug from title (required by concept schema).
  static String _slugFromTitle(String title) {
    if (title.isEmpty) return 'untitled';
    final slug = title
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'[\s_]+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .trim();
    return slug.isEmpty ? 'untitled' : slug;
  }

  /// Extract plain text from Sanity portable text (content array of blocks).
  String _contentToText(dynamic content) {
    if (content == null) return '';
    if (content is String) return content;
    if (content is! List || content.isEmpty) return '';
    final first = content.first;
    if (first is! Map) return '';
    final children = first['children'];
    if (children is! List) return '';
    final buf = StringBuffer();
    for (final c in children) {
      if (c is Map && c['text'] != null) buf.write(c['text']);
    }
    return buf.toString();
  }

  Future<void> _createContent() async {
    if (_contentTitleController.text.isEmpty || _contentBodyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and content are required')),
      );
      return;
    }
    final videoUrl = _videoUrlController.text.trim();
    if (videoUrl.isNotEmpty) {
      final uri = Uri.tryParse(videoUrl);
      if (uri == null || !uri.hasScheme) {
        setState(() => _videoUrlError = 'Enter a valid URL (e.g. https://...)');
        return;
      }
    }
    setState(() => _videoUrlError = null);

    if (widget.chapterId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chapter ID is missing')),
      );
      return;
    }

    try {
      const projectId = 'w18438cu';
      const dataset = 'production';
      final token = dotenv.env['SANITY_API_TOKEN'] ?? dotenv.env['SANITY_TOKEN'];
      
      if (token == null || token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sanity token not configured')),
        );
        return;
      }

      final url = Uri.https('$projectId.api.sanity.io', '/v2023-05-30/data/mutate/$dataset');
      
      final title = _contentTitleController.text;
      final slug = _slugFromTitle(title);
      final text = _contentBodyController.text;
      final content = text.isEmpty
          ? <Map<String, dynamic>>[]
          : [
              {
                '_type': 'block',
                'children': [
                  {'_type': 'span', 'text': text, 'marks': []}
                ],
              }
            ];
      final body = jsonEncode({
        'mutations': [
          {
            'create': {
              '_type': 'concept',
              'title': title,
              'slug': {'_type': 'slug', 'current': slug},
              'content': content,
              if (_videoUrlController.text.isNotEmpty) 'videoUrl': _videoUrlController.text,
              'chapter': {'_type': 'reference', '_ref': widget.chapterId},
            }
          }
        ]
      });

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http.post(url, body: body, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('Concept create response: ${response.statusCode}');
        if (data['results'] != null && data['results'].isNotEmpty) {
          final result = data['results'][0];
          final newContent = result['document'] ?? result;
          
          if (mounted) {
            setState(() {
              _contents.add(newContent);
            });
            _contentTitleController.clear();
            _contentBodyController.clear();
            _videoUrlController.clear();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Content added successfully!'),
                backgroundColor: LMSTheme.successColor,
              ),
            );
            // Reload contents from Sanity
            _loadContents();
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Content created but response is empty')),
            );
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      debugPrint('Exception: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _deleteContent(Map<String, dynamic> content) async {
    final id = content['_id'] as String?;
    if (id == null || id.isEmpty) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete content?'),
        content: Text(
          'Remove "${content['title'] ?? 'Untitled'}"? This cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    try {
      final token = dotenv.env['SANITY_API_TOKEN'] ?? dotenv.env['SANITY_TOKEN'];
      if (token == null || token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sanity token not configured')),
        );
        return;
      }
      const projectId = 'w18438cu';
      const dataset = 'production';
      final url = Uri.https(
        '$projectId.api.sanity.io',
        '/v2023-05-30/data/mutate/$dataset',
      );
      final body = jsonEncode({
        'mutations': [
          {'delete': {'id': id}},
        ],
      });
      final response = await http.post(
        url,
        body: body,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (mounted) {
        if (response.statusCode == 200) {
          setState(() => _contents.removeWhere((c) => c is Map && c['_id'] == id));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Content deleted')),
          );
          _loadContents();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Delete failed: ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      debugPrint('Delete error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _contentTitleController.dispose();
    _contentBodyController.dispose();
    _videoUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.subjectTitle,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              widget.chapterTitle,
              style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.grey),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Content Creation Form
                Card(
                  elevation: 0,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Add Content', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _contentTitleController,
                          decoration: InputDecoration(
                            hintText: 'Content title',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _contentBodyController,
                          decoration: InputDecoration(
                            hintText: 'Content body (supports markdown)',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          maxLines: 5,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _videoUrlController,
                          decoration: InputDecoration(
                            hintText: 'Video URL (YouTube, Vimeo, etc.)',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            errorText: _videoUrlError,
                          ),
                          keyboardType: TextInputType.url,
                          onChanged: (_) => setState(() => _videoUrlError = null),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: _createContent,
                              icon: const Icon(Icons.add),
                              label: const Text('Add Content'),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton.icon(
                              onPressed: null,
                              icon: const Icon(Icons.image),
                              label: const Text('Upload Image (Soon)'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Content List
                Text('Contents', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                if (_contents.isEmpty)
                  Card(
                    elevation: 0,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          'No content yet',
                          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                        ),
                      ),
                    ),
                  )
                else
                  ..._contents.map((content) {
                    return Card(
                      elevation: 0,
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    content is Map ? (content['title'] ?? 'Untitled') : 'Content',
                                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, size: 18),
                                  onPressed: () => _deleteContent(
                                    content is Map ? Map<String, dynamic>.from(content) : <String, dynamic>{},
                                  ),
                                ),
                              ],
                            ),
                            if (content is Map) ...[
                              const SizedBox(height: 8),
                              Text(
                                _contentToText(content['content']),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                            if (content is Map && content['videoUrl'] != null) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.video_library, size: 16, color: theme.colorScheme.primary),
                                  const SizedBox(width: 8),
                                  Text('Video included', style: theme.textTheme.labelSmall),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }),
              ],
            ),
    );
  }
}
