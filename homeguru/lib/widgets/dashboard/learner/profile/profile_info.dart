import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../services/learner_profile_service.dart';
import '../../../../services/learner_data_model.dart';
import '../../../profile_edit_screen.dart';

class ProfileInfo extends StatefulWidget {
  const ProfileInfo({super.key});

  @override
  State<ProfileInfo> createState() => _ProfileInfoState();
}

class _ProfileInfoState extends State<ProfileInfo> {
  Map<String, dynamic>? _profile;
  Map<String, dynamic>? _stats;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final learnerId = prefs.getString('userId');
      if (learnerId == null) {
        setState(() => _loading = false);
        return;
      }

      final profile = await LearnerProfileService.fetchProfile(learnerId);
      final stats = await LearnerDataModel.fetchLearnerStats(learnerId);

      if (mounted) {
        setState(() {
          _profile = profile;
          _stats = stats;
          _loading = false;
        });
      }
    } catch (e) {
      print('Error loading profile data: $e');
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _navigateToEdit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileEditScreen()),
    );
    if (result == true) {
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final firstName = _profile?['firstName']?.toString() ?? '';
    final lastName = _profile?['lastName']?.toString() ?? '';
    final name = '$firstName $lastName'.trim();
    final bio = _profile?['bio']?.toString() ?? 'No bio yet';
    final email = _profile?['email']?.toString() ?? '';
    final joinedDate = _profile?['createdAt']?.toString() ?? '';
    final joined = joinedDate.isNotEmpty ? 'Joined ${_formatDate(joinedDate)}' : 'Joined recently';

    final sessions = _stats?['sessions'] ?? 0;
    final tutors = _stats?['tutors'] ?? 0;
    final hours = _stats?['hours'] ?? 0;
    final streak = _stats?['streak'] ?? 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _PillButton(
                label: 'Edit',
                icon: Icons.edit_outlined,
                outlined: false,
                cs: cs,
                tt: tt,
                onTap: _navigateToEdit,
              ),
              const SizedBox(width: 8),
              _PillButton(label: 'Share', icon: Icons.reply_rounded, outlined: true, cs: cs, tt: tt),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Flexible(
                child: Text(name.isNotEmpty ? name : 'Student',
                    style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w500)),
              ),
              const SizedBox(width: 5),
              Icon(Icons.verified_rounded, size: 16, color: cs.primary),
            ],
          ),
          const SizedBox(height: 1),
          Text(email, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text(bio, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 14,
            runSpacing: 4,
            children: [
              _Meta(icon: Icons.calendar_today_outlined, label: joined, cs: cs, tt: tt),
            ],
          ),
          const SizedBox(height: 20),
          _StatsRow(sessions: sessions, tutors: tutors, hours: hours, streak: streak, cs: cs, tt: tt),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return 'recently';
    }
  }
}

// ─── Supporting widgets ───────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.sessions,
    required this.tutors,
    required this.hours,
    required this.streak,
    required this.cs,
    required this.tt,
  });
  final int sessions;
  final int tutors;
  final int hours;
  final int streak;
  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    final stats = [
      ('$sessions', 'Sessions'),
      ('$tutors', 'Tutors'),
      ('${hours}h', 'Learning'),
      ('$streak', 'Streak'),
    ];
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

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.label,
    required this.icon,
    required this.outlined,
    required this.cs,
    required this.tt,
    this.onTap,
  });
  final String label;
  final IconData icon;
  final bool outlined;
  final ColorScheme cs;
  final TextTheme tt;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(999));
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13),
        const SizedBox(width: 5),
        Text(label, style: tt.labelSmall?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
    if (outlined) {
      return OutlinedButton(
        onPressed: onTap ?? () {},
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          minimumSize: const Size(0, 32),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: shape,
          side: BorderSide(color: cs.outlineVariant),
        ),
        child: child,
      );
    }
    return FilledButton(
      onPressed: onTap ?? () {},
      style: FilledButton.styleFrom(
        backgroundColor: cs.primaryContainer,
        foregroundColor: cs.onPrimaryContainer,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        minimumSize: const Size(0, 32),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: shape,
      ),
      child: child,
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
