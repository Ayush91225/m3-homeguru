import 'package:flutter/material.dart';
import '../../../../services/audio_device_manager.dart';

class AudioOutputSheet extends StatefulWidget {
  final String currentDevice;
  final Function(String, AudioDeviceType) onDeviceSelected;

  const AudioOutputSheet({
    super.key,
    required this.currentDevice,
    required this.onDeviceSelected,
  });

  static void show(
    BuildContext context, {
    required String currentDevice,
    required Function(String, AudioDeviceType) onDeviceSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => AudioOutputSheet(
        currentDevice: currentDevice,
        onDeviceSelected: onDeviceSelected,
      ),
    );
  }

  @override
  State<AudioOutputSheet> createState() => _AudioOutputSheetState();
}

class _AudioOutputSheetState extends State<AudioOutputSheet> {
  late String _selectedDevice;
  List<AudioDevice> _devices = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _selectedDevice = widget.currentDevice;
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    final devices = await AudioDeviceManager.getAvailableDevices();
    if (mounted) {
      setState(() {
        _devices = devices;
        _loading = false;
      });
    }
  }

  void _selectDevice(AudioDevice device) {
    setState(() => _selectedDevice = device.name);
    AudioDeviceManager.setAudioDevice(device.id);
    widget.onDeviceSelected(device.name, device.type);
    Navigator.pop(context);
  }

  IconData _getIconForType(AudioDeviceType type) {
    switch (type) {
      case AudioDeviceType.bluetooth:
        return Icons.bluetooth_audio_rounded;
      case AudioDeviceType.wired:
        return Icons.headset_rounded;
      case AudioDeviceType.earpiece:
        return Icons.phone_in_talk_rounded;
      case AudioDeviceType.speaker:
        return Icons.volume_up_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
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
              'Audio output',
              style: tt.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            // Loading or device list
            if (_loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_devices.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'No audio devices available',
                    style: tt.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else
              ...(_devices.map((device) {
                final isSelected = _selectedDevice == device.name;
                return AnimatedScale(
                  scale: 1.0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: device.isAvailable
                          ? () => _selectDevice(device)
                          : null,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? cs.primaryContainer
                              : cs.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _getIconForType(device.type),
                              color: isSelected
                                  ? cs.onPrimaryContainer
                                  : device.isAvailable
                                      ? cs.onSurfaceVariant
                                      : cs.onSurfaceVariant
                                          .withValues(alpha: 0.4),
                              size: 24,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                device.name,
                                style: tt.bodyLarge?.copyWith(
                                  color: isSelected
                                      ? cs.onPrimaryContainer
                                      : device.isAvailable
                                          ? cs.onSurface
                                          : cs.onSurface
                                              .withValues(alpha: 0.4),
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle_rounded,
                                color: cs.primary,
                                size: 24,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              })),
          ],
        ),
      ),
    );
  }
}
