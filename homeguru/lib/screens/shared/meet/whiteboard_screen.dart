import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../../services/meeting_signaling_service.dart';

class WhiteboardScreen extends StatefulWidget {
  final VoidCallback onClose;
  final MeetingSignalingService? signalingService;

  const WhiteboardScreen({
    super.key,
    required this.onClose,
    this.signalingService,
  });

  @override
  State<WhiteboardScreen> createState() => _WhiteboardScreenState();
}

class _WhiteboardScreenState extends State<WhiteboardScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  StreamSubscription? _signalingSubscription;
  bool _isRemoteUpdate = false;

  @override
  void initState() {
    super.initState();
    _initWebView();
    _setupSignaling();
  }

  void _setupSignaling() {
    if (widget.signalingService == null) return;

    _signalingSubscription = widget.signalingService!.messages.listen((msg) {
      if (msg['action'] == 'whiteboard-update') {
        _handleRemoteUpdate(msg);
      } else if (msg['action'] == 'whiteboard-request-sync') {
        _sendFullSync();
      }
    });

    // Request initial sync after 500ms
    Future.delayed(const Duration(milliseconds: 500), () {
      widget.signalingService?.requestWhiteboardSync();
    });
  }

  void _handleRemoteUpdate(Map<String, dynamic> msg) {
    if (_isRemoteUpdate) return;
    _isRemoteUpdate = true;

    final data = jsonEncode(msg);
    _controller.runJavaScript('window.updateWhiteboard($data);');

    Future.delayed(const Duration(milliseconds: 100), () {
      _isRemoteUpdate = false;
    });
  }

  void _sendFullSync() async {
    final result = await _controller.runJavaScriptReturningResult('window.getWhiteboardData();');
    if (result.toString() != 'null') {
      try {
        final data = jsonDecode(result.toString());
        widget.signalingService?.sendWhiteboardUpdate(
          data['elements'] ?? [],
          partial: false,
        );
      } catch (e) {
        debugPrint('❌ Sync error: $e');
      }
    }
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..addJavaScriptChannel(
        'FlutterBridge',
        onMessageReceived: (JavaScriptMessage message) {
          if (_isRemoteUpdate) return;
          try {
            final data = jsonDecode(message.message);
            if (data['action'] == 'whiteboard-update') {
              widget.signalingService?.sendWhiteboardUpdate(
                data['elements'] ?? [],
                partial: true,
              );
            } else if (data['action'] == 'pick-image') {
              _pickImage();
            } else if (data['action'] == 'save-image') {
              _saveImage(data['dataUrl']);
            }
          } catch (e) {
            debugPrint('❌ Bridge error: $e');
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
          },
        ),
      )
      ..loadFlutterAsset('assets/excalidraw.html');
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        final bytes = await image.readAsBytes();
        final base64 = base64Encode(bytes);
        final mimeType = image.mimeType ?? 'image/png';
        final dataUrl = 'data:$mimeType;base64,$base64';
        
        _controller.runJavaScript('window.insertImage("$dataUrl");');
      }
    } catch (e) {
      debugPrint('❌ Pick image error: $e');
    }
  }

  Future<void> _saveImage(String dataUrl) async {
    try {
      // Remove data URL prefix
      final base64Data = dataUrl.split(',').last;
      final bytes = base64Decode(base64Data);
      
      // Get directory
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${directory.path}/whiteboard_$timestamp.png';
      
      // Save file
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved to $filePath'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Save image error: $e');
    }
  }

  @override
  void dispose() {
    _signalingSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: widget.onClose,
          icon: const Icon(Icons.arrow_back),
        ),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFDCE8F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.brush, size: 16, color: Color(0xFF1E3162)),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Whiteboard',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Collaborative drawing',
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.outline,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          RepaintBoundary(
            child: WebViewWidget(controller: _controller),
          ),
          if (_isLoading)
            Container(
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCE8F5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.brush, size: 24, color: Color(0xFF1E3162)),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Loading whiteboard...',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.outline,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
