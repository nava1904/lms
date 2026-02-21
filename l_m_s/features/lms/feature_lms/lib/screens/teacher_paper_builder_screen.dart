import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/lms_theme.dart';
import '../services/sanity_service.dart';

/// Paper Builder: left question bank, center selected questions (reorder/remove), right settings, preview, publish.
class TeacherPaperBuilderScreen extends StatefulWidget {
  const TeacherPaperBuilderScreen({super.key});

  @override
  State<TeacherPaperBuilderScreen> createState() => _TeacherPaperBuilderScreenState();
}

class _TeacherPaperBuilderScreenState extends State<TeacherPaperBuilderScreen> {
  final SanityService _sanity = SanityService();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<Map<String, dynamic>> _allQuestions = [];
  final List<Map<String, dynamic>> _selectedQuestions = [];
  bool _loading = true;
  int _durationMinutes = 60;
  int _passingMarks = 40;
  bool _shuffleQuestions = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    setState(() => _loading = true);
    try {
      final list = await _sanity.fetchQuestions();
      if (mounted) setState(() { _allQuestions = list; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = e.toString(); });
    }
  }

  int get _totalMarks => _selectedQuestions.fold<int>(
        0,
        (sum, q) => sum + ((q['marks'] as num?)?.toInt() ?? 1),
      );

  void _addToPaper(Map<String, dynamic> q) {
    setState(() => _selectedQuestions.add(Map<String, dynamic>.from(q)));
  }

  void _removeFromPaper(int index) {
    setState(() => _selectedQuestions.removeAt(index));
  }

  void _moveUp(int index) {
    if (index <= 0) return;
    setState(() {
      final q = _selectedQuestions.removeAt(index);
      _selectedQuestions.insert(index - 1, q);
    });
  }

  void _moveDown(int index) {
    if (index >= _selectedQuestions.length - 1) return;
    setState(() {
      final q = _selectedQuestions.removeAt(index);
      _selectedQuestions.insert(index + 1, q);
    });
  }

  Future<void> _publish() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter paper title')),
      );
      return;
    }
    if (_selectedQuestions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one question')),
      );
      return;
    }
    setState(() => _error = null);
    try {
      final totalMarks = _totalMarks;
      final test = await _sanity.createTest(
        title: title,
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        duration: _durationMinutes,
        totalMarks: totalMarks,
        passingMarks: (_passingMarks / 100 * totalMarks).round().clamp(0, totalMarks),
        isPublished: true,
      );
      if (test == null) throw Exception('Failed to create test');
      final testId = test['documentId'] as String? ?? test['_id'] as String? ?? '';
      if (testId.isEmpty) throw Exception('No test ID returned');
      for (final q in _selectedQuestions) {
        final id = q['_id'] as String?;
        if (id != null) await _sanity.addQuestionToTest(testId, id);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Paper published')));
        context.go('/teacher-dashboard');
      }
    } catch (e) {
      setState(() => _error = e.toString());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Publish failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: LMSTheme.surfaceColor,
      appBar: AppBar(
        title: const Text('Paper Builder'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/teacher-dashboard'),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: LMSTheme.primaryColor))
          : Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 320,
                  child: Card(
                    margin: const EdgeInsets.all(16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(LMSTheme.radiusMd),
                      side: const BorderSide(color: LMSTheme.borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Question Bank',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Expanded(
                          child: _allQuestions.isEmpty
                              ? const Center(child: Text('No questions. Add from Question Bank.'))
                              : ListView.builder(
                                  itemCount: _allQuestions.length,
                                  itemBuilder: (context, index) {
                                    final q = _allQuestions[index];
                                    final text = q['questionText'] as String? ?? '';
                                    final marks = q['marks'] as num? ?? 1;
                                    return ListTile(
                                      title: Text(
                                        text.length > 60 ? '${text.substring(0, 60)}...' : text,
                                        style: theme.textTheme.bodySmall,
                                      ),
                                      subtitle: Text('${marks} marks'),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.add_circle_outline),
                                        onPressed: () => _addToPaper(q),
                                        tooltip: 'Add to paper',
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Card(
                    margin: const EdgeInsets.all(16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(LMSTheme.radiusMd),
                      side: const BorderSide(color: LMSTheme.borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Paper questions (${_selectedQuestions.length}) – reorder or remove',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Expanded(
                          child: _selectedQuestions.isEmpty
                              ? Center(
                                  child: Text(
                                    'Add questions from the left panel',
                                    style: theme.textTheme.bodyMedium?.copyWith(color: LMSTheme.mutedForeground),
                                  ),
                                )
                              : ReorderableListView.builder(
                                  itemCount: _selectedQuestions.length,
                                  onReorder: (oldIndex, newIndex) {
                                    setState(() {
                                      if (newIndex > oldIndex) newIndex--;
                                      final q = _selectedQuestions.removeAt(oldIndex);
                                      _selectedQuestions.insert(newIndex, q);
                                    });
                                  },
                                  itemBuilder: (context, index) {
                                    final q = _selectedQuestions[index];
                                    final id = q['_id'] as String? ?? '$index';
                                    final text = q['questionText'] as String? ?? '';
                                    final marks = q['marks'] as num? ?? 1;
                                    return Card(
                                      key: ValueKey(id),
                                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        side: const BorderSide(color: LMSTheme.borderColor),
                                      ),
                                      child: ListTile(
                                        leading: ReorderableDragStartListener(
                                          index: index,
                                          child: const Icon(Icons.drag_handle),
                                        ),
                                        title: Text(
                                          text.length > 80 ? '${text.substring(0, 80)}...' : text,
                                          style: theme.textTheme.bodySmall,
                                        ),
                                        subtitle: Text('${marks} marks'),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.arrow_upward, size: 18),
                                              onPressed: () => _moveUp(index),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.arrow_downward, size: 18),
                                              onPressed: () => _moveDown(index),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.remove_circle_outline, size: 18),
                                              onPressed: () => _removeFromPaper(index),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 280,
                  child: Card(
                    margin: const EdgeInsets.all(16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(LMSTheme.radiusMd),
                      side: const BorderSide(color: LMSTheme.borderColor),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Paper settings',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              labelText: 'Title',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _descriptionController,
                            maxLines: 2,
                            decoration: const InputDecoration(
                              labelText: 'Description',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            initialValue: '60',
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Duration (minutes)',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (v) => _durationMinutes = int.tryParse(v) ?? 60,
                          ),
                          const SizedBox(height: 12),
                          Text('Total marks: $_totalMarks', style: theme.textTheme.titleSmall),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<int>(
                            value: _passingMarks,
                            decoration: const InputDecoration(
                              labelText: 'Pass %',
                              border: OutlineInputBorder(),
                            ),
                            items: [40, 50, 60, 70, 80].map((e) => DropdownMenuItem(value: e, child: Text('$e%'))).toList(),
                            onChanged: (v) => setState(() => _passingMarks = v ?? 40),
                          ),
                          const SizedBox(height: 12),
                          SwitchListTile(
                            title: const Text('Shuffle questions'),
                            value: _shuffleQuestions,
                            onChanged: (v) => setState(() => _shuffleQuestions = v),
                          ),
                          if (_error != null) ...[
                            const SizedBox(height: 8),
                            Text(_error!, style: const TextStyle(color: LMSTheme.errorColor, fontSize: 12)),
                          ],
                          const SizedBox(height: 24),
                          FilledButton.icon(
                            onPressed: _selectedQuestions.isEmpty ? null : _publish,
                            icon: const Icon(Icons.publish),
                            label: const Text('Publish paper'),
                            style: FilledButton.styleFrom(
                              backgroundColor: LMSTheme.primaryColor,
                              minimumSize: const Size(double.infinity, 44),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
