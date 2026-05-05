import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../services/user_profile_store.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  bool _notifs = true;
  bool _emails = false;

  static const _email = 'ravi.kumar@example.com';
  String _phone = '+91 98765 43210';

  @override
  Widget build(BuildContext context) {
    final cs    = Theme.of(context).colorScheme;
    final tt    = Theme.of(context).textTheme;
    final store = ProfileStore.of(context);

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

        // ── Sub-profiles ─────────────────────────────────────────────
        _GroupLabel('Sub-profiles', cs: cs, tt: tt),
        const SizedBox(height: 8),

        // Existing sub-profile cards
        ...store.subProfiles.asMap().entries.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _SubProfileCard(
            profile: e.value,
            cs: cs, tt: tt,
            onDelete: () => store.removeSubProfile(e.key),
          ),
        )),

        _ActionTile(
          icon: Icons.person_add_outlined,
          label: 'Add Sub-profile',
          cs: cs, tt: tt,
          onTap: () => _handleAddSubProfile(context, store),
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
        _ActionTile(icon: Icons.help_outline_rounded, label: 'Help & Support',  cs: cs, tt: tt),
        const SizedBox(height: 8),
        _ActionTile(icon: Icons.privacy_tip_outlined, label: 'Privacy Policy',  cs: cs, tt: tt),
      ],
    );
  }

  // ── Sub-profile flow ────────────────────────────────────────────────────────

  void _handleAddSubProfile(BuildContext context, UserProfileStore store) {
    if (store.guardianWarningShown) {
      _showSubProfileForm(context, store);
    } else {
      _showSubProfileWarning(context, store);
    }
  }

  void _showSubProfileWarning(BuildContext context, UserProfileStore store) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => _SubProfileWarningSheet(
        onContinue: () async {
          await store.markGuardianWarningSeen();
          if (ctx.mounted) Navigator.pop(ctx);
          if (context.mounted) _showSubProfileForm(context, store);
        },
      ),
    );
  }

  void _showSubProfileForm(BuildContext context, UserProfileStore store) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => _SubProfileFormSheet(
        onCreated: (name) => store.addSubProfile(SubProfile(name: name)),
      ),
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

// ─── Sub-profile card ─────────────────────────────────────────────────────────

class _SubProfileCard extends StatelessWidget {
  const _SubProfileCard({required this.profile, required this.cs, required this.tt, required this.onDelete});
  final SubProfile profile;
  final ColorScheme cs;
  final TextTheme tt;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: cs.primaryContainer,
            child: Text(
              profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '?',
              style: tt.titleSmall?.copyWith(
                  color: cs.onPrimaryContainer, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(profile.name,
                    style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                Text('Sub-profile',
                    style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: cs.secondaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('Active',
                style: tt.labelSmall?.copyWith(
                    color: cs.onSecondaryContainer, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _confirmDelete(context),
            child: Icon(Icons.delete_outline_rounded, size: 20, color: cs.error),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Sub-profile'),
        content: Text('Remove "${profile.name}" from your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () { Navigator.pop(ctx); onDelete(); },
            style: FilledButton.styleFrom(backgroundColor: cs.error, foregroundColor: cs.onError),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}

// ─── Sub-profile warning sheet ────────────────────────────────────────────────

class _SubProfileWarningSheet extends StatelessWidget {
  const _SubProfileWarningSheet({required this.onContinue});
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DragHandle(cs: cs),
          const SizedBox(height: 24),
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(color: cs.tertiaryContainer, shape: BoxShape.circle),
            child: Icon(Icons.shield_outlined, size: 32, color: cs.onTertiaryContainer),
          ),
          const SizedBox(height: 16),
          Text('Guardian Profile',
              style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Text(
            'Adding a sub-profile will convert your current account into a Guardian profile.\n\nAs a Guardian, you can manage and monitor all sub-profiles under your account.',
            style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: onContinue,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Continue'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Sub-profile form sheet ───────────────────────────────────────────────────

class _SubProfileFormSheet extends StatefulWidget {
  const _SubProfileFormSheet({required this.onCreated});
  final ValueChanged<String> onCreated;

  @override
  State<_SubProfileFormSheet> createState() => _SubProfileFormSheetState();
}

class _SubProfileFormSheetState extends State<_SubProfileFormSheet> {
  final _nameCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure   = true;
  final _form     = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 12, 24, MediaQuery.of(context).viewInsets.bottom + 32),
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DragHandle(cs: cs),
            const SizedBox(height: 20),
            Text('New Sub-profile', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('Set a name and password for this profile.',
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Name',
                prefixIcon: const Icon(Icons.person_outline_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _passCtrl,
              obscureText: _obscure,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              validator: (v) => (v == null || v.length < 6) ? 'Min 6 characters' : null,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  if (_form.currentState!.validate()) {
                    widget.onCreated(_nameCtrl.text.trim());
                    Navigator.pop(context);
                  }
                },
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Create Sub-profile'),
              ),
            ),
          ],
        ),
      ),
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
    // Simulate network delay
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
                color: cs.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: cs.primary.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  Icon(Icons.mark_email_read_outlined, color: cs.primary, size: 20),
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
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
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
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('Edit',
                    style: tt.labelSmall?.copyWith(
                        color: cs.onPrimaryContainer, fontWeight: FontWeight.w600)),
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
