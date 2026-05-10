import 'package:flutter/material.dart';
import 'quiz_screen.dart';

class QuizPreviewMode extends StatelessWidget {
  final List<QuizQuestion> questions;
  final Map<String, int> markingScheme;
  final VoidCallback onRegenerate;
  final VoidCallback onPost;
  final Function(int) onDelete;

  const QuizPreviewMode({
    super.key,
    required this.questions,
    required this.markingScheme,
    required this.onRegenerate,
    required this.onPost,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Text(
                'REVIEW ${questions.length} QUESTIONS',
                style: tt.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: questions.length,
            itemBuilder: (context, i) {
              final q = questions[i];
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: cs.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                q.question,
                                style: tt.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...q.options.asMap().entries.map((entry) {
                                final oi = entry.key;
                                final opt = entry.value;
                                final isCorrect = oi == q.correct;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: isCorrect
                                            ? Colors.green.withValues(alpha: 0.1)
                                            : cs.surfaceContainerLow,
                                          border: Border.all(
                                            color: isCorrect
                                              ? Colors.green
                                              : cs.outlineVariant.withValues(alpha: 0.5),
                                          ),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: isCorrect
                                          ? const Icon(Icons.check, size: 12, color: Colors.green)
                                          : null,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          opt,
                                          style: tt.labelSmall?.copyWith(
                                            color: isCorrect ? Colors.green : cs.onSurfaceVariant,
                                            fontWeight: isCorrect ? FontWeight.w600 : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline, size: 18, color: cs.error),
                          onPressed: () => onDelete(i),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: 1,
                    indent: 60,
                    color: cs.outlineVariant.withValues(alpha: 0.3),
                  ),
                ],
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: cs.outlineVariant)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onRegenerate,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: const Text('Regenerate'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: questions.isEmpty ? null : onPost,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: const Text('Post Quiz'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${questions.length} questions · ${questions.length * (markingScheme['correct'] ?? 0)} max points',
                style: tt.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
