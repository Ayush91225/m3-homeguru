import Flutter
import UIKit
import AVFoundation

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
    private let AUDIO_CHANNEL = "com.homeguru/audio"
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        let controller = window?.rootViewController as! FlutterViewController
        let audioChannel = FlutterMethodChannel(
            name: AUDIO_CHANNEL,
            binaryMessenger: controller.binaryMessenger
        )
        
        audioChannel.setMethodCallHandler { [weak self] (call, result) in
            guard let self = self else { return }
            
            switch call.method {
            case "getAudioDevices":
                let devices = self.getAvailableAudioDevices()
                result(devices)
            case "setAudioDevice":
                if let args = call.arguments as? [String: Any],
                   let deviceId = args["deviceId"] as? String {
                    self.setAudioDevice(deviceId: deviceId)
                    result(nil)
                } else {
                    result(FlutterError(code: "INVALID_ARGUMENT",
                                      message: "Device ID is required",
                                      details: nil))
                }
            case "getCurrentDevice":
                let currentDevice = self.getCurrentAudioDevice()
                result(currentDevice)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
        GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    }
    
    private func getAvailableAudioDevices() -> [[String: Any]] {
        var devices: [[String: Any]] = []
        
        // Always add speaker
        devices.append([
            "id": "speaker",
            "name": "iPhone Speaker",
            "type": "speaker",
            "isAvailable": true
        ])
        
        // Always add earpiece
        devices.append([
            "id": "earpiece",
            "name": "Earpiece",
            "type": "earpiece",
            "isAvailable": true
        ])
        
        let audioSession = AVAudioSession.sharedInstance()
        let availableInputs = audioSession.availableInputs ?? []
        
        for input in availableInputs {
            switch input.portType {
            case .headphones, .headsetMic:
                devices.append([
                    "id": "wired_\(input.uid)",
                    "name": input.portName,
                    "type": "wired",
                    "isAvailable": true
                ])
            case .bluetoothA2DP, .bluetoothHFP, .bluetoothLE:
                devices.append([
                    "id": "bluetooth_\(input.uid)",
                    "name": input.portName,
                    "type": "bluetooth",
                    "isAvailable": true
                ])
            default:
                break
            }
        }
        
        // Check current route for additional outputs
        let currentRoute = audioSession.currentRoute
        for output in currentRoute.outputs {
            switch output.portType {
            case .bluetoothA2DP, .bluetoothHFP, .bluetoothLE:
                // Check if not already added
                let exists = devices.contains { device in
                    if let id = device["id"] as? String {
                        return id.contains(output.uid)
                    }
                    return false
                }
                if !exists {
                    devices.append([
                        "id": "bluetooth_\(output.uid)",
                        "name": output.portName,
                        "type": "bluetooth",
                        "isAvailable": true
                    ])
                }
            default:
                break
            }
        }
        
        return devices
    }
    
    private func setAudioDevice(deviceId: String) {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(.playAndRecord, mode: .voiceChat, options: [.allowBluetooth, .allowBluetoothA2DP])
            
            if deviceId == "speaker" {
                try audioSession.overrideOutputAudioPort(.speaker)
            } else if deviceId == "earpiece" {
                try audioSession.overrideOutputAudioPort(.none)
            } else if deviceId.starts(with: "bluetooth") {
                // Bluetooth will be automatically selected if available
                try audioSession.setPreferredInput(nil)
            } else if deviceId.starts(with: "wired") {
                // Wired headset will be automatically selected if plugged in
                try audioSession.overrideOutputAudioPort(.none)
            }
            
            try audioSession.setActive(true)
        } catch {
            print("Failed to set audio device: \(error.localizedDescription)")
        }
    }
    
    private func getCurrentAudioDevice() -> String {
        let audioSession = AVAudioSession.sharedInstance()
        let currentRoute = audioSession.currentRoute
        
        for output in currentRoute.outputs {
            switch output.portType {
            case .bluetoothA2DP, .bluetoothHFP, .bluetoothLE:
                return "bluetooth"
            case .headphones, .headsetMic:
                return "wired"
            case .builtInSpeaker:
                return "speaker"
            case .builtInReceiver:
                return "earpiece"
            default:
                break
            }
        }
        
        return "speaker"
    }
}
