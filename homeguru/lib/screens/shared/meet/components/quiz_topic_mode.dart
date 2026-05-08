import 'package:flutter/material.dart';

class QuizTopicMode extends StatefulWidget {
  final String initialTopic;
  final int questionCount;
  final bool generating;
  final String error;
  final VoidCallback onBack;
  final Function(String) onTopicChanged;
  final Function(int) onCountChanged;
  final VoidCallback onGenerate;

  const QuizTopicMode({
    super.key,
    required this.initialTopic,
    required this.questionCount,
    required this.generating,
    required this.error,
    required this.onBack,
    required this.onTopicChanged,
    required this.onCountChanged,
    required this.onGenerate,
  });

  @override
  State<QuizTopicMode> createState() => _QuizTopicModeState();
}

class _QuizTopicModeState extends State<QuizTopicMode> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialTopic);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
            border: Border(
              bottom: BorderSide(color: cs.outlineVariant),
            ),
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
                      'Enter Topic',
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'AI GENERATION',
                      style: tt.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
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
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              TextField(
                controller: _controller,
                maxLines: 4,
                onChanged: widget.onTopicChanged,
                decoration: InputDecoration(
                  hintText: 'e.g. Quantum Physics, Photosynthesis, History of Renaissance...',
                  filled: true,
                  fillColor: cs.surfaceContainerLow,
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
                'QUESTIONS',
                style: tt.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [5, 10, 15, 20].map((count) {
                  final isSelected = widget.questionCount == count;
                  return FilterChip(
                    label: Text('$count'),
                    selected: isSelected,
                    onSelected: (_) => widget.onCountChanged(count),
                    selectedColor: cs.primaryContainer,
                    backgroundColor: cs.surfaceContainerLow,
                    side: BorderSide(
                      color: cs.outlineVariant.withOpacity(0.5),
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    labelStyle: tt.labelLarge?.copyWith(
                      color: isSelected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  );
                }).toList(),
              ),
              if (widget.error.isNotEmpty) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cs.errorContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: cs.onErrorContainer, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.error,
                          style: tt.bodySmall?.copyWith(
                            color: cs.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (widget.generating) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: cs.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'AI is generating questions...',
                        style: tt.bodySmall?.copyWith(
                          color: cs.onPrimaryContainer,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: cs.outlineVariant),
            ),
          ),
          child: FilledButton.icon(
            onPressed: _controller.text.trim().isEmpty || widget.generating
                ? null
                : widget.onGenerate,
            icon: widget.generating
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.auto_awesome_rounded),
            label: Text(
              widget.generating
                  ? 'Generating...'
                  : 'Generate ${widget.questionCount} Questions',
            ),
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
