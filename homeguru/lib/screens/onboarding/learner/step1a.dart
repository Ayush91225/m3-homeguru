import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LearnerStep1aBody extends StatefulWidget {
  const LearnerStep1aBody({super.key, required this.email, required this.onNext, this.useTertiary = false});
  final String email;
  final VoidCallback onNext;
  final bool useTertiary;

  @override
  State<LearnerStep1aBody> createState() => _LearnerStep1aBodyState();
}

class _LearnerStep1aBodyState extends State<LearnerStep1aBody> {
  bool _loading = false;
  bool _resending = false;

  Future<void> _checkVerified() async {
    HapticFeedback.mediumImpact();
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _loading = false);
      widget.onNext();
    }
  }

  Future<void> _resend() async {
    HapticFeedback.lightImpact();
    setState(() => _resending = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _resending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email resent to ${widget.email}'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final brandColor = widget.useTertiary ? cs.tertiary : cs.primary;
    final onBrandColor = widget.useTertiary ? cs.onTertiary : cs.onPrimary;
    final tt = Theme.of(context).textTheme;
    final w = MediaQuery.sizeOf(context).width;
    final hPad = w >= 600 ? w * 0.2 : 24.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.fromLTRB(hPad, 24, hPad, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.mark_email_unread_outlined, size: 48, color: brandColor),
                const SizedBox(height: 24),
                Text('We sent a link to', style: tt.bodyLarge?.copyWith(color: cs.onSurfaceVariant)),
                const SizedBox(height: 4),
                Text(widget.email, style: tt.titleMedium?.copyWith(color: cs.onSurface, fontWeight: FontWeight.w600)),
                const SizedBox(height: 24),
                Text(
                  "Click the link in the email to verify your account. If you don't see it, check your spam folder.",
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant, height: 1.5),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 8),
          child: FilledButton(
            onPressed: _loading ? null : _checkVerified,
            style: widget.useTertiary ? FilledButton.styleFrom(backgroundColor: cs.tertiary, foregroundColor: cs.onTertiary) : null,
            child: _loading
                ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: onBrandColor))
                : const Text('I verified my email'),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 16),
          child: FilledButton.tonal(
            onPressed: _resending ? null : _resend,
            style: widget.useTertiary ? FilledButton.styleFrom(backgroundColor: cs.tertiaryContainer, foregroundColor: cs.onTertiaryContainer) : null,
            child: _resending
                ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: brandColor))
                : const Text('Resend email'),
          ),
        ),
      ],
    );
  }
}
