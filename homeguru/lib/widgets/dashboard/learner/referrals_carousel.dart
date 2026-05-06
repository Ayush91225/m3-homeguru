import 'package:flutter/material.dart';

class ReferralsCarousel extends StatelessWidget {
  final List<({String name, String phone, String status, int xp})> referrals;

  const ReferralsCarousel({super.key, required this.referrals});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: CarouselView.weighted(
        flexWeights: const [3, 2, 1],
        itemSnapping: true,
        padding: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        children: referrals.map((referral) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final isSmall = w < 100;
              final isMedium = w < 200;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: _ReferralCard(
                  referral: referral,
                  isSmall: isSmall,
                  isMedium: isMedium,
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}

class _ReferralCard extends StatelessWidget {
  final ({String name, String phone, String status, int xp}) referral;
  final bool isSmall;
  final bool isMedium;

  const _ReferralCard({
    required this.referral,
    required this.isSmall,
    required this.isMedium,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isJoined = referral.status == 'joined';

    if (isSmall) {
      return Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Center(
          child: CircleAvatar(
            radius: 16,
            backgroundColor: cs.primaryContainer,
            child: Text(
              referral.name[0],
              style: tt.labelMedium?.copyWith(
                color: cs.onPrimaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      );
    }

    if (isMedium) {
      return Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: cs.primaryContainer,
              child: Text(
                referral.name[0],
                style: tt.labelLarge?.copyWith(
                  color: cs.onPrimaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              referral.name.split(' ')[0],
              style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isJoined
                    ? (isDark ? const Color(0xFF81C784).withValues(alpha: 0.2) : const Color(0xFF81C784).withValues(alpha: 0.15))
                    : cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isJoined ? '+${referral.xp} XP' : 'Pending',
                style: tt.labelSmall?.copyWith(
                  color: isJoined
                      ? (isDark ? const Color(0xFF81C784) : const Color(0xFF2E7D32))
                      : cs.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: cs.primaryContainer,
                child: Text(
                  referral.name[0],
                  style: tt.titleMedium?.copyWith(
                    color: cs.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      referral.name,
                      style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      referral.phone,
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Icon(
                isJoined ? Icons.check_circle_rounded : Icons.schedule_rounded,
                size: 14,
                color: isJoined
                    ? (isDark ? const Color(0xFF81C784) : const Color(0xFF2E7D32))
                    : cs.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                isJoined ? 'Joined' : 'Pending',
                style: tt.labelSmall?.copyWith(
                  color: isJoined
                      ? (isDark ? const Color(0xFF81C784) : const Color(0xFF2E7D32))
                      : cs.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isJoined
                      ? (isDark ? const Color(0xFF81C784).withValues(alpha: 0.2) : const Color(0xFF81C784).withValues(alpha: 0.15))
                      : cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isJoined ? '+${referral.xp} XP' : '0 XP',
                  style: tt.labelMedium?.copyWith(
                    color: isJoined
                        ? (isDark ? const Color(0xFF81C784) : const Color(0xFF2E7D32))
                        : cs.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
