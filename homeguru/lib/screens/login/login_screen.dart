import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../widgets/welcome/role_sheet.dart';
import '../../widgets/login/forgot_password_view.dart';
class LoginSheet {
  static void show(BuildContext context, {String? role}) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      isDismissible: true,
      enableDrag: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => _LoginSheetContent(role: role),
    );
  }
}

class LoginScreen extends StatelessWidget {
  final String? role;
  const LoginScreen({super.key, this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(child: _LoginSheetContent(role: role, isPage: true)),
    );
  }
}



// ─────────────────────────────────────────────────────────────────────────────
// Sheet — Dynamic height switcher with Shared Axis Transition
// ─────────────────────────────────────────────────────────────────────────────

class _LoginSheetContent extends StatefulWidget {
  const _LoginSheetContent({this.role, this.isPage = false});
  final String? role;
  final bool isPage;

  @override
  State<_LoginSheetContent> createState() => _LoginSheetContentState();
}

class _LoginSheetContentState extends State<_LoginSheetContent> {
  // 'login' | 'forgot' | 'sent'
  String _view = 'login';
  String _sentEmail = '';

  void _goForgot() {
    HapticFeedback.selectionClick();
    setState(() => _view = 'forgot');
  }

  void _goLogin() {
    HapticFeedback.selectionClick();
    setState(() { _view = 'login'; _sentEmail = ''; });
  }

  void _onSent(String email) {
    setState(() { _view = 'sent'; _sentEmail = email; });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.width >= 600;
    final hPad = isTablet ? size.width * 0.15 : 24.0;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          if (!widget.isPage) ...[
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],

          // Clip to prevent overflow during height transitions
          ClipRect(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              alignment: Alignment.topCenter,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                layoutBuilder: (currentChild, previousChildren) {
                  return Stack(
                    alignment: Alignment.topCenter,
                    children: <Widget>[
                      ...previousChildren,
                      currentChild ?? const SizedBox.shrink(),
                    ],
                  );
                },
                child: switch (_view) {
                  'forgot' => Padding(
                      key: const ValueKey('forgot'),
                      padding: EdgeInsets.symmetric(horizontal: hPad),
                      child: ForgotPasswordView(
                        onBack: _goLogin,
                        onSent: _onSent,
                      ),
                    ),
                  'sent' => Padding(
                      key: const ValueKey('sent'),
                      padding: EdgeInsets.symmetric(horizontal: hPad),
                      child: _SentView(
                        email: _sentEmail,
                        onBack: _goLogin,
                      ),
                    ),
                  _ => Padding(
                      key: const ValueKey('login'),
                      padding: EdgeInsets.symmetric(horizontal: hPad),
                      child: _LoginView(
                        role: widget.role,
                        onForgot: _goForgot,
                      ),
                    ),
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          const _AegisTag(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Login View
// ─────────────────────────────────────────────────────────────────────────────

class _LoginView extends StatefulWidget {
  const _LoginView({
    required this.onForgot,
    this.role,
  });
  final VoidCallback onForgot;
  final String? role;

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String _error = '';
  String _selectedRole = 'tutor'; // Default to tutor

  @override
  void initState() {
    super.initState();
    // Use widget.role if provided, otherwise default to tutor
    _selectedRole = widget.role ?? 'tutor';
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    
    print('[LOGIN] Attempting login with role: $_selectedRole, email: $email');
    
    HapticFeedback.mediumImpact();
    setState(() {
      _loading = true;
      _error = '';
    });
    
    try {
      final response = await http.post(
        Uri.parse('https://app.homeguruworld.com/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': pass, 'role': _selectedRole}),
      );
      
      print('[LOGIN] Response status: ${response.statusCode}');
      print('[LOGIN] Response body: ${response.body}');
      
      if (!mounted) return;
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        print('[LOGIN] Login successful, role from API: ${data['role']}');
        
        // Store session
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('authToken', data['token']);
        await prefs.setString('userId', data['userId']);
        await prefs.setString('userRole', data['role']);
        await prefs.setString('logged_in_user', data['role']);
        await prefs.setString('userEmail', email);
        if (data['onboardingComplete'] == true) {
          await prefs.setBool('onboarding_complete', true);
        }
        
        if (!mounted) return;
        
        final userRole = data['role'] as String;
        
        print('[LOGIN] Navigating based on role: $userRole, onboardingComplete: ${data['onboardingComplete']}');
        
        if (data['onboardingComplete'] == true) {
          final dashboardRoute = userRole == 'learner' ? '/learner-dashboard' : '/tutor-dashboard';
          print('[LOGIN] Navigating to dashboard: $dashboardRoute');
          Navigator.pushNamedAndRemoveUntil(
            context,
            dashboardRoute,
            (route) => false,
          );
        } else {
          final step = data['currentStep'] ?? 'profile';
          final onboardingRoute = userRole == 'learner' ? '/learner-onboarding' : '/tutor-onboarding';
          print('[LOGIN] Navigating to onboarding: $onboardingRoute, step: $step');
          Navigator.pushNamedAndRemoveUntil(
            context,
            onboardingRoute,
            (route) => false,
            arguments: {'resumeStep': step},
          );
        }
      } else {
        final errorBody = jsonDecode(response.body);
        final errorMessage = errorBody['error'] ?? 'Login failed';
        print('[LOGIN] Login failed: $errorMessage');
        setState(() {
          _loading = false;
          _error = errorMessage;
        });
        HapticFeedback.heavyImpact();
      }
    } catch (e) {
      print('[LOGIN] Exception: $e');
      setState(() {
        _loading = false;
        _error = 'Network error. Please try again.';
      });
      HapticFeedback.heavyImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        _Header(
          title: 'Welcome back',
          subtitle: 'Sign in to your account.',
          role: null, // Don't show role badge, we have toggle now
        ),
        const SizedBox(height: 20),
        // Role Toggle - M3 Style
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            children: [
              Expanded(
                child: _RoleToggleButton(
                  label: 'Tutor',
                  icon: Icons.school_rounded,
                  isSelected: _selectedRole == 'tutor',
                  onTap: () {
                    if (_selectedRole != 'tutor') {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedRole = 'tutor');
                    }
                  },
                ),
              ),
              Expanded(
                child: _RoleToggleButton(
                  label: 'Learner',
                  icon: Icons.person_rounded,
                  isSelected: _selectedRole == 'learner',
                  onTap: () {
                    if (_selectedRole != 'learner') {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedRole = 'learner');
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (_error.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _error,
                    style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Email address',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter your email';
                  if (!v.contains('@')) return 'Enter a valid email';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passCtrl,
                obscureText: _obscure,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (v) => _submit(),
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(_obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter your password';
                  if (v.length < 6) return 'At least 6 characters';
                  return null;
                },
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: widget.onForgot,
            child: const Text('Forgot password?'),
          ),
        ),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: _loading ? null : _submit,
          child: _loading
              ? const _Loading(size: 20)
              : const Text('Sign in'),
        ),
        const SizedBox(height: 20),
        const _DividerLine(),
        const SizedBox(height: 12),
        _FooterLink(
          text: "Don't have an account?",
          linkText: 'Register',
          onTap: () {
            HapticFeedback.selectionClick();
            Navigator.pop(context);
            RoleSheet.show(context);
          },
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared Components
// ─────────────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.subtitle, this.role});
  final String title;
  final String subtitle;
  final String? role;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: tt.headlineMedium?.copyWith(
                      color: cs.onSurface, fontWeight: FontWeight.w700, height: 1.1)),
              const SizedBox(height: 4),
              Text(subtitle, style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
            ],
          ),
        ),
        if (role != null) ...[
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: cs.secondaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(_cap(role!),
                style: tt.labelMedium?.copyWith(
                    color: cs.onSecondaryContainer, fontWeight: FontWeight.w700)),
          ),
        ],
      ],
    );
  }
}

class _DividerLine extends StatelessWidget {
  const _DividerLine();
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(child: Divider(color: cs.outlineVariant)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text('or',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ),
        Expanded(child: Divider(color: cs.outlineVariant)),
      ],
    );
  }
}

class _FooterLink extends StatelessWidget {
  const _FooterLink({required this.text, required this.linkText, required this.onTap});
  final String text;
  final String linkText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(text, style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
        TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(linkText,
              style: tt.bodyMedium?.copyWith(
                  color: cs.primary, fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}

class _SentView extends StatelessWidget {
  const _SentView({required this.email, required this.onBack});
  final String email;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: cs.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(Icons.mark_email_read_rounded,
                  color: cs.onPrimaryContainer, size: 26),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Check your inbox',
                        style: tt.titleSmall?.copyWith(
                            color: cs.onPrimaryContainer,
                            fontWeight: FontWeight.w700,
                            inherit: true)),
                    const SizedBox(height: 2),
                    Text('Reset link sent to $email',
                        style: tt.bodySmall?.copyWith(
                            color: cs.onPrimaryContainer.withValues(alpha: 0.8),
                            inherit: true)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        FilledButton.tonal(
          onPressed: onBack,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: const StadiumBorder(),
            elevation: 0,
          ),
          child: const Text('Back to sign in'),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}


class _Loading extends StatelessWidget {
  const _Loading({this.size = 20});
  final double size;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _AegisTag extends StatelessWidget {
  const _AegisTag();
  static final _url = Uri.parse('https://aegis.navchetna.tech');

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        launchUrl(_url, mode: LaunchMode.externalApplication);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('secured by ',
              style: TextStyle(
                fontFamily: 'Courier',
                fontSize: 10,
                color: cs.onSurfaceVariant.withValues(alpha: 0.6),
              )),
          const SizedBox(width: 4),
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              cs.onSurfaceVariant.withValues(alpha: 0.8),
              BlendMode.srcIn,
            ),
            child: Image.network(
              'https://navchetna.in/aegis.png',
              height: 14,
              cacheWidth: 80,
              fit: BoxFit.contain,
              errorBuilder: (c, e, s) => Text('Aegis',
                  style: TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurfaceVariant)),
            ),
          ),
        ],
      ),
    );
  }
}

String _cap(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

class _RoleToggleButton extends StatelessWidget {
  const _RoleToggleButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? cs.secondaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? cs.onSecondaryContainer : cs.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: tt.labelLarge?.copyWith(
                color: isSelected ? cs.onSecondaryContainer : cs.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
