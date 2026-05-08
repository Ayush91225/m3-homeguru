import 'package:flutter/material.dart';

enum ClassSection { rec, transcript, aiNotes, chats, files, quiz, polls, flashcards }

const sectionLabels = {
  ClassSection.rec: 'Class Rec',
  ClassSection.transcript: 'Transcript',
  ClassSection.aiNotes: 'AI Notes',
  ClassSection.chats: 'Chats',
  ClassSection.files: 'Files',
  ClassSection.quiz: 'Quiz',
  ClassSection.polls: 'Polls',
  ClassSection.flashcards: 'Flashcards',
};

const sectionIcons = {
  ClassSection.rec: Icons.play_circle_outline_rounded,
  ClassSection.transcript: Icons.article_outlined,
  ClassSection.aiNotes: Icons.auto_awesome_outlined,
  ClassSection.chats: Icons.chat_bubble_outline_rounded,
  ClassSection.files: Icons.folder_outlined,
  ClassSection.quiz: Icons.quiz_outlined,
  ClassSection.polls: Icons.poll_outlined,
  ClassSection.flashcards: Icons.style_outlined,
};

// ── Section header ────────────────────────────────────────────────────────────

class SectionHeader extends StatelessWidget {
  final ClassSection section;
  const SectionHeader({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
      child: Row(
        children: [
          Icon(sectionIcons[section], size: 18, color: cs.primary),
          const SizedBox(width: 8),
          Text(sectionLabels[section]!, style: tt.titleSmall?.copyWith(color: cs.onSurface)),
        ],
      ),
    );
  }
}

// ── Collapsible section wrapper ───────────────────────────────────────────────

class CollapsibleSection extends StatefulWidget {
  final ClassSection section;
  final Widget child;
  final double previewHeight;

  const CollapsibleSection({
    super.key,
    required this.section,
    required this.child,
    this.previewHeight = 200,
  });

  @override
  State<CollapsibleSection> createState() => _CollapsibleSectionState();
}

class _CollapsibleSectionState extends State<CollapsibleSection> {
  bool _expanded = false;

  void _toggle() {
    setState(() => _expanded = !_expanded);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SectionHeader(section: widget.section),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Stack(
            children: [
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 300),
                crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                firstChild: SizedBox(
                  height: widget.previewHeight,
                  width: double.infinity,
                  child: ClipRect(
                    child: widget.child,
                  ),
                ),
                secondChild: SizedBox(
                  width: double.infinity,
                  child: widget.child,
                ),
              ),
              if (!_expanded)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            cs.surface.withValues(alpha: 0),
                            cs.surface,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: InkWell(
            onTap: _toggle,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _expanded ? 'Show less' : 'Show more',
                    style: tt.labelMedium?.copyWith(color: cs.primary, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: cs.primary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
