import 'package:flutter/material.dart';

class ReactionBar extends StatelessWidget {
  final Function(String) onReaction;

  const ReactionBar({super.key, required this.onReaction});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final reactions = ['👍', '❤️', '😂', '😮', '😢', '👏', '🎉', '🔥', '💯', '🙌', '👌', '🤔'];

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: reactions.map((emoji) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: InkWell(
                  onTap: () => onReaction(emoji),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        emoji,
                        style: const TextStyle(fontSize: 26),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
