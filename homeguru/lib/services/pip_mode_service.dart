import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class PipModeService {
  static const _channel = MethodChannel('com.navchetna.homeguru/pip');

  static Future<bool> enterPipMode() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return false;
    }
    
    try {
      final result = await _channel.invokeMethod('enterPipMode');
      return result == true;
    } catch (e) {
      debugPrint('Error entering PIP mode: $e');
      return false;
    }
  }

  static Future<bool> isPipSupported() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return false;
    }
    
    try {
      final result = await _channel.invokeMethod('isPipSupported');
      return result == true;
    } catch (e) {
      debugPrint('Error checking PIP support: $e');
      return false;
    }
  }
}
