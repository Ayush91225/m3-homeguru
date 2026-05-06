import 'package:flutter/material.dart';
import '../../../widgets/dashboard/learner/certifications_hero_card.dart';

const _allCertifications = [
  (icon: Icons.workspace_premium_rounded, title: 'Math Mastery', desc: 'Completed Advanced Math', earned: true, colorIndex: 0),
  (icon: Icons.science_rounded, title: 'Science Pro', desc: 'Completed Science Course', earned: true, colorIndex: 1),
  (icon: Icons.language_rounded, title: 'English Expert', desc: 'Completed English Course', earned: true, colorIndex: 2),
  (icon: Icons.calculate_rounded, title: 'Algebra Champion', desc: 'Mastered Algebra', earned: true, colorIndex: 3),
  (icon: Icons.biotech_rounded, title: 'Biology Star', desc: 'Completed Biology', earned: true, colorIndex: 4),
  (icon: Icons.public_rounded, title: 'Geography Guru', desc: 'Completed Geography', earned: true, colorIndex: 5),
  (icon: Icons.history_edu_rounded, title: 'History Scholar', desc: 'Completed History', earned: false, colorIndex: 6),
  (icon: Icons.palette_rounded, title: 'Art Enthusiast', desc: 'Completed Art Course', earned: false, colorIndex: 7),
  (icon: Icons.music_note_rounded, title: 'Music Maestro', desc: 'Completed Music Theory', earned: false, colorIndex: 8),
  (icon: Icons.sports_soccer_rounded, title: 'Sports Champion', desc: 'Completed PE Course', earned: false, colorIndex: 0),
  (icon: Icons.computer_rounded, title: 'Tech Wizard', desc: 'Completed Computer Science', earned: false, colorIndex: 1),
  (icon: Icons.psychology_rounded, title: 'Psychology Pro', desc: 'Completed Psychology', earned: false, colorIndex: 2),
];

const _certColors = [
  (light: Color(0xFF81C784), dark: Color(0xFF81C784)), // Green
  (light: Color(0xFF64B5F6), dark: Color(0xFF64B5F6)), // Blue
  (light: Color(0xFF9575CD), dark: Color(0xFF9575CD)), // Purple
  (light: Color(0xFFFFB74D), dark: Color(0xFFFFB74D)), // Orange
  (light: Color(0xFFF06292), dark: Color(0xFFF06292)), // Pink
  (light: Color(0xFF4DB6AC), dark: Color(0xFF4DB6AC)), // Teal
  (light: Color(0xFFE57373), dark: Color(0xFFEF5350)), // Red
  (light: Color(0xFFFFD54F), dark: Color(0xFFFFD54F)), // Amber
  (light: Color(0xFF90CAF9), dark: Color(0xFF90CAF9)), // Light Blue
];

class CertificationsScreen extends StatefulWidget {
  const CertificationsScreen({super.key});

  @override
  State<CertificationsScreen> createState() => _CertificationsScreenState();
}

class _CertificationsScreenState extends State<CertificationsScreen> {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final earned = _allCertifications.where((c) => c.earned).toList();

    return Scaffold(
      backgroundColor: cs.surface,
      extendBodyBehindAppBar: true,
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: CertificationsHeroCard()),

          // ── stats cards ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.workspace_premium_rounded,
                      label: 'Certificates Earned',
                      value: '${earned.length}',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.emoji_events_rounded,
                      label: 'Total Courses',
                      value: '${_allCertifications.length}',
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── "All Certifications" title ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Text('All Certifications', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            ),
          ),

          // ── certifications carousel ──
          SliverToBoxAdapter(
            child: SizedBox(
              height: 140,
              child: CarouselView.weighted(
                flexWeights: const [3, 2, 1],
                padding: EdgeInsets.zero,
                itemSnapping: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                children: _allCertifications.map((cert) {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final w = constraints.maxWidth;
                      final isSmall = w < 100;
                      final isMedium = w < 200;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: _CertCarouselCard(
                          cert: cert,
                          isSmall: isSmall,
                          isMedium: isMedium,
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ),
          ),

          // ── "Earned Certificates" title ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Text('Earned Certificates (${earned.length})', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            ),
          ),

          // ── earned certificates grid ──
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            sliver: SliverGrid.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: earned.length,
              itemBuilder: (_, i) {
                final cert = earned[i];
                return _EarnedCertCard(cert: cert);
              },
            ),
          ),
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

class _CertCarouselCard extends StatelessWidget {
  final ({IconData icon, String title, String desc, bool earned, int colorIndex}) cert;
  final bool isSmall;
  final bool isMedium;

  const _CertCarouselCard({
    required this.cert,
    required this.isSmall,
    required this.isMedium,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final certColor = isDark
        ? _certColors[cert.colorIndex % _certColors.length].dark
        : _certColors[cert.colorIndex % _certColors.length].light;

    if (isSmall) {
      return Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: certColor.withValues(alpha: isDark ? 0.25 : 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(cert.icon, size: 16, color: certColor),
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
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: certColor.withValues(alpha: isDark ? 0.25 : 0.18),
                shape: BoxShape.circle,
              ),
              child: Icon(cert.icon, size: 20, color: certColor),
            ),
            const SizedBox(height: 8),
            Text(
              cert.title,
              style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            if (!cert.earned)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_rounded, size: 10, color: cs.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      'Locked',
                      style: tt.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                  ],
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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: certColor.withValues(alpha: isDark ? 0.25 : 0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(cert.icon, size: 24, color: certColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cert.title,
                      style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      cert.desc,
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
                cert.earned ? Icons.check_circle_rounded : Icons.lock_rounded,
                size: 14,
                color: cert.earned ? certColor : cs.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                cert.earned ? 'Earned' : 'Locked',
                style: tt.labelSmall?.copyWith(
                  color: cert.earned ? certColor : cs.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (cert.earned)
                Icon(Icons.download_rounded, size: 18, color: certColor),
            ],
          ),
        ],
      ),
    );
  }
}

class _EarnedCertCard extends StatelessWidget {
  final ({IconData icon, String title, String desc, bool earned, int colorIndex}) cert;

  const _EarnedCertCard({required this.cert});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final certColor = isDark
        ? _certColors[cert.colorIndex % _certColors.length].dark
        : _certColors[cert.colorIndex % _certColors.length].light;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Container(
            height: 90,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  certColor.withValues(alpha: isDark ? 0.3 : 0.2),
                  certColor.withValues(alpha: isDark ? 0.18 : 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: certColor.withValues(alpha: isDark ? 0.25 : 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(cert.icon, size: 32, color: certColor),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    cert.title,
                    style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cert.desc,
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
