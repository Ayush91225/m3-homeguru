# Meeting App - Platform Implementation

## Overview
The HomeGuru meeting app now has full native platform integration for audio device detection and call notifications.

## Features Implemented

### 1. Audio Device Detection (Real Hardware)
- **Android**: Uses `AudioManager` to detect all available audio devices
- **iOS**: Uses `AVAudioSession` to detect all available audio devices
- Detects: Phone speaker, Earpiece, Wired headsets, Bluetooth devices
- Real-time device switching during calls

### 2. Active Call Notification
- **Flutter**: Uses `flutter_local_notifications` package
- **Android**: Ongoing notification with chronometer (auto-updating timer)
- **iOS**: Time-sensitive notification
- Shows meeting code and call duration
- Persistent notification that stays until call ends

### 3. Class Recording
- Always active during meetings
- Visual indicator in more sheet
- Shows "Class recording is active" message

## Setup Instructions

### 1. Install Dependencies
```bash
cd homeguru
flutter pub get
```

### 2. Android Setup
The Android implementation is complete in `MainActivity.kt`:
- Audio device detection using `AudioManager`
- Support for Android 6.0+ (API 23+)
- Fallback for older Android versions
- Bluetooth SCO support

**Permissions** (already added in AndroidManifest.xml):
- `MODIFY_AUDIO_SETTINGS`
- `BLUETOOTH`
- `BLUETOOTH_CONNECT`
- `POST_NOTIFICATIONS`
- `FOREGROUND_SERVICE`

### 3. iOS Setup
The iOS implementation is complete in `AppDelegate.swift`:
- Audio device detection using `AVAudioSession`
- Support for iOS 12.0+
- Automatic Bluetooth device selection
- Wired headset detection

**Permissions** (already added in Info.plist):
- `NSMicrophoneUsageDescription`
- `NSCameraUsageDescription`

### 4. Build and Run
```bash
# Android
flutter run

# iOS
cd ios
pod install
cd ..
flutter run
```

## How It Works

### Audio Device Detection

**Android Flow:**
1. `AudioDeviceManager.getAvailableDevices()` calls native method
2. `MainActivity.kt` queries `AudioManager.getDevices()`
3. Returns list of available devices with type and name
4. User selects device → `setAudioDevice()` configures audio routing

**iOS Flow:**
1. `AudioDeviceManager.getAvailableDevices()` calls native method
2. `AppDelegate.swift` queries `AVAudioSession.availableInputs`
3. Returns list of available devices with type and name
4. User selects device → `setAudioDevice()` configures audio routing

### Call Notification

**Notification Flow:**
1. Meeting starts → `CallNotificationService.startCallNotification()`
2. Creates ongoing notification with meeting details
3. Timer updates every 5 seconds (Android chronometer auto-updates)
4. Meeting ends → `CallNotificationService.stopCallNotification()`

**Android Notification:**
- Channel: "Active Calls"
- Priority: High
- Ongoing: true (can't be dismissed)
- Chronometer: Auto-updating timer
- Color: #1E3162 (brand color)

**iOS Notification:**
- Interruption Level: Time Sensitive
- Shows in notification center
- Stays until call ends

## Testing

### Test Audio Devices
1. Start a meeting
2. Tap audio output button (top right)
3. See all available devices:
   - Phone speaker
   - Earpiece
   - Wired headset (if connected)
   - Bluetooth devices (if connected)
4. Select different devices and verify audio routing

### Test Call Notification
1. Start a meeting
2. Pull down notification shade
3. See "Class with [Tutor]" or "HomeGuru Meeting"
4. See meeting code and timer
5. Timer updates automatically
6. End call → notification disappears

## Architecture

```
Flutter Layer
├── CallNotificationService (flutter_local_notifications)
├── AudioDeviceManager (platform channels)
└── MeetScreen (UI)

Platform Layer (Android)
├── MainActivity.kt
│   ├── Audio device detection
│   └── Audio routing
└── AndroidManifest.xml (permissions)

Platform Layer (iOS)
├── AppDelegate.swift
│   ├── Audio device detection
│   └── Audio routing
└── Info.plist (permissions)
```

## Files Modified/Created

### Flutter
- `lib/services/call_notification_service.dart` - Notification service
- `lib/services/audio_device_manager.dart` - Audio device manager
- `lib/main.dart` - Initialize notification service
- `pubspec.yaml` - Added flutter_local_notifications

### Android
- `android/app/src/main/kotlin/com/navchetna/homeguru/MainActivity.kt` - Native audio implementation
- `android/app/src/main/AndroidManifest.xml` - Permissions (already had them)

### iOS
- `ios/Runner/AppDelegate.swift` - Native audio implementation
- `ios/Runner/Info.plist` - Permissions (already had them)

## Troubleshooting

### Android
- **No Bluetooth devices showing**: Enable Bluetooth and pair device first
- **Notification not showing**: Grant notification permission in app settings
- **Audio not routing**: Check MODIFY_AUDIO_SETTINGS permission

### iOS
- **No audio devices**: Check microphone permission
- **Bluetooth not working**: Ensure device is paired in iOS Settings
- **Notification not showing**: Check notification permissions

## Future Enhancements
- CallKit integration for iOS (native call UI)
- Picture-in-Picture mode
- Screen sharing implementation
- Real-time captions
- Background blur for camera

## Notes
- Audio device detection works on real devices only (not simulators)
- Bluetooth devices must be paired before they appear
- Notification requires permission grant on first use
- Class recording is always active (visual indicator only)
