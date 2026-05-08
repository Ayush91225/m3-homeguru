import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../services/meeting_signaling_service.dart';

class GraphingCalculatorScreen extends StatefulWidget {
  final VoidCallback? onClose;
  final MeetingSignalingService? signalingService;

  const GraphingCalculatorScreen({
    super.key,
    this.onClose,
    this.signalingService,
  });

  @override
  State<GraphingCalculatorScreen> createState() => _GraphingCalculatorScreenState();
}

class _GraphingCalculatorScreenState extends State<GraphingCalculatorScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
    _listenToSignaling();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            setState(() => _isLoading = false);
          },
        ),
      )
      ..addJavaScriptChannel(
        'FlutterSync',
        onMessageReceived: (message) {
          widget.signalingService?.send({
            'action': 'calc-sync',
            'calcType': 'graphing',
            'state': message.message,
          });
        },
      )
      ..loadFlutterAsset('assets/desmos_graphing.html');
  }

  void _listenToSignaling() {
    widget.signalingService?.messages.listen((msg) {
      if (msg['action'] == 'calc-sync' && msg['calcType'] == 'graphing') {
        _controller.runJavaScript(
          'if (window.receiveState) window.receiveState(${msg['state']});',
        );
      } else if (msg['action'] == 'calc-request-sync') {
        _controller.runJavaScript('if (window.sendState) window.sendState();');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: cs.onSurface),
          onPressed: widget.onClose ?? () => Navigator.pop(context),
        ),
        title: Text(
          'Graphing Calculator',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: cs.surfaceContainerLow,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: cs.primary),
                    const SizedBox(height: 16),
                    Text(
                      'Loading graphing calculator...',
                      style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant, fontWeight: FontWeight.w500),
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
