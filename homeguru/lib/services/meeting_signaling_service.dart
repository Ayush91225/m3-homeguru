import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class MeetingSignalingService {
  WebSocketChannel? _channel;
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  Timer? _reconnectTimer;
  int _reconnectCount = 0;
  bool _isConnected = false;
  String? _myConnectionId;

  final String wsUrl;
  final String roomId;
  final String userName;
  final bool isHost;

  MeetingSignalingService({
    required this.wsUrl,
    required this.roomId,
    required this.userName,
    required this.isHost,
  });

  Stream<Map<String, dynamic>> get messages => _messageController.stream;
  bool get isConnected => _isConnected;
  String? get myConnectionId => _myConnectionId;

  Future<void> connect() async {
    try {
      final uri = Uri.parse('$wsUrl?roomId=${Uri.encodeComponent(roomId)}&name=${Uri.encodeComponent(userName)}&isHost=$isHost');
      _channel = WebSocketChannel.connect(uri);

      _channel!.stream.listen(
        (data) {
          try {
            final msg = jsonDecode(data as String) as Map<String, dynamic>;
            _handleMessage(msg);
          } catch (e) {
            debugPrint('❌ Message parse error: $e');
          }
        },
        onDone: _handleDisconnect,
        onError: (e) {
          debugPrint('❌ WebSocket error: $e');
          _handleDisconnect();
        },
      );

      _isConnected = true;
      _reconnectCount = 0;
      send({'action': 'join-room'});
      debugPrint('✅ Connected to signaling server');
    } catch (e) {
      debugPrint('❌ Connection error: $e');
      _handleDisconnect();
    }
  }

  void _handleMessage(Map<String, dynamic> msg) {
    if (msg['action'] == 'room-peers' && msg['myConnectionId'] != null) {
      _myConnectionId = msg['myConnectionId'] as String;
      debugPrint('✅ My connection ID: $_myConnectionId');
    }
    _messageController.add(msg);
  }

  void _handleDisconnect() {
    _isConnected = false;
    _channel = null;

    final delay = Duration(milliseconds: (1000 * (1 << _reconnectCount)).clamp(1000, 15000));
    _reconnectCount++;

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, () {
      debugPrint('🔄 Reconnecting... (attempt $_reconnectCount)');
      connect();
    });
  }

  void send(Map<String, dynamic> message) {
    if (_channel != null && _isConnected) {
      try {
        _channel!.sink.add(jsonEncode(message));
      } catch (e) {
        debugPrint('❌ Send error: $e');
      }
    }
  }

  // Convenience methods
  void sendStateUpdate(Map<String, dynamic> state) {
    send({'action': 'state-update', ...state});
  }

  void sendChatMessage(String text) {
    send({'action': 'chat-message', 'text': text});
  }

  void sendReaction(String emoji) {
    send({'action': 'reaction', 'emoji': emoji});
  }

  void sendWhiteboardUpdate(List<dynamic> elements, {bool partial = true}) {
    send({
      'action': 'whiteboard-update',
      'elements': elements,
      'partial': partial,
    });
  }

  void requestWhiteboardSync() {
    send({'action': 'whiteboard-request-sync'});
  }

  void dispose() {
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _messageController.close();
  }
}
