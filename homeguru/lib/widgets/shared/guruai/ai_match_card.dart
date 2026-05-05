import 'package:flutter/material.dart';

class AIMatchCard extends StatefulWidget {
  const AIMatchCard({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  State<AIMatchCard> createState() => _AIMatchCardState();
}

class _AIMatchCardState extends State<AIMatchCard> with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
    
    _shimmerAnimation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            _GradientBlob(
              top: -120,
              right: -120,
              size: 320,
              color: const Color(0xFF4A90E2),
              opacity: isDark ? 0.5 : 0.25,
            ),
            _GradientBlob(
              bottom: -100,
              left: -100,
              size: 280,
              color: const Color(0xFFFF9F5C),
              opacity: isDark ? 0.45 : 0.22,
            ),
            _GradientBlob(
              top: -80,
              left: -60,
              size: 560,
              color: const Color(0xFFA8C5FF),
              opacity: isDark ? 0.22 : 0.12,
            ),
            AnimatedBuilder(
              animation: _shimmerAnimation,
              builder: (context, child) {
                return Positioned.fill(
                  child: Transform.translate(
                    offset: Offset(_shimmerAnimation.value * 200, 0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.transparent,
                            Colors.white.withValues(alpha: isDark ? 0.03 : 0.15),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: cs.outlineVariant),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome_rounded, size: 14, color: cs.primary),
                        const SizedBox(width: 6),
                        Text(
                          'AI-Powered Matching',
                          style: tt.labelSmall?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  RichText(
                    text: TextSpan(
                      style: tt.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w400,
                        color: cs.onSurface,
                        height: 1.35,
                        letterSpacing: -0.01,
                      ),
                      children: [
                        const TextSpan(text: 'Your perfect tutor,\n'),
                        TextSpan(
                          text: 'matched by AI',
                          style: TextStyle(fontWeight: FontWeight.w500, color: cs.primary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'No more guessing. Meet tutors aligned with your learning goals.',
                    style: tt.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: widget.onTap,
                    style: FilledButton.styleFrom(
                      backgroundColor: cs.primaryContainer,
                      foregroundColor: cs.onPrimaryContainer,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Find my match',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: cs.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward_rounded, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GradientBlob extends StatelessWidget {
  final double? top, bottom, left, right;
  final double size;
  final Color color;
  final double opacity;

  const _GradientBlob({
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.size,
    required this.color,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: opacity),
              color.withValues(alpha: 0.0),
            ],
            stops: const [0.0, 0.85],
          ),
        ),
      ),
    );
  }
}
