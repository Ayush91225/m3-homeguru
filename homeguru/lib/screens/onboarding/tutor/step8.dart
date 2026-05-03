import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TutorStep8Body extends StatefulWidget {
  const TutorStep8Body({super.key, required this.onNext});
  final VoidCallback onNext;

  @override
  State<TutorStep8Body> createState() => _TutorStep8BodyState();
}

class _TutorStep8BodyState extends State<TutorStep8Body> {
  _VerifyState _state = _VerifyState.idle;

  Future<void> _startVerification() async {
    HapticFeedback.mediumImpact();
    setState(() => _state = _VerifyState.verifying);
    // TODO: open Cashfree DigiLocker WebView
    // On success:
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _state = _VerifyState.done);
  }

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
          child: Padding(
            padding: EdgeInsets.fromLTRB(hPad, 32, hPad, 24),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: cs.tertiaryContainer, borderRadius: BorderRadius.circular(24)),
                  child: Column(children: [
                    Icon(Icons.badge_outlined, size: 48, color: cs.onTertiaryContainer),
                    const SizedBox(height: 16),
                    Text('Identity Verification', style: tt.titleMedium?.copyWith(color: cs.onTertiaryContainer, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text('Verify your Aadhaar and PAN instantly via DigiLocker. This is a one-time secure process.',
                      style: tt.bodySmall?.copyWith(color: cs.onTertiaryContainer.withValues(alpha: 0.8), height: 1.5),
                      textAlign: TextAlign.center),
                  ]),
                ),

                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: cs.surfaceContainerLow, borderRadius: BorderRadius.circular(20)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _StepRow('1', 'Tap "Verify Now" below', cs, tt),
                    _StepRow('2', 'A secure DigiLocker window opens', cs, tt),
                    _StepRow('3', 'Aadhaar & PAN verified instantly', cs, tt),
                  ]),
                ),

                if (_state == _VerifyState.done) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(16)),
                    child: Row(children: [
                      Icon(Icons.verified_rounded, color: Colors.green.shade600, size: 22),
                      const SizedBox(width: 12),
                      Text('Identity verified successfully!', style: tt.bodyMedium?.copyWith(color: Colors.green.shade700, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ],

                const SizedBox(height: 16),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.lock_outline_rounded, size: 14, color: cs.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Text('Powered by Cashfree · DigiLocker', style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                ]),
              ],
            ),
          ),
        ),

        Padding(
          padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 16),
          child: _state == _VerifyState.done
              ? FilledButton(
                  onPressed: widget.onNext,
                  style: FilledButton.styleFrom(backgroundColor: cs.tertiary, foregroundColor: cs.onTertiary),
                  child: const Text('Continue'),
                )
              : FilledButton(
                  onPressed: _state == _VerifyState.verifying ? null : _startVerification,
                  style: FilledButton.styleFrom(backgroundColor: cs.tertiary, foregroundColor: cs.onTertiary),
                  child: _state == _VerifyState.verifying
                      ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: cs.onTertiary))
                      : const Text('Verify Now'),
                ),
        ),
      ],
    );
  }
}

enum _VerifyState { idle, verifying, done }

class _StepRow extends StatelessWidget {
  const _StepRow(this.num, this.text, this.cs, this.tt);
  final String num, text;
  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(children: [
      Container(
        width: 26, height: 26,
        decoration: BoxDecoration(color: cs.tertiaryContainer, shape: BoxShape.circle),
        child: Center(child: Text(num, style: tt.labelSmall?.copyWith(color: cs.onTertiaryContainer, fontWeight: FontWeight.w700))),
      ),
      const SizedBox(width: 12),
      Expanded(child: Text(text, style: tt.bodySmall?.copyWith(color: cs.onSurface))),
    ]),
  );
}
