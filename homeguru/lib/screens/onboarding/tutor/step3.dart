import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/tutor_onboarding_service.dart';

class TutorStep3Body extends StatefulWidget {
  const TutorStep3Body({super.key, required this.onNext});
  final VoidCallback onNext;

  @override
  State<TutorStep3Body> createState() => _TutorStep3BodyState();
}

class _TutorStep3BodyState extends State<TutorStep3Body> {
  bool _audioCompleted = false;
  bool _acknowledged = false;

  void _onAudioCompleted() => setState(() => _audioCompleted = true);

  bool get _canContinue => _audioCompleted && _acknowledged;

  static final _steps = [
    _Step(icon: Icons.menu_book_rounded,      label: 'SUBJECTS',     title: 'Subjects\n& Skills',      body: 'Tell us what you can teach — subjects, skills, and the levels you cover.'),
    _Step(icon: Icons.quiz_rounded,           label: 'TEST',         title: 'Qualification\nTest',     body: 'A short problem-solving test to verify your teaching ability.'),
    _Step(icon: Icons.receipt_long_rounded,   label: 'LISTING FEE',  title: '₹499\nper year',          body: 'One-time annual listing fee · valid for 365 days · no hidden charges.'),
    _Step(icon: Icons.badge_outlined,         label: 'VERIFY',       title: 'ID\nVerification',        body: 'Verify your government-issued ID and bank account for payouts.'),
    _Step(icon: Icons.rocket_launch_rounded,  label: 'GO LIVE',      title: 'Start\nGetting Students', body: 'Your profile goes live instantly — students can find and book you right away.'),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final w = MediaQuery.sizeOf(context).width;
    final hPad = w >= 600 ? w * 0.2 : 24.0;

    final cardColors = [
      (bg: cs.tertiaryContainer,  fg: cs.onTertiaryContainer,  accent: cs.tertiary),
      (bg: cs.primaryContainer,   fg: cs.onPrimaryContainer,   accent: cs.primary),
      (bg: cs.secondaryContainer, fg: cs.onSecondaryContainer, accent: cs.secondary),
      (bg: cs.tertiaryContainer,  fg: cs.onTertiaryContainer,  accent: cs.tertiary),
      (bg: cs.primaryContainer,   fg: cs.onPrimaryContainer,   accent: cs.primary),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: hPad),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _InstructionsCard(
                    onAudioCompleted: _onAudioCompleted,
                    acknowledged: _acknowledged,
                    onAcknowledgeChanged: (v) => setState(() => _acknowledged = v),
                  ),
                  if (_audioCompleted) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Swipe up to see what\'s next',
                      style: tt.labelMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Icon(Icons.keyboard_arrow_down_rounded, color: cs.onSurfaceVariant, size: 32),
                  ],
                ],
              ),
            ),
          ),
        ),
        if (_audioCompleted && _acknowledged) ...[
          SizedBox(
            height: 400,
            child: LayoutBuilder(builder: (ctx, outer) {
              const itemExtent = 328.0;
              const shrinkExtent = 72.0;

              return CarouselView(
                scrollDirection: Axis.vertical,
                itemExtent: itemExtent,
                shrinkExtent: shrinkExtent,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                itemSnapping: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(28)),
                ),
                children: List.generate(_steps.length, (i) {
                  final step = _steps[i];
                  final c = cardColors[i];

                  return RepaintBoundary(
                    child: LayoutBuilder(builder: (_, inner) {
                      final isShrunk = inner.maxHeight < itemExtent * 0.5;

                      return Container(
                        decoration: BoxDecoration(color: c.bg),
                        clipBehavior: Clip.hardEdge,
                        child: Stack(
                          clipBehavior: Clip.hardEdge,
                          children: [
                            if (!isShrunk)
                              Positioned(
                                right: -16,
                                bottom: -16,
                                child: Icon(step.icon, size: 160, color: c.accent.withValues(alpha: 0.07)),
                              ),
                            if (isShrunk)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: c.fg.withValues(alpha: 0.12),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text('${i + 1}',
                                              style: tt.labelSmall?.copyWith(
                                                color: c.fg,
                                                fontWeight: FontWeight.w700,
                                              )),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Icon(step.icon, size: 16, color: c.fg.withValues(alpha: 0.7)),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          step.title.replaceAll('\n', ' '),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: tt.labelMedium?.copyWith(
                                            color: c.fg.withValues(alpha: 0.8),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            if (!isShrunk)
                              Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                          decoration: BoxDecoration(
                                            color: c.accent.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text('${i + 1} of ${_steps.length}',
                                              style: tt.labelSmall?.copyWith(
                                                color: c.accent,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 0.5,
                                              )),
                                        ),
                                        const Spacer(),
                                        Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: c.fg.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          child: Icon(step.icon, size: 26, color: c.fg),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    Text(step.label,
                                        style: tt.labelSmall?.copyWith(
                                          color: c.accent,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1.4,
                                        )),
                                    const SizedBox(height: 6),
                                    Text(step.title,
                                        style: tt.displaySmall?.copyWith(
                                          color: c.fg,
                                          height: 1.0,
                                          fontWeight: FontWeight.w800,
                                        )),
                                    const SizedBox(height: 14),
                                    Text(step.body,
                                        style: tt.bodyLarge?.copyWith(
                                          color: c.fg.withValues(alpha: 0.75),
                                          height: 1.5,
                                        )),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      );
                    }),
                  );
                }),
              );
            }),
          ),
        ],

          Padding(
          padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 16),
          child: FilledButton(
            onPressed: _canContinue ? () async {
              HapticFeedback.mediumImpact();
              
              // Get tutorId from SharedPreferences
              final prefs = await SharedPreferences.getInstance();
              final tutorId = prefs.getString('tutorId');
              
              if (tutorId == null) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Session expired. Please start over.')),
                  );
                }
                return;
              }
              
              // Save journey acknowledgment to API
              final result = await TutorOnboardingService.completeJourney(tutorId, true);
              
              if (result['success'] == true) {
                widget.onNext();
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(result['error'] ?? 'Failed to save acknowledgment')),
                  );
                }
              }
            } : null,
            style: FilledButton.styleFrom(
              backgroundColor: cs.tertiary,
              foregroundColor: cs.onTertiary,
            ),
            child: const Text("Let's Begin"),
          ),
        ),
      ],
    );
  }
}

class _Step {
  const _Step({required this.icon, required this.label, required this.title, required this.body});
  final IconData icon;
  final String label;
  final String title;
  final String body;
}

class _InstructionsCard extends StatefulWidget {
  const _InstructionsCard({
    required this.onAudioCompleted,
    required this.acknowledged,
    required this.onAcknowledgeChanged,
  });
  final VoidCallback onAudioCompleted;
  final bool acknowledged;
  final ValueChanged<bool> onAcknowledgeChanged;

  @override
  State<_InstructionsCard> createState() => _InstructionsCardState();
}

class _InstructionsCardState extends State<_InstructionsCard> with SingleTickerProviderStateMixin {
  final _audioPlayer = AudioPlayer();
  String _selectedLanguage = 'English';
  bool _isPlaying = false;
  bool _hasCompleted = false;
  double _progress = 0.0;
  late AnimationController _waveController;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _audioPlayer.onPlayerStateChanged.listen((_) {});

    _audioPlayer.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });

    _audioPlayer.onPositionChanged.listen((p) {
      if (mounted) {
        setState(() {
          _position = p;
          if (_duration.inMilliseconds > 0) {
            _progress = p.inMilliseconds / _duration.inMilliseconds;
          }
        });
      }
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _hasCompleted = true;
          _isPlaying = false;
          _progress = 1.0;
        });
        widget.onAudioCompleted();
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _waveController.dispose();
    super.dispose();
  }

  Future<void> _playPause() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
        setState(() => _isPlaying = false);
      } else {
        if (_position == _duration && _hasCompleted) {
          await _audioPlayer.seek(Duration.zero);
          setState(() {
            _progress = 0.0;
            _hasCompleted = false;
          });
        }
        setState(() => _isPlaying = true);
        await _audioPlayer.play(UrlSource('https://samplelib.com/mp3/sample-9s.mp3'));
      }
    } catch (e) {
      setState(() => _isPlaying = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error playing audio: $e')),
        );
      }
    }
  }

  void _changeLanguage(String lang) {
    if (_selectedLanguage == lang) return;
    setState(() => _selectedLanguage = lang);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.tertiaryContainer,
        borderRadius: BorderRadius.circular(28),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: cs.tertiary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('INSTRUCTIONS',
                    style: tt.labelSmall?.copyWith(
                      color: cs.tertiary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    )),
              ),
              const Spacer(),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: cs.onTertiaryContainer.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.info_outline_rounded, size: 26, color: cs.onTertiaryContainer),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Text('Listen\nCarefully',
              style: tt.displaySmall?.copyWith(
                color: cs.onTertiaryContainer,
                height: 1.0,
                fontWeight: FontWeight.w800,
              )),
          const SizedBox(height: 16),

          // Language selector - M3 split button
          Row(
            children: [
              Icon(Icons.language_rounded, size: 18, color: cs.onTertiaryContainer.withValues(alpha: 0.7)),
              const SizedBox(width: 8),
              Container(
                height: 36,
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Text(_selectedLanguage,
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurface,
                          fontWeight: FontWeight.w600,
                        )),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      width: 1,
                      color: cs.outlineVariant,
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          final newLang = _selectedLanguage == 'English' ? 'Hindi' : 'English';
                          _changeLanguage(newLang);
                        },
                        borderRadius: const BorderRadius.horizontal(right: Radius.circular(18)),
                        child: Container(
                          width: 36,
                          height: 36,
                          alignment: Alignment.center,
                          child: Icon(Icons.swap_horiz_rounded, color: cs.onSurface, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          SizedBox(
            height: 50,
            child: _isPlaying
              ? AnimatedBuilder(
                  animation: _waveController,
                  builder: (context, child) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: List.generate(15, (i) {
                        final offset = (i * 0.07) % 1.0;
                        final value = (((_waveController.value + offset) % 1.0) * 2 - 1).abs();
                        return Container(
                          width: 3,
                          height: 10 + (value * 40),
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: cs.tertiary,
                            borderRadius: BorderRadius.circular(1.5),
                          ),
                        );
                      }),
                    );
                  },
                )
              : Icon(Icons.graphic_eq_rounded, size: 40, color: cs.tertiary.withValues(alpha: 0.2)),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Material(
                color: cs.tertiary,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: _playPause,
                  customBorder: const CircleBorder(),
                  child: Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    child: Icon(
                      _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: cs.onTertiary,
                      size: 24,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LinearProgressIndicator(
                      value: _progress,
                      minHeight: 4,
                      backgroundColor: cs.onTertiaryContainer.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation(cs.tertiary),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${(_progress * 100).toInt()}% complete',
                      style: tt.labelSmall?.copyWith(
                        color: cs.onTertiaryContainer,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _hasCompleted ? () => widget.onAcknowledgeChanged(!widget.acknowledged) : null,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _hasCompleted ? cs.surface : cs.surface.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: widget.acknowledged ? cs.tertiary : (_hasCompleted ? cs.outlineVariant : cs.outlineVariant.withValues(alpha: 0.3)),
                    width: widget.acknowledged ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: widget.acknowledged ? cs.tertiary : Colors.transparent,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: _hasCompleted ? cs.tertiary : cs.outlineVariant,
                          width: 2,
                        ),
                      ),
                      child: widget.acknowledged
                        ? Icon(Icons.check_rounded, size: 12, color: cs.onTertiary)
                        : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'I understood the instructions',
                        style: tt.labelMedium?.copyWith(
                          color: _hasCompleted ? cs.onSurface : cs.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (!_hasCompleted) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.lock_outline_rounded, size: 14, color: cs.error),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Complete audio to continue',
                    style: tt.labelSmall?.copyWith(
                      color: cs.error,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
