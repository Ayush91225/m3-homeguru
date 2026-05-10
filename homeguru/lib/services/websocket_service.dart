import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

/// WebSocket Service for HomeGuru Flutter App
/// Handles real-time bidirectional communication with backend
/// Features: Auto-reconnection, event handling, heartbeat, message queuing
/// FULLY GENERIC - Works with any event structure

enum ConnectionState {
  connecting,
  connected,
  disconnected,
  reconnecting,
  failed,
}

class WebSocketMessage {
  final String event;
  final dynamic data;
  final int timestamp;
  final String? id;

  WebSocketMessage({
    required this.event,
    required this.data,
    required this.timestamp,
    this.id,
  });

  Map<String, dynamic> toJson() => {
    'event': event,
    'data': data,
    'timestamp': timestamp,
    if (id != null) 'id': id,
  };

  factory WebSocketMessage.fromJson(Map<String, dynamic> json) => WebSocketMessage(
    event: json['event'] as String,
    data: json['data'],
    timestamp: json['timestamp'] as int,
    id: json['id'] as String?,
  );
}

class WebSocketService {
  final String url;
  final int reconnectInterval;
  final int maxReconnectAttempts;
  final int heartbeatInterval;
  final bool debug;
  final bool autoReconnect;

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;
  
  ConnectionState _connectionState = ConnectionState.disconnected;
  int _reconnectAttempts = 0;
  String? _userId;
  String? _authToken;
  Map<String, dynamic> _metadata = {};
  
  final List<WebSocketMessage> _messageQueue = [];
  final Map<String, Set<Function(dynamic)>> _eventHandlers = {};
  final Set<Function(Map<String, dynamic>)> _wildcardHandlers = {};
  final Set<Function(ConnectionState)> _connectionStateHandlers = {};

  WebSocketService({
    required this.url,
    this.reconnectInterval = 3000,
    this.maxReconnectAttempts = 10,
    this.heartbeatInterval = 30000,
    this.debug = false,
    this.autoReconnect = true,
  });

  /// Initialize WebSocket connection
  void connect(String userId, String authToken, {Map<String, dynamic>? metadata}) {
    if (_channel != null && _connectionState == ConnectionState.connected) {
      _log('WebSocket already connected');
      return;
    }

    _userId = userId;
    _authToken = authToken;
    _metadata = metadata ?? {};
    _setConnectionState(ConnectionState.connecting);

    try {
      final params = {
        'userId': userId,
        'token': authToken,
        ..._metadata,
      };
      final queryString = params.entries.map((e) => '${e.key}=${e.value}').join('&');
      final wsUrl = '$url?$queryString';
      
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      
      _subscription = _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleClose,
        cancelOnError: false,
      );

      _handleOpen();
    } catch (e) {
      _log('Connection error: $e');
      if (autoReconnect) {
        _handleReconnect();
      }
    }
  }

  /// Disconnect WebSocket
  void disconnect() {
    _log('Disconnecting WebSocket');
    _clearTimers();
    
    _subscription?.cancel();
    _channel?.sink.close(status.normalClosure);
    _channel = null;
    
    _setConnectionState(ConnectionState.disconnected);
    _reconnectAttempts = 0;
  }

  /// Send message through WebSocket
  void send(String event, dynamic data, {bool priority = false}) {
    final message = WebSocketMessage(
      event: event,
      data: data,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      id: _generateMessageId(),
    );

    if (_channel != null && _connectionState == ConnectionState.connected) {
      _channel!.sink.add(jsonEncode(message.toJson()));
      _log('Message sent: ${message.event}');
    } else {
      _log('WebSocket not connected, queuing message');
      if (priority) {
        _messageQueue.insert(0, message);
      } else {
        _messageQueue.add(message);
      }
    }
  }

  /// Subscribe to specific event
  void Function() on(String event, Function(dynamic) handler) {
    _eventHandlers.putIfAbsent(event, () => {});
    _eventHandlers[event]!.add(handler);

    // Return unsubscribe function
    return () => off(event, handler);
  }

  /// Subscribe to all events (wildcard)
  void Function() onAny(Function(Map<String, dynamic>) handler) {
    _wildcardHandlers.add(handler);
    return () => _wildcardHandlers.remove(handler);
  }

  /// Subscribe to events matching pattern
  void Function() onPattern(Pattern pattern, Function(dynamic) handler) {
    final wrappedHandler = (Map<String, dynamic> payload) {
      final event = payload['event'] as String;
      if (pattern is String) {
        if (RegExp(pattern).hasMatch(event)) {
          handler(payload['data']);
        }
      } else if (pattern is RegExp) {
        if (pattern.hasMatch(event)) {
          handler(payload['data']);
        }
      }
    };
    return onAny(wrappedHandler);
  }

  /// Unsubscribe from event
  void off(String event, Function(dynamic) handler) {
    _eventHandlers[event]?.remove(handler);
    if (_eventHandlers[event]?.isEmpty ?? false) {
      _eventHandlers.remove(event);
    }
  }

  /// Subscribe to connection state changes
  void Function() onConnectionStateChange(Function(ConnectionState) handler) {
    _connectionStateHandlers.add(handler);
    return () => _connectionStateHandlers.remove(handler);
  }

  /// Get current connection state
  ConnectionState get connectionState => _connectionState;

  /// Check if connected
  bool get isConnected => _connectionState == ConnectionState.connected;

  /// Get queued message count
  int get queuedMessageCount => _messageQueue.length;

  /// Clear message queue
  void clearQueue() {
    _messageQueue.clear();
  }

  /// Update metadata
  void updateMetadata(Map<String, dynamic> metadata) {
    _metadata = {..._metadata, ...metadata};
  }

  // Private methods

  void _handleOpen() {
    _log('WebSocket connected');
    _setConnectionState(ConnectionState.connected);
    _reconnectAttempts = 0;
    _startHeartbeat();
    _flushMessageQueue();
    _emit('connect', {'userId': _userId, 'metadata': _metadata});
  }

  void _handleMessage(dynamic message) {
    try {
      final json = jsonDecode(message as String) as Map<String, dynamic>;
      final wsMessage = WebSocketMessage.fromJson(json);
      _log('Message received: ${wsMessage.event}');

      // Handle heartbeat response
      if (wsMessage.event == 'pong') {
        return;
      }

      _emit(wsMessage.event, wsMessage.data);
    } catch (e) {
      _log('Error parsing message: $e');
    }
  }

  void _handleError(dynamic error) {
    _log('WebSocket error: $error');
    _emit('error', {'error': error.toString()});
  }

  void _handleClose() {
    _log('WebSocket closed');
    _clearTimers();
    _setConnectionState(ConnectionState.disconnected);
    _emit('disconnect', {});

    // Attempt reconnection if auto-reconnect is enabled
    if (autoReconnect) {
      _handleReconnect();
    }
  }

  void _handleReconnect() {
    if (_reconnectAttempts >= maxReconnectAttempts) {
      _log('Max reconnection attempts reached');
      _setConnectionState(ConnectionState.failed);
      _emit('reconnect:failed', {'attempts': _reconnectAttempts});
      return;
    }

    _reconnectAttempts++;
    _setConnectionState(ConnectionState.reconnecting);
    
    final delay = (reconnectInterval * (1 << (_reconnectAttempts - 1))).clamp(0, 30000);

    _log('Reconnecting in ${delay}ms (attempt $_reconnectAttempts)');
    _emit('reconnect:attempt', {'attempt': _reconnectAttempts, 'delay': delay});

    _reconnectTimer = Timer(Duration(milliseconds: delay), () {
      if (_userId != null && _authToken != null) {
        connect(_userId!, _authToken!, metadata: _metadata);
      }
    });
  }

  void _startHeartbeat() {
    _heartbeatTimer = Timer.periodic(Duration(milliseconds: heartbeatInterval), (_) {
      if (_channel != null && _connectionState == ConnectionState.connected) {
        _channel!.sink.add(jsonEncode({'event': 'ping', 'timestamp': DateTime.now().millisecondsSinceEpoch}));
      }
    });
  }

  void _clearTimers() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  void _flushMessageQueue() {
    while (_messageQueue.isNotEmpty) {
      final message = _messageQueue.removeAt(0);
      send(message.event, message.data);
    }
  }

  void _emit(String event, dynamic data) {
    // Emit to specific event handlers
    final handlers = _eventHandlers[event];
    if (handlers != null) {
      for (final handler in handlers) {
        try {
          handler(data);
        } catch (e) {
          _log('Error in event handler: $e');
        }
      }
    }

    // Emit to wildcard handlers
    for (final handler in _wildcardHandlers) {
      try {
        handler({'event': event, 'data': data});
      } catch (e) {
        _log('Error in wildcard handler: $e');
      }
    }
  }

  void _setConnectionState(ConnectionState state) {
    if (_connectionState != state) {
      _connectionState = state;
      for (final handler in _connectionStateHandlers) {
        try {
          handler(state);
        } catch (e) {
          _log('Error in connection state handler: $e');
        }
      }
    }
  }

  String _generateMessageId() {
    return '${DateTime.now().millisecondsSinceEpoch}-${_randomString(9)}';
  }

  String _randomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(length, (index) => chars[(DateTime.now().microsecond + index) % chars.length]).join();
  }

  void _log(String message) {
    if (debug) {
      print('[WebSocket] $message');
    }
  }

  void dispose() {
    disconnect();
    _eventHandlers.clear();
    _wildcardHandlers.clear();
    _connectionStateHandlers.clear();
    _messageQueue.clear();
  }
}

// Singleton instance
WebSocketService? _wsInstance;

WebSocketService initWebSocket({
  required String url,
  int reconnectInterval = 3000,
  int maxReconnectAttempts = 10,
  int heartbeatInterval = 30000,
  bool debug = false,
  bool autoReconnect = true,
}) {
  _wsInstance ??= WebSocketService(
    url: url,
    reconnectInterval: reconnectInterval,
    maxReconnectAttempts: maxReconnectAttempts,
    heartbeatInterval: heartbeatInterval,
    debug: debug,
    autoReconnect: autoReconnect,
  );
  return _wsInstance!;
}

WebSocketService getWebSocket() {
  if (_wsInstance == null) {
    throw Exception('WebSocket not initialized. Call initWebSocket first.');
  }
  return _wsInstance!;
}
