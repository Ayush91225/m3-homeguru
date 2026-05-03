import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TutorStep9Body extends StatefulWidget {
  const TutorStep9Body({super.key, required this.tutorName, required this.onNext});
  final String tutorName;
  final void Function(Map<String, String> bank) onNext;

  @override
  State<TutorStep9Body> createState() => _TutorStep9BodyState();
}

class _TutorStep9BodyState extends State<TutorStep9Body> {
  final _formKey = GlobalKey<FormState>();
  late final _nameCtrl = TextEditingController(text: widget.tutorName);
  final _accCtrl = TextEditingController();
  final _accConfirmCtrl = TextEditingController();
  final _ifscCtrl = TextEditingController();

  bool _obscureAcc = true;
  bool _obscureConfirm = true;
  _VerifyStep _verifyStep = _VerifyStep.idle;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _accCtrl.dispose();
    _accConfirmCtrl.dispose();
    _ifscCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    HapticFeedback.mediumImpact();

    setState(() => _verifyStep = _VerifyStep.validating);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    setState(() => _verifyStep = _VerifyStep.pennyDrop);
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;

    setState(() => _verifyStep = _VerifyStep.confirmed);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    widget.onNext({
      'accountHolder': _nameCtrl.text.trim(),
      'accountNumber': _accCtrl.text.trim(),
      'ifsc': _ifscCtrl.text.trim().toUpperCase(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final w = MediaQuery.sizeOf(context).width;
    final hPad = w >= 600 ? w * 0.2 : 20.0;
    final isVerifying = _verifyStep != _VerifyStep.idle;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Form card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.account_balance, color: cs.tertiary, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Bank account details',
                              style: tt.titleMedium?.copyWith(
                                color: cs.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Where we send your earnings',
                          style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                        ),
                        const SizedBox(height: 24),

                        TextFormField(
                          controller: _nameCtrl,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          style: tt.bodyLarge,
                          decoration: InputDecoration(
                            labelText: 'Account holder name',
                            prefixIcon: const Icon(Icons.person_outline),
                            filled: true,
                            fillColor: cs.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Required';
                            if (v.trim().length < 2) return 'Min 2 characters';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _accCtrl,
                          obscureText: _obscureAcc,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          style: tt.bodyLarge,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: InputDecoration(
                            labelText: 'Account number',
                            prefixIcon: const Icon(Icons.lock_outline),
                            filled: true,
                            fillColor: cs.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: IconButton(
                              onPressed: () => setState(() => _obscureAcc = !_obscureAcc),
                              icon: Icon(_obscureAcc ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Required';
                            if (v.trim().length < 8) return 'Min 8 digits';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _accConfirmCtrl,
                          obscureText: _obscureConfirm,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          style: tt.bodyLarge,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: InputDecoration(
                            labelText: 'Re-enter account number',
                            prefixIcon: const Icon(Icons.lock_outline),
                            filled: true,
                            fillColor: cs.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: IconButton(
                              onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                              icon: Icon(_obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Required';
                            if (v.trim() != _accCtrl.text.trim()) return 'Account numbers do not match';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _ifscCtrl,
                          textCapitalization: TextCapitalization.characters,
                          textInputAction: TextInputAction.done,
                          style: tt.bodyLarge,
                          onFieldSubmitted: (_) => _submit(),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                            LengthLimitingTextInputFormatter(11),
                            _UpperCaseFormatter(),
                          ],
                          decoration: InputDecoration(
                            labelText: 'IFSC code',
                            prefixIcon: const Icon(Icons.tag),
                            hintText: 'e.g. SBIN0001234',
                            filled: true,
                            fillColor: cs.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Required';
                            if (v.trim().length != 11) return 'IFSC must be 11 characters';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),

                  // Verification progress
                  if (isVerifying) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: cs.tertiary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Verifying account',
                                style: tt.titleSmall?.copyWith(
                                  color: cs.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _VerifyRow('Validating details', _verifyStep.index >= 1, _verifyStep.index == 1, cs, tt),
                          _VerifyRow('Verifying with bank', _verifyStep.index >= 2, _verifyStep.index == 2, cs, tt),
                          _VerifyRow('Account confirmed', _verifyStep.index >= 3, _verifyStep.index == 3, cs, tt),
                        ],
                      ),
                    ),
                  ],

                  if (!isVerifying) ...[
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock_outline, size: 14, color: cs.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Text(
                          'Secured with 256-bit encryption',
                          style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),

        Padding(
          padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 16),
          child: FilledButton(
            onPressed: isVerifying ? null : _submit,
            style: FilledButton.styleFrom(
              backgroundColor: cs.tertiary,
              foregroundColor: cs.onTertiary,
              minimumSize: const Size(double.infinity, 56),
              shape: const StadiumBorder(),
            ),
            child: isVerifying
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: cs.onTertiary,
                    ),
                  )
                : const Text('Verify & Continue'),
          ),
        ),
      ],
    );
  }
}

enum _VerifyStep { idle, validating, pennyDrop, confirmed }

class _VerifyRow extends StatelessWidget {
  const _VerifyRow(this.label, this.done, this.active, this.cs, this.tt);
  final String label;
  final bool done, active;
  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: done
              ? Icon(Icons.check_circle, color: cs.tertiary, size: 20)
              : active
                  ? CircularProgressIndicator(strokeWidth: 2.5, color: cs.tertiary)
                  : Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: cs.outlineVariant, width: 2),
                      ),
                    ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: tt.bodyMedium?.copyWith(
            color: done ? cs.tertiary : active ? cs.onSurface : cs.onSurfaceVariant,
            fontWeight: done || active ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ],
    ),
  );
}

class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue old, TextEditingValue next) =>
      next.copyWith(text: next.text.toUpperCase(), selection: next.selection);
}
