import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../widgets/onboarding/phone_field.dart';
import '../../../services/tutor_onboarding_service.dart';
import '../../../models/tutor_onboarding_model.dart';

class TutorStep1Body extends StatefulWidget {
  const TutorStep1Body({super.key, required this.onNext});
  final void Function(String email, String phoneCountry, String firstName, String lastName) onNext;

  @override
  State<TutorStep1Body> createState() => _TutorStep1BodyState();
}

class _TutorStep1BodyState extends State<TutorStep1Body> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _referralCtrl = TextEditingController();

  String _phoneNumber = '';
  bool _phoneValid = false;
  String _phoneCountry = 'India';
  bool _otpSent = false;
  bool _otpVerified = false;
  bool _sendingOtp = false;
  bool _verifyingOtp = false;
  bool _obscure = true;
  bool _obscureConfirm = true;
  bool _loading = false;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _otpCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _referralCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_phoneValid || _phoneNumber.isEmpty) return;
    FocusScope.of(context).unfocus();
    HapticFeedback.lightImpact();
    setState(() => _sendingOtp = true);
    
    final result = await TutorOnboardingService.sendOTP(_phoneNumber);
    
    if (mounted) {
      setState(() => _sendingOtp = false);
      if (result['success'] == true) {
        setState(() => _otpSent = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP sent via WhatsApp'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error'] ?? 'Failed to send OTP')),
        );
      }
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpCtrl.text.trim().length < 6) return;
    FocusScope.of(context).unfocus();
    HapticFeedback.lightImpact();
    setState(() => _verifyingOtp = true);
    
    final result = await TutorOnboardingService.verifyOTP(_phoneNumber, _otpCtrl.text.trim());
    
    if (mounted) {
      setState(() => _verifyingOtp = false);
      if (result['success'] == true) {
        setState(() => _otpVerified = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Phone verified successfully!'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error'] ?? 'Invalid OTP')),
        );
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_otpVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please verify your phone number first')),
      );
      return;
    }
    FocusScope.of(context).unfocus();
    HapticFeedback.mediumImpact();
    setState(() => _loading = true);
    
    // Call registration API
    final tutorData = TutorOnboarding();
    tutorData.set('firstName', _firstNameCtrl.text.trim());
    tutorData.set('lastName', _lastNameCtrl.text.trim());
    tutorData.set('email', _emailCtrl.text.trim());
    tutorData.set('phone', _phoneNumber);
    tutorData.set('password', _passwordCtrl.text);
    if (_referralCtrl.text.trim().isNotEmpty) {
      tutorData.set('referralCode', _referralCtrl.text.trim());
    }
    
    final result = await TutorOnboardingService.register(tutorData);
    
    if (mounted) {
      setState(() => _loading = false);
      if (result['success'] == true) {
        // Save tutorId for next steps
        tutorData.tutorId = result['tutorId'];
        // Don't set currentStep - API returns string but model expects int
        
        // Navigate to email verification regardless of whether it's new or existing user
        widget.onNext(_emailCtrl.text.trim(), _phoneCountry, _firstNameCtrl.text.trim(), _lastNameCtrl.text.trim());
      } else {
        // Check if error message indicates user should verify email
        final errorMsg = result['error'] ?? 'Registration failed';
        if (errorMsg.toLowerCase().contains('verify') || errorMsg.toLowerCase().contains('already')) {
          // Show message and redirect to email verification anyway
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMsg), backgroundColor: Colors.orange),
          );
          // Still navigate to email verification
          widget.onNext(_emailCtrl.text.trim(), _phoneCountry, _firstNameCtrl.text.trim(), _lastNameCtrl.text.trim());
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMsg)),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final w = MediaQuery.sizeOf(context).width;
    final hPad = w >= 600 ? w * 0.2 : 20.0;

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
                  _Card(cs: cs, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _CardTitle('Personal info', cs, tt),
                    const SizedBox(height: 16),
                    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Expanded(child: TextFormField(
                        controller: _firstNameCtrl,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(labelText: 'First name', prefixIcon: Icon(Icons.person_outline_rounded)),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: TextFormField(
                        controller: _lastNameCtrl,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(labelText: 'Last name'),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                      )),
                    ]),
                  ])),

                  const SizedBox(height: 16),

                  _Card(cs: cs, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _CardTitle('Contact', cs, tt),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(labelText: 'Email address', prefixIcon: Icon(Icons.email_outlined)),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Enter your email';
                        if (!v.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    PhoneField(
                      enabled: !_otpVerified,
                      verified: _otpVerified,
                      otpSent: _otpSent,
                      sending: _sendingOtp,
                      onSendOtp: _sendOtp,
                      useTertiary: true,
                      onChanged: (dial, number, valid, country) {
                        _phoneValid = valid;
                        _phoneCountry = country;
                        _phoneNumber = dial + number;
                        if (_otpSent && !_otpVerified) {
                          setState(() { _otpSent = false; _otpCtrl.clear(); });
                        }
                      },
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Enter your phone number';
                        if (!_phoneValid) return 'Enter a valid number';
                        return null;
                      },
                    ),
                    if (_otpSent && !_otpVerified) ...[
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _otpCtrl,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        autofocus: true,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
                        style: tt.titleLarge?.copyWith(letterSpacing: 10, fontWeight: FontWeight.w700),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: '· · · · · ·',
                          labelText: 'OTP',
                          suffixIcon: _verifyingOtp
                              ? Padding(padding: const EdgeInsets.only(right: 14), child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: cs.tertiary)))
                              : TextButton(
                                  onPressed: _verifyOtp,
                                  style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                                  child: Text('Verify', style: tt.labelMedium?.copyWith(color: cs.tertiary, fontWeight: FontWeight.w700)),
                                ),
                          suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                        ),
                        onFieldSubmitted: (_) => _verifyOtp(),
                      ),
                      const SizedBox(height: 6),
                      Row(children: [
                        Icon(Icons.chat_bubble_outline_rounded, size: 13, color: cs.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text('Sent via WhatsApp', style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                      ]),
                    ],
                    if (_otpVerified) ...[
                      const SizedBox(height: 10),
                      Row(children: [
                        Icon(Icons.verified_rounded, size: 16, color: Colors.green.shade600),
                        const SizedBox(width: 6),
                        Text('Phone number verified', style: tt.bodySmall?.copyWith(color: Colors.green.shade600, fontWeight: FontWeight.w600)),
                      ]),
                    ],
                  ])),

                  const SizedBox(height: 16),

                  _Card(cs: cs, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _CardTitle('Referral', cs, tt),
                    const SizedBox(height: 4),
                    Text('Have a referral code? Enter it for bonus rewards.', style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _referralCtrl,
                      textCapitalization: TextCapitalization.characters,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(labelText: 'Referral code (optional)', prefixIcon: Icon(Icons.card_giftcard_rounded)),
                    ),
                  ])),

                  const SizedBox(height: 16),

                  _Card(cs: cs, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _CardTitle('Security', cs, tt),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: _obscure,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(onPressed: () => setState(() => _obscure = !_obscure), icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined)),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter a password';
                        if (v.length < 8) return 'At least 8 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _confirmCtrl,
                      obscureText: _obscureConfirm,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      decoration: InputDecoration(
                        labelText: 'Confirm password',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm), icon: Icon(_obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined)),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Confirm your password';
                        if (v != _passwordCtrl.text) return 'Passwords do not match';
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(children: [
                      Icon(Icons.shield_outlined, size: 13, color: cs.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Text('Your data is encrypted and secure', style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                    ]),
                  ])),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 16),
          child: FilledButton(
            onPressed: _loading ? null : _submit,
            style: FilledButton.styleFrom(backgroundColor: cs.tertiary, foregroundColor: cs.onTertiary),
            child: _loading
                ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: cs.onTertiary))
                : const Text('Continue'),
          ),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.cs, required this.child});
  final ColorScheme cs;
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: cs.surfaceContainerLow, borderRadius: BorderRadius.circular(24)),
    child: child,
  );
}

class _CardTitle extends StatelessWidget {
  const _CardTitle(this.label, this.cs, this.tt);
  final String label;
  final ColorScheme cs;
  final TextTheme tt;
  @override
  Widget build(BuildContext context) => Text(label, style: tt.titleSmall?.copyWith(color: cs.onSurface, fontWeight: FontWeight.w700));
}
