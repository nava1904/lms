import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';
import 'package:sanity_client/sanity_client.dart';
import '../sanity_client_helper.dart';
import '../stores/test_store.dart';
import '../theme/lms_theme.dart';

/// NTA-style test window: question area left, question palette right.
/// Uses TestStore; persists testAttempt with timeSpentPerQuestion on submit.
class TestWindowScreen extends StatefulWidget {
  final String assessmentId;
  final String studentId;

  const TestWindowScreen({super.key, required this.assessmentId, this.studentId = ''});

  @override
  State<TestWindowScreen> createState() => _TestWindowScreenState();
}

class _TestWindowScreenState extends State<TestWindowScreen> {
  final TestStore _store = TestStore();
  Timer? _timer;
  int _secondsRemaining = 0;
  SanityClient? _client;
  DateTime? _questionStartTime;

  List<dynamic> get _questions {
    final a = _store.currentAssessment;
    if (a == null) return [];
    return a.questions.map((q) => {
      '_id': q.id,
      'queText': q.questionText,
      'type': q.questionType,
      'options': q.options,
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _store.loadAssessment(widget.assessmentId).then((_) {
      if (mounted && _store.currentAssessment != null) {
        final mins = _store.currentAssessment!.durationMinutes ?? 30;
        _secondsRemaining = mins * 60;
        _startTimer();
        _questionStartTime = DateTime.now();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _store.reset();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_secondsRemaining <= 0) {
          _timer?.cancel();
          _submitTest();
          return;
        }
        _secondsRemaining--;
      });
    });
  }

  void _recordTimeForCurrentQuestion() {
    if (_questionStartTime != null) {
      final secs = DateTime.now().difference(_questionStartTime!).inSeconds;
      _store.recordTime(_store.currentIndex, secs);
    }
    _questionStartTime = DateTime.now();
  }

  Future<void> _submitTest() async {
    _timer?.cancel();
    _recordTimeForCurrentQuestion();
    final studentId = widget.studentId.isNotEmpty ? widget.studentId : 'demo-student';
    final ok = await _store.submitTest(studentId);
    if (!mounted) return;
    final errorMsg = lastMutationError;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Test submitted'),
        content: Text(ok
            ? 'Your answers have been saved. Check Analytics for detailed results.'
            : errorMsg != null && errorMsg.isNotEmpty
                ? 'Submission failed: $errorMsg'
                : 'Submission may have failed. Set SANITY_API_TOKEN in l_m_s/apps/l_m_s/.env for saves. Check your connection.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) context.go('/tests');
              });
            },
            child: const Text('Back to tests'),
          ),
          if (studentId.isNotEmpty)
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (context.mounted) context.go('/analytics', extra: {'studentId': studentId});
                });
              },
              child: const Text('View analytics'),
            ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        if (_store.loading) {
          return Scaffold(
            body: Container(
              color: LMSTheme.surfaceColor,
              child: const Center(child: CircularProgressIndicator()),
            ),
          );
        }
        if (_store.error != null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Test')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_store.error!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => _store.loadAssessment(widget.assessmentId),
                      child: const Text('Retry'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(onPressed: () => context.pop(), child: const Text('Back')),
                  ],
                ),
              ),
            ),
          );
        }
        final questions = _questions;
        if (questions.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: Text(_store.currentAssessment?.title ?? 'Test')),
            body: const Center(child: Text('No questions in this assessment.')),
          );
        }

        final idx = _store.currentIndex;
        return Scaffold(
          body: Container(
            color: LMSTheme.surfaceColor,
            child: SafeArea(
              child: Column(
                children: [
                  AppBar(
                    title: Text(_store.currentAssessment?.title ?? 'Test'),
                    backgroundColor: LMSTheme.primaryColor,
                    foregroundColor: Colors.white,
                    leading: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () async {
                        final leave = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Leave test?'),
                            content: const Text('Your progress will not be saved.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: const Text('Stay'),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.of(ctx).pop(true),
                                child: const Text('Leave'),
                              ),
                            ],
                          ),
                        );
                        if (leave == true) context.go('/tests');
                      },
                    ),
                    actions: [
                      Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: Text(
                          _formatTime(_secondsRemaining),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _secondsRemaining <= 300 ? LMSTheme.errorColor : Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Question ${idx + 1} of ${questions.length}',
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                                const SizedBox(height: 16),
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: _QuestionCard(
                                      question: questions[idx],
                                      questionIndex: idx,
                                      client: _client,
                                      selectedOptionIndex: _store.answers[idx] != null ? int.tryParse(_store.answers[idx]!) : null,
                                      textAnswer: _store.answers[idx],
                                      onOptionSelected: (index) {
                                        _store.setAnswer(idx, index.toString());
                                      },
                                      onTextAnswer: (text) {
                                        _store.setAnswer(idx, text);
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    OutlinedButton.icon(
                                      onPressed: idx > 0
                                          ? () {
                                              _recordTimeForCurrentQuestion();
                                              _store.setCurrentIndex(idx - 1);
                                              setState(() {});
                                            }
                                          : null,
                                      icon: const Icon(Icons.arrow_back),
                                      label: const Text('Previous'),
                                    ),
                                    TextButton.icon(
                                      onPressed: () {
                                        _store.toggleMarked(idx);
                                        setState(() {});
                                      },
                                      icon: Icon(
                                        _store.marked.contains(idx) ? Icons.bookmark : Icons.bookmark_border,
                                      ),
                                      label: Text(_store.marked.contains(idx) ? 'Unmark' : 'Mark for review'),
                                    ),
                                    FilledButton.icon(
                                      onPressed: idx < questions.length - 1
                                          ? () {
                                              _recordTimeForCurrentQuestion();
                                              _store.setCurrentIndex(idx + 1);
                                              setState(() {});
                                            }
                                          : () => _submitTest(),
                                      icon: Icon(idx < questions.length - 1 ? Icons.arrow_forward : Icons.check),
                                      label: Text(idx < questions.length - 1 ? 'Next' : 'Submit test'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          width: 120,
                          margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Question palette',
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                child: GridView.builder(
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4,
                                    mainAxisSpacing: 4,
                                    crossAxisSpacing: 4,
                                    childAspectRatio: 1,
                                  ),
                                  itemCount: questions.length,
                                  itemBuilder: (context, i) {
                                    final answered = _store.answered.contains(i);
                                    final marked = _store.marked.contains(i);
                                    final current = i == idx;
                                    return InkWell(
                                      onTap: () {
                                        _recordTimeForCurrentQuestion();
                                        _store.setCurrentIndex(i);
                                        setState(() {});
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: current
                                              ? LMSTheme.primaryColor
                                              : marked
                                                  ? LMSTheme.warningColor.withValues(alpha: 0.3)
                                                  : answered
                                                      ? LMSTheme.successColor.withValues(alpha: 0.3)
                                                      : Colors.grey.shade200,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          '${i + 1}',
                                          style: TextStyle(
                                            fontWeight: current ? FontWeight.bold : null,
                                            color: current ? Colors.white : null,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final dynamic question;
  final int questionIndex;
  final SanityClient? client;
  final int? selectedOptionIndex;
  final String? textAnswer;
  final ValueChanged<int>? onOptionSelected;
  final ValueChanged<String>? onTextAnswer;

  const _QuestionCard({
    required this.question,
    required this.questionIndex,
    this.client,
    this.selectedOptionIndex,
    this.textAnswer,
    this.onOptionSelected,
    this.onTextAnswer,
  });

  @override
  Widget build(BuildContext context) {
    final queText = question['queText'] ?? 'No question text';
    final type = question['type'] ?? 'mcq';
    final options = question['options'] as List<dynamic>? ?? [];
    final imageInQue = question['imageInQue'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              queText,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (imageInQue != null && imageInQue['asset'] != null && client != null) ...[
              const SizedBox(height: 12),
              Image.network(
                _imageUrl(imageInQue),
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ],
            const SizedBox(height: 16),
            if (type == 'mcq' && options.isNotEmpty) ...[
              ...List.generate(options.length, (i) {
                final opt = options[i];
                final text = opt is Map
                    ? (opt['text']?.toString() ?? 'Option ${i + 1}')
                    : (opt?.toString().trim().isEmpty == true ? 'Option ${i + 1}' : (opt?.toString() ?? 'Option ${i + 1}'));
                final selected = selectedOptionIndex == i;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () => onOptionSelected?.call(i),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: selected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).dividerColor,
                          width: selected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            selected ? Icons.radio_button_checked : Icons.radio_button_off,
                            size: 24,
                            color: selected
                                ? Theme.of(context).colorScheme.primary
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text(text)),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ]
            else if (type == 'truefalse') ...[
              Row(
                children: [
                  Expanded(
                    child: _TrueFalseOption(
                      label: 'True',
                      selected: selectedOptionIndex == 0,
                      onTap: () => onOptionSelected?.call(0),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TrueFalseOption(
                      label: 'False',
                      selected: selectedOptionIndex == 1,
                      onTap: () => onOptionSelected?.call(1),
                    ),
                  ),
                ],
              ),
            ]
            else if (type == 'fillblank') ...[
              TextFormField(
                key: ValueKey(question['_id']),
                initialValue: textAnswer ?? '',
                maxLines: 1,
                decoration: const InputDecoration(
                  hintText: 'Fill in the blank...',
                  border: OutlineInputBorder(),
                ),
                onChanged: onTextAnswer,
              ),
            ]
            else if (type == 'short' || type == 'long') ...[
              TextFormField(
                key: ValueKey(question['_id']),
                initialValue: textAnswer ?? '',
                maxLines: type == 'long' ? 5 : 1,
                decoration: const InputDecoration(
                  hintText: 'Type your answer...',
                  border: OutlineInputBorder(),
                ),
                onChanged: onTextAnswer,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _imageUrl(dynamic image) {
    final asset = image['asset'];
    if (asset == null) return '';
    final ref = asset['_ref'] ?? asset['_id'];
    if (ref == null || ref is! String) return '';
    try {
      return client!.imageUrl(ref).toString();
    } catch (_) {
      return '';
    }
  }
}

class _TrueFalseOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const _TrueFalseOption({
    required this.label,
    required this.selected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).dividerColor,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 24,
              color: selected ? Theme.of(context).colorScheme.primary : null,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(label)),
          ],
        ),
      ),
    );
  }
}
