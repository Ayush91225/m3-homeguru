import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraPreviewWidget extends StatefulWidget {
  final CameraController? cameraController;
  final bool isCameraOn;
  final bool isMicOn;
  final VoidCallback onSwitchCamera;
  final VoidCallback onToggleMic;
  final bool isHandRaised;

  const CameraPreviewWidget({
    super.key,
    required this.cameraController,
    required this.isCameraOn,
    required this.isMicOn,
    required this.onSwitchCamera,
    required this.onToggleMic,
    this.isHandRaised = false,
  });

  @override
  State<CameraPreviewWidget> createState() => _CameraPreviewWidgetState();
}

class _CameraPreviewWidgetState extends State<CameraPreviewWidget> {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: 130,
      height: 200,
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          if (widget.isCameraOn && widget.cameraController != null && widget.cameraController!.value.isInitialized)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: widget.cameraController!.value.previewSize!.height,
                    height: widget.cameraController!.value.previewSize!.width,
                    child: CameraPreview(widget.cameraController!),
                  ),
                ),
              ),
            )
          else
            Center(
              child: Icon(
                Icons.videocam_off_rounded,
                color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                size: 40,
              ),
            ),
          if (widget.isHandRaised)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.front_hand_rounded,
                  color: cs.onPrimaryContainer,
                  size: 20,
                ),
              ),
            ),
          Positioned(
            bottom: 8,
            right: 8,
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: cs.surface.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: widget.onToggleMic,
                    icon: Icon(widget.isMicOn ? Icons.mic_rounded : Icons.mic_off_rounded),
                    iconSize: 18,
                    color: cs.onSurface,
                    padding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: cs.surface.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: widget.onSwitchCamera,
                    icon: const Icon(Icons.flip_camera_ios_rounded),
                    iconSize: 18,
                    color: cs.onSurface,
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
