import 'package:flutter/material.dart';

class MeetMoreSheet extends StatelessWidget {
  final bool isSpeakerOn;
  final bool isHandRaised;
  final bool isRecording;
  final VoidCallback onToggleSpeaker;
  final VoidCallback onRaiseHand;
  final VoidCallback onPresent;
  final VoidCallback onCaptions;
  final VoidCallback onMessages;
  final VoidCallback onRecording;
  final VoidCallback onSettings;
  final VoidCallback onReport;
  final VoidCallback onTools;

  const MeetMoreSheet({
    super.key,
    required this.isSpeakerOn,
    required this.isHandRaised,
    required this.isRecording,
    required this.onToggleSpeaker,
    required this.onRaiseHand,
    required this.onPresent,
    required this.onCaptions,
    required this.onMessages,
    required this.onRecording,
    required this.onSettings,
    required this.onReport,
    required this.onTools,
  });

  static void show(
    BuildContext context, {
    required bool isSpeakerOn,
    required bool isHandRaised,
    required bool isRecording,
    required VoidCallback onToggleSpeaker,
    required VoidCallback onRaiseHand,
    required VoidCallback onPresent,
    required VoidCallback onCaptions,
    required VoidCallback onMessages,
    required VoidCallback onRecording,
    required VoidCallback onSettings,
    required VoidCallback onReport,
    required VoidCallback onTools,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => MeetMoreSheet(
        isSpeakerOn: isSpeakerOn,
        isHandRaised: isHandRaised,
        isRecording: isRecording,
        onToggleSpeaker: onToggleSpeaker,
        onRaiseHand: onRaiseHand,
        onPresent: onPresent,
        onCaptions: onCaptions,
        onMessages: onMessages,
        onRecording: onRecording,
        onSettings: onSettings,
        onReport: onReport,
        onTools: onTools,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: cs.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            // Raise hand button
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onRaiseHand,
                borderRadius: BorderRadius.circular(40),
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: isHandRaised ? cs.primaryContainer : cs.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(40),
                    border: isHandRaised ? null : Border.all(
                      color: cs.outlineVariant.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.front_hand_rounded,
                      color: isHandRaised ? cs.onPrimaryContainer : cs.onSurfaceVariant,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Icon grid
            Row(
              children: [
                Expanded(
                  child: _GridButton(
                    icon: Icons.present_to_all_rounded,
                    onTap: onPresent,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _GridButton(
                    icon: Icons.closed_caption_rounded,
                    onTap: onCaptions,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _GridButton(
                    icon: Icons.volume_up_rounded,
                    isActive: isSpeakerOn,
                    onTap: onToggleSpeaker,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Messages and Class Recording
            Row(
              children: [
                Expanded(
                  child: _TextCard(
                    icon: Icons.chat_bubble_rounded,
                    title: 'In-call\nmessages',
                    onTap: onMessages,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _TextCard(
                    icon: Icons.fiber_manual_record_rounded,
                    title: 'Class\nRecording',
                    onTap: onRecording,
                    isActive: isRecording,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Bottom utility row
            Row(
              children: [
                Expanded(
                  child: _UtilButton(
                    icon: Icons.construction_rounded,
                    label: 'Tools',
                    onTap: onTools,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _UtilButton(
                    icon: Icons.settings_rounded,
                    label: 'Settings',
                    onTap: onSettings,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _UtilButton(
                    icon: Icons.report_rounded,
                    label: 'Report',
                    onTap: onReport,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GridButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _GridButton({
    required this.icon,
    this.isActive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(isActive ? 28 : 44),
        child: Container(
          height: 88,
          decoration: BoxDecoration(
            color: isActive ? cs.primaryContainer : cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(isActive ? 28 : 44),
            border: isActive ? null : Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Center(
            child: Icon(
              icon,
              color: isActive ? cs.onPrimaryContainer : cs.onSurfaceVariant,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}

class _TextCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isActive;

  const _TextCard({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isActive ? cs.primaryContainer : cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(24),
            border: isActive ? null : Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: isActive ? cs.onPrimaryContainer : cs.onSurfaceVariant,
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: tt.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: isActive ? cs.onPrimaryContainer : cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UtilButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _UtilButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: cs.onSurfaceVariant, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
