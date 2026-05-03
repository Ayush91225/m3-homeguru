import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TutorStep3Body extends StatelessWidget {
  const TutorStep3Body({super.key, required this.onNext});
  final VoidCallback onNext;

  static const _steps = [
    _Step(icon: Icons.menu_book_rounded,      label: 'SUBJECTS',     title: 'Subjects\n& Skills',      body: 'Tell us what you can teach — subjects, skills, and the levels you cover.'),
    _Step(icon: Icons.quiz_rounded,           label: 'TEST',         title: 'Qualification\nTest',     body: 'A short problem-solving test to verify your teaching ability.'),
    _Step(icon: Icons.receipt_long_rounded,   label: 'LISTING FEE',  title: '₹499\nper year',          body: 'One-time annual listing fee · valid for 365 days · no hidden charges.'),
    _Step(icon: Icons.badge_outlined,         label: 'VERIFY',       title: 'ID\nVerification',        body: 'Verify your government-issued ID and bank account for payouts.'),
    _Step(icon: Icons.rocket_launch_rounded,  label: 'GO LIVE',      title: 'Start\nGetting Students', body: 'Your profile goes live instantly — students can find and book you right away.'),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final w = MediaQuery.sizeOf(context).width;
    final hPad = w >= 600 ? w * 0.2 : 24.0;

    final cardColors = [
      (bg: cs.tertiaryContainer,  fg: cs.onTertiaryContainer,  accent: cs.tertiary),
      (bg: cs.primaryContainer,   fg: cs.onPrimaryContainer,   accent: cs.primary),
      (bg: cs.secondaryContainer, fg: cs.onSecondaryContainer, accent: cs.secondary),
      (bg: cs.tertiaryContainer,  fg: cs.onTertiaryContainer,  accent: cs.tertiary),
      (bg: cs.primaryContainer,   fg: cs.onPrimaryContainer,   accent: cs.primary),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Vertical carousel
        Expanded(
          child: LayoutBuilder(builder: (ctx, outer) {
            final itemExtent = outer.maxHeight - 72;
            const shrinkExtent = 72.0;

            return CarouselView(
              scrollDirection: Axis.vertical,
              itemExtent: itemExtent,
              shrinkExtent: shrinkExtent,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              itemSnapping: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(28)),
              ),
              children: List.generate(_steps.length, (i) {
                final step = _steps[i];
                final c = cardColors[i];

                return RepaintBoundary(
                  child: LayoutBuilder(builder: (_, inner) {
                    final isShrunk = inner.maxHeight < itemExtent * 0.5;

                    return Container(
                      decoration: BoxDecoration(color: c.bg),
                      clipBehavior: Clip.hardEdge,
                      child: Stack(
                        clipBehavior: Clip.hardEdge,
                        children: [
                          // Watermark icon
                          if (!isShrunk)
                            Positioned(
                              right: -16,
                              bottom: -16,
                              child: Icon(step.icon, size: 160, color: c.accent.withValues(alpha: 0.07)),
                            ),

                          // Shrunk: show step number + label
                          if (isShrunk)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: c.fg.withValues(alpha: 0.12),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text('${i + 1}',
                                            style: tt.labelSmall?.copyWith(
                                              color: c.fg,
                                              fontWeight: FontWeight.w700,
                                            )),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Icon(step.icon, size: 16, color: c.fg.withValues(alpha: 0.7)),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        step.title.replaceAll('\n', ' '),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: tt.labelMedium?.copyWith(
                                          color: c.fg.withValues(alpha: 0.8),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          // Expanded: full card
                          if (!isShrunk)
                            Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Top row: pill + icon
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: c.accent.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text('${i + 1} of ${_steps.length}',
                                            style: tt.labelSmall?.copyWith(
                                              color: c.accent,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 0.5,
                                            )),
                                      ),
                                      const Spacer(),
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: c.fg.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Icon(step.icon, size: 26, color: c.fg),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  // Label tag
                                  Text(step.label,
                                      style: tt.labelSmall?.copyWith(
                                        color: c.accent,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.4,
                                      )),
                                  const SizedBox(height: 6),
                                  // Big title
                                  Text(step.title,
                                      style: tt.displaySmall?.copyWith(
                                        color: c.fg,
                                        height: 1.0,
                                        fontWeight: FontWeight.w800,
                                      )),
                                  const SizedBox(height: 14),
                                  // Body
                                  Text(step.body,
                                      style: tt.bodyLarge?.copyWith(
                                        color: c.fg.withValues(alpha: 0.75),
                                        height: 1.5,
                                      )),
                                ],
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                );
              }),
            );
          }),
        ),

        Padding(
          padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 16),
          child: FilledButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              onNext();
            },
            style: FilledButton.styleFrom(
              backgroundColor: cs.tertiary,
              foregroundColor: cs.onTertiary,
            ),
            child: const Text("Let's Begin"),
          ),
        ),
      ],
    );
  }
}

class _Step {
  const _Step({required this.icon, required this.label, required this.title, required this.body});
  final IconData icon;
  final String label;
  final String title;
  final String body;
}
