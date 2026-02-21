import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/lms_theme.dart';
import '../services/sanity_service.dart';

/// Question Bank: list, filter, bulk select, Add Question, Edit, Duplicate.
class TeacherQuestionBankScreen extends StatefulWidget {
  const TeacherQuestionBankScreen({super.key});

  @override
  State<TeacherQuestionBankScreen> createState() => _TeacherQuestionBankScreenState();
}

class _TeacherQuestionBankScreenState extends State<TeacherQuestionBankScreen> {
  final SanityService _sanity = SanityService();
  List<Map<String, dynamic>> _questions = [];
  List<Map<String, dynamic>> _subjects = [];
  bool _loading = true;
  String? _error;
  String? _filterSubjectId;
  String? _filterDifficulty;
  String? _filterType;
  final Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final questions = await _sanity.fetchQuestions();
      final subjects = await _sanity.fetchSubjects();
      if (mounted) setState(() {
        _questions = questions;
        _subjects = subjects;
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = e.toString(); });
    }
  }

  List<Map<String, dynamic>> get _filteredQuestions {
    var list = _questions;
    if (_filterSubjectId != null) {
      list = list.where((q) => q['subject']?['_id'] == _filterSubjectId).toList();
    }
    if (_filterDifficulty != null) {
      list = list.where((q) => q['difficulty'] == _filterDifficulty).toList();
    }
    if (_filterType != null) {
      final f = _filterType!.toLowerCase().replaceAll(' ', '');
      list = list.where((q) {
        final t = (q['questionType'] as String? ?? '').toLowerCase().replaceAll(' ', '');
        return t == f;
      }).toList();
    }
    return list;
  }

  void _toggleSelect(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _selectAll() {
    setState(() {
      if (_selectedIds.length == _filteredQuestions.length) {
        _selectedIds.clear();
      } else {
        _selectedIds.addAll(_filteredQuestions.map((q) => q['_id'] as String).whereType<String>());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: LMSTheme.surfaceColor,
      appBar: AppBar(
        title: const Text('Question Bank'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/teacher-dashboard'),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
          FilledButton.icon(
            onPressed: () => context.push('/teacher/question-bank/add'),
            icon: const Icon(Icons.add, size: 20),
            label: const Text('Add Question'),
            style: FilledButton.styleFrom(backgroundColor: LMSTheme.primaryColor),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: LMSTheme.primaryColor))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 200,
                        child: DropdownButtonFormField<String>(
                          value: _filterSubjectId,
                          decoration: const InputDecoration(
                            labelText: 'Subject',
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: [
                            const DropdownMenuItem(value: null, child: Text('All')),
                            ..._subjects.map((s) => DropdownMenuItem(
                                  value: s['_id'] as String?,
                                  child: Text((s['title'] as String? ?? '').length > 25
                                      ? '${(s['title'] as String).substring(0, 25)}...'
                                      : s['title'] as String? ?? ''),
                                )),
                          ],
                          onChanged: (v) => setState(() => _filterSubjectId = v),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 120,
                        child: DropdownButtonFormField<String>(
                          value: _filterDifficulty,
                          decoration: const InputDecoration(
                            labelText: 'Difficulty',
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: [
                            const DropdownMenuItem(value: null, child: Text('All')),
                            ...['easy', 'medium', 'hard'].map((e) => DropdownMenuItem(value: e, child: Text(e))),
                          ],
                          onChanged: (v) => setState(() => _filterDifficulty = v),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 140,
                        child: DropdownButtonFormField<String>(
                          value: _filterType,
                          decoration: const InputDecoration(
                            labelText: 'Type',
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: [
                            const DropdownMenuItem(value: null, child: Text('All')),
                            const DropdownMenuItem(value: 'mcq', child: Text('MCQ')),
                            const DropdownMenuItem(value: 'truefalse', child: Text('True/False')),
                            const DropdownMenuItem(value: 'short', child: Text('Short')),
                            const DropdownMenuItem(value: 'long', child: Text('Long')),
                            const DropdownMenuItem(value: 'fillblank', child: Text('Fill blank')),
                          ],
                          onChanged: (v) => setState(() => _filterType = v),
                        ),
                      ),
                      const SizedBox(width: 16),
                      if (_selectedIds.isNotEmpty)
                        Text(
                          '${_selectedIds.length} selected',
                          style: theme.textTheme.labelMedium?.copyWith(color: LMSTheme.mutedForeground),
                        ),
                    ],
                  ),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(_error!, style: const TextStyle(color: LMSTheme.errorColor)),
                  ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _load,
                    color: LMSTheme.primaryColor,
                    child: _filteredQuestions.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.4,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.quiz_outlined, size: 64, color: LMSTheme.mutedForeground),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No questions match filters',
                                        style: theme.textTheme.titleMedium?.copyWith(color: LMSTheme.mutedForeground),
                                      ),
                                      const SizedBox(height: 8),
                                      FilledButton.icon(
                                        onPressed: () => context.push('/teacher/question-bank/add'),
                                        icon: const Icon(Icons.add),
                                        label: const Text('Add Question'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          itemCount: _filteredQuestions.length,
                          itemBuilder: (context, index) {
                            final q = _filteredQuestions[index];
                            final id = q['_id'] as String? ?? '';
                            final text = q['questionText'] as String? ?? '';
                            final type = q['questionType'] as String? ?? 'mcq';
                            final difficulty = q['difficulty'] as String? ?? 'medium';
                            final marks = q['marks'] as num? ?? 1;
                            final subject = q['subject']?['title'] as String? ?? '';
                            final selected = _selectedIds.contains(id);
                            return Card(
                              elevation: 0,
                              margin: const EdgeInsets.only(bottom: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(LMSTheme.radiusMd),
                                side: BorderSide(
                                  color: selected ? LMSTheme.primaryColor : LMSTheme.borderColor,
                                  width: selected ? 2 : 1,
                                ),
                              ),
                              child: InkWell(
                                onTap: () => _toggleSelect(id),
                                borderRadius: BorderRadius.circular(LMSTheme.radiusMd),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Checkbox(
                                        value: selected,
                                        onChanged: (_) => _toggleSelect(id),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              text.length > 120 ? '${text.substring(0, 120)}...' : text,
                                              style: theme.textTheme.bodyMedium,
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                _chip(type, LMSTheme.primaryColor),
                                                const SizedBox(width: 8),
                                                _chip(difficulty, LMSTheme.warningColor),
                                                const SizedBox(width: 8),
                                                _chip('$marks marks', LMSTheme.successColor),
                                                if (subject.isNotEmpty) ...[
                                                  const SizedBox(width: 8),
                                                  _chip(subject, LMSTheme.mutedForeground),
                                                ],
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      PopupMenuButton<String>(
                                        icon: const Icon(Icons.more_vert),
                                        onSelected: (v) {
                                          if (v == 'edit') {
                                            context.push('/teacher/question-bank/edit/$id');
                                          } else if (v == 'duplicate') {
                                            _duplicateQuestion(q);
                                          } else if (v == 'export') {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Export PDF coming soon')),
                                            );
                                          }
                                        },
                                        itemBuilder: (_) => [
                                          const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 20), SizedBox(width: 8), Text('Edit')])),
                                          const PopupMenuItem(value: 'duplicate', child: Row(children: [Icon(Icons.copy, size: 20), SizedBox(width: 8), Text('Duplicate')])),
                                          const PopupMenuItem(value: 'export', child: Row(children: [Icon(Icons.picture_as_pdf, size: 20), SizedBox(width: 8), Text('Export PDF')])),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
    );
  }

  Future<void> _duplicateQuestion(Map<String, dynamic> q) async {
    try {
      final options = (q['options'] as List?)?.map((e) => e.toString()).toList() ?? [];
      await _sanity.createQuestion(
        questionText: q['questionText'] as String? ?? '',
        questionType: q['questionType'] as String? ?? 'mcq',
        options: options,
        correctAnswer: q['correctAnswer'] as String? ?? '',
        marks: (q['marks'] as num?)?.toInt() ?? 1,
        explanation: q['explanation'] as String?,
        difficulty: q['difficulty'] as String? ?? 'medium',
        subjectId: q['subject']?['_id'] as String?,
        chapterId: q['chapter']?['_id'] as String?,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Question duplicated')));
        _load();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Duplicate failed: $e')));
      }
    }
  }
}
