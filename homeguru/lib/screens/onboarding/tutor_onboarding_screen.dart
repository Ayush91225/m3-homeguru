import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/onboarding/onboarding_header.dart';
import '../../widgets/mascot/open_sprite.dart';
import 'tutor/step0.dart';
import 'tutor/step1.dart';
import 'tutor/step1a.dart';
import 'tutor/step2.dart';
import 'tutor/step3.dart';
import 'tutor/step4.dart';
import 'tutor/step5.dart';
import 'tutor/step6.dart';
import 'tutor/step7.dart';
import 'tutor/step8.dart';
import 'tutor/step9.dart';

class TutorOnboardingScreen extends StatefulWidget {
  const TutorOnboardingScreen({super.key});

  static void show(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const TutorOnboardingScreen()),
    );
  }

  @override
  State<TutorOnboardingScreen> createState() => _TutorOnboardingScreenState();
}

class _StepState {
  const _StepState({required this.stepValue, required this.showHeader, required this.title, required this.subtitle});
  final double stepValue;
  final bool showHeader;
  final String title;
  final String subtitle;
}

class _TutorOnboardingScreenState extends State<TutorOnboardingScreen> {
  static const int _totalSteps = 10;
  final _navKey = GlobalKey<NavigatorState>();

  final List<_StepState> _history = [
    const _StepState(stepValue: 0, showHeader: false, title: '', subtitle: ''),
  ];

  String _email = '';
  String _phoneCountry = 'India';
  String _firstName = '';
  String _lastName = '';
  bool _testPassed = false;
  int _testScore = 0;

  _StepState get _current => _history.last;

  void _push(_StepState state, Widget page) {
    setState(() => _history.add(state));
    _navKey.currentState?.push(_route(page));
  }

  void _back() {
    HapticFeedback.selectionClick();
    if (_history.length <= 1) { Navigator.of(context).pop(); return; }
    setState(() => _history.removeLast());
    _navKey.currentState?.pop();
  }

  void _goStep1() => _push(
    const _StepState(stepValue: 1, showHeader: true, title: 'Create your account', subtitle: 'Tell us a bit about yourself.'),
    TutorStep1Body(onNext: (email, phoneCountry, firstName, lastName, password) {
      _email = email; _phoneCountry = phoneCountry; _firstName = firstName; _lastName = lastName;
      _goStep1a();
    }),
  );

  void _goStep1a() => _push(
    const _StepState(stepValue: 1, showHeader: true, title: 'Verify your email', subtitle: 'Check your inbox to continue.'),
    TutorStep1aBody(email: _email, onNext: _goStep2),
  );

  void _goStep2() => _push(
    const _StepState(stepValue: 2, showHeader: true, title: 'About you', subtitle: 'Tell us about yourself as a tutor.'),
    TutorStep2Body(firstName: _firstName, lastName: _lastName, phoneCountry: _phoneCountry, onNext: (_) => _goStep3()),
  );

  void _goStep3() => _push(
    const _StepState(stepValue: 3, showHeader: true, title: 'Your journey', subtitle: 'Becoming a HomeGuru Tutor.'),
    TutorStep3Body(onNext: _goStep4),
  );

  void _goStep4() => _push(
    const _StepState(stepValue: 4, showHeader: true, title: 'What you teach', subtitle: 'Select subjects and topics'),
    TutorStep4Body(onNext: (_) => _goStep5()),
  );

  void _goStep5() => _push(
    const _StepState(stepValue: 5, showHeader: true, title: 'Teaching assessment', subtitle: '10 questions · ~15 minutes · proctored'),
    TutorStep5Body(
      onPass: () { _testPassed = true; _testScore = 75; _goStep6(); },
      onFail: () { _testPassed = false; _testScore = 40; _goStep6(); },
    ),
  );

  void _goStep6() => _push(
    _StepState(stepValue: 6, showHeader: true, title: _testPassed ? 'Assessment passed!' : 'Assessment result', subtitle: _testPassed ? 'Well done!' : 'Better luck next time.'),
    TutorStep6Body(passed: _testPassed, score: _testScore, onContinue: _goStep7),
  );

  void _goStep7() => _push(
    const _StepState(stepValue: 7, showHeader: true, title: 'Annual listing fee', subtitle: '₹499/year · valid for 365 days'),
    TutorStep7Body(onNext: (_) => _goStep8()),
  );

  void _goStep8() => _push(
    const _StepState(stepValue: 8, showHeader: true, title: 'Identity verification', subtitle: 'Aadhaar & PAN via DigiLocker'),
    TutorStep8Body(onNext: _goStep9),
  );

  void _goStep9() => _push(
    const _StepState(stepValue: 9, showHeader: true, title: 'Bank account', subtitle: 'Where we send your earnings'),
    TutorStep9Body(tutorName: '$_firstName $_lastName'.trim(), onNext: (_) => _goFinish()),
  );

  void _goFinish() {
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
            tutorName: _firstName,
            onStart: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('logged_in_user', 'tutor');
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/tutor-dashboard',
                  (route) => false,
                );
              }
            },
          ),
        ),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  PageRoute _route(Widget page) => PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, anim, secondaryAnimation, child) =>
        FadeTransition(opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut), child: child),
    transitionDuration: const Duration(milliseconds: 220),
  );

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final w = MediaQuery.sizeOf(context).width;
    final hPad = w >= 600 ? w * 0.2 : 24.0;
    final cur = _current;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) { if (!didPop) _back(); },
      child: Scaffold(
        backgroundColor: cs.surface,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (cur.showHeader)
                Padding(
                  padding: EdgeInsets.fromLTRB(hPad, 24, hPad, 0),
                  child: OnboardingHeader(
                    step: cur.stepValue.ceil().clamp(1, _totalSteps),
                    totalSteps: _totalSteps,
                    progress: cur.stepValue / _totalSteps,
                    title: cur.title,
                    subtitle: cur.subtitle,
                    onBack: _back,
                    useTertiary: true,
                  ),
                ),
              Expanded(
                child: Navigator(
                  key: _navKey,
                  onGenerateRoute: (_) => _route(TutorStep0Body(onNext: _goStep1)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Congrats overlay
// ─────────────────────────────────────────────────────────────────────────────

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
                      style: FilledButton.styleFrom(
                        backgroundColor: cs.tertiary,
                        foregroundColor: cs.onTertiary,
                      ),
                      child: const Text('Go to Dashboard'),
                    ),
                  ),
                ],
              ),
            ),
            // Sprite sitting on top edge
            Positioned(
              top: -spriteOverhang,
              child: const OpenSprite(size: spriteSize),
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
