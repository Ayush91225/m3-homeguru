import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TutorStep9Body extends StatefulWidget {
  const TutorStep9Body({super.key, required this.onNext});
  final VoidCallback onNext;

  @override
  State<TutorStep9Body> createState() => _TutorStep9BodyState();
}

class _TutorStep9BodyState extends State<TutorStep9Body> with SingleTickerProviderStateMixin {
  final _accName = TextEditingController();
  final _accNum = TextEditingController();
  final _confirmNum = TextEditingController();
  final _ifsc = TextEditingController();
  bool _tried = false;

  int _state = 0; // 0=input, 1=verifying, 2=verified, 3=failed
  int _verifyStep = 0;
  String? _errorMsg;
  Timer? _stepTimer;

  late final AnimationController _checkCtrl;
  late final Animation<double> _checkAnim;

  String? get _nameErr => _accName.text.trim().length < 2 ? 'Required' : null;
  String? get _numErr => _accNum.text.trim().length < 8 ? 'Min 8 digits' : null;
  String? get _confirmErr {
    if (_confirmNum.text.isEmpty) return 'Required';
    if (_confirmNum.text != _accNum.text) return 'Does not match';
    return null;
  }
  String? get _ifscErr => _ifsc.text.trim().length != 11 ? '11 characters' : null;

  bool get _canProceed => _nameErr == null && _numErr == null && _confirmErr == null && _ifscErr == null;

  @override
  void initState() {
    super.initState();
    _checkCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _checkAnim = CurvedAnimation(parent: _checkCtrl, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _accName.dispose(); _accNum.dispose(); _confirmNum.dispose(); _ifsc.dispose();
    _stepTimer?.cancel(); _checkCtrl.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    setState(() => _tried = true);
    if (!_canProceed) return;
    HapticFeedback.mediumImpact();
    setState(() { _state = 1; _verifyStep = 0; _errorMsg = null; });

    _stepTimer = Timer.periodic(const Duration(milliseconds: 1200), (t) {
      if (!mounted) { t.cancel(); return; }
      if (_verifyStep < 2) setState(() => _verifyStep++);
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final tutorId = prefs.getString('userId') ?? '';
      
      final response = await http.post(
        Uri.parse('https://app.homeguruworld.com/api/onboarding/tutor/verify/bank'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'tutorId': tutorId,
          'bankAccount': _accNum.text.trim(),
          'ifsc': _ifsc.text.trim().toUpperCase(),
          'name': _accName.text.trim(),
          'phone': '',
        }),
      );
      
      _stepTimer?.cancel();
      if (!mounted) return;
      
      final res = jsonDecode(response.body);
      
      if (res['success'] == true) {
        setState(() { _state = 2; _verifyStep = 3; });
        _checkCtrl.forward();
      } else {
        setState(() { _state = 3; _errorMsg = res['error'] ?? 'Verification failed'; });
      }
    } catch (e) {
      _stepTimer?.cancel();
      if (mounted) setState(() { _state = 3; _errorMsg = 'Network error. Please try again.'; });
    }
  }

  Widget _input(TextEditingController c, String hint, {String? err, TextInputType? kb, String? helper, bool obscure = false, bool caps = false}) {
    final hasErr = _tried && err != null;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      TextField(
        controller: c, keyboardType: kb, obscureText: obscure,
        textCapitalization: caps ? TextCapitalization.characters : TextCapitalization.none,
        inputFormatters: caps ? [_UpperCaseFormatter()] : null,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          errorText: hasErr ? err : null,
        ),
      ),
      if (helper != null && !hasErr) Padding(padding: const EdgeInsets.only(top: 4, left: 4),
        child: Text(helper, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant))),
    ]);
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
            child: _state == 0 ? _buildInput(cs, tt, hPad)
              : _state == 1 ? _buildVerifying(cs, tt)
              : _state == 2 ? _buildVerified(cs, tt)
              : _buildFailed(cs, tt),
          ),
        ),
        if (_state == 0 || _state == 2)
          Padding(
            padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 16),
            child: FilledButton(
              onPressed: _state == 0 ? (_canProceed ? _verify : null) : widget.onNext,
              style: FilledButton.styleFrom(backgroundColor: cs.tertiary, foregroundColor: cs.onTertiary),
              child: Text(_state == 0 ? 'Verify Account' : 'Continue'),
            ),
          ),
      ],
    );
  }

  Widget _buildInput(ColorScheme cs, TextTheme tt, double hPad) {
    return ListView(
      children: [
        Icon(Icons.account_balance_rounded, size: 64, color: cs.tertiary),
        const SizedBox(height: 24),
        Text('Bank Account', textAlign: TextAlign.center, style: tt.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: cs.onSurface)),
        const SizedBox(height: 12),
        Text('For receiving session payments.', textAlign: TextAlign.center, style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
        const SizedBox(height: 32),

        _input(_accName, 'Account holder name', err: _nameErr),
        const SizedBox(height: 16),
        _input(_accNum, 'Account number', err: _numErr, kb: TextInputType.number, obscure: true),
        const SizedBox(height: 16),
        _input(_confirmNum, 'Re-enter account number', err: _confirmErr, kb: TextInputType.number),
        const SizedBox(height: 16),
        _input(_ifsc, 'IFSC code', err: _ifscErr, helper: 'e.g. SBIN0001234', caps: true),
        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: cs.tertiaryContainer.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(12), border: Border.all(color: cs.tertiary.withValues(alpha: 0.3))),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.info_outline_rounded, size: 18, color: cs.tertiary),
            const SizedBox(width: 10),
            Expanded(child: Text('Your bank account details will be verified instantly via Cashfree. Payments for sessions will be credited to this account.', style: tt.bodySmall?.copyWith(color: cs.onSurface))),
          ]),
        ),
      ],
    );
  }

  Widget _buildVerifying(ColorScheme cs, TextTheme tt) {
    const steps = ['Verifying account details...', 'Confirming IFSC...', 'Account verified...'];
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        width: 80, height: 80,
        decoration: BoxDecoration(color: cs.tertiaryContainer, shape: BoxShape.circle),
        child: Icon(Icons.account_balance_rounded, size: 40, color: cs.tertiary),
      ),
      const SizedBox(height: 32),
      ...List.generate(3, (i) {
        final done = i < _verifyStep;
        final active = i == _verifyStep;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(children: [
            SizedBox(width: 28, height: 28, child: Center(
              child: done
                  ? Icon(Icons.check_circle_rounded, size: 24, color: cs.tertiary)
                  : active
                      ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: cs.tertiary))
                      : Container(width: 10, height: 10, decoration: BoxDecoration(color: cs.outlineVariant, shape: BoxShape.circle)),
            )),
            const SizedBox(width: 14),
            Text(steps[i], style: tt.bodyMedium?.copyWith(
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
              color: done ? cs.tertiary : active ? cs.onSurface : cs.onSurfaceVariant,
            )),
          ]),
        );
      }),
    ]));
  }

  Widget _buildVerified(ColorScheme cs, TextTheme tt) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      ScaleTransition(
        scale: _checkAnim,
        child: Container(
          width: 80, height: 80,
          decoration: BoxDecoration(color: cs.tertiaryContainer, shape: BoxShape.circle),
          child: Icon(Icons.check_circle_rounded, size: 48, color: cs.tertiary),
        ),
      ),
      const SizedBox(height: 24),
      Text('Account Verified!', style: tt.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: cs.onSurface)),
      const SizedBox(height: 12),
      Text('${_accName.text.trim()}\'s bank account has been verified successfully.', textAlign: TextAlign.center,
        style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
      const SizedBox(height: 32),
      ...['Account number verified', 'IFSC confirmed', 'Ready for payouts'].map((t) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(color: cs.surfaceContainerLow, borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            Icon(Icons.check_circle_rounded, size: 18, color: cs.tertiary),
            const SizedBox(width: 12),
            Text(t, style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: cs.onSurface)),
          ]),
        ),
      )),
    ]);
  }

  Widget _buildFailed(ColorScheme cs, TextTheme tt) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        width: 80, height: 80,
        decoration: BoxDecoration(color: cs.errorContainer, shape: BoxShape.circle),
        child: Icon(Icons.cancel_rounded, size: 48, color: cs.error),
      ),
      const SizedBox(height: 24),
      Text('Verification Failed', style: tt.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: cs.onSurface)),
      const SizedBox(height: 12),
      Text(_errorMsg ?? 'Could not verify your bank account. Please check the details and try again.', textAlign: TextAlign.center,
        style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
      const SizedBox(height: 32),
      FilledButton(
        onPressed: () => setState(() { _state = 0; _tried = false; _errorMsg = null; }),
        child: const Text('Try Again'),
      ),
    ]));
  }
}

class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue old, TextEditingValue val) {
    return val.copyWith(text: val.text.toUpperCase());
  }
}
