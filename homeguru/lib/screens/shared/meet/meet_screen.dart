import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:async';
import 'components/camera_preview_widget.dart';
import 'components/meet_top_bar.dart';
import 'components/meet_bottom_nav.dart';
import 'components/meet_more_sheet.dart';
import 'components/meet_tools_drawer.dart';
import 'components/audio_output_sheet.dart';
import 'components/report_issue_sheet.dart';
import 'components/meet_empty_state.dart';
import 'components/shared_image_viewer.dart';
import 'components/floating_reaction.dart';
import 'components/reaction_bar.dart';
import '../chat/conversation_screen.dart';
import '../chat/chat_models.dart';
import '../../../services/audio_device_manager.dart';
import '../../../services/call_notification_service.dart';
import '../../../services/pip_mode_service.dart';

class MeetScreen extends StatefulWidget {
  final String meetingCode;
  final String userName;
  final bool initialCameraState;
  final bool initialMicState;
  final ChatTutor? tutor;
  final List<ChatMessage>? chatMessages;

  const MeetScreen({
    super.key,
    required this.meetingCode,
    required this.userName,
    this.initialCameraState = true,
    this.initialMicState = false,
    this.tutor,
    this.chatMessages,
  });

  @override
  State<MeetScreen> createState() => _MeetScreenState();
}

class _MeetScreenState extends State<MeetScreen> {
  late bool _isCameraOn;
  late bool _isMicOn;
  bool _isFrontCamera = true;
  bool _isSpeakerOn = true;
  bool _showControls = true;
  bool _isHandRaised = false;
  bool _showReactionBar = false;
  final bool _isRecording = true;
  bool _isScreenSharing = false;
  String _audioOutput = 'Phone speaker';
  AudioDeviceType _audioDeviceType = AudioDeviceType.speaker;
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  final List<_ReactionData> _activeReactions = [];
  Timer? _callTimer;
  Duration _callDuration = Duration.zero;
  bool _isDisposed = false;
  bool _isInitializing = false;

  @override
  void initState() {
    super.initState();
    _isCameraOn = widget.initialCameraState;
    _isMicOn = widget.initialMicState;
    // Lazy camera init with delay to let UI settle
    if (_isCameraOn) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && !_isDisposed) _initializeCamera();
      });
    }
    _startCallTimer();
    _setDefaultAudioOutput();
    _startCallNotification();
    _setupNotificationActions();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _setupNotificationActions() {
    CallNotificationService.setActionCallback((action) {
      if (!mounted || _isDisposed) return;
      
      switch (action) {
        case 'camera_toggle':
          _toggleCamera();
          break;
        case 'mic_toggle':
          _toggleMic();
          break;
        case 'end_call':
          _endCall();
          break;
      }
    });
  }

  Future<void> _setDefaultAudioOutput() async {
    try {
      // Set speaker as default
      await AudioDeviceManager.setAudioDevice('speaker');
      final devices = await AudioDeviceManager.getAvailableDevices();
      final speaker = devices.firstWhere(
        (d) => d.id == 'speaker',
        orElse: () => devices.first,
      );
      if (mounted && !_isDisposed) {
        setState(() {
          _audioOutput = speaker.name;
          _audioDeviceType = speaker.type;
        });
      }
    } catch (e) {
      debugPrint('Audio device error: $e');
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _cameraController?.dispose();
    _callTimer?.cancel();
    CallNotificationService.stopCallNotification();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _startCallNotification() {
    CallNotificationService.startCallNotification(
      meetingCode: widget.meetingCode,
      userName: widget.userName,
      tutorName: widget.tutor?.name,
      duration: _callDuration,
      isCameraOn: _isCameraOn,
      isMicOn: _isMicOn,
    );
  }

  void _startCallTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isDisposed && mounted) {
        setState(() {
          _callDuration = Duration(seconds: timer.tick);
        });
        // Update notification every 10 seconds
        if (timer.tick % 10 == 0) {
          CallNotificationService.updateCallDuration(_callDuration);
        }
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  Future<void> _initializeCamera() async {
    if (_isDisposed || _isInitializing) return;
    _isInitializing = true;
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty || _isDisposed) {
        _isInitializing = false;
        return;
      }

      final camera = _cameras!.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras!.first,
      );

      _cameraController = CameraController(
        camera,
        ResolutionPreset.low,
        enableAudio: true,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _cameraController!.initialize();
      if (mounted && !_isDisposed) setState(() {});
    } catch (e) {
      debugPrint('Camera init error: $e');
    } finally {
      _isInitializing = false;
    }
  }

  void _toggleCamera() {
    setState(() => _isCameraOn = !_isCameraOn);
    if (_isCameraOn && _cameraController == null) {
      _initializeCamera();
    }
    CallNotificationService.updateCallNotification(
      isCameraOn: _isCameraOn,
      isMicOn: _isMicOn,
    );
  }
  
  void _toggleMic() {
    setState(() => _isMicOn = !_isMicOn);
    CallNotificationService.updateCallNotification(
      isCameraOn: _isCameraOn,
      isMicOn: _isMicOn,
    );
  }
  void _toggleSpeaker() => setState(() => _isSpeakerOn = !_isSpeakerOn);
  void _toggleRaiseHand() {
    setState(() => _isHandRaised = !_isHandRaised);
    Navigator.pop(context);
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
      if (!_showControls) _showReactionBar = false;
    });
  }

  void _switchCamera() async {
    if (_cameras == null || _cameras!.length < 2 || _cameraController == null || _isDisposed || _isInitializing) return;

    _isInitializing = true;
    final newDirection = _isFrontCamera
        ? CameraLensDirection.back
        : CameraLensDirection.front;

    final camera = _cameras!.firstWhere(
      (c) => c.lensDirection == newDirection,
      orElse: () => _cameras!.first,
    );

    await _cameraController?.dispose();

    _cameraController = CameraController(
      camera,
      ResolutionPreset.low,
      enableAudio: true,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await _cameraController!.initialize();
      if (mounted && !_isDisposed) {
        setState(() => _isFrontCamera = !_isFrontCamera);
      }
    } catch (e) {
      debugPrint('Camera switch error: $e');
    } finally {
      _isInitializing = false;
    }
  }

  void _copyMeetingLink() {
    Clipboard.setData(ClipboardData(text: 'meet.homeguru.com/${widget.meetingCode}'));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Meeting link copied'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _shareInvite() {
    Share.share(
      'Join my meeting on HomeGuru\nmeet.homeguru.com/${widget.meetingCode}',
      subject: 'Join my HomeGuru meeting',
    );
  }

  void _showReactionPicker() {
    setState(() => _showReactionBar = !_showReactionBar);
  }

  void _sendReaction(String emoji) {
    if (_activeReactions.length >= 3) return;
    
    final reactionData = _ReactionData(
      key: UniqueKey(),
      emoji: emoji,
      startTime: DateTime.now(),
    );
    
    setState(() {
      _showReactionBar = false;
      _activeReactions.add(reactionData);
    });

    Future.delayed(const Duration(milliseconds: 4000), () {
      if (mounted && !_isDisposed) {
        setState(() {
          _activeReactions.removeWhere((r) => r.key == reactionData.key);
        });
      }
    });
  }

  void _showMoreOptions() {
    MeetMoreSheet.show(
      context,
      isSpeakerOn: _isSpeakerOn,
      isHandRaised: _isHandRaised,
      isRecording: _isRecording,
      onToggleSpeaker: _toggleSpeaker,
      onRaiseHand: _toggleRaiseHand,
      onPresent: _startScreenSharing,
      onCaptions: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Captions feature coming soon'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          ),
        );
      },
      onMessages: _showMessages,
      onRecording: _showRecordingMessage,
      onSettings: _showSettings,
      onReport: _showReportIssue,
      onTools: _showTools,
    );
  }

  void _showTools() {
    Navigator.pop(context); // close more sheet first
    MeetToolsDrawer.show(
      context,
      onShareMedia: _handleShareMedia,
    );
  }

  void _handleShareMedia(String type, dynamic content) {
    debugPrint('_handleShareMedia called: type=$type, content=$content');
    if (type == 'image') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (ctx) => SharedImageViewer(
            imageUrl: content as String,
            onClose: () => Navigator.pop(ctx),
          ),
        ),
      );
      // TODO: Send via WebSocket signaling: signaling.send({'action': 'image-share', 'mediaType': 'image', 'content': content});
    }
  }

  void _startScreenSharing() {
    Navigator.pop(context);
    setState(() => _isScreenSharing = !_isScreenSharing);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isScreenSharing 
            ? 'Screen sharing started' 
            : 'Screen sharing stopped'
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        action: _isScreenSharing ? SnackBarAction(
          label: 'Stop',
          onPressed: () => setState(() => _isScreenSharing = false),
        ) : null,
      ),
    );
  }

  void _showSettings() {
    Navigator.pop(context);
    // TODO: Implement real settings
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings feature coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showMessages() {
    Navigator.pop(context);
    
    // Use the tutor passed from prejoin, don't create a fallback
    if (widget.tutor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chat not available'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConversationScreen(
          tutor: widget.tutor!,
          messages: widget.chatMessages ?? [],
        ),
      ),
    );
  }

  void _showRecordingMessage() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Class recording is active'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
    );
  }

  void _showAudioOutput() {
    AudioOutputSheet.show(
      context,
      currentDevice: _audioOutput,
      onDeviceSelected: (device, type) {
        setState(() {
          _audioOutput = device;
          _audioDeviceType = type;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Audio output: $device'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  void _showReportIssue() {
    ReportIssueSheet.show(context);
  }

  void _endCall() {
    // Pop all routes and go back to home
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final pipSupported = await PipModeService.isPipSupported();
        if (pipSupported) {
          await PipModeService.enterPipMode();
        } else {
          if (context.mounted) Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
        body: SafeArea(
        child: Stack(
          children: [
            // Main content
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggleControls,
                child: Container(
                  color: Colors.transparent,
                  child: MeetEmptyState(
                    meetingCode: widget.meetingCode,
                    onCopyLink: _copyMeetingLink,
                    onShareInvite: _shareInvite,
                  ),
                ),
              ),
            ),

            // Top bar
            if (_showControls)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: MeetTopBar(
                  onBack: _endCall,
                  statusText: _formatDuration(_callDuration),
                  meetingCode: widget.meetingCode,
                  onAudioOutput: _showAudioOutput,
                  audioDeviceType: _audioDeviceType,
                ),
              ),

            // Camera preview
            if (_showControls)
              Positioned(
                bottom: 100,
                right: 16,
                child: CameraPreviewWidget(
                  cameraController: _cameraController,
                  isCameraOn: _isCameraOn,
                  isMicOn: _isMicOn,
                  onSwitchCamera: _switchCamera,
                  onToggleMic: _toggleMic,
                  isHandRaised: _isHandRaised,
                ),
              )
            else
              Positioned(
                bottom: 16,
                right: 16,
                child: CameraPreviewWidget(
                  cameraController: _cameraController,
                  isCameraOn: _isCameraOn,
                  isMicOn: _isMicOn,
                  onSwitchCamera: _switchCamera,
                  onToggleMic: _toggleMic,
                  isHandRaised: _isHandRaised,
                ),
              ),

            // Floating reactions
            ..._activeReactions.map((reaction) => 
                  FloatingReactionWidget(
                    key: reaction.key,
                    emoji: reaction.emoji,
                  ),
                ),

            // Screen sharing indicator
            if (_isScreenSharing && _showControls)
              Positioned(
                top: 80,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.screen_share_rounded,
                        size: 16,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Sharing screen',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (_isScreenSharing)
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.screen_share_rounded,
                        size: 16,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Sharing screen',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Reaction bar
            if (_showReactionBar)
              Positioned(
                bottom: _showControls ? 110 : 10,
                left: 0,
                right: 0,
                child: ReactionBar(onReaction: _sendReaction),
              ),

            // Bottom nav
            if (_showControls)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: MeetBottomNav(
                  isCameraOn: _isCameraOn,
                  isMicOn: _isMicOn,
                  onToggleCamera: _toggleCamera,
                  onToggleMic: _toggleMic,
                  onReactions: _showReactionPicker,
                  onMore: _showMoreOptions,
                  onEndCall: _endCall,
                ),
              ),
          ],
        ),
      ),
    ),
    );
  }
}

class _ReactionData {
  final Key key;
  final String emoji;
  final DateTime startTime;

  _ReactionData({
    required this.key,
    required this.emoji,
    required this.startTime,
  });
}
