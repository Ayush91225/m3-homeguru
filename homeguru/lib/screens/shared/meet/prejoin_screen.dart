import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:camera/camera.dart';
import '../../../services/user_profile_store.dart';
import '../../../widgets/schedule/cancel_sheet.dart';
import '../../../widgets/schedule/reschedule_sheet.dart';
import '../../../widgets/schedule/calendar_types.dart';
import '../chat/chat_models.dart';
import 'meeting_details_sheet.dart';
import 'meet_screen.dart';

class PrejoinScreen extends StatefulWidget {
  final String meetingCode;
  final String userName;
  final String userRole;
  final CalendarEvent? event;
  final ChatTutor? tutor;
  final List<ChatMessage>? chatMessages;

  const PrejoinScreen({
    super.key,
    required this.meetingCode,
    required this.userName,
    required this.userRole,
    this.event,
    this.tutor,
    this.chatMessages,
  });

  @override
  State<PrejoinScreen> createState() => _PrejoinScreenState();
}

class _PrejoinScreenState extends State<PrejoinScreen> {
  bool _isCameraOn = false;
  bool _isMicOn = true;
  bool _isFrontCamera = true;
  bool _hasPermissions = false;
  bool _isCheckingPermissions = true;
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _checkPermissions() async {
    final cameraStatus = await Permission.camera.status;
    final micStatus = await Permission.microphone.status;
    
    setState(() {
      _hasPermissions = cameraStatus.isGranted && micStatus.isGranted;
      _isCheckingPermissions = false;
    });

    if (!_hasPermissions) {
      _requestPermissions();
    } else {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        debugPrint('No cameras available');
        return;
      }
      
      final camera = _cameras!.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras!.first,
      );
      
      _cameraController = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: true, // Enable audio for VOIP
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      
      await _cameraController!.initialize();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Camera init error: $e');
      if (mounted) {
        setState(() {
          _hasPermissions = false;
        });
      }
    }
  }

  Future<void> _requestPermissions() async {
    final statuses = await [
      Permission.camera,
      Permission.microphone,
    ].request();

    setState(() {
      _hasPermissions = statuses[Permission.camera]!.isGranted && 
                       statuses[Permission.microphone]!.isGranted;
    });
    
    if (_hasPermissions) {
      _initializeCamera();
    }
  }

  void _toggleCamera() async {
    if (!_hasPermissions) {
      await _requestPermissions();
      return;
    }
    
    if (!_isCameraOn && _cameraController == null) {
      await _initializeCamera();
    }
    
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      setState(() => _isCameraOn = !_isCameraOn);
    }
  }

  void _toggleMic() {
    setState(() => _isMicOn = !_isMicOn);
  }

  void _switchCamera() async {
    if (_cameras == null || _cameras!.length < 2 || _cameraController == null) return;
    
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
      ResolutionPreset.medium,
      enableAudio: true, // Enable audio for VOIP
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    
    try {
      await _cameraController!.initialize();
      if (mounted) {
        setState(() => _isFrontCamera = !_isFrontCamera);
      }
    } catch (e) {
      debugPrint('Camera switch error: $e');
    }
  }

  void _joinMeeting() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MeetScreen(
          meetingCode: widget.meetingCode,
          userName: widget.userName,
          initialCameraState: _isCameraOn,
          initialMicState: _isMicOn,
          tutor: widget.tutor,
          chatMessages: widget.chatMessages,
        ),
      ),
    );
  }

  void _showMeetingDetails() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MeetingDetailsSheet(
        meetingCode: widget.meetingCode,
        event: widget.event,
      ),
    );
  }

  void _showHelpMenu() {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: cs.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.play_circle_outline_rounded, color: cs.primary),
              title: const Text('How to use'),
              subtitle: const Text('Watch tutorial video'),
              onTap: () async {
                Navigator.pop(context);
                final url = Uri.parse('https://www.youtube.com/live/BiM2t-Xvag4?si=9kW_vCxuaHtZNAJR');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRescheduleSheet() {
    if (widget.event == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RescheduleSheet(event: widget.event!),
    );
  }

  void _showCancelSheet() {
    if (widget.event == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CancelSheet(event: widget.event!),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final profile = ProfileStore.of(context);

    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with user name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    style: IconButton.styleFrom(
                      foregroundColor: cs.onSurface,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        profile.name,
                        style: tt.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _showHelpMenu,
                    icon: const Icon(Icons.more_vert_rounded),
                    style: IconButton.styleFrom(
                      foregroundColor: cs.onSurface,
                    ),
                  ),
                ],
              ),
            ),

            // Preview card with animation
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOutCubic,
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Stack(
                    children: [
                      // Camera preview or avatar
                      if (_isCheckingPermissions)
                        Center(child: CircularProgressIndicator(color: cs.primary))
                      else if (_isCameraOn && _cameraController != null && _cameraController!.value.isInitialized)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: SizedBox.expand(
                            child: FittedBox(
                              fit: BoxFit.cover,
                              child: SizedBox(
                                width: _cameraController!.value.previewSize!.height,
                                height: _cameraController!.value.previewSize!.width,
                                child: CameraPreview(_cameraController!),
                              ),
                            ),
                          ),
                        )
                      else
                        Center(
                          child: AnimatedScale(
                            scale: 1.0,
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOutCubic,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: cs.primaryContainer,
                              ),
                              child: profile.avatar != null
                                  ? ClipOval(
                                      child: Image.file(
                                        profile.avatar!,
                                        fit: BoxFit.cover,
                                        width: 120,
                                        height: 120,
                                      ),
                                    )
                                  : Center(
                                      child: Text(
                                        profile.name.isNotEmpty
                                            ? profile.name[0].toUpperCase()
                                            : 'U',
                                        style: tt.displaySmall?.copyWith(
                                          color: cs.onPrimaryContainer,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                        ),

                      // Switch camera button (top right)
                      if (_isCameraOn && _cameras != null && _cameras!.length > 1)
                        Positioned(
                          top: 16,
                          right: 16,
                          child: AnimatedOpacity(
                            opacity: 1.0,
                            duration: const Duration(milliseconds: 200),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _switchCamera,
                                borderRadius: BorderRadius.circular(50),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: cs.surface.withValues(alpha: 0.9),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.2),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.flip_camera_ios_rounded,
                                    color: cs.onSurface,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                      // Bottom controls overlay
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.7),
                                Colors.black.withValues(alpha: 0.3),
                                Colors.transparent,
                              ],
                            ),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(24),
                              bottomRight: Radius.circular(24),
                            ),
                          ),
                          padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _ControlButton(
                                    icon: _isMicOn ? Icons.mic : Icons.mic_off,
                                    isActive: _isMicOn,
                                    onTap: _toggleMic,
                                    cs: cs,
                                  ),
                                  const SizedBox(width: 16),
                                  _ControlButton(
                                    icon: _isCameraOn ? Icons.videocam : Icons.videocam_off,
                                    isActive: _isCameraOn,
                                    onTap: _toggleCamera,
                                    cs: cs,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Meeting info with animation
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutCubic,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _showMeetingDetails,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline_rounded, size: 20, color: cs.onSurfaceVariant),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Ready to join?',
                                  style: tt.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: cs.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.meetingCode,
                                  style: tt.bodySmall?.copyWith(
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded, size: 20, color: cs.onSurfaceVariant),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Join button with animation
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AnimatedScale(
                scale: 1.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                child: FilledButton(
                  onPressed: _hasPermissions ? _joinMeeting : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: cs.onPrimary,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: Text(
                    'Join now',
                    style: tt.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.1,
                      color: cs.onPrimary,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Bottom buttons with animation
            if (widget.event != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _showRescheduleSheet,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: cs.onSurface,
                            side: BorderSide(color: cs.outline),
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: Text(
                            'Reschedule',
                            style: tt.labelLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _showCancelSheet,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: cs.error,
                            side: BorderSide(color: cs.error),
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: tt.labelLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  final ColorScheme cs;

  const _ControlButton({
    required this.icon,
    required this.isActive,
    required this.onTap,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: isActive
                ? Colors.white
                : cs.errorContainer,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: isActive ? Colors.black87 : cs.onErrorContainer,
            size: 24,
          ),
        ),
      ),
    );
  }
}
