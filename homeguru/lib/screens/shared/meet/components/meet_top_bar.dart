import 'package:flutter/material.dart';
import '../../../../services/audio_device_manager.dart';

class MeetTopBar extends StatelessWidget {
  final VoidCallback onBack;
  final String statusText;
  final String meetingCode;
  final VoidCallback onAudioOutput;
  final AudioDeviceType audioDeviceType;

  const MeetTopBar({
    super.key,
    required this.onBack,
    required this.statusText,
    required this.meetingCode,
    required this.onAudioOutput,
    required this.audioDeviceType,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    IconData audioIcon;
    switch (audioDeviceType) {
      case AudioDeviceType.bluetooth:
        audioIcon = Icons.bluetooth_audio_rounded;
        break;
      case AudioDeviceType.wired:
        audioIcon = Icons.headset_rounded;
        break;
      case AudioDeviceType.earpiece:
        audioIcon = Icons.phone_in_talk_rounded;
        break;
      case AudioDeviceType.speaker:
        audioIcon = Icons.volume_up_rounded;
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
            style: IconButton.styleFrom(
              backgroundColor: cs.surfaceContainerLow,
              foregroundColor: cs.onSurface,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_rounded,
                  size: 16,
                  color: cs.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  statusText,
                  style: tt.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '• $meetingCode',
                  style: tt.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onAudioOutput,
            icon: Icon(audioIcon),
            style: IconButton.styleFrom(
              backgroundColor: cs.surfaceContainerLow,
              foregroundColor: cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
