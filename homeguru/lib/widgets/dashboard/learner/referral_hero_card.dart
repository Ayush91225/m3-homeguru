import 'package:flutter/material.dart';
import '../../../screens/shared/wallet/refer_earn_sheet.dart';

class ReferralHeroCard extends StatelessWidget {
  const ReferralHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFFEF5350), const Color(0xFFC62828)]
              : [const Color(0xFFFF6B6B), const Color(0xFFEE5A6F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 8),
              Icon(Icons.card_giftcard_rounded, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Text(
                'Refer & Earn',
                style: tt.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Invite friends and earn 200 XP for each successful referral',
            style: tt.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => ReferEarnSheet.show(context),
            icon: const Icon(Icons.share_rounded),
            label: const Text('Refer Now'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFFEF5350),
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
