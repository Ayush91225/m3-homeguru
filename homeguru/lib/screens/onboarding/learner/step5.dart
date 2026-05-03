import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LearnerStep5Body extends StatefulWidget {
  const LearnerStep5Body({
    super.key,
    required this.subject,
    required this.totalSubjects,
    required this.subjectIndex,
    required this.onNext,
  });

  /// The single subject this screen is asking about
  final String subject;

  /// Total number of real (non-Others) subjects — for sub-progress display
  final int totalSubjects;
  final int subjectIndex;

  final void Function(String subject, int level) onNext;

  @override
  State<LearnerStep5Body> createState() => _LearnerStep5BodyState();
}

class _LearnerStep5BodyState extends State<LearnerStep5Body> {
  int? _selected;

  List<_Level> get _levels => [
        _Level(
          index: 0,
          icon: Icons.waving_hand_rounded,
          label: "I'm new to ${widget.subject}",
          description: 'Just starting out — no prior experience.',
        ),
        _Level(
          index: 1,
          icon: Icons.lightbulb_outline_rounded,
          label: 'I know some basics',
          description: 'Familiar with a few concepts but need guidance.',
        ),
        _Level(
          index: 2,
          icon: Icons.school_outlined,
          label: 'I can handle basic ${widget.subject} concepts',
          description: 'Comfortable with fundamentals, ready to go deeper.',
        ),
        _Level(
          index: 3,
          icon: Icons.trending_up_rounded,
          label: 'I can work with various ${widget.subject} topics',
          description: 'Good understanding across multiple areas.',
        ),
        _Level(
          index: 4,
          icon: Icons.workspace_premium_rounded,
          label: 'I can discuss most ${widget.subject} topics in detail',
          description: 'Strong grasp — looking to master advanced concepts.',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final w = MediaQuery.sizeOf(context).width;
    final hPad = w >= 600 ? w * 0.2 : 24.0;
    final levels = _levels;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sub-progress if multiple subjects
        if (widget.totalSubjects > 1)
          Padding(
            padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 0),
            child: Row(
              children: List.generate(widget.totalSubjects, (i) {
                final done = i < widget.subjectIndex;
                final active = i == widget.subjectIndex;
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: i < widget.totalSubjects - 1 ? 6 : 0),
                    height: 4,
                    decoration: BoxDecoration(
                      color: done || active ? cs.primary : cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),

        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: levels.map((level) {
                final selected = _selected == level.index;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      color: selected ? cs.primaryContainer : cs.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected ? cs.primary : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selected = level.index);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                          child: Row(
                            children: [
                              // Level indicator bar
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(5, (i) {
                                  final filled = i <= level.index;
                                  return Container(
                                    width: 4,
                                    height: 8,
                                    margin: const EdgeInsets.only(bottom: 2),
                                    decoration: BoxDecoration(
                                      color: filled
                                          ? (selected ? cs.primary : cs.onSurfaceVariant)
                                          : (selected ? cs.primary.withValues(alpha: 0.2) : cs.surfaceContainerHighest),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  );
                                }).reversed.toList(),
                              ),
                              const SizedBox(width: 14),
                              Icon(
                                level.icon,
                                size: 22,
                                color: selected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      level.label,
                                      style: tt.bodyMedium?.copyWith(
                                        color: selected ? cs.onPrimaryContainer : cs.onSurface,
                                        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      level.description,
                                      style: tt.bodySmall?.copyWith(
                                        color: selected
                                            ? cs.onPrimaryContainer.withValues(alpha: 0.7)
                                            : cs.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: selected ? cs.primary : Colors.transparent,
                                  border: Border.all(
                                    color: selected ? cs.primary : cs.outlineVariant,
                                    width: 2,
                                  ),
                                ),
                                child: selected
                                    ? const Icon(Icons.check_rounded, size: 13, color: Colors.white)
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
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
                    widget.onNext(widget.subject, _selected!);
                  },
            child: Text(widget.subjectIndex < widget.totalSubjects - 1 ? 'Next subject' : 'Continue'),
          ),
        ),
      ],
    );
  }
}

class _Level {
  const _Level({
    required this.index,
    required this.icon,
    required this.label,
    required this.description,
  });
  final int index;
  final IconData icon;
  final String label;
  final String description;
}
