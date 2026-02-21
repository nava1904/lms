import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/lms_theme.dart';
import '../services/sanity_service.dart';

/// Erudex-style Add Question: type selector, rich editor, right panel metadata, correct answer, solution.
class TeacherQuestionAddScreen extends StatefulWidget {
  final String? editQuestionId;

  const TeacherQuestionAddScreen({super.key, this.editQuestionId});

  @override
  State<TeacherQuestionAddScreen> createState() => _TeacherQuestionAddScreenState();
}

class _TeacherQuestionAddScreenState extends State<TeacherQuestionAddScreen> {
  final SanityService _sanity = SanityService();
  final _questionTextController = TextEditingController();
  final _explanationController = TextEditingController();
  final _optionControllers = <TextEditingController>[];
  final _correctAnswerController = TextEditingController();
  final _marksController = TextEditingController(text: '1');

  String _questionType = 'mcq';
  String _difficulty = 'medium';
  String? _subjectId;
  String? _chapterId;
  List<String> _options = ['', ''];
  int _correctOptionIndex = 0;
  String _correctAnswerText = '';

  List<Map<String, dynamic>> _subjects = [];
  List<Map<String, dynamic>> _chapters = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _optionControllers.addAll([TextEditingController(), TextEditingController()]);
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    try {
      final list = await _sanity.fetchSubjects();
      if (mounted) setState(() => _subjects = list);
    } catch (e) {
      if (mounted) {
        setState(() => _subjects = []);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load subjects: $e')),
        );
      }
    }
  }

  Future<void> _loadChapters() async {
    if (_subjectId == null) {
      setState(() => _chapters = []);
      return;
    }
    try {
      final list = await _sanity.fetchChapters(subjectId: _subjectId);
      if (mounted) setState(() => _chapters = list);
    } catch (e) {
      if (mounted) {
        setState(() => _chapters = []);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load chapters: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _questionTextController.dispose();
    _explanationController.dispose();
    _correctAnswerController.dispose();
    _marksController.dispose();
    for (final c in _optionControllers) c.dispose();
    super.dispose();
  }

  void _addOption() {
    setState(() {
      _options.add('');
      _optionControllers.add(TextEditingController());
    });
  }

  void _removeOption(int i) {
    if (_options.length <= 2) return;
    setState(() {
      _options.removeAt(i);
      _optionControllers[i].dispose();
      _optionControllers.removeAt(i);
      if (_correctOptionIndex >= _optionControllers.length) {
        _correctOptionIndex = _optionControllers.length - 1;
      } else if (i < _correctOptionIndex) {
        _correctOptionIndex--;
      }
    });
  }

  Future<void> _save({bool draft = false}) async {
    final questionText = _questionTextController.text.trim();
    if (questionText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Question text is required')),
      );
      return;
    }
    final options = _questionType == 'mcq'
        ? _optionControllers.map((c) => c.text.trim()).where((s) => s.isNotEmpty).toList()
        : <String>[];
    if (_questionType == 'mcq' && options.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('MCQ needs at least 2 options')),
      );
      return;
    }
    final correctAnswer = _questionType == 'mcq'
        ? (options.isNotEmpty && _correctOptionIndex >= 0 && _correctOptionIndex < options.length
            ? options[_correctOptionIndex]
            : (options.isNotEmpty ? options[0] : ''))
        : _correctAnswerController.text.trim();
    if (correctAnswer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Correct answer is required')),
      );
      return;
    }

    final marks = int.tryParse(_marksController.text.trim()) ?? 1;
    if (marks < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Marks must be at least 1')),
      );
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final res = await _sanity.createQuestion(
        questionText: questionText,
        questionType: _questionType,
        options: options,
        correctAnswer: correctAnswer,
        marks: marks,
        explanation: _explanationController.text.trim().isEmpty ? null : _explanationController.text.trim(),
        difficulty: _difficulty,
        subjectId: _subjectId,
        chapterId: _chapterId,
      );
      if (mounted) {
        setState(() => _loading = false);
        if (res != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Question saved')),
          );
          context.go('/teacher/question-bank');
        }
      }
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = e.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: LMSTheme.surfaceColor,
      appBar: AppBar(
        title: const Text('Add Question'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/teacher/question-bank'),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: LMSTheme.primaryColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 180,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Question Type', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        ...['mcq', 'truefalse', 'short', 'long', 'fillblank'].map((t) {
                          final label = t == 'mcq' ? 'MCQ' : t == 'truefalse' ? 'True/False' : t == 'short' ? 'Short/Numerical' : t == 'long' ? 'Descriptive' : 'Fill in Blank';
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: FilterChip(
                              label: Text(label),
                              selected: _questionType == t,
                              onSelected: (_) => setState(() => _questionType = t),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 2,
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(LMSTheme.radiusMd),
                        side: const BorderSide(color: LMSTheme.borderColor),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Question', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _questionTextController,
                              maxLines: 5,
                              decoration: InputDecoration(
                                hintText: 'Enter question text...',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                            if (_questionType == 'mcq') ...[
                              const SizedBox(height: 16),
                              Text('Options', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                              ..._optionControllers.asMap().entries.map((e) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: e.value,
                                          decoration: InputDecoration(
                                            labelText: 'Option ${e.key + 1}',
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle_outline),
                                        onPressed: _optionControllers.length > 2 ? () => _removeOption(e.key) : null,
                                      ),
                                    ],
                                  ),
                                );
                              }),
                              TextButton.icon(
                                onPressed: _addOption,
                                icon: const Icon(Icons.add),
                                label: const Text('Add option'),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<int>(
                                value: _correctOptionIndex >= 0 && _correctOptionIndex < _optionControllers.length ? _correctOptionIndex : 0,
                                decoration: const InputDecoration(labelText: 'Correct option'),
                                items: List.generate(_optionControllers.length, (i) => DropdownMenuItem(value: i, child: Text('Option ${i + 1}'))),
                                onChanged: (v) => setState(() => _correctOptionIndex = v ?? 0),
                              ),
                            ] else ...[
                              const SizedBox(height: 12),
                              TextField(
                                controller: _correctAnswerController,
                                decoration: const InputDecoration(
                                  labelText: 'Correct answer',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),
                            Text('Explanation (optional)', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            TextField(
                              controller: _explanationController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText: 'Solution / explanation',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  SizedBox(
                    width: 220,
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(LMSTheme.radiusMd),
                        side: const BorderSide(color: LMSTheme.borderColor),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Difficulty', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                            DropdownButtonFormField<String>(
                              value: _difficulty,
                              items: ['easy', 'medium', 'hard'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                              onChanged: (v) => setState(() => _difficulty = v ?? 'medium'),
                            ),
                            const SizedBox(height: 12),
                            Text('Subject', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                            DropdownButtonFormField<String>(
                              value: _subjectId,
                              items: [const DropdownMenuItem(value: null, child: Text('—'))]
                                ..addAll(_subjects.map((s) => DropdownMenuItem(value: s['_id'] as String?, child: Text(s['title'] as String? ?? '')))),
                              onChanged: (v) => setState(() { _subjectId = v; _chapterId = null; _loadChapters(); }),
                            ),
                            const SizedBox(height: 12),
                            Text('Chapter', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                            DropdownButtonFormField<String>(
                              value: _chapterId,
                              items: [const DropdownMenuItem(value: null, child: Text('—'))]
                                ..addAll(_chapters.map((c) => DropdownMenuItem(value: c['_id'] as String?, child: Text(c['title'] as String? ?? '')))),
                              onChanged: (v) => setState(() => _chapterId = v),
                            ),
                            const SizedBox(height: 12),
                            Text('Marks', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                            TextFormField(
                              controller: _marksController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Marks',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: _error != null
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(_error!, style: const TextStyle(color: LMSTheme.errorColor)),
              ),
            )
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => context.go('/teacher/question-bank'),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: _loading ? null : () => _save(draft: true),
                      icon: const Icon(Icons.save_outlined, size: 18),
                      label: const Text('Save as Draft'),
                      style: FilledButton.styleFrom(backgroundColor: LMSTheme.mutedForeground),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: _loading ? null : _save,
                      icon: const Icon(Icons.save, size: 18),
                      label: const Text('Save'),
                      style: FilledButton.styleFrom(backgroundColor: LMSTheme.primaryColor),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
