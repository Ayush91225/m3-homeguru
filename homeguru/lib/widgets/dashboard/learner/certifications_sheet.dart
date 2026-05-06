import 'package:flutter/material.dart';
import '../../../screens/dashboard/learner/certifications_screen.dart';

const _certs = [
  (icon: Icons.workspace_premium_rounded, title: 'Math', earned: true, colorIndex: 0),
  (icon: Icons.science_rounded, title: 'Science', earned: true, colorIndex: 1),
  (icon: Icons.language_rounded, title: 'English', earned: true, colorIndex: 2),
  (icon: Icons.calculate_rounded, title: 'Algebra', earned: true, colorIndex: 3),
  (icon: Icons.biotech_rounded, title: 'Biology', earned: true, colorIndex: 4),
  (icon: Icons.public_rounded, title: 'Geography', earned: true, colorIndex: 5),
  (icon: Icons.history_edu_rounded, title: 'History', earned: false, colorIndex: 6),
  (icon: Icons.palette_rounded, title: 'Art', earned: false, colorIndex: 7),
  (icon: Icons.music_note_rounded, title: 'Music', earned: false, colorIndex: 8),
  (icon: Icons.sports_soccer_rounded, title: 'Sports', earned: false, colorIndex: 0),
  (icon: Icons.computer_rounded, title: 'Tech', earned: false, colorIndex: 1),
  (icon: Icons.psychology_rounded, title: 'Psychology', earned: false, colorIndex: 2),
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

class CertificationsSheet extends StatelessWidget {
  const CertificationsSheet({super.key});

  static void show(BuildContext context) => showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (_) => const CertificationsSheet(),
      );

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final earned = _certs.where((c) => c.earned).length;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // handle + open
          Row(
            children: [
              const Spacer(),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CertificationsScreen()));
                },
                icon: Icon(Icons.open_in_new_rounded, color: cs.primary, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // title + count
          Row(
            children: [
              Text('Certifications',
                  style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('$earned earned',
                    style: tt.labelMedium?.copyWith(
                        color: cs.onPrimaryContainer, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // certifications
          SizedBox(
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _certs.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final c = _certs[i];
                final certColor = isDark 
                    ? _certColors[c.colorIndex % _certColors.length].dark
                    : _certColors[c.colorIndex % _certColors.length].light;
                
                return Container(
                  width: 70,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: cs.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: certColor.withValues(alpha: isDark ? 0.25 : 0.18),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(c.icon,
                            size: 20,
                            color: certColor),
                      ),
                      const SizedBox(height: 6),
                      Text(c.title,
                          style: tt.labelSmall?.copyWith(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      if (!c.earned) ...[ 
                        const SizedBox(height: 2),
                        Icon(Icons.lock_rounded, size: 10, color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
