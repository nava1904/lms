import 'package:flutter/material.dart';
import '../sanity_client_helper.dart';

class ContentScreen extends StatefulWidget {
  final Map<String, dynamic> subject;
  const ContentScreen({super.key, required this.subject});

  @override
  State<ContentScreen> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  List<dynamic>? _chapters;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadChapters();
  }

  Future<void> _loadChapters() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final client = createLmsClient();
      final chapterIds = widget.subject['chapters'] as List<dynamic>?;
      if (chapterIds == null || chapterIds.isEmpty) {
        setState(() {
          _chapters = [];
          _loading = false;
        });
        return;
      }
      // Fetch chapters by IDs
      final res = await client.fetch('''
        *[_type == "chapter" && _id in ${chapterIds.map((c) => '"${c['_id']}"').toList()}] {
          _id,
          conceptGraphs,
          theory,
          videos,
          practiceSheets
        }
      ''');
      if (mounted) {
        setState(() {
          _chapters = res.result as List<dynamic>?;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subject = widget.subject;
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text(subject['title'] ?? 'Content')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text(subject['title'] ?? 'Content')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline_rounded, size: 48, color: theme.colorScheme.error),
                const SizedBox(height: 16),
                Text('Could not load chapters', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(_error!, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error)),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _loadChapters,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    final chapters = _chapters ?? [];
    return Scaffold(
      appBar: AppBar(title: Text(subject['title'] ?? 'Content')),
      body: RefreshIndicator(
        onRefresh: _loadChapters,
        child: chapters.isEmpty
            ? ListView(
                children: [
                  const SizedBox(height: 48),
                  Icon(Icons.menu_book_rounded, size: 64, color: theme.colorScheme.outline),
                  const SizedBox(height: 16),
                  Text('No chapters yet', style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text('Add chapters in Sanity Studio to see them here.',
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        textAlign: TextAlign.center),
                  ),
                ],
              )
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: chapters.length,
                itemBuilder: (context, index) {
                  final c = chapters[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Chapter ${index + 1}', style: theme.textTheme.labelLarge),
                          const SizedBox(height: 8),
                          if (c['conceptGraphs'] != null && (c['conceptGraphs'] as List).isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Concept Graphs:', style: theme.textTheme.bodyMedium),
                                const SizedBox(height: 8),
                                ...((c['conceptGraphs'] as List).map((img) => Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Image.network('https://cdn.sanity.io/images/YOUR_PROJECT_ID/production/${img['asset']['_ref']}', height: 120, fit: BoxFit.cover),
                                    ))),
                              ],
                            ),
                          if (c['theory'] != null && (c['theory'] as String).isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text('Theory:', style: theme.textTheme.bodyMedium),
                            const SizedBox(height: 4),
                            Text(c['theory'], style: theme.textTheme.bodySmall),
                          ],
                          if (c['videos'] != null && (c['videos'] as List).isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text('Videos:', style: theme.textTheme.bodyMedium),
                            const SizedBox(height: 4),
                            ...((c['videos'] as List).map((url) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(url, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary)),
                                ))),
                          ],
                          if (c['practiceSheets'] != null && (c['practiceSheets'] as List).isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text('Practice Sheets:', style: theme.textTheme.bodyMedium),
                            const SizedBox(height: 4),
                            ...((c['practiceSheets'] as List).map((file) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(file['asset']['_ref'], style: theme.textTheme.bodySmall),
                                ))),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
