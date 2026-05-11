import 'package:flutter/material.dart';
import 'stat_card.dart';
import '../../../services/learner_data_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StatsCarousel extends StatefulWidget {
  const StatsCarousel({super.key});

  @override
  State<StatsCarousel> createState() => _StatsCarouselState();
}

class _StatsCarouselState extends State<StatsCarousel> {
  Map<String, dynamic> _stats = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final learnerId = prefs.getString('userId');
      if (learnerId != null) {
        final stats = await LearnerDataModel.fetchLearnerStats(learnerId);
        if (mounted) {
          setState(() {
            _stats = stats;
            _loading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading stats: $e');
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  List<({String value, String label, IconData icon})> get _statsData => [
    (value: _stats['xp']?.toString() ?? '0', label: 'XP', icon: Icons.stars_rounded),
    (value: '${_stats['streak'] ?? 0}d', label: 'Streak', icon: Icons.local_fire_department_rounded),
    (value: _stats['sessions']?.toString() ?? '0', label: 'Sessions', icon: Icons.event_available_rounded),
    (value: '${(_stats['hours'] ?? 0).toStringAsFixed(1)}h', label: 'Hours', icon: Icons.schedule_rounded),
    (value: _stats['tutors']?.toString() ?? '0', label: 'Tutors', icon: Icons.people_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (_loading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 16),
            child: Row(
              children: [
                Icon(Icons.analytics_rounded, size: 18, color: cs.onSurfaceVariant),
                const SizedBox(width: 8),
                Text(
                  'Your Stats',
                  style: tt.bodyMedium?.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
            ),
            child: const Center(child: CircularProgressIndicator()),
          ),
        ],
      );
    }

    final stats = _statsData;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Row(
            children: [
              Icon(Icons.analytics_rounded, size: 18, color: cs.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(
                'Your Stats',
                style: tt.bodyMedium?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 120,
          child: CarouselView.weighted(
            flexWeights: const [3, 2, 1],
            itemSnapping: true,
            padding: EdgeInsets.zero,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            children: [
              ...List.generate(stats.length, (i) {
                final stat = stats[i];

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final w = constraints.maxWidth;

                    final isSmall = w < 72;
                    final isMedium = w < 120;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: StatCard(
                        value: stat.value,
                        label: stat.label,
                        icon: stat.icon,
                        bgColor: cs.surface,
                        fgColor: cs.onSurface,
                        accentColor: cs.primary,
                        showLabel: !isMedium,
                        showValue: !isSmall,
                        iconSize: isSmall ? 22.0 : (isMedium ? 26.0 : 30.0),
                      ),
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}
