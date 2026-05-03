import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../main.dart' show themeModeNotifier, saveTheme;
import '../../widgets/mascot/mascot_card.dart';
import '../../widgets/welcome/feature_carousel.dart';
import '../../widgets/welcome/role_sheet.dart';
import '../login/login_screen.dart';

const double _kTablet = 600;

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enter;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fade = CurvedAnimation(parent: _enter, curve: Curves.easeOutCubic);
    _slide = Tween(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(CurvedAnimation(parent: _enter, curve: Curves.easeOutCubic));
    _enter.forward();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ));
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isTablet = MediaQuery.sizeOf(context).width >= _kTablet;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: isTablet
                ? _TabletLayout(onGetStarted: () => RoleSheet.show(context))
                : _PhoneLayout(onGetStarted: () => RoleSheet.show(context)),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Top bar
// ─────────────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({this.logoHeight = 28.0});
  final double logoHeight;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, mode, child) {
        final isDark = mode == ThemeMode.dark;
        return Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              'assets/logo.png',
              height: logoHeight,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stack) => Text('HomeGuru',
                  style: tt.titleMedium?.copyWith(color: cs.primary)),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  final next = isDark ? ThemeMode.light : ThemeMode.dark;
                  themeModeNotifier.value = next;
                  saveTheme(next);
                },
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    isDark
                        ? Icons.light_mode_rounded
                        : Icons.dark_mode_rounded,
                    key: ValueKey(isDark),
                    color: cs.onSurfaceVariant,
                  ),
                ),
                style: IconButton.styleFrom(
                  backgroundColor: cs.surfaceContainerHighest,
                  shape: const CircleBorder(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Phone layout
// ─────────────────────────────────────────────────────────────────────────────

class _PhoneLayout extends StatelessWidget {
  const _PhoneLayout({required this.onGetStarted});
  final VoidCallback onGetStarted;

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height;
    final vGap = h < 700 ? 10.0 : 16.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20, vGap, 12, 0),
          child: const _TopBar(logoHeight: 28),
        ),
        SizedBox(height: vGap),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: MascotCard(),
        ),
        SizedBox(height: vGap),
        const Expanded(child: FeatureCarousel()),
        Padding(
          padding: EdgeInsets.fromLTRB(20, vGap, 20, vGap + 8),
          child: _Buttons(onGetStarted: onGetStarted),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tablet layout
// ─────────────────────────────────────────────────────────────────────────────

class _TabletLayout extends StatelessWidget {
  const _TabletLayout({required this.onGetStarted});
  final VoidCallback onGetStarted;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Container(
            color: cs.surfaceContainerLow,
            padding: const EdgeInsets.all(36),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _TopBar(logoHeight: 30),
                SizedBox(height: 32),
                MascotCard(),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 6,
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Expanded(child: FeatureCarousel()),
              Padding(
                padding: const EdgeInsets.fromLTRB(40, 24, 40, 40),
                child: _Buttons(onGetStarted: onGetStarted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Buttons
// ─────────────────────────────────────────────────────────────────────────────

class _Buttons extends StatelessWidget {
  const _Buttons({required this.onGetStarted});
  final VoidCallback onGetStarted;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final h = MediaQuery.sizeOf(context).height;
    final pad = h < 700 ? 14.0 : 16.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: onGetStarted,
          icon: const Icon(Icons.arrow_forward_rounded),
          label: const Text('Get Started'),
          style: FilledButton.styleFrom(
            backgroundColor: cs.primary,
            foregroundColor: cs.onPrimary,
            padding: EdgeInsets.symmetric(vertical: pad),
            textStyle: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            shape: const StadiumBorder(),
            elevation: 0,
          ),
        ),
        const SizedBox(height: 10),
        FilledButton.tonal(
          onPressed: () {
            HapticFeedback.selectionClick();
            LoginSheet.show(context);
          },
          style: FilledButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: pad),
            textStyle: tt.titleMedium?.copyWith(fontWeight: FontWeight.w500),
            shape: const StadiumBorder(),
            elevation: 0,
          ),
          child: const Text('Sign in'),
        ),
      ],
    );
  }
}
