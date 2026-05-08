import 'package:flutter/material.dart';

class ReportIssueSheet extends StatefulWidget {
  const ReportIssueSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const ReportIssueSheet(),
    );
  }

  @override
  State<ReportIssueSheet> createState() => _ReportIssueSheetState();
}

class _ReportIssueSheetState extends State<ReportIssueSheet> {
  String? _selectedIssue;
  final _descriptionController = TextEditingController();

  final List<String> _issues = [
    'Audio problem',
    'Video problem',
    'Connection issue',
    'Inappropriate behavior',
    'Other',
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_selectedIssue == null) return;

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Report submitted: $_selectedIssue'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
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
                const SizedBox(height: 24),

                // Title
                Text(
                  'Report Issue',
                  style: tt.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),

                // Issue buttons
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _issues.map((issue) {
                    final isSelected = _selectedIssue == issue;
                    return AnimatedScale(
                      scale: 1.0,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutCubic,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => setState(() => _selectedIssue = issue),
                          borderRadius: BorderRadius.circular(12),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? cs.primaryContainer
                                  : cs.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? cs.primary
                                    : cs.outlineVariant.withValues(alpha: 0.5),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Text(
                              issue,
                              style: tt.labelMedium?.copyWith(
                                color: isSelected
                                    ? cs.onPrimaryContainer
                                    : cs.onSurfaceVariant,
                                fontWeight:
                                    isSelected ? FontWeight.w600 : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),

                // Description field
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    hintText: 'Describe the issue (optional)...',
                    hintStyle: tt.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                    filled: true,
                    fillColor: cs.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: cs.outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: cs.outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: cs.primary,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                ),

                const SizedBox(height: 16),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.pop(context),
                        style: FilledButton.styleFrom(
                          backgroundColor: cs.surfaceContainerHighest,
                          foregroundColor: cs.onSurfaceVariant,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                            side: BorderSide(
                              color: cs.outlineVariant.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: tt.labelLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _selectedIssue != null ? _submit : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: cs.primary,
                          foregroundColor: cs.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          disabledBackgroundColor:
                              cs.surfaceContainerHighest,
                          disabledForegroundColor:
                              cs.onSurfaceVariant.withValues(alpha: 0.6),
                        ),
                        child: Text(
                          'Submit',
                          style: tt.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: _selectedIssue != null ? cs.onPrimary : null,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

