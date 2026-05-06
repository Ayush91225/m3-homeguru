import 'package:flutter/material.dart';
import '../../../widgets/dashboard/learner/referral_hero_card.dart';
import '../../../widgets/dashboard/learner/referrals_carousel.dart';
import '../../../widgets/dashboard/learner/contacts_list.dart';

const _mockReferrals = [
  (name: 'Aryan Mehta', phone: '+91 98765 43210', status: 'joined', xp: 200),
  (name: 'Priya Sharma', phone: '+91 98765 43211', status: 'joined', xp: 200),
  (name: 'Rohan Gupta', phone: '+91 98765 43212', status: 'pending', xp: 0),
  (name: 'Sneha Patel', phone: '+91 98765 43213', status: 'joined', xp: 200),
  (name: 'Vikram Singh', phone: '+91 98765 43214', status: 'pending', xp: 0),
];

class ReferralsScreen extends StatelessWidget {
  const ReferralsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final earnedXP = _mockReferrals.where((r) => r.status == 'joined').fold(0, (sum, r) => sum + r.xp);
    final totalReferrals = _mockReferrals.length;

    return Scaffold(
      backgroundColor: cs.surface,
      extendBodyBehindAppBar: true,
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: ReferralHeroCard()),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.people_rounded,
                      label: 'Your Referrals',
                      value: '$totalReferrals',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.stars_rounded,
                      label: 'Earned XP',
                      value: '$earnedXP',
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Text('Your Referrals', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            ),
          ),

          SliverToBoxAdapter(
            child: ReferralsCarousel(referrals: _mockReferrals),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('How to Refer & Earn', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _HowToCard(
                          icon: Icons.share_rounded,
                          title: 'Share Link',
                          desc: 'Send your referral code to friends',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _HowToCard(
                          icon: Icons.person_add_rounded,
                          title: 'Friend Joins',
                          desc: 'They sign up using your code',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _HowToCard(
                          icon: Icons.school_rounded,
                          title: 'First Session',
                          desc: 'They complete their first session',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _HowToCard(
                          icon: Icons.emoji_events_rounded,
                          title: 'Earn Rewards',
                          desc: 'You both get 200 XP',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Text('Refer a Friend', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          const ContactsList(),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: cs.primary, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: tt.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _HowToCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;

  const _HowToCard({
    required this.icon,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: cs.onPrimaryContainer, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: tt.labelLarge?.copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
