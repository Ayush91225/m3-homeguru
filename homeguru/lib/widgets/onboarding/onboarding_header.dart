import 'package:flutter/material.dart';

class OnboardingHeader extends StatelessWidget {
  const OnboardingHeader({
    super.key,
    required this.step,
    required this.totalSteps,
    required this.title,
    required this.subtitle,
    this.progress,
    this.onBack,
    this.progressColor,
    this.useTertiary = false,
  });

  final int step;
  final int totalSteps;
  final String title;
  final String subtitle;
  final double? progress;
  final VoidCallback? onBack;
  final Color? progressColor;
  final bool useTertiary;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final p = progress ?? step / totalSteps;
    final barColor = progressColor ?? (useTertiary ? cs.tertiary : cs.primary);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (onBack != null) ...[
              IconButton(
                onPressed: onBack,
                icon: Icon(Icons.arrow_back_rounded, color: cs.onSurface),
                style: IconButton.styleFrom(
                  backgroundColor: cs.surfaceContainerHighest,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(8),
                  minimumSize: const Size(36, 36),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: p),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOut,
                builder: (context, value, child) => LinearProgressIndicator(
                  value: value,
                  borderRadius: BorderRadius.circular(8),
                  minHeight: 6,
                  backgroundColor: cs.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation(barColor),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '$step/$totalSteps',
              style: tt.labelSmall?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Column(
            key: ValueKey(title),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: tt.headlineMedium?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
