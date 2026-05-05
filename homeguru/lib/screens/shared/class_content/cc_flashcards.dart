import 'package:flutter/material.dart';
import 'cc_shared.dart';

const _mockFlashcards = [
  ("What is Newton's Second Law?", 'F = ma — Force equals mass times acceleration.'),
  ('What is the unit of force?', 'Newton (N)'),
  ('If mass = 1000 kg and a = 2 m/s², what is F?', 'F = 1000 × 2 = 2000 N'),
  ("What does Newton's Third Law state?", 'For every action there is an equal and opposite reaction.'),
  ('What is the formula for weight?', 'Weight = mass × gravity (W = mg)'),
  ('If F = 500 N and m = 50 kg, what is acceleration?', 'a = F / m = 500 / 50 = 10 m/s²'),
];

class FlashcardsSection extends StatefulWidget {
  const FlashcardsSection({super.key});

  @override
  State<FlashcardsSection> createState() => _FlashcardsSectionState();
}

class _FlashcardsSectionState extends State<FlashcardsSection> {
  int _index = 0;
  bool _revealed = false;

  void _go(int delta) {
    setState(() {
      _index = (_index + delta).clamp(0, _mockFlashcards.length - 1);
      _revealed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final (front, back) = _mockFlashcards[_index];
    final total = _mockFlashcards.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(section: ClassSection.flashcards),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GestureDetector(
            onHorizontalDragEnd: (d) {
              if (d.primaryVelocity! < 0 && _index < total - 1) _go(1);
              if (d.primaryVelocity! > 0 && _index > 0) _go(-1);
            },
            onTap: () => setState(() => _revealed = !_revealed),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeInOut,
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 160),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: _revealed ? cs.primaryContainer : cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _revealed
                      ? cs.primary.withValues(alpha: 0.4)
                      : cs.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _revealed ? Icons.lightbulb_rounded : Icons.help_outline_rounded,
                    size: 28,
                    color: _revealed ? cs.primary : cs.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _revealed ? back : front,
                    style: (_revealed ? tt.bodyMedium : tt.bodyLarge)?.copyWith(
                      color: _revealed ? cs.onPrimaryContainer : cs.onSurface,
                      fontWeight: _revealed ? FontWeight.w500 : FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (!_revealed) ...[
                    const SizedBox(height: 12),
                    Text(
                      'tap to reveal answer',
                      style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: _index > 0 ? () => _go(-1) : null,
                style: IconButton.styleFrom(
                  backgroundColor: cs.surface,
                  side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
                  disabledBackgroundColor: cs.surface,
                ),
                icon: Icon(Icons.chevron_left_rounded, color: cs.onSurfaceVariant),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '${_index + 1} of $total',
                  style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant, fontWeight: FontWeight.w500),
                ),
              ),
              IconButton(
                onPressed: _index < total - 1 ? () => _go(1) : null,
                style: IconButton.styleFrom(
                  backgroundColor: cs.surface,
                  side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
                  disabledBackgroundColor: cs.surface,
                ),
                icon: Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
