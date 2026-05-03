import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PhoneField extends StatefulWidget {
  const PhoneField({
    super.key,
    required this.onChanged,
    required this.onSendOtp,
    this.enabled = true,
    this.verified = false,
    this.otpSent = false,
    this.sending = false,
    this.validator,
    this.useTertiary = false,
  });

  final void Function(String dialCode, String number, bool valid, String countryName) onChanged;
  final VoidCallback onSendOtp;
  final bool enabled;
  final bool verified;
  final bool otpSent;
  final bool sending;
  final String? Function(String?)? validator;
  final bool useTertiary;

  @override
  State<PhoneField> createState() => _PhoneFieldState();
}

class _PhoneFieldState extends State<PhoneField> {
  final _ctrl = TextEditingController();
  _Country _selected = _kCountries[0];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _notify() {
    final n = _ctrl.text.trim();
    widget.onChanged(
      _selected.dial,
      n,
      n.length >= _selected.minLen && n.length <= _selected.maxLen,
      _selected.name,
    );
  }

  void _pickCountry() async {
    final result = await showModalBottomSheet<_Country>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const _CountryPicker(),
    );
    if (result != null) {
      setState(() => _selected = result);
      _notify();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final brandColor = widget.useTertiary ? cs.tertiary : cs.primary;
    final tt = Theme.of(context).textTheme;

    Widget suffix;
    if (widget.verified) {
      suffix = Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Icon(Icons.verified_rounded, color: Colors.green.shade600),
      );
    } else if (widget.sending) {
      suffix = Padding(
        padding: const EdgeInsets.only(right: 14),
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2, color: brandColor),
        ),
      );
    } else {
      suffix = TextButton(
        onPressed: widget.onSendOtp,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          widget.otpSent ? 'Resend' : 'Send OTP',
          style: tt.labelMedium?.copyWith(
            color: brandColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return TextFormField(
      controller: _ctrl,
      enabled: widget.enabled,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.done,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(_selected.maxLen),
      ],
      onChanged: (_) => _notify(),
      decoration: InputDecoration(
        labelText: 'Phone number',
        prefixIcon: GestureDetector(
          onTap: widget.enabled ? _pickCountry : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_selected.flag, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 4),
                Text(
                  _selected.dial,
                  style: TextStyle(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Icon(Icons.arrow_drop_down_rounded,
                    size: 18, color: cs.onSurfaceVariant),
              ],
            ),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        suffixIcon: suffix,
        suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      ),
      validator: widget.validator ??
          (v) {
            if (v == null || v.trim().isEmpty) return 'Enter your phone number';
            if (v.trim().length < _selected.minLen) {
              return 'Enter a valid number';
            }
            return null;
          },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Country picker sheet
// ─────────────────────────────────────────────────────────────────────────────

class _CountryPicker extends StatefulWidget {
  const _CountryPicker();

  @override
  State<_CountryPicker> createState() => _CountryPickerState();
}

class _CountryPickerState extends State<_CountryPicker> {
  final _search = TextEditingController();
  List<_Country> _filtered = _kCountries;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _filter(String q) {
    final lower = q.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? _kCountries
          : _kCountries
              .where((c) =>
                  c.name.toLowerCase().contains(lower) ||
                  c.dial.contains(lower))
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 32,
            height: 4,
            decoration: BoxDecoration(
              color: cs.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text('Select country',
                style:
                    tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _search,
              autofocus: true,
              onChanged: _filter,
              decoration: const InputDecoration(
                hintText: 'Search country or code',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 340,
            child: ListView.builder(
              itemCount: _filtered.length,
              itemBuilder: (_, i) {
                final c = _filtered[i];
                return ListTile(
                  leading:
                      Text(c.flag, style: const TextStyle(fontSize: 24)),
                  title: Text(c.name, style: tt.bodyMedium),
                  trailing: Text(c.dial,
                      style: tt.bodyMedium
                          ?.copyWith(color: cs.onSurfaceVariant)),
                  onTap: () => Navigator.pop(context, c),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Country data
// ─────────────────────────────────────────────────────────────────────────────

class _Country {
  const _Country(this.flag, this.name, this.dial, this.minLen, this.maxLen);
  final String flag, name, dial;
  final int minLen, maxLen;
}

const _kCountries = [
  _Country('🇮🇳', 'India', '+91', 10, 10),
  _Country('🇺🇸', 'United States', '+1', 10, 10),
  _Country('🇬🇧', 'United Kingdom', '+44', 10, 10),
  _Country('🇦🇪', 'UAE', '+971', 9, 9),
  _Country('🇸🇦', 'Saudi Arabia', '+966', 9, 9),
  _Country('🇦🇺', 'Australia', '+61', 9, 9),
  _Country('🇨🇦', 'Canada', '+1', 10, 10),
  _Country('🇸🇬', 'Singapore', '+65', 8, 8),
  _Country('🇳🇿', 'New Zealand', '+64', 9, 9),
  _Country('🇿🇦', 'South Africa', '+27', 9, 9),
  _Country('🇩🇪', 'Germany', '+49', 10, 11),
  _Country('🇫🇷', 'France', '+33', 9, 9),
  _Country('🇮🇹', 'Italy', '+39', 9, 10),
  _Country('🇪🇸', 'Spain', '+34', 9, 9),
  _Country('🇳🇱', 'Netherlands', '+31', 9, 9),
  _Country('🇧🇷', 'Brazil', '+55', 10, 11),
  _Country('🇲🇽', 'Mexico', '+52', 10, 10),
  _Country('🇯🇵', 'Japan', '+81', 10, 10),
  _Country('🇰🇷', 'South Korea', '+82', 9, 10),
  _Country('🇨🇳', 'China', '+86', 11, 11),
  _Country('🇵🇰', 'Pakistan', '+92', 10, 10),
  _Country('🇧🇩', 'Bangladesh', '+880', 10, 10),
  _Country('🇱🇰', 'Sri Lanka', '+94', 9, 9),
  _Country('🇳🇵', 'Nepal', '+977', 9, 10),
  _Country('🇲🇾', 'Malaysia', '+60', 9, 10),
  _Country('🇮🇩', 'Indonesia', '+62', 9, 12),
  _Country('🇵🇭', 'Philippines', '+63', 10, 10),
  _Country('🇹🇭', 'Thailand', '+66', 9, 9),
  _Country('🇻🇳', 'Vietnam', '+84', 9, 10),
  _Country('🇰🇪', 'Kenya', '+254', 9, 9),
  _Country('🇳🇬', 'Nigeria', '+234', 10, 10),
  _Country('🇬🇭', 'Ghana', '+233', 9, 9),
  _Country('🇪🇬', 'Egypt', '+20', 10, 10),
  _Country('🇷🇺', 'Russia', '+7', 10, 10),
  _Country('🇹🇷', 'Turkey', '+90', 10, 10),
];
