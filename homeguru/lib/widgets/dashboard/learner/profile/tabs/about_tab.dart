import 'package:flutter/material.dart';

class AboutTab extends StatelessWidget {
  const AboutTab({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        _SectionLabel('Bio', tt: tt),
        const SizedBox(height: 8),
        Text(
          'Passionate about mathematics and physics. Preparing for JEE 2026 with a focus on problem-solving and conceptual clarity.',
          style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant, height: 1.5),
        ),
        const SizedBox(height: 20),
        _SectionLabel('Subjects', tt: tt),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['Mathematics', 'Physics', 'Chemistry', 'English']
              .map((s) => Chip(
                    label: Text(s, style: tt.labelSmall),
                    backgroundColor: cs.secondaryContainer,
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    visualDensity: VisualDensity.compact,
                  ))
              .toList(),
        ),
        const SizedBox(height: 20),
        _SectionLabel('Goals', tt: tt),
        const SizedBox(height: 10),
        _GoalTile(icon: Icons.emoji_events_rounded, label: 'Crack JEE Advanced 2026', cs: cs, tt: tt),
        _GoalTile(icon: Icons.auto_graph_rounded,   label: 'Score 95%+ in boards',    cs: cs, tt: tt),
        _GoalTile(icon: Icons.timer_outlined,       label: 'Study 6 hours daily',      cs: cs, tt: tt),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text, {required this.tt});
  final String text;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700));
}

class _GoalTile extends StatelessWidget {
  const _GoalTile({required this.icon, required this.label, required this.cs, required this.tt});
  final IconData icon;
  final String label;
  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 16, color: cs.onPrimaryContainer),
          ),
          const SizedBox(width: 12),
          Text(label, style: tt.bodyMedium),
        ],
      ),
    );
  }
}
