import 'package:flutter/material.dart';
import 'quiz_screen.dart';

class QuizManualMode extends StatefulWidget {
  final List<QuizQuestion> questions;
  final VoidCallback onBack;
  final VoidCallback onPreview;
  final VoidCallback onPost;
  final Function(QuizQuestion) onAddQuestion;
  final Function(int) onDeleteQuestion;

  const QuizManualMode({
    super.key,
    required this.questions,
    required this.onBack,
    required this.onPreview,
    required this.onPost,
    required this.onAddQuestion,
    required this.onDeleteQuestion,
  });

  @override
  State<QuizManualMode> createState() => _QuizManualModeState();
}

class _QuizManualModeState extends State<QuizManualMode> {
  String _question = '';
  List<String> _options = ['', '', '', ''];
  int _correct = 0;

  bool _canAdd() {
    return _question.trim().isNotEmpty &&
           _options.where((o) => o.trim().isNotEmpty).length >= 2;
  }

  void _addQuestion() {
    if (!_canAdd()) return;
    
    widget.onAddQuestion(QuizQuestion(
      id: 'manual_${DateTime.now().millisecondsSinceEpoch}',
      question: _question.trim(),
      options: _options.map((o) => o.trim().isEmpty 
        ? 'Option ${_options.indexOf(o) + 1}' 
        : o.trim()).toList(),
      correct: _correct,
    ));
    
    setState(() {
      _question = '';
      _options = ['', '', '', ''];
      _correct = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: cs.outlineVariant)),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: widget.onBack,
                icon: const Icon(Icons.arrow_back_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: cs.surfaceContainerHighest,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Manual Builder',
                      style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${widget.questions.length} QUESTIONS ADDED',
                      style: tt.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.questions.isNotEmpty)
                TextButton(
                  onPressed: widget.onPreview,
                  child: const Text('Preview'),
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (widget.questions.isNotEmpty) ...[
                ...widget.questions.asMap().entries.map((entry) {
                  final i = entry.key;
                  final q = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: cs.primaryContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              '${i + 1}',
                              style: tt.labelMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: cs.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            q.question,
                            style: tt.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline, 
                            size: 20, 
                            color: cs.error,
                          ),
                          onPressed: () => widget.onDeleteQuestion(i),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 24),
                Divider(color: cs.outlineVariant),
                const SizedBox(height: 24),
              ],
              Text(
                'QUESTION',
                style: tt.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                maxLines: 3,
                onChanged: (v) => setState(() => _question = v),
                decoration: InputDecoration(
                  hintText: 'Type your question...',
                  filled: true,
                  fillColor: cs.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: cs.outlineVariant),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: cs.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'OPTIONS (TAP TO MARK CORRECT)',
                style: tt.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              ..._options.asMap().entries.map((entry) {
                final i = entry.key;
                final isCorrect = _correct == i;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => setState(() => _correct = i),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isCorrect ? Colors.green : cs.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isCorrect ? Colors.green : cs.outlineVariant.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Center(
                            child: isCorrect
                              ? const Icon(Icons.check_circle, 
                                  color: Colors.white, size: 22)
                              : Text(
                                  String.fromCharCode(65 + i),
                                  style: tt.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          onChanged: (v) {
                            setState(() => _options[i] = v);
                          },
                          decoration: InputDecoration(
                            hintText: 'Option ${String.fromCharCode(65 + i)}',
                            filled: true,
                            fillColor: isCorrect 
                              ? Colors.green.withValues(alpha: 0.05)
                              : cs.surfaceContainerLow,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: isCorrect 
                                  ? Colors.green.withValues(alpha: 0.3)
                                  : cs.outlineVariant,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: isCorrect ? Colors.green : cs.primary,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _canAdd() ? _addQuestion : null,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Question'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (widget.questions.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: cs.outlineVariant)),
            ),
            child: FilledButton.icon(
              onPressed: widget.onPost,
              icon: const Icon(Icons.send_rounded),
              label: Text('Post ${widget.questions.length} Questions'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
