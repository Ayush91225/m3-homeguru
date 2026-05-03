import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LearnerStep3Body extends StatefulWidget {
  const LearnerStep3Body({super.key, required this.onNext});
  final void Function(String choice) onNext;

  @override
  State<LearnerStep3Body> createState() => _LearnerStep3BodyState();
}

class _LearnerStep3BodyState extends State<LearnerStep3Body> {
  String? _selected;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final w = MediaQuery.sizeOf(context).width;
    final hPad = w >= 600 ? w * 0.2 : 24.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 16),
            child: Column(
              children: [
                Expanded(
                  child: _ChoiceCard(
                    selected: _selected == 'academic',
                    title: 'Academic',
                    subtitle: 'Structured learning for school & college',
                    tags: const ['Maths', 'Science', 'English', 'History', 'Economics', 'Computer Science'],
                    icons: const [Icons.calculate_rounded, Icons.science_rounded, Icons.auto_stories_rounded, Icons.public_rounded, Icons.bar_chart_rounded, Icons.computer_rounded],
                    color: cs.primaryContainer,
                    onColor: cs.onPrimaryContainer,
                    accentColor: cs.primary,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selected = 'academic');
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: _ChoiceCard(
                    selected: _selected == 'non_academic',
                    title: 'Non-Academic',
                    subtitle: 'Skills & passions beyond the classroom',
                    tags: const ['Music', 'Dance', 'Coding', 'Art', 'Photography', 'Fitness'],
                    icons: const [Icons.music_note_rounded, Icons.directions_run_rounded, Icons.code_rounded, Icons.brush_rounded, Icons.camera_alt_rounded, Icons.fitness_center_rounded],
                    color: cs.tertiaryContainer,
                    onColor: cs.onTertiaryContainer,
                    accentColor: cs.tertiary,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selected = 'non_academic');
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 16),
          child: FilledButton(
            onPressed: _selected == null
                ? null
                : () {
                    HapticFeedback.mediumImpact();
                    widget.onNext(_selected!);
                  },
            child: const Text('Continue'),
          ),
        ),
      ],
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.tags,
    required this.icons,
    required this.color,
    required this.onColor,
    required this.accentColor,
    required this.onTap,
  });

  final bool selected;
  final String title;
  final String subtitle;
  final List<String> tags;
  final List<IconData> icons;
  final Color color;
  final Color onColor;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: selected ? accentColor : Colors.transparent,
          width: 2.5,
        ),
        boxShadow: selected
            ? [BoxShadow(color: accentColor.withValues(alpha: 0.18), blurRadius: 16, offset: const Offset(0, 4))]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(26),
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: title + check
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: tt.headlineSmall?.copyWith(
                                color: onColor,
                                fontWeight: FontWeight.w800,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: tt.bodySmall?.copyWith(
                                color: onColor.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: selected ? accentColor : Colors.transparent,
                          border: Border.all(
                            color: selected
                                ? accentColor
                                : onColor.withValues(alpha: 0.25),
                            width: 2,
                          ),
                        ),
                        child: selected
                            ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                            : null,
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Subject icon grid
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(tags.length, (i) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: onColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(icons[i], size: 13, color: onColor.withValues(alpha: 0.8)),
                            const SizedBox(width: 5),
                            Text(
                              tags[i],
                              style: tt.labelSmall?.copyWith(
                                color: onColor.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
