import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class ReferEarnSheet extends StatelessWidget {
  const ReferEarnSheet({super.key});

  static void show(BuildContext context) => showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (_) => const ReferEarnSheet(),
      );

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    const code = 'GURU-VAN42';
    const white = Colors.white;
    const white70 = Colors.white70;

    return SizedBox(
      height: 380,
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // bg image
            Image.asset('assets/refer.png', fit: BoxFit.cover),
            // bottom-up scrim for text readability
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black54, Colors.black87],
                  stops: [0.25, 0.55, 1.0],
                ),
              ),
            ),
            // full-height content
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // handle
                  Center(
                    child: Container(
                      width: 36, height: 4,
                      decoration: BoxDecoration(
                        color: white.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const Spacer(),
                  // heading
                  Text('Refer & Earn',
                      style: tt.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800, color: white)),
                  const SizedBox(height: 6),
                  Text('Invite a friend · you both get 200 XP',
                      style: tt.bodyMedium?.copyWith(color: white70)),
                  const Spacer(),
                  // XP reward chips
                  Row(
                    children: [
                      _XpChip(icon: Icons.person_rounded, label: 'You get 200 XP'),
                      const SizedBox(width: 10),
                      _XpChip(icon: Icons.group_rounded, label: 'Friend gets 200 XP'),
                    ],
                  ),
                  const Spacer(),
                  // code box
                  InkWell(
                    onTap: () {
                      Clipboard.setData(const ClipboardData(text: code));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Code copied!'),
                            duration: Duration(seconds: 2)),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.35), width: 1.5),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.confirmation_number_rounded,
                              size: 18, color: white),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(code,
                                style: tt.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 3,
                                    color: white)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('COPY',
                                style: tt.labelSmall?.copyWith(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // share button
                  FilledButton.icon(
                    onPressed: () => Share.share(
                      'Join me on HomeGuru! Use my referral code $code to get 200 XP 🎉\nhttps://app.homeguruworld.com/refer/$code',
                      subject: 'Join HomeGuru',
                    ),
                    icon: const Icon(Icons.share_rounded, size: 16),
                    label: const Text('Share Invite Link'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(44),
                      backgroundColor: white,
                      foregroundColor: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _XpChip extends StatelessWidget {
  const _XpChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 5),
          Text(label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
