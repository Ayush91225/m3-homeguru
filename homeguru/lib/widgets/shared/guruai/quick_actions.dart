import 'package:flutter/material.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key, required this.onActionTap});

  final ValueChanged<String> onActionTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final smallActions = [
      {'icon': Icons.school_outlined, 'label': 'Explain concept'},
      {'icon': Icons.quiz_outlined, 'label': 'Homework'},
      {'icon': Icons.translate_rounded, 'label': 'Language'},
      {'icon': Icons.calculate_outlined, 'label': 'Math'},
    ];

    final largeActions = [
      {'icon': Icons.science_outlined, 'label': 'Science help'},
      {'icon': Icons.history_edu_outlined, 'label': 'History facts'},
      {'icon': Icons.code_outlined, 'label': 'Code review'},
      {'icon': Icons.lightbulb_outline, 'label': 'Study tips'},
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 40,
          padding: const EdgeInsets.only(bottom: 4),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: smallActions.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final action = smallActions[index];
              return ActionChip(
                avatar: Icon(action['icon'] as IconData, size: 16),
                label: Text(action['label'] as String, style: const TextStyle(fontSize: 13)),
                onPressed: () => onActionTap(action['label'] as String),
                backgroundColor: cs.surfaceContainerHighest,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              );
            },
          ),
        ),
        Container(
          height: 48,
          padding: const EdgeInsets.only(bottom: 4),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: largeActions.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final action = largeActions[index];
              return ActionChip(
                avatar: Icon(action['icon'] as IconData, size: 18),
                label: Text(action['label'] as String),
                onPressed: () => onActionTap(action['label'] as String),
                backgroundColor: cs.surfaceContainerHighest,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              );
            },
          ),
        ),
      ],
    );
  }
}
