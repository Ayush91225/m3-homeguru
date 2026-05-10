import 'package:flutter/material.dart';
import '../../../../services/user_profile_store.dart';
import 'boost_profile_sheet.dart';
import 'boost_analytics_screen.dart';

class TutorProfileInfo extends StatefulWidget {
  const TutorProfileInfo({super.key, this.viewMode = false});
  
  final bool viewMode;

  @override
  State<TutorProfileInfo> createState() => _TutorProfileInfoState();
}

class _TutorProfileInfoState extends State<TutorProfileInfo> {
  static const _joined = 'Teaching since March 2024';
  static const _verified = true;
  
  bool _isBoosted = false;
  DateTime? _boostEndDate;
  String? _boostCity;
  int? _boostBudget;

  void _showBoostSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const BoostProfileSheet(),
    ).then((result) {
      if (result != null && result is Map<String, dynamic>) {
        setState(() {
          _isBoosted = true;
          _boostCity = result['city'];
          _boostBudget = result['budget'];
          _boostEndDate = DateTime.now().add(Duration(days: result['duration']));
        });
      }
    });
  }

  void _showAnalytics() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BoostAnalyticsScreen(
          city: _boostCity!,
          budget: _boostBudget!,
          duration: (_boostEndDate!.difference(DateTime.now()).inDays + 3),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final store = ProfileStore.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(store.name,
                    style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w500)),
              ),
              if (_verified) ...[ 
                const SizedBox(width: 5),
                Icon(Icons.verified_rounded, size: 16, color: cs.tertiary),
              ],
              if (_isBoosted) ...[
                const SizedBox(width: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.workspace_premium, size: 10, color: Colors.white),
                      SizedBox(width: 2),
                      Text(
                        'PREMIUM',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: cs.tertiary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.rocket_launch, size: 10, color: cs.onTertiary),
                      const SizedBox(width: 2),
                      Text(
                        'BOOSTED',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          color: cs.onTertiary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 1),
          Text(store.handle, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text(store.bio, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 14,
            runSpacing: 4,
            children: [
              _Meta(icon: Icons.calendar_today_outlined, label: _joined, cs: cs, tt: tt),
              _Meta(icon: Icons.school_outlined, label: 'Mathematics, Physics', cs: cs, tt: tt),
            ],
          ),
          if (!widget.viewMode) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Edit Profile'),
                    style: FilledButton.styleFrom(
                      backgroundColor: cs.tertiary,
                      foregroundColor: cs.onTertiary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: _isBoosted
                      ? OutlinedButton.icon(
                          onPressed: _showAnalytics,
                          icon: Icon(Icons.analytics_outlined, size: 18, color: cs.tertiary),
                          label: Text('Analytics', style: TextStyle(color: cs.tertiary)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            side: BorderSide(color: cs.tertiary, width: 1.5),
                          ),
                        )
                      : OutlinedButton.icon(
                          onPressed: _showBoostSheet,
                          icon: Icon(Icons.rocket_launch_rounded, size: 18, color: cs.tertiary),
                          label: Text('Boost', style: TextStyle(color: cs.tertiary)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            side: BorderSide(color: cs.tertiary, width: 1.5),
                          ),
                        ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          _StatsRow(cs: cs, tt: tt, viewMode: widget.viewMode),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.cs, required this.tt, required this.viewMode});
  final ColorScheme cs;
  final TextTheme tt;
  final bool viewMode;

  @override
  Widget build(BuildContext context) {
    final stats = viewMode
        ? [('4.8', 'Rating'), ('156', 'Reviews'), ('320+', 'Students'), ('2.5k', 'Hours')]
        : [('42', 'Students'), ('156', 'Sessions'), ('240h', 'Teaching'), ('4.8', 'Rating')];
    
    return Row(
      children: List.generate(stats.length, (i) => Expanded(
        child: Container(
          margin: EdgeInsets.only(right: i < stats.length - 1 ? 8 : 0),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Text(stats[i].$1, style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 1),
              Text(stats[i].$2, style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant, fontSize: 10)),
            ],
          ),
        ),
      )),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.label, required this.cs, required this.tt});
  final IconData icon;
  final String label;
  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: cs.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(label, style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
      ],
    );
  }
}
