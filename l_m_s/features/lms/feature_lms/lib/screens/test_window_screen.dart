import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sanity_client/sanity_client.dart';
import '../sanity_client_helper.dart';

/// Full-screen test window. Students attempt the assessment here;
/// questions and answers are loaded from Sanity.
class TestWindowScreen extends StatefulWidget {
  final String assessmentId;

  const TestWindowScreen({super.key, required this.assessmentId});

  @override
  State<TestWindowScreen> createState() => _TestWindowScreenState();
}

class _TestWindowScreenState extends State<TestWindowScreen> {
  Map<String, dynamic>? _assessment;
  String? _error;
  bool _loading = true;
  int _currentIndex = 0;
  final Map<String, dynamic> _answers = {};
  Timer? _timer;
  int _secondsRemaining = 0;
  SanityClient? _client;

  List<dynamic> get _questions {
    final worksheet = _assessment?['worksheet'];
    if (worksheet == null) return [];
    final q = worksheet['questions'];
    return q is List ? q : [];
  }

  @override
  void initState() {
    super.initState();
    _loadAssessment();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadAssessment() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final client = createLmsClient();
      final res = await client.fetch(
        LmsQueries.assessmentById(widget.assessmentId),
        params: {'id': widget.assessmentId},
      );
      final result = res.result;
      if (mounted) {
        setState(() {
          _client = client;
          _assessment = result is Map ? result as Map<String, dynamic> : null;
          _loading = false;
          if (_assessment != null) {
            final mins = _assessment!['durationMinutes'] ?? 30;
            _secondsRemaining = mins * 60;
            _startTimer();
          }
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

  void _submitTest() {
    _timer?.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Test submitted'),
        content: const Text(
          'Your answers have been recorded. In a full implementation, '
          'they would be sent to Sanity (e.g. testAttempt document).',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.pop();
            },
            child: const Text('Back to tests'),
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
    if (_loading) {
      return Scaffold(
        body: Container(
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Test')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                const SizedBox(height: 16),
                FilledButton(onPressed: _loadAssessment, child: const Text('Retry')),
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
        appBar: AppBar(title: Text(_assessment?['title'] ?? 'Test')),
        body: const Center(child: Text('No questions in this assessment.')),
      );
    }

    return Scaffold(
      body: Container(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                title: Text(_assessment?['title'] ?? 'Test'),
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
                    if (leave == true && mounted) context.pop();
                  },
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Text(
                      _formatTime(_secondsRemaining),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _secondsRemaining <= 300
                            ? Theme.of(context).colorScheme.error
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Question ${_currentIndex + 1} of ${questions.length}',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: SingleChildScrollView(
                          child: _QuestionCard(
                            question: questions[_currentIndex],
                            questionIndex: _currentIndex,
                            client: _client,
                            selectedOptionIndex: _answers['q_${questions[_currentIndex]['_id']}']?['option'] as int?,
                            textAnswer: _answers['q_${questions[_currentIndex]['_id']}']?['text'] as String?,
                            onOptionSelected: (index) {
                              setState(() {
                                _answers['q_${questions[_currentIndex]['_id']}'] = {'option': index};
                              });
                            },
                            onTextAnswer: (text) {
                              setState(() {
                                _answers['q_${questions[_currentIndex]['_id']}'] = {'text': text};
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (_currentIndex > 0)
                            OutlinedButton.icon(
                              onPressed: () => setState(() => _currentIndex--),
                              icon: const Icon(Icons.arrow_back),
                              label: const Text('Previous'),
                            )
                          else
                            const SizedBox.shrink(),
                          if (_currentIndex < questions.length - 1)
                            FilledButton.icon(
                              onPressed: () => setState(() => _currentIndex++),
                              icon: const Icon(Icons.arrow_forward),
                              label: const Text('Next'),
                            )
                          else
                            FilledButton.icon(
                              onPressed: _submitTest,
                              icon: const Icon(Icons.check),
                              label: const Text('Submit test'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
                final opt = options[i] is Map ? options[i] as Map : <String, dynamic>{};
                final text = opt['text'] ?? 'Option ${i + 1}';
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
            ]             else if (type == 'short' || type == 'long') ...[
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
