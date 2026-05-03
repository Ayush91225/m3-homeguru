import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../screens/onboarding/learner_onboarding_screen.dart';
import '../../screens/onboarding/tutor_onboarding_screen.dart';

const double _kTablet = 600;

class RoleSheet extends StatelessWidget {
  const RoleSheet({super.key});

  /// Call this to show the sheet from any context
  static void show(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const RoleSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final w = MediaQuery.sizeOf(context).width;
    final hPad = w >= _kTablet ? w * 0.2 : 24.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 32,
            height: 4,
            decoration: BoxDecoration(
              color: cs.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 20),

          Text('How will you use HomeGuru?',
              style: tt.headlineSmall?.copyWith(color: cs.onSurface),
              textAlign: TextAlign.center),

          const SizedBox(height: 6),

          Text('Pick your role to personalise your experience.',
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center),

          const SizedBox(height: 24),

          _RoleCard(
            icon: Icons.menu_book_rounded,
            title: 'Learner',
            subtitle: 'Discover courses, book sessions\nand track your progress.',
            containerColor: cs.primaryContainer,
            onContainerColor: cs.onPrimaryContainer,
            onTap: () {
              HapticFeedback.mediumImpact();
              Navigator.pop(context);
              LearnerOnboardingScreen.show(context);
            },
          ),

          const SizedBox(height: 12),

          _RoleCard(
            icon: Icons.co_present_rounded,
            title: 'Tutor',
            subtitle: 'Create lessons, manage students\nand grow your audience.',
            containerColor: cs.tertiaryContainer,
            onContainerColor: cs.onTertiaryContainer,
            onTap: () {
              HapticFeedback.mediumImpact();
              Navigator.pop(context);
              TutorOnboardingScreen.show(context);
            },
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.containerColor,
    required this.onContainerColor,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color containerColor;
  final Color onContainerColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: containerColor,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: cs.surface.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, size: 26, color: onContainerColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: tt.titleMedium?.copyWith(
                            color: onContainerColor,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: tt.bodySmall?.copyWith(
                            color: onContainerColor.withValues(alpha: 0.8),
                            height: 1.5)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: onContainerColor.withValues(alpha: 0.7)),
            ],
          ),
        ),
      ),
    );
  }
}
