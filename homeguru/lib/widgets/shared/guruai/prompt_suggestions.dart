import 'package:flutter/material.dart';

class PromptSuggestions extends StatelessWidget {
  const PromptSuggestions({super.key, required this.onSuggestionTap});

  final ValueChanged<String> onSuggestionTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final suggestions = [
      {
        'icon': Icons.school_outlined,
        'title': 'Explain a concept',
        'subtitle': 'Break down complex topics',
      },
      {
        'icon': Icons.quiz_outlined,
        'title': 'Help with homework',
        'subtitle': 'Get step-by-step guidance',
      },
      {
        'icon': Icons.translate_rounded,
        'title': 'Practice language',
        'subtitle': 'Improve your skills',
      },
      {
        'icon': Icons.calculate_outlined,
        'title': 'Solve math problems',
        'subtitle': 'Work through equations',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        return InkWell(
          onTap: () => onSuggestionTap(suggestion['title'] as String),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  suggestion['icon'] as IconData,
                  size: 28,
                  color: cs.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  suggestion['title'] as String,
                  style: tt.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  suggestion['subtitle'] as String,
                  style: tt.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
