import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TutorStep1aBody extends StatefulWidget {
  const TutorStep1aBody({super.key, required this.email, required this.onNext});
  final String email;
  final VoidCallback onNext;

  @override
  State<TutorStep1aBody> createState() => _TutorStep1aBodyState();
}

class _TutorStep1aBodyState extends State<TutorStep1aBody> {
  bool _loading = false;
  bool _resending = false;

  Future<void> _checkVerified() async {
    HapticFeedback.mediumImpact();
    setState(() => _loading = true);
    
    try {
      // Call backend API to check verification status
      final response = await http.post(
        Uri.parse('https://app.homeguruworld.com/api/auth/check-verification'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': widget.email}),
      );
      
      final data = jsonDecode(response.body);
      
      if (mounted) {
        setState(() => _loading = false);
        
        if (data['success'] == true && data['verified'] == true) {
          // Email is verified, proceed to next step
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email verified successfully!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          widget.onNext();
        } else {
          // Email not verified yet
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please verify your email first. Check your inbox.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error checking verification: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _resend() async {
    HapticFeedback.lightImpact();
    setState(() => _resending = true);
    
    try {
      final response = await http.post(
        Uri.parse('https://app.homeguruworld.com/api/auth/resend-verification'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': widget.email}),
      );
      
      final data = jsonDecode(response.body);
      
      if (mounted) {
        setState(() => _resending = false);
        if (data['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Verification email sent to ${widget.email}'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['error'] ?? 'Failed to send email'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _resending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
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
            padding: EdgeInsets.fromLTRB(hPad, 24, hPad, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.mark_email_unread_outlined, size: 48, color: cs.tertiary),
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
            style: FilledButton.styleFrom(backgroundColor: cs.tertiary, foregroundColor: cs.onTertiary),
            child: _loading
                ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: cs.onTertiary))
                : const Text('I verified my email'),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 16),
          child: FilledButton.tonal(
            onPressed: _resending ? null : _resend,
            style: FilledButton.styleFrom(
              backgroundColor: cs.tertiaryContainer,
              foregroundColor: cs.onTertiaryContainer,
            ),
            child: _resending
                ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: cs.tertiary))
                : const Text('Resend email'),
          ),
        ),
      ],
    );
  }
}
