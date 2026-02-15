import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../sanity_client_helper.dart';
import 'content_editor_screen.dart';

class ChapterManagementScreen extends StatefulWidget {
  final String subjectId;
  final String subjectTitle;

  const ChapterManagementScreen({
    super.key,
    required this.subjectId,
    required this.subjectTitle,
  });

  @override
  State<ChapterManagementScreen> createState() => _ChapterManagementScreenState();
}

class _ChapterManagementScreenState extends State<ChapterManagementScreen> {
  List<dynamic> _chapters = [];
  bool _loading = true;
  final _chapterNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadChapters();
  }

  Future<void> _loadChapters() async {
    try {
      final client = createLmsClient();
      final res = await client.fetch('''*[_type == "chapter" && subject._ref == "${ widget.subjectId}"]{_id, title}''');
      setState(() {
        _chapters = res.result as List<dynamic>? ?? [];
        _loading = false;
      });
    } catch (e) {
      setState(() { _loading = false; });
    }
  }

  Future<void> _createChapter() async {
    if (_chapterNameController.text.isEmpty) return;
    
    try {
      const projectId = 'w18438cu';
      const dataset = 'production';
      final token = dotenv.env['SANITY_TOKEN'] ?? '';
      final url = Uri.https('$projectId.api.sanity.io', '/v2023-05-30/data/mutate/$dataset');
      
      final body = jsonEncode({
        'mutations': [
          {
            'create': {
              '_type': 'chapter',
              'title': _chapterNameController.text,
              'subject': {'_type': 'reference', '_ref': widget.subjectId},
            }
          }
        ]
      });

      final headers = {
        'Content-Type': 'application/json',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      final response = await http.post(url, body: body, headers: headers);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newChapter = data['results'][0]['document'];
        setState(() {
          _chapters.add(newChapter);
        });
        _chapterNameController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chapter added successfully!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  void dispose() {
    _chapterNameController.dispose();
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
        title: Text(
          'Chapters - ${widget.subjectTitle}',
          style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w600),
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
                Card(
                  elevation: 0,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextField(
                          controller: _chapterNameController,
                          decoration: InputDecoration(
                            hintText: 'Chapter name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _createChapter,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Chapter'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (_chapters.isEmpty)
                  Card(
                    elevation: 0,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          'No chapters yet',
                          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                        ),
                      ),
                    ),
                  )
                else
                  ..._chapters.asMap().entries.map((entry) {
                    final chapter = entry.value;
                    return Card(
                      elevation: 0,
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(Icons.book, color: theme.colorScheme.primary),
                        title: Text(chapter['title'] ?? 'Chapter'),
                        trailing: IconButton(
                          icon: const Icon(Icons.arrow_forward_ios, size: 16),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ContentEditorScreen(
                                  chapterId: chapter['_id'] ?? '',
                                  chapterTitle: chapter['title'] ?? 'Chapter',
                                  subjectTitle: widget.subjectTitle,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }),
              ],
            ),
    );
  }
}
