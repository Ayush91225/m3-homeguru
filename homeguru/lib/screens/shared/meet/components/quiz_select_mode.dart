import 'package:flutter/material.dart';

class QuizSelectMode extends StatelessWidget {
  final Map<String, int> markingScheme;
  final VoidCallback onTopicBased;
  final VoidCallback onClassBased;
  final VoidCallback onManualBuild;

  const QuizSelectMode({
    super.key,
    required this.markingScheme,
    required this.onTopicBased,
    required this.onClassBased,
    required this.onManualBuild,
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
                'CREATE QUIZ',
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
          child: ListView(
            padding: const EdgeInsets.only(bottom: 16),
            children: [
              _OptionTile(
                icon: Icons.psychology_rounded,
                title: 'Topic Based',
                subtitle: 'AI Generation from topic',
                color: cs.primary,
                onTap: onTopicBased,
              ),
              _OptionTile(
                icon: Icons.auto_awesome_rounded,
                title: 'Class Based',
                subtitle: 'Generate from content / transcript',
                color: cs.tertiary,
                onTap: onClassBased,
              ),
              _OptionTile(
                icon: Icons.edit_rounded,
                title: 'Manual Build',
                subtitle: 'Create questions yourself',
                color: cs.secondary,
                onTap: onManualBuild,
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            border: Border(top: BorderSide(color: cs.outlineVariant)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 16, color: cs.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(
                'Marking: ',
                style: tt.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '+${markingScheme['correct']}',
                  style: tt.labelSmall?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${markingScheme['incorrect']}',
                  style: tt.labelSmall?.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: tt.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: cs.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
        Divider(
          height: 1,
          indent: 68,
          color: cs.outlineVariant.withOpacity(0.3),
        ),
      ],
    );
  }
}
