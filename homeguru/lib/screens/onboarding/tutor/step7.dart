import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TutorStep7Body extends StatefulWidget {
  const TutorStep7Body({super.key, required this.onNext});
  final void Function(Map<String, String> payment) onNext;

  @override
  State<TutorStep7Body> createState() => _TutorStep7BodyState();
}

class _TutorStep7BodyState extends State<TutorStep7Body> {
  bool _loading = false;

  Future<void> _pay() async {
    HapticFeedback.mediumImpact();
    setState(() => _loading = true);
    // TODO: integrate Razorpay SDK
    // On success call widget.onNext with payment details
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _loading = false);
      widget.onNext({
        'paymentId': 'pay_mock_123',
        'orderId': 'order_mock_456',
        'signature': 'sig_mock_789',
        'paymentDate': DateTime.now().toIso8601String(),
        'validUntil': DateTime.now().add(const Duration(days: 365)).toIso8601String(),
      });
    }
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
                // Price card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: cs.tertiaryContainer,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(children: [
                    Icon(Icons.receipt_long_rounded, size: 40, color: cs.onTertiaryContainer),
                    const SizedBox(height: 16),
                    Text('Annual Listing Fee', style: tt.titleMedium?.copyWith(color: cs.onTertiaryContainer, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text('₹499', style: tt.displaySmall?.copyWith(color: cs.tertiary, fontWeight: FontWeight.w800)),
                    Text('per year', style: tt.bodySmall?.copyWith(color: cs.onTertiaryContainer.withValues(alpha: 0.7))),
                  ]),
                ),

                const SizedBox(height: 24),

                // What's included
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: cs.surfaceContainerLow, borderRadius: BorderRadius.circular(20)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text("What's included", style: tt.titleSmall?.copyWith(color: cs.onSurface, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    _IncludeRow('Valid for 365 days from payment', cs, tt),
                    _IncludeRow('Verified tutor badge on your profile', cs, tt),
                    _IncludeRow('Appear in student search results', cs, tt),
                    _IncludeRow('Unlimited student bookings', cs, tt),
                    _IncludeRow('No commission on first ₹10,000 earned', cs, tt),
                  ]),
                ),

                const SizedBox(height: 16),

                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.lock_outline_rounded, size: 14, color: cs.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Text('Secured by Razorpay', style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                ]),
              ],
            ),
          ),
        ),

        Padding(
          padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 16),
          child: FilledButton(
            onPressed: _loading ? null : _pay,
            style: FilledButton.styleFrom(backgroundColor: cs.tertiary, foregroundColor: cs.onTertiary),
            child: _loading
                ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: cs.onTertiary))
                : const Text('Pay ₹499 & Continue'),
          ),
        ),
      ],
    );
  }
}

class _IncludeRow extends StatelessWidget {
  const _IncludeRow(this.text, this.cs, this.tt);
  final String text;
  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(children: [
      Icon(Icons.check_rounded, size: 16, color: cs.tertiary),
      const SizedBox(width: 10),
      Expanded(child: Text(text, style: tt.bodySmall?.copyWith(color: cs.onSurface))),
    ]),
  );
}
