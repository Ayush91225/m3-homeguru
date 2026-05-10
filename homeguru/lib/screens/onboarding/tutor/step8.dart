import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TutorStep8Body extends StatefulWidget {
  const TutorStep8Body({super.key, required this.onNext});
  final VoidCallback onNext;

  @override
  State<TutorStep8Body> createState() => _TutorStep8BodyState();
}

class _TutorStep8BodyState extends State<TutorStep8Body> with SingleTickerProviderStateMixin {
  int _state = 0; // 0=intro, 1=loading, 2=checking, 3=verified, 4=failed
  String? _errorMsg;
  String _verificationId = '';

  AnimationController? _checkCtrl;
  Animation<double>? _checkAnim;

  @override
  void initState() {
    super.initState();
    _checkCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _checkAnim = CurvedAnimation(parent: _checkCtrl!, curve: Curves.elasticOut);
    _restoreSession();
  }

  @override
  void dispose() {
    _checkCtrl?.dispose();
    super.dispose();
  }

  Future<void> _restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final vid = prefs.getString('digilocker_vid') ?? '';
    if (vid.isNotEmpty && mounted) {
      _verificationId = vid;
      _checkStatus(silent: true);
    }
  }

  Future<void> _saveSession(String vid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('digilocker_vid', vid);
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('digilocker_vid');
  }

  Future<void> _initiateDigiLocker() async {
    setState(() { _state = 1; _errorMsg = null; });
    HapticFeedback.mediumImpact();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final tutorId = prefs.getString('userId') ?? '';
      
      final response = await http.post(
        Uri.parse('https://app.homeguruworld.com/api/onboarding/tutor/verify/digilocker'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'tutorId': tutorId, 'action': 'initiate'}),
      );
      final res = jsonDecode(response.body);
      
      if (res['success'] != true || res['url'] == null) {
        setState(() { _state = 4; _errorMsg = res['error'] ?? 'Failed to start verification'; });
        return;
      }
      
      final vid = res['verificationId'] ?? '';
      final url = res['url'] ?? '';
      _verificationId = vid;
      await _saveSession(vid);
      
      if (!mounted) return;
      _showDigiLockerModal(url);
    } catch (e) {
      setState(() { _state = 4; _errorMsg = 'Network error. Please try again.'; });
    }
  }

  void _showDigiLockerModal(String url) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (ctx) => _DigiLockerScreen(
          url: url,
          onDone: () {
            Navigator.of(ctx).pop();
            _checkStatus();
          },
          onClose: () {
            Navigator.of(ctx).pop();
            setState(() => _state = 0);
          },
        ),
      ),
    );
  }

  Future<void> _checkStatus({bool silent = false}) async {
    if (_verificationId.isEmpty) return;
    if (!silent) setState(() => _state = 2);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final tutorId = prefs.getString('userId') ?? '';
      
      final response = await http.post(
        Uri.parse('https://app.homeguruworld.com/api/onboarding/tutor/verify/digilocker'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'tutorId': tutorId, 'action': 'get_document', 'verificationId': _verificationId}),
      );
      final res = jsonDecode(response.body);
      
      if (res['success'] == true && res['aadhaarVerified'] == true) {
        await _clearSession();
        if (mounted) {
          setState(() => _state = 3);
          _checkCtrl?.forward();
        }
      } else {
        final status = (res['status'] ?? '').toString().toUpperCase();
        const terminalFail = {'EXPIRED', 'REJECTED', 'FAILED', 'CANCELLED'};
        if (terminalFail.contains(status)) {
          await _clearSession();
          if (mounted) setState(() { _state = 4; _errorMsg = res['error'] ?? 'Verification failed'; });
        } else {
          if (mounted && !silent) setState(() => _state = 0);
        }
      }
    } catch (_) {
      if (mounted && !silent) setState(() => _state = 0);
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
            child: _state == 0 ? _buildIntro(cs, tt)
              : _state == 1 ? _buildLoading(cs, tt)
              : _state == 2 ? _buildChecking(cs, tt)
              : _state == 3 ? _buildVerified(cs, tt)
              : _buildFailed(cs, tt),
          ),
        ),
        if (_state == 0 || _state == 3)
          Padding(
            padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 16),
            child: FilledButton(
              onPressed: _state == 0 ? _initiateDigiLocker : widget.onNext,
              style: FilledButton.styleFrom(backgroundColor: cs.tertiary, foregroundColor: cs.onTertiary),
              child: Text(_state == 0 ? 'Verify via DigiLocker' : 'Continue'),
            ),
          ),
      ],
    );
  }

  Widget _buildIntro(ColorScheme cs, TextTheme tt) => Column(children: [
    Icon(Icons.verified_user_rounded, size: 64, color: cs.tertiary),
    const SizedBox(height: 24),
    Text('Identity Verification', style: tt.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: cs.onSurface)),
    const SizedBox(height: 12),
    Text('Verify your identity via DigiLocker to keep our platform safe for students.', textAlign: TextAlign.center, style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
    const SizedBox(height: 32),
    Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: cs.surfaceContainerLow, borderRadius: BorderRadius.circular(20)),
      child: Column(children: [
        Row(children: [
          Container(width: 48, height: 48, decoration: BoxDecoration(color: cs.tertiaryContainer, borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.shield_outlined, size: 24, color: cs.tertiary)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('DigiLocker + Cashfree', style: tt.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: cs.onSurface)),
            Text('Govt-backed verification', style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
          ])),
        ]),
        const SizedBox(height: 16),
        Divider(color: cs.outlineVariant),
        const SizedBox(height: 16),
        ...['Aadhaar & PAN verified instantly', 'Secure government portal', 'Required for all tutors'].map((t) =>
          Padding(padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              Icon(Icons.check_circle_rounded, size: 16, color: cs.tertiary),
              const SizedBox(width: 10),
              Text(t, style: tt.bodySmall?.copyWith(color: cs.onSurface)),
            ]))),
      ]),
    ),
  ]);

  Widget _buildLoading(ColorScheme cs, TextTheme tt) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    CircularProgressIndicator(color: cs.tertiary),
    const SizedBox(height: 24),
    Text('Setting up verification...', style: tt.bodyLarge?.copyWith(color: cs.onSurfaceVariant)),
  ]));

  Widget _buildChecking(ColorScheme cs, TextTheme tt) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    CircularProgressIndicator(color: cs.tertiary),
    const SizedBox(height: 24),
    Text('Verifying your identity...', style: tt.bodyLarge?.copyWith(color: cs.onSurfaceVariant)),
  ]));

  Widget _buildVerified(ColorScheme cs, TextTheme tt) => Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    ScaleTransition(
      scale: _checkAnim ?? const AlwaysStoppedAnimation(1.0),
      child: Container(width: 80, height: 80, decoration: BoxDecoration(color: cs.tertiaryContainer, shape: BoxShape.circle),
        child: Icon(Icons.check_circle_rounded, size: 48, color: cs.tertiary))),
    const SizedBox(height: 24),
    Text('Identity Verified!', style: tt.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: cs.onSurface)),
    const SizedBox(height: 12),
    Text('Your Aadhaar and PAN have been verified successfully.', textAlign: TextAlign.center, style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
    const SizedBox(height: 32),
    ...['Aadhaar verified via DigiLocker', 'PAN card verified', 'Identity confirmed'].map((t) =>
      Padding(padding: const EdgeInsets.symmetric(vertical: 4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(color: cs.surfaceContainerLow, borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            Icon(Icons.check_circle_rounded, size: 18, color: cs.tertiary),
            const SizedBox(width: 12),
            Text(t, style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: cs.onSurface)),
          ]),
        ))),
  ]);

  Widget _buildFailed(ColorScheme cs, TextTheme tt) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Container(width: 80, height: 80, decoration: BoxDecoration(color: cs.errorContainer, shape: BoxShape.circle),
      child: Icon(Icons.cancel_rounded, size: 48, color: cs.error)),
    const SizedBox(height: 24),
    Text('Verification Failed', style: tt.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: cs.onSurface)),
    const SizedBox(height: 12),
    Text(_errorMsg ?? 'Could not verify your identity. Please try again.', textAlign: TextAlign.center, style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
    const SizedBox(height: 32),
    FilledButton(
      onPressed: () {
        _clearSession();
        setState(() { _state = 0; _errorMsg = null; _verificationId = ''; });
      },
      child: const Text('Try Again'),
    ),
  ]));
}

class _DigiLockerScreen extends StatelessWidget {
  final String url;
  final VoidCallback onDone;
  final VoidCallback onClose;
  const _DigiLockerScreen({required this.url, required this.onDone, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DigiLocker Verification'),
        leading: IconButton(icon: const Icon(Icons.close_rounded), onPressed: onClose),
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(url)),
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          domStorageEnabled: true,
          useShouldOverrideUrlLoading: true,
        ),
        shouldOverrideUrlLoading: (controller, navigationAction) async {
          final urlStr = navigationAction.request.url?.toString() ?? '';
          if (urlStr.contains('digilocker-done') || urlStr.contains('/id/callback')) {
            onDone();
            return NavigationActionPolicy.CANCEL;
          }
          return NavigationActionPolicy.ALLOW;
        },
      ),
    );
  }
}
