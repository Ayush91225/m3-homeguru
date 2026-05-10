import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

class CallNotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static const int _callNotificationId = 999;
  static bool _isInitialized = false;
  static String? _currentMeetingCode;
  static String? _currentTutorName;
  static DateTime? _callStartTime;
  static const _actionChannel = MethodChannel('com.navchetna.homeguru/call_actions');
  static Function(String)? onActionCallback;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        if (details.actionId != null) {
          _handleNotificationAction(details.actionId!);
        }
      },
    );

    // Set up method channel to receive actions from native
    _actionChannel.setMethodCallHandler((call) async {
      if (call.method == 'onNotificationAction') {
        final action = call.arguments['action'] as String?;
        if (action != null) {
          _handleNotificationAction(action);
        }
      }
    });

    if (defaultTargetPlatform == TargetPlatform.android) {
      const androidChannel = AndroidNotificationChannel(
        'homeguru_call_channel',
        'Active Calls',
        description: 'Ongoing video call notifications',
        importance: Importance.max,
        playSound: false,
        enableVibration: false,
        showBadge: false,
      );

      await _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidChannel);

      await _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: false,
            sound: false,
          );
    }

    _isInitialized = true;
    debugPrint('✅ CallNotificationService initialized');
  }

  static void _handleNotificationAction(String actionId) {
    debugPrint('📱 Notification action: $actionId');
    onActionCallback?.call(actionId);
  }

  static void setActionCallback(Function(String) callback) {
    onActionCallback = callback;
  }

  static Future<void> startCallNotification({
    required String meetingCode,
    required String userName,
    String? tutorName,
    required Duration duration,
    bool isCameraOn = true,
    bool isMicOn = true,
  }) async {
    try {
      await initialize();

      _currentMeetingCode = meetingCode;
      _currentTutorName = tutorName;
      _callStartTime ??= DateTime.now();

      final title = tutorName != null && tutorName.isNotEmpty
          ? 'Ongoing class with $tutorName'
          : 'HomeGuru Meeting';

      final body = 'Tap to return • $meetingCode';

      if (Platform.isAndroid) {
        // Use native Android notification with action buttons
        await _actionChannel.invokeMethod('showCallNotification', {
          'title': title,
          'body': body,
          'meetingCode': meetingCode,
          'tutorName': tutorName ?? '',
          'startTime': _callStartTime!.millisecondsSinceEpoch,
          'isCameraOn': isCameraOn,
          'isMicOn': isMicOn,
        });
      } else {
        // iOS fallback
        const iosDetails = DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: false,
          presentSound: false,
          interruptionLevel: InterruptionLevel.timeSensitive,
        );

        const details = NotificationDetails(iOS: iosDetails);

        await _notifications.show(
          _callNotificationId,
          title,
          body,
          details,
        );
      }
      debugPrint('✅ Call notification shown: $title');
    } catch (e) {
      debugPrint('❌ Notification error: $e');
    }
  }

  static Future<void> updateCallNotification({
    required bool isCameraOn,
    required bool isMicOn,
  }) async {
    if (_currentMeetingCode == null) return;

    await startCallNotification(
      meetingCode: _currentMeetingCode!,
      userName: '',
      tutorName: _currentTutorName,
      duration: _callStartTime != null
          ? DateTime.now().difference(_callStartTime!)
          : Duration.zero,
      isCameraOn: isCameraOn,
      isMicOn: isMicOn,
    );
  }

  static Future<void> updateCallDuration(Duration duration) async {}

  static Future<void> stopCallNotification() async {
    try {
      if (Platform.isAndroid) {
        await _actionChannel.invokeMethod('cancelCallNotification');
      } else {
        await _notifications.cancel(_callNotificationId);
      }
      _currentMeetingCode = null;
      _currentTutorName = null;
      _callStartTime = null;
      debugPrint('✅ Call notification stopped');
    } catch (e) {
      debugPrint('❌ Stop notification error: $e');
    }
  }
}
