import 'package:flutter/material.dart';

class MeetBottomNav extends StatelessWidget {
  final bool isCameraOn;
  final bool isMicOn;
  final VoidCallback onToggleCamera;
  final VoidCallback onToggleMic;
  final VoidCallback onReactions;
  final VoidCallback onMore;
  final VoidCallback onEndCall;

  const MeetBottomNav({
    super.key,
    required this.isCameraOn,
    required this.isMicOn,
    required this.onToggleCamera,
    required this.onToggleMic,
    required this.onReactions,
    required this.onMore,
    required this.onEndCall,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _BottomControlButton(
              icon: isCameraOn ? Icons.videocam_rounded : Icons.videocam_off_rounded,
              onTap: onToggleCamera,
              isOff: !isCameraOn,
            ),
            _BottomControlButton(
              icon: isMicOn ? Icons.mic_rounded : Icons.mic_off_rounded,
              onTap: onToggleMic,
              isOff: !isMicOn,
            ),
            _BottomControlButton(
              icon: Icons.mood_rounded,
              onTap: onReactions,
            ),
            _BottomControlButton(
              icon: Icons.more_vert_rounded,
              onTap: onMore,
            ),
            Container(
              width: 64,
              height: 48,
              decoration: BoxDecoration(
                color: cs.error,
                borderRadius: BorderRadius.circular(24),
              ),
              child: IconButton(
                onPressed: onEndCall,
                icon: const Icon(Icons.call_end_rounded),
                color: cs.onError,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isOff;

  const _BottomControlButton({
    required this.icon,
    required this.onTap,
    this.isOff = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: 56,
      height: 48,
      decoration: BoxDecoration(
        color: isOff ? cs.errorContainer : cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon),
        color: isOff ? cs.onErrorContainer : cs.onSurface,
      ),
    );
  }
}
