import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';
import 'dart:async';
import '../../../services/meeting_signaling_service.dart';

class ScientificCalculatorScreen extends StatefulWidget {
  final VoidCallback onClose;
  final MeetingSignalingService? signalingService;

  const ScientificCalculatorScreen({
    super.key,
    required this.onClose,
    this.signalingService,
  });

  @override
  State<ScientificCalculatorScreen> createState() => _ScientificCalculatorScreenState();
}

class _ScientificCalculatorScreenState extends State<ScientificCalculatorScreen> {
  late WebViewController _controller;
  bool _isLoaded = false;
  bool _isRemote = false;
  String _lastSentState = '';
  StreamSubscription? _signalingSubscription;

  @override
  void initState() {
    super.initState();
    _initWebView();
    _setupSignaling();
  }

  void _setupSignaling() {
    if (widget.signalingService == null) return;

    _signalingSubscription = widget.signalingService!.messages.listen((msg) {
      if (msg['action'] == 'calc-sync' && msg['calcType'] == 'scientific') {
        _handleRemoteUpdate(msg);
      } else if (msg['action'] == 'calc-request-sync' && msg['calcType'] == 'scientific') {
        _controller.runJavaScript('broadcastState()');
      }
    });

    // Request initial sync after 500ms
    Future.delayed(const Duration(milliseconds: 500), () {
      widget.signalingService?.send({'action': 'calc-request-sync', 'calcType': 'scientific'});
    });
  }

  void _handleRemoteUpdate(Map<String, dynamic> msg) {
    if (_isRemote) return;
    _isRemote = true;
    final state = jsonEncode(msg['state']);
    _lastSentState = state;
    _controller.runJavaScript('receiveState($state)');
    Future.delayed(const Duration(milliseconds: 300), () => _isRemote = false);
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..addJavaScriptChannel('CalcSync', onMessageReceived: (msg) {
        if (_isRemote || widget.signalingService == null) return;
        final state = msg.message;
        if (state == _lastSentState) return;
        _lastSentState = state;
        widget.signalingService!.send({'action': 'calc-sync', 'calcType': 'scientific', 'state': state});
      })
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) {
          setState(() => _isLoaded = true);
        },
      ))
      ..loadFlutterAsset('assets/desmos_scientific.html');
  }

  @override
  void dispose() {
    _signalingSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          if (_isLoaded)
            WebViewWidget(controller: _controller)
          else
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      color: cs.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Loading scientific calculator...',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          Positioned(
            top: 16,
            right: 16,
            child: SafeArea(
              child: Material(
                color: Colors.white.withValues(alpha: 0.8),
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: widget.onClose,
                  customBorder: const CircleBorder(),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(Icons.close, color: cs.onSurfaceVariant, size: 20),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
