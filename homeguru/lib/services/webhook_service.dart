import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Webhook Service for HomeGuru Flutter App
/// Handles incoming webhook events from backend
/// Features: Event validation, signature verification, retry handling
/// FULLY GENERIC - Works with any event structure

class WebhookPayload {
  final String event;
  final dynamic data;
  final int timestamp;
  final String? signature;
  final String id;

  WebhookPayload({
    required this.event,
    required this.data,
    required this.timestamp,
    this.signature,
    required this.id,
  });

  factory WebhookPayload.fromJson(Map<String, dynamic> json) => WebhookPayload(
    event: json['event'] as String,
    data: json['data'],
    timestamp: json['timestamp'] as int,
    signature: json['signature'] as String?,
    id: json['id'] as String,
  );

  Map<String, dynamic> toJson() => {
    'event': event,
    'data': data,
    'timestamp': timestamp,
    if (signature != null) 'signature': signature,
    'id': id,
  };
}

class WebhookService {
  final String? secret;
  final bool debug;
  final bool validateSignature;
  final int maxProcessedEvents;

  final Map<String, Set<Function(WebhookPayload)>> _handlers = {};
  final Set<Function(WebhookPayload)> _wildcardHandlers = {};
  final Set<String> _processedEvents = {};

  WebhookService({
    this.secret,
    this.debug = false,
    this.validateSignature = true,
    this.maxProcessedEvents = 1000,
  });

  /// Register webhook handler for specific event
  void Function() on(String event, Function(WebhookPayload) handler) {
    _handlers.putIfAbsent(event, () => {});
    _handlers[event]!.add(handler);

    _log('Handler registered for event: $event');

    // Return unsubscribe function
    return () => off(event, handler);
  }

  /// Register webhook handler for all events (wildcard)
  void Function() onAny(Function(WebhookPayload) handler) {
    _wildcardHandlers.add(handler);
    _log('Wildcard handler registered');
    return () => _wildcardHandlers.remove(handler);
  }

  /// Register webhook handler for events matching pattern
  void Function() onPattern(Pattern pattern, Function(WebhookPayload) handler) {
    final wrappedHandler = (WebhookPayload payload) {
      if (pattern is String) {
        if (RegExp(pattern).hasMatch(payload.event)) {
          handler(payload);
        }
      } else if (pattern is RegExp) {
        if (pattern.hasMatch(payload.event)) {
          handler(payload);
        }
      }
    };
    return onAny(wrappedHandler);
  }

  /// Unregister webhook handler
  void off(String event, Function(WebhookPayload) handler) {
    _handlers[event]?.remove(handler);
    if (_handlers[event]?.isEmpty ?? false) {
      _handlers.remove(event);
    }
    _log('Handler unregistered for event: $event');
  }

  /// Process incoming webhook
  Future<bool> process(WebhookPayload payload) async {
    try {
      _log('Processing webhook: ${payload.event}');

      // Check for duplicate events
      if (_isDuplicate(payload.id)) {
        _log('Duplicate event detected, skipping: ${payload.id}');
        return true;
      }

      // Validate signature if enabled
      if (validateSignature && payload.signature != null) {
        if (!_validateSignature(payload)) {
          _log('Invalid signature, rejecting webhook');
          return false;
        }
      }

      // Mark as processed
      _markAsProcessed(payload.id);

      // Execute handlers
      await _executeHandlers(payload);

      _log('Webhook processed successfully: ${payload.id}');
      return true;
    } catch (e) {
      _log('Error processing webhook: $e');
      return false;
    }
  }

  /// Validate webhook signature
  bool _validateSignature(WebhookPayload payload) {
    if (secret == null || payload.signature == null) {
      return false;
    }

    try {
      // Create signature from payload
      final data = jsonEncode({
        'event': payload.event,
        'data': payload.data,
        'timestamp': payload.timestamp,
        'id': payload.id,
      });

      final expectedSignature = _generateSignature(data);
      return expectedSignature == payload.signature;
    } catch (e) {
      _log('Signature validation error: $e');
      return false;
    }
  }

  /// Generate signature for payload
  String _generateSignature(String data) {
    final key = utf8.encode(secret!);
    final bytes = utf8.encode(data);
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(bytes);
    return digest.toString();
  }

  /// Check if event is duplicate
  bool _isDuplicate(String eventId) {
    return _processedEvents.contains(eventId);
  }

  /// Mark event as processed
  void _markAsProcessed(String eventId) {
    _processedEvents.add(eventId);

    // Limit size of processed events set
    if (_processedEvents.length > maxProcessedEvents) {
      final firstEvent = _processedEvents.first;
      _processedEvents.remove(firstEvent);
    }
  }

  /// Execute all handlers for a webhook
  Future<void> _executeHandlers(WebhookPayload payload) async {
    final futures = <Future<void>>[];

    // Execute specific event handlers
    final handlers = _handlers[payload.event];
    if (handlers != null && handlers.isNotEmpty) {
      for (final handler in handlers) {
        futures.add(
          Future(() async {
            try {
              await handler(payload);
            } catch (e) {
              _log('Error in webhook handler for ${payload.event}: $e');
            }
          })
        );
      }
    }

    // Execute wildcard handlers
    for (final handler in _wildcardHandlers) {
      futures.add(
        Future(() async {
          try {
            await handler(payload);
          } catch (e) {
            _log('Error in wildcard webhook handler: $e');
          }
        })
      );
    }

    if (futures.isEmpty) {
      _log('No handlers registered for event: ${payload.event}');
    }

    await Future.wait(futures);
  }

  /// Clear all handlers
  void clearHandlers() {
    _handlers.clear();
    _wildcardHandlers.clear();
    _log('All webhook handlers cleared');
  }

  /// Clear processed events cache
  void clearProcessedEvents() {
    _processedEvents.clear();
    _log('Processed events cache cleared');
  }

  /// Get statistics
  Map<String, int> getStats() {
    int handlerCount = _wildcardHandlers.length;
    _handlers.forEach((_, handlers) {
      handlerCount += handlers.length;
    });
    return {
      'handlerCount': handlerCount,
      'processedEventCount': _processedEvents.length,
    };
  }

  void _log(String message) {
    if (debug) {
      print('[Webhook] $message');
    }
  }

  void dispose() {
    _handlers.clear();
    _wildcardHandlers.clear();
    _processedEvents.clear();
  }
}

// Singleton instance
WebhookService? _webhookInstance;

WebhookService initWebhook({
  String? secret,
  bool debug = false,
  bool validateSignature = true,
  int maxProcessedEvents = 1000,
}) {
  _webhookInstance ??= WebhookService(
    secret: secret,
    debug: debug,
    validateSignature: validateSignature,
    maxProcessedEvents: maxProcessedEvents,
  );
  return _webhookInstance!;
}

WebhookService getWebhook() {
  if (_webhookInstance == null) {
    throw Exception('Webhook service not initialized. Call initWebhook first.');
  }
  return _webhookInstance!;
}
