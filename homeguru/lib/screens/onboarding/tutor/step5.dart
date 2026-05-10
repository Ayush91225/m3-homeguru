import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TutorStep5Body extends StatefulWidget {
  const TutorStep5Body({super.key, required this.onPass, required this.onFail});
  final VoidCallback onPass;
  final VoidCallback onFail;

  @override
  State<TutorStep5Body> createState() => _TutorStep5BodyState();
}

class _TutorStep5BodyState extends State<TutorStep5Body> {
  _State _state = _State.idle;
  DateTime? _scheduledAt;
  Timer? _pollTimer;
  int _pollCount = 0;
  static const _pollInterval = Duration(seconds: 10);
  static const _maxPolls = 180; // 30 min timeout

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _sendNow() async {
    HapticFeedback.mediumImpact();
    setState(() => _state = _State.generating);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final tutorId = prefs.getString('tutorId');
      
      if (tutorId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Session expired')),
          );
        }
        return;
      }

      final response = await http.post(
        Uri.parse('https://app.homeguruworld.com/api/onboarding/tutor/test/generate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'tutorId': tutorId}),
      );

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        setState(() => _state = _State.waiting);
        _startPolling(data['testId'], tutorId);
      } else {
        if (mounted) {
          setState(() => _state = _State.idle);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['error'] ?? 'Failed to generate test')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _state = _State.idle);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _startPolling(String testId, String tutorId) {
    _pollCount = 0;
    _pollTimer = Timer.periodic(_pollInterval, (t) async {
      _pollCount++;
      
      try {
        final response = await http.get(
          Uri.parse('https://app.homeguruworld.com/api/onboarding/tutor/test/result?testId=$testId&tutorId=$tutorId'),
        );

        final data = jsonDecode(response.body);

        if (data['success'] == true && data['status'] == 'completed') {
          t.cancel();
          if (mounted) {
            setState(() => _state = data['result']['passed'] ? _State.passed : _State.timeout);
          }
        }
      } catch (e) {
        // Continue polling
      }

      if (_pollCount >= _maxPolls) {
        t.cancel();
        if (mounted) setState(() => _state = _State.timeout);
      }
    });
  }

  Future<void> _checkTestCompletion() async {
    HapticFeedback.mediumImpact();
    setState(() => _state = _State.checking);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final tutorId = prefs.getString('tutorId');
      
      if (tutorId == null) {
        if (mounted) {
          setState(() => _state = _State.waiting);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Session expired')),
          );
        }
        return;
      }

      // Get test data from tutor profile
      final response = await http.get(
        Uri.parse('https://app.homeguruworld.com/api/onboarding/tutor/register?tutorId=$tutorId'),
      );

      final data = jsonDecode(response.body);

      if (data['success'] == true && data['data']['testCompleted'] == true) {
        if (mounted) {
          setState(() => _state = data['data']['testPassed'] ? _State.passed : _State.timeout);
        }
      } else {
        if (mounted) {
          setState(() => _state = _State.waiting);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Test not completed yet')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _state = _State.waiting);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  String _fmt(DateTime dt) =>
      '${dt.day}/${dt.month}/${dt.year} at ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final w = MediaQuery.sizeOf(context).width;
    final hPad = w >= 600 ? w * 0.2 : 24.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(hPad, 24, hPad, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                // Info card
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(color: cs.tertiaryContainer, borderRadius: BorderRadius.circular(24)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Icon(Icons.quiz_rounded, color: cs.onTertiaryContainer, size: 26),
                      const SizedBox(width: 12),
                      Text('Teaching Assessment', style: tt.titleMedium?.copyWith(color: cs.onTertiaryContainer, fontWeight: FontWeight.w700)),
                    ]),
                    const SizedBox(height: 16),
                    _InfoRow(Icons.laptop_mac_rounded,     'Taken on your laptop or desktop', cs, tt),
                    _InfoRow(Icons.videocam_outlined,       'Camera, mic & screen sharing required', cs, tt),
                    _InfoRow(Icons.help_outline_rounded,    '10 MCQ questions · ~15 minutes', cs, tt),
                    _InfoRow(Icons.check_circle_outline_rounded, 'Minimum 60% to pass', cs, tt),
                    _InfoRow(Icons.replay_rounded,          '1 attempt per 45-day window', cs, tt),
                  ]),
                ),

                const SizedBox(height: 28),

                // State-based UI
                if (_state == _State.idle) ...[
                  _OptionCard(
                    cs: cs, tt: tt,
                    icon: Icons.send_rounded,
                    title: 'Send link now',
                    sub: "We'll send the test URL to your WhatsApp immediately.",
                    accentColor: const Color(0xFF25D366),
                    onTap: _sendNow,
                  ),
                ],

                if (_state == _State.scheduled && _scheduledAt != null)
                  _StatusCard(
                    cs: cs, tt: tt,
                    icon: Icons.event_available_rounded,
                    iconColor: cs.tertiary,
                    bgColor: cs.surfaceContainerLow,
                    title: 'Test scheduled',
                    body: 'Link will be sent to your WhatsApp on ${_fmt(_scheduledAt!)}.\n\nOpen it on your laptop/desktop and complete the test.',
                  ),

                if (_state == _State.generating)
                  _StatusCard(
                    cs: cs, tt: tt,
                    icon: Icons.auto_awesome_rounded,
                    iconColor: cs.tertiary,
                    bgColor: cs.surfaceContainerLow,
                    title: 'Generating your test...',
                    body: 'Creating personalized questions based on your profile and subjects.\n\nThis may take 30-60 seconds.',
                    showSpinner: true,
                  ),

                if (_state == _State.waiting)
                  _StatusCard(
                    cs: cs, tt: tt,
                    icon: Icons.hourglass_top_rounded,
                    iconColor: cs.tertiary,
                    bgColor: cs.surfaceContainerLow,
                    title: 'Link sent to your WhatsApp',
                    body: 'Open the link on your laptop or desktop.\n\nMake sure your camera, microphone and screen sharing are enabled before starting.\n\nWe\'ll automatically detect when you\'re done.',
                    showSpinner: true,
                  ),

                if (_state == _State.checking)
                  _StatusCard(
                    cs: cs, tt: tt,
                    icon: Icons.hourglass_bottom_rounded,
                    iconColor: cs.tertiary,
                    bgColor: cs.surfaceContainerLow,
                    title: 'Checking your test...',
                    body: 'Please wait while we verify your test completion.',
                    showSpinner: true,
                  ),

                if (_state == _State.passed)
                  _StatusCard(
                    cs: cs, tt: tt,
                    icon: Icons.check_circle_rounded,
                    iconColor: cs.tertiary,
                    bgColor: cs.tertiaryContainer,
                    title: 'Test completed!',
                    body: 'Your result is ready. Tap Continue to see your score.',
                    onColor: cs.onTertiaryContainer,
                  ),

                if (_state == _State.timeout)
                  _StatusCard(
                    cs: cs, tt: tt,
                    icon: Icons.error_outline_rounded,
                    iconColor: cs.error,
                    bgColor: cs.errorContainer,
                    title: 'Result not received',
                    body: 'We couldn\'t fetch your result yet. Please complete the test on your laptop and come back.',
                    onColor: cs.onErrorContainer,
                  ),
              ],
            ),
          ),
        ),

        if (_state == _State.waiting)
          Padding(
            padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 16),
            child: FilledButton(
              onPressed: _checkTestCompletion,
              style: FilledButton.styleFrom(backgroundColor: cs.tertiary, foregroundColor: cs.onTertiary),
              child: const Text('I have completed the test'),
            ),
          ),

        if (_state == _State.passed)
          Padding(
            padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 16),
            child: FilledButton(
              onPressed: widget.onPass,
              style: FilledButton.styleFrom(backgroundColor: cs.tertiary, foregroundColor: cs.onTertiary),
              child: const Text('See my result'),
            ),
          ),
      ],
    );
  }
}

enum _State { idle, generating, waiting, scheduled, checking, passed, timeout }

// ─────────────────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.icon, this.text, this.cs, this.tt);
  final IconData icon;
  final String text;
  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(children: [
      Icon(icon, size: 15, color: cs.onTertiaryContainer.withValues(alpha: 0.75)),
      const SizedBox(width: 10),
      Expanded(child: Text(text, style: tt.bodySmall?.copyWith(color: cs.onTertiaryContainer, height: 1.4))),
    ]),
  );
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({required this.cs, required this.tt, required this.icon, required this.title, required this.sub, required this.accentColor, required this.onTap});
  final ColorScheme cs;
  final TextTheme tt;
  final IconData icon;
  final String title;
  final String sub;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: cs.surfaceContainerLow,
    borderRadius: BorderRadius.circular(20),
    child: InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: accentColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: accentColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: tt.titleSmall?.copyWith(color: cs.onSurface, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(sub, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant, height: 1.4)),
          ])),
          Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
        ]),
      ),
    ),
  );
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.cs, required this.tt, required this.icon, required this.iconColor, required this.bgColor, required this.title, required this.body, this.showSpinner = false, this.onColor});
  final ColorScheme cs;
  final TextTheme tt;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String title;
  final String body;
  final bool showSpinner;
  final Color? onColor;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(width: 10),
        Expanded(child: Text(title, style: tt.titleSmall?.copyWith(color: onColor ?? cs.onSurface, fontWeight: FontWeight.w700))),
        if (showSpinner) SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: iconColor)),
      ]),
      const SizedBox(height: 10),
      Text(body, style: tt.bodySmall?.copyWith(color: (onColor ?? cs.onSurfaceVariant).withValues(alpha: 0.85), height: 1.6)),
    ]),
  );
}
