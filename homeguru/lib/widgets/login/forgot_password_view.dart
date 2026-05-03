import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key, required this.onBack, required this.onSent});
  final VoidCallback onBack;
  final void Function(String email) onSent;

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _loading = false;

  static final _inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none);
  static final _focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFF1A73E8), width: 2));
  static final _errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Colors.red, width: 1.5));

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.mediumImpact();
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) widget.onSent(_emailCtrl.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 28),
        Row(
          children: [
            IconButton(
              onPressed: widget.onBack,
              icon: Icon(Icons.arrow_back_rounded, color: cs.onSurface),
              style: IconButton.styleFrom(
                backgroundColor: cs.surfaceContainerHighest,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(8),
                minimumSize: const Size(36, 36),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Reset password',
                      style: tt.headlineMedium?.copyWith(
                          color: cs.onSurface,
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                          inherit: true)),
                  const SizedBox(height: 2),
                  Text("We'll send a reset link to your email.",
                      style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          inherit: true)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Form(
          key: _formKey,
          child: TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _send(),
            decoration: InputDecoration(
              labelText: 'Email address',
              prefixIcon: Icon(Icons.email_outlined, color: cs.onSurfaceVariant),
              filled: true,
              fillColor: cs.surfaceContainerLow,
              border: _inputBorder,
              focusedBorder: _focusedBorder,
              errorBorder: _errorBorder,
              focusedErrorBorder: _focusedBorder,
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Enter your email';
              if (!v.contains('@')) return 'Enter a valid email';
              return null;
            },
          ),
        ),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: _loading ? null : _send,
          style: FilledButton.styleFrom(
            backgroundColor: cs.primary,
            foregroundColor: cs.onPrimary,
            disabledBackgroundColor: cs.surfaceContainerHighest,
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            shape: const StadiumBorder(),
            elevation: 0,
          ),
          child: _loading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: cs.onSurfaceVariant))
              : const Text('Send reset link'),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
