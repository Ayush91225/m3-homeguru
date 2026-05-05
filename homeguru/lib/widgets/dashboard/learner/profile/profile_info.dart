import 'package:flutter/material.dart';
import '../../../../services/user_profile_store.dart';

class ProfileInfo extends StatelessWidget {
  const ProfileInfo({super.key});

  static const _joined         = 'Joined June 2025';
  static const _subProfilesMax = 3;
  static const _verified       = true;

  @override
  Widget build(BuildContext context) {
    final cs    = Theme.of(context).colorScheme;
    final tt    = Theme.of(context).textTheme;
    final store = ProfileStore.of(context);
    final count = store.subProfiles.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _PillButton(label: 'Share', icon: Icons.reply_rounded, outlined: true, cs: cs, tt: tt),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Flexible(
                child: Text(store.name,
                    style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w500)),
              ),
              if (_verified) ...[
                const SizedBox(width: 5),
                Icon(Icons.verified_rounded, size: 16, color: cs.primary),
              ],
            ],
          ),
          const SizedBox(height: 1),
          Text(store.handle, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text(store.bio,    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 14,
            runSpacing: 4,
            children: [
              _Meta(icon: Icons.calendar_today_outlined, label: _joined,                              cs: cs, tt: tt),
              _Meta(icon: Icons.people_outline_rounded,  label: 'Sub-profiles: $count/$_subProfilesMax', cs: cs, tt: tt),
            ],
          ),
          const SizedBox(height: 20),
          _StatsRow(cs: cs, tt: tt),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

// ─── Supporting widgets ───────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.cs, required this.tt});
  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    const stats = [('24', 'Sessions'), ('6', 'Tutors'), ('48h', 'Learning'), ('12', 'Streak')];
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
    required this.label, required this.icon,
    required this.outlined, required this.cs, required this.tt,
  });
  final String label;
  final IconData icon;
  final bool outlined;
  final ColorScheme cs;
  final TextTheme tt;

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
        onPressed: () {},
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
      onPressed: () {},
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
