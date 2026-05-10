import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TutorSettingsTab extends StatefulWidget {
  const TutorSettingsTab({super.key});

  @override
  State<TutorSettingsTab> createState() => _TutorSettingsTabState();
}

class _TutorSettingsTabState extends State<TutorSettingsTab> {
  bool _notifs = true;
  bool _emails = false;
  bool _autoAccept = false;

  static const _email = 'priya.sharma@example.com';
  String _phone = '+91 98765 12345';

  @override
  Widget build(BuildContext context) {
    final cs    = Theme.of(context).colorScheme;
    final tt    = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        // ── Account ──────────────────────────────────────────────────
        _GroupLabel('Account', cs: cs, tt: tt),
        const SizedBox(height: 8),
        _InfoTile(icon: Icons.email_outlined,  label: 'Email', value: _email, cs: cs, tt: tt),
        const SizedBox(height: 8),
        _InfoTile(
          icon: Icons.phone_outlined, label: 'Phone', value: _phone,
          cs: cs, tt: tt,
          onEdit: () => _showEditPhone(context),
        ),
        const SizedBox(height: 20),

        // ── Teaching Preferences ─────────────────────────────────────
        _GroupLabel('Teaching Preferences', cs: cs, tt: tt),
        const SizedBox(height: 8),
        _ActionTile(
          icon: Icons.schedule_outlined, label: 'Availability Schedule',
          cs: cs, tt: tt,
        ),
        const SizedBox(height: 8),
        _ActionTile(
          icon: Icons.attach_money_rounded, label: 'Pricing & Rates',
          cs: cs, tt: tt,
        ),
        const SizedBox(height: 8),
        _SwitchTile(
          icon: Icons.check_circle_outline_rounded, label: 'Auto-accept Bookings',
          value: _autoAccept, cs: cs, tt: tt,
          onChanged: (v) => setState(() => _autoAccept = v),
        ),
        const SizedBox(height: 20),

        // ── Notifications ─────────────────────────────────────────────
        _GroupLabel('Notifications', cs: cs, tt: tt),
        const SizedBox(height: 8),
        _SwitchTile(
          icon: Icons.notifications_outlined, label: 'Push Notifications',
          value: _notifs, cs: cs, tt: tt,
          onChanged: (v) => setState(() => _notifs = v),
        ),
        const SizedBox(height: 8),
        _SwitchTile(
          icon: Icons.email_outlined, label: 'Email Updates',
          value: _emails, cs: cs, tt: tt,
          onChanged: (v) => setState(() => _emails = v),
        ),
        const SizedBox(height: 20),

        // ── More ──────────────────────────────────────────────────────
        _GroupLabel('More', cs: cs, tt: tt),
        const SizedBox(height: 8),
        _ActionTile(
          icon: Icons.lock_outline_rounded, label: 'Change Password',
          cs: cs, tt: tt,
          onTap: () => _showChangePassword(context),
        ),
        const SizedBox(height: 8),
        _ActionTile(icon: Icons.account_balance_wallet_outlined, label: 'Payment Settings',  cs: cs, tt: tt),
        const SizedBox(height: 8),
        _ActionTile(icon: Icons.help_outline_rounded, label: 'Help & Support',  cs: cs, tt: tt),
        const SizedBox(height: 8),
        _ActionTile(icon: Icons.privacy_tip_outlined, label: 'Privacy Policy',  cs: cs, tt: tt),
      ],
    );
  }

  // ── Edit phone ──────────────────────────────────────────────────────────────

  void _showEditPhone(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => _EditPhoneSheet(
        current: _phone,
        onSave: (v) => setState(() => _phone = v),
      ),
    );
  }

  // ── Change password ─────────────────────────────────────────────────────────

  void _showChangePassword(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => _ChangePasswordSheet(email: _email),
    );
  }
}

// ─── Edit phone sheet ─────────────────────────────────────────────────────────

class _EditPhoneSheet extends StatefulWidget {
  const _EditPhoneSheet({required this.current, required this.onSave});
  final String current;
  final ValueChanged<String> onSave;

  @override
  State<_EditPhoneSheet> createState() => _EditPhoneSheetState();
}

class _EditPhoneSheetState extends State<_EditPhoneSheet> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.current);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 12, 24, MediaQuery.of(context).viewInsets.bottom + 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DragHandle(cs: cs),
          const SizedBox(height: 20),
          Text('Edit Phone Number', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Enter your new phone number below.',
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: 20),
          TextField(
            controller: _ctrl,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9 +\-()]'))],
            decoration: InputDecoration(
              labelText: 'Phone number',
              prefixIcon: const Icon(Icons.phone_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () {
              final v = _ctrl.text.trim();
              if (v.isNotEmpty) widget.onSave(v);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

// ─── Change password sheet ────────────────────────────────────────────────────

class _ChangePasswordSheet extends StatefulWidget {
  const _ChangePasswordSheet({required this.email});
  final String email;

  @override
  State<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<_ChangePasswordSheet> {
  late final TextEditingController _ctrl;
  bool _sent = false;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.email);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    setState(() => _sending = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (mounted) setState(() { _sending = false; _sent = true; });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 12, 24, MediaQuery.of(context).viewInsets.bottom + 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DragHandle(cs: cs),
          const SizedBox(height: 20),
          Text('Change Password', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(
            _sent
                ? 'A password reset link has been sent to your email.'
                : 'We\'ll send a password reset link to your email address.',
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          if (_sent) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.tertiaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: cs.tertiary.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  Icon(Icons.mark_email_read_outlined, color: cs.tertiary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Check your inbox at\n${_ctrl.text.trim()}',
                      style: tt.bodySmall?.copyWith(color: cs.onSurface, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Done'),
            ),
          ] else ...[
            TextField(
              controller: _ctrl,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email address',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _sending ? null : _send,
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _sending
                  ? SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: cs.onTertiary),
                    )
                  : const Text('Send Reset Link'),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Shared tile widgets ──────────────────────────────────────────────────────

class _GroupLabel extends StatelessWidget {
  const _GroupLabel(this.text, {required this.cs, required this.tt});
  final String text;
  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(text,
            style: tt.labelSmall?.copyWith(
                color: cs.onSurfaceVariant, fontWeight: FontWeight.w600, letterSpacing: 0.6)),
      );
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon, required this.label, required this.value,
    required this.cs, required this.tt, this.onEdit,
  });
  final IconData icon;
  final String label, value;
  final ColorScheme cs;
  final TextTheme tt;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: cs.onSurfaceVariant),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                const SizedBox(height: 1),
                Text(value, style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          if (onEdit != null)
            GestureDetector(
              onTap: onEdit,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: cs.tertiaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('Edit',
                    style: tt.labelSmall?.copyWith(
                        color: cs.onTertiaryContainer, fontWeight: FontWeight.w600)),
              ),
            ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon, required this.label,
    required this.cs, required this.tt, this.onTap,
  });
  final IconData icon;
  final String label;
  final ColorScheme cs;
  final TextTheme tt;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: cs.onSurfaceVariant),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: tt.bodyMedium)),
            Icon(Icons.chevron_right_rounded, size: 18, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.icon, required this.label, required this.value,
    required this.cs, required this.tt, required this.onChanged,
  });
  final IconData icon;
  final String label;
  final bool value;
  final ColorScheme cs;
  final TextTheme tt;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: cs.onSurfaceVariant),
          const SizedBox(width: 14),
          Expanded(child: Text(label, style: tt.bodyMedium)),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle({required this.cs});
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) => Center(
        child: Container(
          width: 32, height: 4,
          decoration: BoxDecoration(
            color: cs.onSurfaceVariant.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );
}
