import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../widgets/mascot/teacher_sprite.dart';

class TutorStep10Body extends StatelessWidget {
  const TutorStep10Body({super.key, required this.tutorName, required this.onGoLive});
  final String tutorName;
  final VoidCallback onGoLive;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showCongratsOverlay(context);
    });

    return const SizedBox.shrink();
  }

  void _showCongratsOverlay(BuildContext context) {
    HapticFeedback.mediumImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black54,
        barrierDismissible: false,
        pageBuilder: (context, animation, secondaryAnimation) => SlideTransition(
          position: Tween(begin: const Offset(0, 1), end: Offset.zero)
              .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
          child: _CongratsOverlay(
            tutorName: tutorName,
            onStart: () {
              Navigator.of(context).pop();
              onGoLive();
            },
          ),
        ),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }
}

class _CongratsOverlay extends StatelessWidget {
  const _CongratsOverlay({required this.tutorName, required this.onStart});
  final String tutorName;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final w = MediaQuery.sizeOf(context).width;
    final hPad = w >= 600 ? w * 0.2 : 24.0;
    const spriteSize = 160.0;
    const spriteOverhang = spriteSize;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            // Sheet surface
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 32),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Container(
                    width: 32,
                    height: 4,
                    decoration: BoxDecoration(
                      color: cs.onSurfaceVariant.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "You're live${tutorName.isNotEmpty ? ', $tutorName' : ''}!",
                    style: tt.headlineMedium?.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Your profile is now live.\nStudents can find and book you.",
                    style: tt.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _Highlight(emoji: '💰', label: 'Earn from\nhome', cs: cs, tt: tt),
                      _Highlight(emoji: '📅', label: 'Flexible\nschedule', cs: cs, tt: tt),
                      _Highlight(emoji: '🎓', label: 'Impact\nstudents', cs: cs, tt: tt),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: onStart,
                      child: const Text('Go to Dashboard'),
                    ),
                  ),
                ],
              ),
            ),
            // Sprite sitting on top edge
            Positioned(
              top: -spriteOverhang,
              child: const TeacherSprite(size: spriteSize),
            ),
          ],
        ),
      ),
    );
  }
}

class _Highlight extends StatelessWidget {
  const _Highlight({
    required this.emoji,
    required this.label,
    required this.cs,
    required this.tt,
  });
  final String emoji;
  final String label;
  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: cs.tertiaryContainer,
              shape: BoxShape.circle,
            ),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 24))),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: tt.labelSmall?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      );
}
