package com.navchetna.homeguru

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.PictureInPictureParams
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.res.Configuration
import android.media.AudioDeviceInfo
import android.media.AudioManager
import android.os.Build
import android.provider.Settings
import android.util.Rational
import androidx.core.app.NotificationCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val AUDIO_CHANNEL = "com.homeguru/audio"
    private val CAPTION_CHANNEL = "com.navchetna.homeguru/captions"
    private val PIP_CHANNEL = "com.navchetna.homeguru/pip"
    private val CALL_ACTION_CHANNEL = "com.navchetna.homeguru/call_actions"
    private var audioManager: AudioManager? = null
    private var callActionChannel: MethodChannel? = null

    companion object {
        const val ACTION_CAMERA_TOGGLE = "com.navchetna.homeguru.CAMERA_TOGGLE"
        const val ACTION_MIC_TOGGLE = "com.navchetna.homeguru.MIC_TOGGLE"
        const val ACTION_END_CALL = "com.navchetna.homeguru.END_CALL"
        const val NOTIFICATION_ID = 999
        const val CHANNEL_ID = "homeguru_call_channel"
    }

    private val notificationActionReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            when (intent?.action) {
                ACTION_CAMERA_TOGGLE -> {
                    callActionChannel?.invokeMethod("onNotificationAction", mapOf("action" to "camera_toggle"))
                }
                ACTION_MIC_TOGGLE -> {
                    callActionChannel?.invokeMethod("onNotificationAction", mapOf("action" to "mic_toggle"))
                }
                ACTION_END_CALL -> {
                    callActionChannel?.invokeMethod("onNotificationAction", mapOf("action" to "end_call"))
                }
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager

        // Register broadcast receiver for notification actions
        val filter = IntentFilter().apply {
            addAction(ACTION_CAMERA_TOGGLE)
            addAction(ACTION_MIC_TOGGLE)
            addAction(ACTION_END_CALL)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(notificationActionReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            registerReceiver(notificationActionReceiver, filter)
        }

        // Audio device channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, AUDIO_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getAudioDevices" -> {
                    val devices = getAvailableAudioDevices()
                    result.success(devices)
                }
                "setAudioDevice" -> {
                    val deviceId = call.argument<String>("deviceId")
                    if (deviceId != null) {
                        setAudioDevice(deviceId)
                        result.success(null)
                    } else {
                        result.error("INVALID_ARGUMENT", "Device ID is required", null)
                    }
                }
                "getCurrentDevice" -> {
                    val currentDevice = getCurrentAudioDevice()
                    result.success(currentDevice)
                }
                else -> result.notImplemented()
            }
        }

        // Caption channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CAPTION_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "openLiveCaptionSettings" -> {
                    try {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                            val intent = Intent(Settings.ACTION_CAPTIONING_SETTINGS)
                            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                            startActivity(intent)
                            result.success(null)
                        } else {
                            result.error("NOT_AVAILABLE", "Live Caption requires Android 10+", null)
                        }
                    } catch (e: Exception) {
                        result.error("ERROR", "Failed to open Live Caption settings: ${e.message}", null)
                    }
                }
                else -> result.notImplemented()
            }
        }

        // PIP channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, PIP_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "enterPipMode" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        val params = PictureInPictureParams.Builder()
                            .setAspectRatio(Rational(9, 16))
                            .build()
                        val entered = enterPictureInPictureMode(params)
                        result.success(entered)
                    } else {
                        result.success(false)
                    }
                }
                "isPipSupported" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        result.success(packageManager.hasSystemFeature("android.software.picture_in_picture"))
                    } else {
                        result.success(false)
                    }
                }
                else -> result.notImplemented()
            }
        }

        // Call action channel
        callActionChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CALL_ACTION_CHANNEL)
        callActionChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "showCallNotification" -> {
                    val title = call.argument<String>("title") ?: "HomeGuru Meeting"
                    val body = call.argument<String>("body") ?: ""
                    val startTime = call.argument<Long>("startTime") ?: System.currentTimeMillis()
                    val isCameraOn = call.argument<Boolean>("isCameraOn") ?: true
                    val isMicOn = call.argument<Boolean>("isMicOn") ?: true
                    showCallNotification(title, body, startTime, isCameraOn, isMicOn)
                    result.success(null)
                }
                "cancelCallNotification" -> {
                    val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                    notificationManager.cancel(NOTIFICATION_ID)
                    result.success(null)
                }
                "handleAction" -> {
                    val action = call.argument<String>("action")
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun showCallNotification(
        title: String,
        body: String,
        startTime: Long,
        isCameraOn: Boolean,
        isMicOn: Boolean
    ) {
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        // Create notification channel
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Active Calls",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Ongoing video call notifications"
                setSound(null, null)
                enableVibration(false)
                enableLights(false)
                setShowBadge(false)
            }
            notificationManager.createNotificationChannel(channel)
        }

        // Create pending intents for actions
        val cameraIntent = Intent(ACTION_CAMERA_TOGGLE).apply {
            setPackage(packageName)
        }
        val cameraPendingIntent = PendingIntent.getBroadcast(
            this,
            0,
            cameraIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val micIntent = Intent(ACTION_MIC_TOGGLE).apply {
            setPackage(packageName)
        }
        val micPendingIntent = PendingIntent.getBroadcast(
            this,
            1,
            micIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val endCallIntent = Intent(ACTION_END_CALL).apply {
            setPackage(packageName)
        }
        val endCallPendingIntent = PendingIntent.getBroadcast(
            this,
            2,
            endCallIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        // Build notification
        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle(title)
            .setContentText(body)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setColor(0xFF1E3162.toInt())
            .setColorized(true)
            .setOngoing(true)
            .setAutoCancel(false)
            .setOnlyAlertOnce(true)
            .setShowWhen(true)
            .setWhen(startTime)
            .setUsesChronometer(true)
            .setChronometerCountDown(false)
            .setCategory(NotificationCompat.CATEGORY_CALL)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setSound(null)
            .setVibrate(null)
            .addAction(
                0,
                if (isCameraOn) "Camera Off" else "Camera On",
                cameraPendingIntent
            )
            .addAction(
                0,
                if (isMicOn) "Mute" else "Unmute",
                micPendingIntent
            )
            .addAction(
                0,
                "Leave",
                endCallPendingIntent
            )
            .build()

        notificationManager.notify(NOTIFICATION_ID, notification)
    }

    override fun onDestroy() {
        try {
            unregisterReceiver(notificationActionReceiver)
        } catch (e: Exception) {
            // Receiver not registered
        }
        super.onDestroy()
    }

    override fun onPictureInPictureModeChanged(
        isInPictureInPictureMode: Boolean,
        newConfig: Configuration
    ) {
        super.onPictureInPictureModeChanged(isInPictureInPictureMode, newConfig)
    }

    private fun getAvailableAudioDevices(): List<Map<String, Any>> {
        val devices = mutableListOf<Map<String, Any>>()

        // Always add phone speaker
        devices.add(mapOf(
            "id" to "speaker",
            "name" to "Phone speaker",
            "type" to "speaker",
            "isAvailable" to true
        ))

        // Always add earpiece
        devices.add(mapOf(
            "id" to "earpiece",
            "name" to "Earpiece",
            "type" to "earpiece",
            "isAvailable" to true
        ))

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            audioManager?.getDevices(AudioManager.GET_DEVICES_OUTPUTS)?.forEach { device ->
                when (device.type) {
                    AudioDeviceInfo.TYPE_WIRED_HEADSET,
                    AudioDeviceInfo.TYPE_WIRED_HEADPHONES,
                    AudioDeviceInfo.TYPE_USB_HEADSET -> {
                        devices.add(mapOf(
                            "id" to "wired_${device.id}",
                            "name" to (device.productName?.toString() ?: "Wired headset"),
                            "type" to "wired",
                            "isAvailable" to true
                        ))
                    }
                    AudioDeviceInfo.TYPE_BLUETOOTH_A2DP,
                    AudioDeviceInfo.TYPE_BLUETOOTH_SCO -> {
                        devices.add(mapOf(
                            "id" to "bluetooth_${device.id}",
                            "name" to (device.productName?.toString() ?: "Bluetooth device"),
                            "type" to "bluetooth",
                            "isAvailable" to true
                        ))
                    }
                }
            }
        } else {
            // Fallback for older Android versions
            if (audioManager?.isWiredHeadsetOn == true) {
                devices.add(mapOf(
                    "id" to "wired",
                    "name" to "Wired headset",
                    "type" to "wired",
                    "isAvailable" to true
                ))
            }
            if (audioManager?.isBluetoothA2dpOn == true || audioManager?.isBluetoothScoOn == true) {
                devices.add(mapOf(
                    "id" to "bluetooth",
                    "name" to "Bluetooth device",
                    "type" to "bluetooth",
                    "isAvailable" to true
                ))
            }
        }

        return devices
    }

    private fun setAudioDevice(deviceId: String) {
        when {
            deviceId == "speaker" -> {
                audioManager?.mode = AudioManager.MODE_IN_COMMUNICATION
                audioManager?.isSpeakerphoneOn = true
            }
            deviceId == "earpiece" -> {
                audioManager?.mode = AudioManager.MODE_IN_COMMUNICATION
                audioManager?.isSpeakerphoneOn = false
            }
            deviceId.startsWith("bluetooth") -> {
                audioManager?.mode = AudioManager.MODE_IN_COMMUNICATION
                audioManager?.startBluetoothSco()
                audioManager?.isBluetoothScoOn = true
            }
            deviceId.startsWith("wired") -> {
                audioManager?.mode = AudioManager.MODE_IN_COMMUNICATION
                audioManager?.isSpeakerphoneOn = false
            }
        }
    }

    private fun getCurrentAudioDevice(): String {
        return when {
            audioManager?.isBluetoothScoOn == true -> "bluetooth"
            audioManager?.isWiredHeadsetOn == true -> "wired"
            audioManager?.isSpeakerphoneOn == true -> "speaker"
            else -> "earpiece"
        }
    }
}
