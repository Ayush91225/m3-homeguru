import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/onboarding/onboarding_header.dart';
import '../../widgets/mascot/open_sprite.dart';
import 'learner/step0.dart';
import 'learner/step1.dart';
import 'learner/step1a.dart';
import 'learner/step2.dart';
import 'learner/step3.dart';
import 'learner/step4.dart';
import 'learner/step5.dart';
import 'learner/step6.dart';
import 'learner/step7.dart';
import 'learner/step8.dart';

class LearnerOnboardingScreen extends StatefulWidget {
  const LearnerOnboardingScreen({super.key});

  static void show(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LearnerOnboardingScreen()),
    );
  }

  @override
  State<LearnerOnboardingScreen> createState() =>
      _LearnerOnboardingScreenState();
}

class _StepState {
  const _StepState({
    required this.stepValue,
    required this.showHeader,
    required this.title,
    required this.subtitle,
  });
  final double stepValue;
  final bool showHeader;
  final String title;
  final String subtitle;
}

class _LearnerOnboardingScreenState extends State<LearnerOnboardingScreen> {
  static const int _totalSteps = 8;

  final _navKey = GlobalKey<NavigatorState>();

  final List<_StepState> _history = [
    const _StepState(stepValue: 0, showHeader: false, title: '', subtitle: ''),
  ];

  String _email = '';
  String _phoneCountry = 'India';
  String _firstName = '';
  String _lastName = '';
  String _interest = '';
  // ignore: unused_field
  String _subject = '';
  List<String> _realSubjects = [];
  final Map<String, int> _proficiency = {};
  // ignore: unused_field
  Map<String, dynamic> _profile = {};
  int _categoryIndex = -1;

  _StepState get _current => _history.last;

  void _push(_StepState state, Widget page) {
    setState(() => _history.add(state));
    _navKey.currentState?.push(_route(page));
  }

  void _back() {
    HapticFeedback.selectionClick();
    if (_history.length <= 1) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _history.removeLast());
    _navKey.currentState?.pop();
  }

  void _goStep1() {
    _push(
      const _StepState(stepValue: 1, showHeader: true, title: 'Create your account', subtitle: 'Tell us a bit about yourself.'),
      LearnerStep1Body(onNext: (email, phoneCountry, firstName, lastName) {
        _email = email;
        _phoneCountry = phoneCountry;
        _firstName = firstName;
        _lastName = lastName;
        _goStep1a();
      }),
    );
  }

  void _goStep1a() {
    _push(
      const _StepState(stepValue: 1, showHeader: true, title: 'Verify your email', subtitle: 'Check your inbox to continue.'),
      LearnerStep1aBody(email: _email, onNext: _goStep2),
    );
  }

  void _goStep2() {
    _push(
      const _StepState(stepValue: 2, showHeader: true, title: 'Where did you\nhear about us?', subtitle: 'Help us understand how you found HomeGuru.'),
      LearnerStep2Body(onNext: _goStep3),
    );
  }

  void _goStep3() {
    _push(
      const _StepState(stepValue: 3, showHeader: true, title: 'What are you\ninterested in?', subtitle: 'Pick the type of learning that suits you.'),
      LearnerStep3Body(onNext: (choice) { _interest = choice; _goStep4(); }),
    );
  }

  void _goStep4() {
    _push(
      _StepState(
        stepValue: 4,
        showHeader: true,
        title: 'What do you want\nto focus on?',
        subtitle: _interest == 'academic' ? 'Pick a subject you want to learn.' : 'Pick a skill you want to develop.',
      ),
      LearnerStep4Body(interest: _interest, onNext: (subjects) {
        _subject = subjects;
        final all = subjects.split(',').map((s) => s.trim()).toList();
        _realSubjects = all.where((s) => s != 'Others').toList();
        if (_realSubjects.isEmpty) {
          _onDone();
        } else {
          _goStep5(0);
        }
      }),
    );
  }

  void _goStep5(int index) {
    final subject = _realSubjects[index];
    final isLast = index == _realSubjects.length - 1;
    _push(
      _StepState(
        stepValue: 5,
        showHeader: true,
        title: 'How much do you\nalready know?',
        subtitle: _realSubjects.length > 1
            ? 'Subject ${index + 1} of ${_realSubjects.length}: $subject'
            : 'Pick your level for $subject.',
      ),
      LearnerStep5Body(
        subject: subject,
        totalSubjects: _realSubjects.length,
        subjectIndex: index,
        onNext: (subj, level) {
          _proficiency[subj] = level;
          if (isLast) {
            _onDone();
          } else {
            _goStep5(index + 1);
          }
        },
      ),
    );
  }

  void _onDone() => _goStep6();

  void _goStep6() {
    _push(
      const _StepState(stepValue: 6, showHeader: true, title: 'One last thing', subtitle: 'A fun fact before we set up your profile.'),
      LearnerStep6Body(onNext: _goStep7),
    );
  }

  void _goStep7() {
    _push(
      const _StepState(stepValue: 7, showHeader: true, title: 'About you', subtitle: 'Tell us a bit more about yourself.'),
      LearnerStep7Body(
        phoneCountry: _phoneCountry,
        firstName: _firstName,
        lastName: _lastName,
        onNext: (profile) {
          _profile = profile;
          _categoryIndex = profile['categoryIndex'] as int? ?? -1;
          if (_categoryIndex <= 2) {
            _goStep8();
          } else {
            _goFinish();
          }
        },
      ),
    );
  }

  void _goStep8() {
    _push(
      _StepState(
        stepValue: 8,
        showHeader: true,
        title: _categoryIndex == 0
            ? 'Your school details'
            : _categoryIndex == 1
                ? 'What are you preparing for?'
                : 'Your college details',
        subtitle: 'Almost done!',
      ),
      LearnerStep8Body(
        categoryIndex: _categoryIndex,
        onNext: (data) => _goFinish(),
      ),
    );
  }

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
            firstName: _firstName,
            onStart: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/learner-dashboard',
                (route) => false,
              );
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
            FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
          child: child,
        ),
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
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        backgroundColor: cs.surface,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Persistent header ────────────────────────────────────
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
                  ),
                ),

              // ── Content navigator ────────────────────────────────────
              Expanded(
                child: Navigator(
                  key: _navKey,
                  onGenerateRoute: (_) => _route(
                    LearnerStep0Body(onNext: _goStep1),
                  ),
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
  const _CongratsOverlay({required this.firstName, required this.onStart});
  final String firstName;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final w = MediaQuery.sizeOf(context).width;
    final hPad = w >= 600 ? w * 0.2 : 24.0;
    const spriteSize = 160.0;
    const spriteOverhang = spriteSize; // full sprite above sheet, feet on rim

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
                    "You're all set${firstName.isNotEmpty ? ', $firstName' : ''}!",
                    style: tt.headlineMedium?.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Your HomeGuru profile is ready.\nLet's find you the perfect tutor.",
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
                      _Highlight(emoji: '🎯', label: 'Personalised\nmatching', cs: cs, tt: tt),
                      _Highlight(emoji: '⚡', label: 'Book in\nseconds', cs: cs, tt: tt),
                      _Highlight(emoji: '🏆', label: 'Track your\nprogress', cs: cs, tt: tt),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: onStart,
                      child: const Text('Start learning'),
                    ),
                  ),
                ],
              ),
            ),
            // Sprite sitting on top edge — half above, half below
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
              color: cs.primaryContainer,
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
