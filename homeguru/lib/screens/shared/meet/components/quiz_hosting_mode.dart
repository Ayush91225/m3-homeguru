import 'package:flutter/material.dart';
import 'quiz_screen.dart';

class QuizHostingMode extends StatefulWidget {
  final List<QuizQuestion> questions;
  final List<Map<String, dynamic>> submissions;
  final Map<String, int> markingScheme;
  final VoidCallback onEndQuiz;

  const QuizHostingMode({
    super.key,
    required this.questions,
    required this.submissions,
    required this.markingScheme,
    required this.onEndQuiz,
  });

  @override
  State<QuizHostingMode> createState() => _QuizHostingModeState();
}

class _QuizHostingModeState extends State<QuizHostingMode> {
  String? _expandedUser;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    const optionLabels = ['A', 'B', 'C', 'D'];
    final sorted = List<Map<String, dynamic>>.from(widget.submissions)
      ..sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));
    final maxScore = widget.questions.length * widget.markingScheme['correct']!;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                cs.primaryContainer,
                cs.tertiaryContainer,
              ],
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.broadcast_on_personal_rounded, 
                  color: cs.onPrimary, 
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live Responses',
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: cs.onPrimaryContainer,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${widget.submissions.length} SUBMITTED · ${widget.questions.length}Q',
                          style: tt.labelSmall?.copyWith(
                            color: cs.onPrimaryContainer.withValues(alpha: 0.8),
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'LIVE',
                      style: tt.labelSmall?.copyWith(
                        color: cs.onPrimary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: widget.submissions.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: cs.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Waiting for responses...',
                      style: tt.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Students are answering ${widget.questions.length} questions',
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: sorted.length,
                itemBuilder: (context, rank) {
                  final sub = sorted[rank];
                  final userName = sub['userName'] as String;
                  final score = sub['score'] as int;
                  final answers = List<int?>.from(sub['answers'] as List);
                  final correctCount = answers.where((a) {
                    final idx = answers.indexOf(a);
                    return idx >= 0 && idx < widget.questions.length && 
                           a == widget.questions[idx].correct;
                  }).length;
                  final pct = maxScore > 0 
                    ? ((score / maxScore) * 100).round() 
                    : 0;
                  final isExpanded = _expandedUser == userName;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: rank == 0 
                          ? cs.primary.withValues(alpha: 0.3)
                          : cs.outlineVariant,
                        width: rank == 0 ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              _expandedUser = isExpanded ? null : userName;
                            });
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: rank == 0
                                      ? const Color(0xFFFFF3E0)
                                      : cs.primaryContainer,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: rank == 0
                                      ? const Icon(Icons.emoji_events, 
                                          color: Color(0xFFFF9800), 
                                          size: 22,
                                        )
                                      : Text(
                                          '#${rank + 1}',
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
                                        userName,
                                        style: tt.bodyLarge?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.green.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              '$correctCount/${widget.questions.length}',
                                              style: tt.labelSmall?.copyWith(
                                                color: Colors.green,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '·',
                                            style: tt.labelSmall?.copyWith(
                                              color: cs.onSurfaceVariant,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '$pct%',
                                            style: tt.labelSmall?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: cs.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '$score',
                                      style: tt.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: cs.primary,
                                      ),
                                    ),
                                    Text(
                                      '/$maxScore',
                                      style: tt.labelSmall?.copyWith(
                                        color: cs.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  isExpanded 
                                    ? Icons.expand_less_rounded
                                    : Icons.expand_more_rounded,
                                  color: cs.onSurfaceVariant,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (isExpanded)
                          Container(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(color: cs.outlineVariant),
                              ),
                            ),
                            child: Column(
                              children: [
                                const SizedBox(height: 12),
                                ...widget.questions.asMap().entries.map((entry) {
                                  final i = entry.key;
                                  final q = entry.value;
                                  final picked = answers[i];
                                  final isCorrect = picked == q.correct;
                                  final points = isCorrect
                                    ? widget.markingScheme['correct']!
                                    : (picked != null 
                                        ? widget.markingScheme['incorrect']! 
                                        : 0);

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: cs.surface,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isCorrect 
                                          ? Colors.green.withValues(alpha: 0.3)
                                          : Colors.red.withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: isCorrect 
                                              ? Colors.green 
                                              : Colors.red,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${i + 1}',
                                              style: tt.labelSmall?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            q.question,
                                            style: tt.bodySmall,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          picked != null 
                                            ? optionLabels[picked] 
                                            : '—',
                                          style: tt.labelMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: cs.onSurface,
                                          ),
                                        ),
                                        if (!isCorrect) ...[
                                          const SizedBox(width: 4),
                                          Icon(Icons.arrow_forward, 
                                            size: 12, 
                                            color: cs.onSurfaceVariant,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            optionLabels[q.correct],
                                            style: tt.labelMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ],
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isCorrect 
                                              ? Colors.green 
                                              : Colors.red,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            points >= 0 ? '+$points' : '$points',
                                            style: tt.labelSmall?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
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
                      ],
                    ),
                  );
                },
              ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: cs.outlineVariant)),
          ),
          child: FilledButton.icon(
            onPressed: widget.onEndQuiz,
            icon: const Icon(Icons.stop_circle_rounded),
            label: const Text('End Quiz'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              backgroundColor: cs.error,
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
