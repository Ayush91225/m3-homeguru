import 'package:flutter/material.dart';
import 'calendar_types.dart';
import 'reschedule_sheet.dart';

class CancelSheet extends StatefulWidget {
  final CalendarEvent event;

  const CancelSheet({super.key, required this.event});

  @override
  State<CancelSheet> createState() => _CancelSheetState();
}

class _CancelSheetState extends State<CancelSheet> {
  int _step = 1;
  int? _selectedScope;
  int? _selectedReason;
  final TextEditingController _otherReasonController = TextEditingController();
  final List<String> _scopes = [
    'Cancel this class only',
    'Cancel all sessions with this tutor',
  ];
  final List<String> _reasons = [
    'Schedule conflict',
    'Not feeling well',
    'Emergency came up',
    'Need to reschedule',
    'Other',
  ];

  @override
  void dispose() {
    _otherReasonController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    if (_step == 1 && _selectedScope != null) {
      setState(() => _step = 2);
    } else if (_step == 2 && _selectedScope == 0) {
      setState(() => _step = 3);
    }
  }

  void _handleReschedule() {
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RescheduleSheet(event: widget.event),
    );
  }

  void _handleCancel() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Class cancelled successfully'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: cs.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(Icons.cancel_rounded, color: cs.error),
              const SizedBox(width: 12),
              Text('Cancel Class', style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 24),
          if (_step == 1) _buildScopeSelection(cs, tt),
          if (_step == 2) _buildReasonSelection(cs, tt),
          if (_step == 3) _buildRescheduleOption(cs, tt),
        ],
      ),
    );
  }

  Widget _buildScopeSelection(ColorScheme cs, TextTheme tt) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.errorContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(Icons.warning_amber_rounded, size: 20, color: cs.error),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Choose what you want to cancel',
                  style: tt.bodySmall?.copyWith(color: cs.onSurface),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Align(
          alignment: Alignment.centerLeft,
          child: Text('What would you like to cancel?', style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 12),
        ...List.generate(_scopes.length, (index) {
          final isSelected = _selectedScope == index;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () => setState(() => _selectedScope = index),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected ? cs.primaryContainer : cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? cs.primary : cs.outlineVariant,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                      size: 20,
                      color: isSelected ? cs.primary : cs.onSurfaceVariant,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _scopes[index],
                      style: tt.bodyMedium?.copyWith(
                        color: isSelected ? cs.onPrimaryContainer : cs.onSurface,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                child: const Text('Go Back'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: _selectedScope != null ? _handleContinue : null,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReasonSelection(ColorScheme cs, TextTheme tt) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.errorContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(Icons.warning_amber_rounded, size: 20, color: cs.error),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _selectedScope == 1
                      ? 'All sessions with this tutor will be cancelled'
                      : 'This action cannot be undone',
                  style: tt.bodySmall?.copyWith(color: cs.onSurface),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Align(
          alignment: Alignment.centerLeft,
          child: Text('Reason for cancellation', style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 12),
        ...List.generate(_reasons.length, (index) {
          final isSelected = _selectedReason == index;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () => setState(() => _selectedReason = index),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected ? cs.primaryContainer : cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? cs.primary : cs.outlineVariant,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                      size: 20,
                      color: isSelected ? cs.primary : cs.onSurfaceVariant,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _reasons[index],
                      style: tt.bodyMedium?.copyWith(
                        color: isSelected ? cs.onPrimaryContainer : cs.onSurface,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        if (_selectedReason == 4) ...[
          const SizedBox(height: 12),
          TextField(
            controller: _otherReasonController,
            decoration: InputDecoration(
              hintText: 'Please specify...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: cs.surfaceContainerHighest,
            ),
            maxLines: 3,
          ),
        ],
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _step = 1),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                child: const Text('Go Back'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: _selectedReason != null &&
                        (_selectedReason != 4 || _otherReasonController.text.isNotEmpty)
                    ? () {
                        if (_selectedScope == 0) {
                          _handleContinue();
                        } else {
                          _handleCancel();
                        }
                      }
                    : null,
                style: FilledButton.styleFrom(
                  backgroundColor: cs.error,
                  foregroundColor: cs.onError,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                child: Text(_selectedScope == 0 ? 'Continue' : 'Cancel All'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRescheduleOption(ColorScheme cs, TextTheme tt) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.primaryContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 20, color: cs.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Would you like to reschedule this class instead?',
                  style: tt.bodySmall?.copyWith(color: cs.onSurface, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Do you want this class to be conducted later?',
          style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _handleCancel,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  side: BorderSide(color: cs.error),
                ),
                child: Text('No, Cancel', style: TextStyle(color: cs.error)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: _handleReschedule,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                child: const Text('Reschedule'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
