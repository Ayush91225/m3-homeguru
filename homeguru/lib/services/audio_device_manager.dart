import 'package:flutter/services.dart';

class AudioDeviceManager {
  static const MethodChannel _channel = MethodChannel('com.homeguru/audio');

  static Future<List<AudioDevice>> getAvailableDevices() async {
    try {
      final List<dynamic> devices = await _channel.invokeMethod('getAudioDevices');
      return devices.map((d) => AudioDevice.fromMap(d)).toList();
    } catch (e) {
      // Fallback to default devices if platform implementation not available
      return _getDefaultDevices();
    }
  }

  static Future<void> setAudioDevice(String deviceId) async {
    try {
      await _channel.invokeMethod('setAudioDevice', {'deviceId': deviceId});
    } catch (e) {
      // Silently fail if platform implementation not available
    }
  }

  static Future<String> getCurrentDevice() async {
    try {
      final result = await _channel.invokeMethod('getCurrentDevice');
      return result ?? 'speaker';
    } catch (e) {
      return 'speaker';
    }
  }

  static List<AudioDevice> _getDefaultDevices() {
    return [
      AudioDevice(
        id: 'speaker',
        name: 'Phone speaker',
        type: AudioDeviceType.speaker,
        isAvailable: true,
      ),
      AudioDevice(
        id: 'earpiece',
        name: 'Earpiece',
        type: AudioDeviceType.earpiece,
        isAvailable: true,
      ),
    ];
  }
}

enum AudioDeviceType {
  speaker,
  earpiece,
  wired,
  bluetooth,
}

class AudioDevice {
  final String id;
  final String name;
  final AudioDeviceType type;
  final bool isAvailable;

  AudioDevice({
    required this.id,
    required this.name,
    required this.type,
    required this.isAvailable,
  });

  factory AudioDevice.fromMap(Map<dynamic, dynamic> map) {
    return AudioDevice(
      id: map['id'] as String,
      name: map['name'] as String,
      type: _parseType(map['type'] as String),
      isAvailable: map['isAvailable'] as bool? ?? true,
    );
  }

  static AudioDeviceType _parseType(String type) {
    switch (type.toLowerCase()) {
      case 'bluetooth':
        return AudioDeviceType.bluetooth;
      case 'wired':
      case 'headset':
        return AudioDeviceType.wired;
      case 'earpiece':
        return AudioDeviceType.earpiece;
      default:
        return AudioDeviceType.speaker;
    }
  }
}
