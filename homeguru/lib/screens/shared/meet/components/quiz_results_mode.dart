import 'package:flutter/material.dart';
import 'quiz_screen.dart';

class QuizResultsMode extends StatelessWidget {
  final List<QuizQuestion> questions;
  final List<int?> myAnswers;
  final int score;
  final Map<String, int> markingScheme;
  final VoidCallback onClose;

  const QuizResultsMode({
    super.key,
    required this.questions,
    required this.myAnswers,
    required this.score,
    required this.markingScheme,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    const optionLabels = ['A', 'B', 'C', 'D'];
    final correctCount = myAnswers.where((a) {
      final idx = myAnswers.indexOf(a);
      return idx >= 0 && idx < questions.length && a == questions[idx].correct;
    }).length;
    final maxScore = questions.length * markingScheme['correct']!;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cs.primaryContainer,
            border: Border(bottom: BorderSide(color: cs.outlineVariant)),
          ),
          child: Column(
            children: [
              Icon(Icons.emoji_events_rounded, size: 48, color: cs.primary),
              const SizedBox(height: 12),
              Text(
                'Quiz Complete!',
                style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$score',
                    style: tt.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.primary,
                    ),
                  ),
                  Text(
                    ' / $maxScore',
                    style: tt.titleMedium?.copyWith(color: cs.onPrimaryContainer),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Text(
                      '$correctCount correct',
                      style: tt.labelSmall?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red),
                    ),
                    child: Text(
                      '${questions.length - correctCount} wrong',
                      style: tt.labelSmall?.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Text(
                'ANSWER REVIEW',
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
              final picked = myAnswers[i];
              final isCorrect = picked == q.correct;
              final pointsEarned = isCorrect
                ? markingScheme['correct']!
                : (picked != null ? markingScheme['incorrect']! : 0);

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
                            color: isCorrect ? Colors.green : Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              '${i + 1}',
                              style: tt.labelMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
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
                                style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Text(
                                    'Your answer: ',
                                    style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isCorrect
                                        ? Colors.green.withOpacity(0.1)
                                        : Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      picked != null ? optionLabels[picked] : '—',
                                      style: tt.labelSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: isCorrect ? Colors.green : Colors.red,
                                      ),
                                    ),
                                  ),
                                  if (!isCorrect) ...[
                                    const SizedBox(width: 8),
                                    Text(
                                      'Correct: ',
                                      style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        optionLabels[q.correct],
                                        style: tt.labelSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isCorrect ? Colors.green : Colors.red,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            pointsEarned >= 0 ? '+$pointsEarned' : '$pointsEarned',
                            style: tt.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: 1,
                    indent: 60,
                    color: cs.outlineVariant.withOpacity(0.3),
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
          child: FilledButton(
            onPressed: onClose,
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            child: const Text('Close'),
          ),
        ),
      ],
    );
  }
}
