import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../widgets/mascot/teacher_sprite.dart';

class TutorStep0Body extends StatefulWidget {
  const TutorStep0Body({super.key, required this.onNext});
  final VoidCallback onNext;

  @override
  State<TutorStep0Body> createState() => _TutorStep0BodyState();
}

class _TutorStep0BodyState extends State<TutorStep0Body>
    with TickerProviderStateMixin {
  int _page = 0;

  late final AnimationController _contentCtrl;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;
  late final AnimationController _bounceCtrl;
  late final Animation<double> _bounce;

  static const _pages = [
    _Page(emoji: '👋', title: "Hi, I'm Hoot!", body: "I'll help you set up your tutor profile on HomeGuru. Let me show you what's possible!", color: Color(0xFFFFDCC2), onColor: Color(0xFF3A1500)),
    _Page(emoji: '📣', title: 'Reach more students', body: 'Thousands of learners are searching for tutors like you — right now.', color: Color(0xFFD3E3FD), onColor: Color(0xFF041E49)),
    _Page(emoji: '📅', title: 'You set the schedule', body: 'Teach on your own terms — set your availability, rates and subjects.', color: Color(0xFFDCEEFB), onColor: Color(0xFF0D2137)),
    _Page(emoji: '💰', title: 'Earn what you deserve', body: 'Get paid directly. No middlemen, no hidden cuts — just you and your students.', color: Color(0xFFFFDCC2), onColor: Color(0xFF3A1500)),
    _Page(emoji: '🚀', title: "Let's get started!", body: 'Set up your tutor profile in minutes and start getting bookings today.', color: Color(0xFFD3E3FD), onColor: Color(0xFF041E49)),
  ];

  @override
  void initState() {
    super.initState();
    _contentCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _contentFade = CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOut);
    _contentSlide = Tween(begin: const Offset(0.06, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOutCubic));
    _bounceCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2800))..repeat(reverse: true);
    _bounce = Tween(begin: 0.0, end: -8.0).animate(CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeInOut));
    _contentCtrl.forward();
  }

  @override
  void dispose() {
    _contentCtrl.dispose();
    _bounceCtrl.dispose();
    super.dispose();
  }

  void _advance() {
    HapticFeedback.lightImpact();
    if (_page < _pages.length - 1) {
      _contentCtrl.reset();
      setState(() => _page++);
      _contentCtrl.forward();
    } else {
      widget.onNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final size = MediaQuery.sizeOf(context);
    final hPad = size.width >= 600 ? size.width * 0.15 : 24.0;
    final isLast = _page == _pages.length - 1;
    final current = _pages[_page];

    return GestureDetector(
      onTap: _advance,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          // Top bar
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                  style: IconButton.styleFrom(shape: const CircleBorder()),
                ),
                const Spacer(),
                if (!isLast)
                  TextButton(onPressed: widget.onNext, child: const Text('Skip')),
              ],
            ),
          ),
          // Dots
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) {
                final active = i == _page;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 28 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active ? cs.tertiary : cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
          // Mascot
          Expanded(
            flex: 5,
            child: AnimatedBuilder(
              animation: _bounce,
              builder: (_, child) => Transform.translate(offset: Offset(0, _bounce.value), child: child),
              child: Center(
                child: TeacherSprite(size: size.width >= 600 ? 220 : size.height < 700 ? 150 : 190),
              ),
            ),
          ),
          // Bubble
          Expanded(
            flex: 4,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad),
              child: FadeTransition(
                opacity: _contentFade,
                child: SlideTransition(
                  position: _contentSlide,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(color: current.color, borderRadius: BorderRadius.circular(28)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Text(current.emoji, style: const TextStyle(fontSize: 28)),
                              const SizedBox(width: 10),
                              Expanded(child: Text(current.title, style: tt.titleLarge?.copyWith(color: current.onColor, fontWeight: FontWeight.w800))),
                            ]),
                            const SizedBox(height: 10),
                            Text(current.body, style: tt.bodyMedium?.copyWith(color: current.onColor.withValues(alpha: 0.8), height: 1.55)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (!isLast)
                        Center(child: Text('Tap anywhere to continue', style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant))),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Button
          Padding(
            padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 24),
            child: FilledButton(
              onPressed: _advance,
              style: FilledButton.styleFrom(backgroundColor: cs.tertiary, foregroundColor: cs.onTertiary),
              child: Text(isLast ? "Let's go!" : 'Next'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Page {
  const _Page({required this.emoji, required this.title, required this.body, required this.color, required this.onColor});
  final String emoji, title, body;
  final Color color, onColor;
}
