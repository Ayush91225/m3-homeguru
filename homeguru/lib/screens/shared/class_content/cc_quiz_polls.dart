import 'package:flutter/material.dart';
import 'cc_shared.dart';

// ── Quiz ──────────────────────────────────────────────────────────────────────

// Each quiz set: (title, score, questions)
// Each question: (question, options, correctIdx)
final _mockQuizSets = [
  (
    'Quiz 1 — Newton\'s Laws',
    '6/15',
    [
      ('What is Newton\'s Second Law?', ['F = mv', 'F = ma', 'F = m/a', 'F = a/m'], 1),
      ('A 500 kg object accelerates at 4 m/s². What is the force?', ['500 N', '1000 N', '2000 N', '4000 N'], 2),
      ('What unit is force measured in?', ['Joule', 'Watt', 'Newton (N)', 'Pascal'], 2),
    ],
  ),
  (
    'Quiz 2 — Application',
    '8/10',
    [
      ('What happens to force if mass doubles but acceleration stays the same?', ['Force halves', 'Force doubles', 'Force stays same', 'Force quadruples'], 1),
      ('Which law explains rocket propulsion?', ['Newton\'s 1st Law', 'Newton\'s 2nd Law', 'Newton\'s 3rd Law', 'Law of Gravity'], 2),
    ],
  ),
];

class QuizSection extends StatefulWidget {
  final Map<String, dynamic> session;
  const QuizSection({super.key, required this.session});

  @override
  State<QuizSection> createState() => _QuizSectionState();
}

class _QuizSectionState extends State<QuizSection> {
  // key: 'quizIdx_questionIdx' → selected option index
  final Map<String, int> _selected = {};

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _mockQuizSets.asMap().entries.map((quizEntry) {
        final qi = quizEntry.key;
        final (quizTitle, score, questions) = quizEntry.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quiz set header
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: cs.tertiaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.emoji_events_rounded, size: 16, color: cs.onTertiaryContainer),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(quizTitle, style: tt.labelMedium?.copyWith(color: cs.onTertiaryContainer, fontWeight: FontWeight.w600)),
                  ),
                  Text('Score: $score', style: tt.labelSmall?.copyWith(color: cs.onTertiaryContainer, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            // Questions
            ...questions.asMap().entries.map((qEntry) {
              final qIdx = qEntry.key;
              final (question, options, correctIdx) = qEntry.value;
              final key = '${qi}_$qIdx';
              final picked = _selected[key];

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Q${qIdx + 1}. $question', style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    ...options.asMap().entries.map((opt) {
                      final oi = opt.key;
                      final isCorrect = oi == correctIdx;
                      final isPicked = picked == oi;
                      Color bg = cs.surfaceContainerLow;
                      Color border = Colors.transparent;
                      Widget? trailing;

                      if (picked != null) {
                        if (isCorrect) {
                          bg = cs.primaryContainer;
                          border = cs.primary;
                          trailing = Icon(Icons.check_circle_rounded, size: 16, color: cs.primary);
                        } else if (isPicked) {
                          bg = cs.errorContainer;
                          border = cs.error;
                          trailing = Icon(Icons.cancel_rounded, size: 16, color: cs.error);
                        }
                      }

                      return GestureDetector(
                        onTap: picked == null ? () => setState(() => _selected[key] = oi) : null,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: border),
                          ),
                          child: Row(
                            children: [
                              Expanded(child: Text(opt.value, style: tt.bodySmall)),
                              if (trailing case final t?) t,
                            ],
                          ),
                        ),
                      );
                    }),
                    // Show correct answer label after picking
                    if (picked != null && picked != correctIdx)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Icon(Icons.lightbulb_outline_rounded, size: 14, color: cs.primary),
                            const SizedBox(width: 6),
                            Text(
                              'Correct: ${options[correctIdx]}',
                              style: tt.labelSmall?.copyWith(color: cs.primary, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            }),
            if (qi < _mockQuizSets.length - 1)
              Divider(color: cs.outlineVariant.withValues(alpha: 0.4), height: 24),
          ],
        );
      }).toList(),
    );

    return CollapsibleSection(
      section: ClassSection.quiz,
      previewHeight: 300,
      child: content,
    );
  }
}

// ── Polls ─────────────────────────────────────────────────────────────────────

const _mockPolls = [
  ('Did you find today\'s session helpful?', ['Very helpful', 'Somewhat helpful', 'Not helpful'], [72, 20, 8]),
  ('Which topic needs more practice?', ['Newton\'s 1st Law', 'Newton\'s 2nd Law', 'Newton\'s 3rd Law'], [30, 55, 15]),
  ('How would you rate the pace of the class?', ['Too fast', 'Just right', 'Too slow'], [15, 70, 15]),
];

class PollsSection extends StatelessWidget {
  const PollsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _mockPolls.asMap().entries.map((e) {
        final (question, options, votes) = e.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(question, style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              ...options.asMap().entries.map((opt) {
                final pct = votes[opt.key];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(opt.value, style: tt.labelSmall),
                          Text('$pct%', style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: pct / 100,
                          minHeight: 6,
                          backgroundColor: cs.surfaceContainerLow,
                          color: cs.primary,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              if (e.key < _mockPolls.length - 1)
                Divider(color: cs.outlineVariant.withValues(alpha: 0.3), height: 8),
            ],
          ),
        );
      }).toList(),
    );

    return CollapsibleSection(
      section: ClassSection.polls,
      previewHeight: 200,
      child: content,
    );
  }
}
