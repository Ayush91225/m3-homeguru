# Generic WebSocket & Webhook Services

## 🎯 Overview

**Fully generic, flexible, and powerful** WebSocket and Webhook services for HomeGuru platform. Works with **ANY event structure** - no fixed event types, complete freedom to define your own events.

## ✨ Key Features

### 🔄 WebSocket Service
- ✅ **100% Generic** - Use ANY event names and data structures
- ✅ **Pattern Matching** - Subscribe to multiple events with regex patterns
- ✅ **Wildcard Support** - Listen to ALL events
- ✅ **Auto-Reconnection** - Exponential backoff with configurable attempts
- ✅ **Message Queuing** - Queue messages when offline, send when reconnected
- ✅ **Priority Messages** - Send urgent messages to front of queue
- ✅ **Heartbeat/Ping-Pong** - Automatic connection health monitoring
- ✅ **Connection States** - Track connecting, connected, disconnected, reconnecting, failed
- ✅ **Metadata Support** - Attach custom metadata to connections
- ✅ **Debug Mode** - Optional logging for development
- ✅ **Perfect Sync** - Web and Flutter implementations are identical

### 📨 Webhook Service
- ✅ **100% Generic** - Handle ANY webhook events
- ✅ **Pattern Matching** - Process webhooks matching patterns
- ✅ **Wildcard Support** - Handle ALL webhooks
- ✅ **Signature Verification** - HMAC-SHA256 validation
- ✅ **Duplicate Detection** - Prevent processing same event twice
- ✅ **Async Processing** - Non-blocking webhook handling
- ✅ **Memory Management** - Auto-cleanup of old events
- ✅ **Statistics** - Track handler count and processed events

## 🚀 Quick Start

### Web App (Next.js/React)

```typescript
// 1. Initialize (in app root)
import { initWebSocket, initWebhook } from '@/services/websocket.service';

const ws = initWebSocket({
  url: 'ws://localhost:8080/ws',
  debug: true,
});

const webhook = initWebhook({
  secret: 'your-secret',
  debug: true,
});

// 2. Connect
ws.connect('user-123', 'auth-token', {
  role: 'tutor',
  platform: 'web',
});

// 3. Use in components
import { useWebSocket, useWebSocketEvent } from '@/hooks/useWebSocket';

function MyComponent() {
  const { send, isConnected } = useWebSocket();

  // Listen to ANY event
  useWebSocketEvent('chat:message', (data) => {
    console.log('Message:', data);
  });

  // Send ANY event
  const sendMessage = () => {
    send('chat:message', { text: 'Hello!' });
  };

  return <button onClick={sendMessage}>Send</button>;
}
```

### Flutter App

```dart
// 1. Initialize (in main.dart)
import 'package:homeguru/services/websocket_service.dart';

void main() {
  initWebSocket(
    url: 'ws://localhost:8080/ws',
    debug: true,
  );
  
  initWebhook(
    secret: 'your-secret',
    debug: true,
  );
  
  runApp(MyApp());
}

// 2. Connect
final ws = getWebSocket();
ws.connect('user-123', 'auth-token', metadata: {
  'role': 'tutor',
  'platform': 'flutter',
});

// 3. Use in widgets
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  final ws = getWebSocket();
  late final void Function() unsubscribe;

  @override
  void initState() {
    super.initState();
    
    // Listen to ANY event
    unsubscribe = ws.on('chat:message', (data) {
      print('Message: $data');
    });
  }

  @override
  void dispose() {
    unsubscribe();
    super.dispose();
  }

  void sendMessage() {
    // Send ANY event
    ws.send('chat:message', {'text': 'Hello!'});
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: sendMessage,
      child: Text('Send'),
    );
  }
}
```

## 📚 Usage Patterns

### 1. Basic Events

```typescript
// Listen to specific event
ws.on('user:login', (data) => {
  console.log('User logged in:', data);
});

// Send event
ws.send('user:login', {
  userId: '123',
  timestamp: Date.now(),
});
```

### 2. Pattern Matching

```typescript
// Listen to ALL booking events
ws.onPattern(/^booking:/, (data) => {
  console.log('Booking event:', data);
});
// Matches: booking:created, booking:updated, booking:cancelled, etc.

// Listen to ALL payment events
ws.onPattern(/^payment:/, (data) => {
  console.log('Payment event:', data);
});
// Matches: payment:success, payment:failed, payment:refund, etc.
```

### 3. Wildcard (All Events)

```typescript
// Listen to EVERY event
ws.onAny((payload) => {
  console.log('Event:', payload.event, 'Data:', payload.data);
});
```

### 4. Priority Messages

```typescript
// Send urgent message (goes to front of queue if offline)
ws.send('alert:critical', {
  message: 'Emergency!',
  level: 'critical',
}, { priority: true });
```

### 5. Connection Metadata

```typescript
// Connect with custom metadata
ws.connect('user-123', 'token', {
  role: 'tutor',
  platform: 'web',
  version: '1.0.0',
  deviceId: 'device-456',
});

// Update metadata later
ws.updateMetadata({
  status: 'active',
  lastSeen: Date.now(),
});
```

### 6. Webhooks

```typescript
// Handle specific webhook
webhook.on('payment.captured', (payload) => {
  console.log('Payment:', payload.data);
});

// Pattern matching
webhook.onPattern(/^payment\./, (payload) => {
  console.log('Payment webhook:', payload.event);
});

// All webhooks
webhook.onAny((payload) => {
  console.log('Webhook:', payload.event);
});
```

## 🎨 Event Naming Conventions

You can use **ANY** naming convention, but we recommend:

### Recommended Format
```
namespace:resource:action
```

### Examples
```typescript
// User events
'user:profile:updated'
'user:login'
'user:logout'
'user:typing'

// Chat events
'chat:message:new'
'chat:message:read'
'chat:message:deleted'
'chat:typing:start'
'chat:typing:stop'

// Booking events
'booking:created'
'booking:confirmed'
'booking:cancelled'
'booking:reminder'

// Session events
'session:started'
'session:ended'
'session:joined'
'session:left'

// Payment events
'payment:initiated'
'payment:success'
'payment:failed'
'payment:refund'

// Notification events
'notification:new'
'notification:read'
'notification:dismissed'

// System events
'system:maintenance'
'system:announcement'
'system:error'

// Custom business events
'tutor:session:request'
'tutor:payment:received'
'tutor:rating:new'
'student:homework:submitted'
'admin:user:banned'
```

## 🔧 Configuration

### WebSocket Config

```typescript
{
  url: string;                    // WebSocket server URL
  reconnectInterval?: number;     // Base reconnect delay (default: 3000ms)
  maxReconnectAttempts?: number;  // Max attempts (default: 10)
  heartbeatInterval?: number;     // Heartbeat interval (default: 30000ms)
  debug?: boolean;                // Enable logging (default: false)
  autoReconnect?: boolean;        // Auto-reconnect (default: true)
}
```

### Webhook Config

```typescript
{
  secret?: string;                // Webhook secret for HMAC verification
  debug?: boolean;                // Enable logging (default: false)
  validateSignature?: boolean;    // Validate signatures (default: true)
  maxProcessedEvents?: number;    // Max cached events (default: 1000)
}
```

## 📊 API Reference

### WebSocket Methods

```typescript
// Connection
connect(userId: string, authToken: string, metadata?: object): void
disconnect(): void

// Messaging
send(event: string, data: any, options?: { priority?: boolean }): void

// Subscriptions
on(event: string, handler: Function): () => void
onPattern(pattern: string | RegExp, handler: Function): () => void
onAny(handler: Function): () => void
off(event: string, handler: Function): void

// State
getConnectionState(): ConnectionState
isConnected(): boolean
getQueuedMessageCount(): number
clearQueue(): void
updateMetadata(metadata: object): void

// Connection state changes
onConnectionStateChange(handler: Function): () => void
```

### Webhook Methods

```typescript
// Subscriptions
on(event: string, handler: Function): () => void
onPattern(pattern: string | RegExp, handler: Function): () => void
onAny(handler: Function): () => void
off(event: string, handler: Function): void

// Processing
process(payload: WebhookPayload): Promise<boolean>

// Management
clearHandlers(): void
clearProcessedEvents(): void
getStats(): { handlerCount: number; processedEventCount: number }
```

## 🎯 Use Cases

### Real-time Chat
```typescript
ws.on('chat:message', handleMessage);
ws.on('chat:typing', showTypingIndicator);
ws.send('chat:message', { text: 'Hello!' });
```

### Live Collaboration
```typescript
ws.on('doc:change', applyChange);
ws.on('doc:cursor', updateCursor);
ws.send('doc:change', { text, position });
```

### Gaming
```typescript
ws.on('game:move', updateGameState);
ws.on('game:score', updateScore);
ws.send('game:move', { x, y });
```

### IoT/Sensors
```typescript
ws.onPattern(/^device:sensor:/, handleSensorData);
ws.send('device:command', { action: 'turn_on' });
```

### Admin Monitoring
```typescript
ws.onPattern(/^system:/, logSystemEvent);
ws.onAny(logAllEvents); // Debug mode
```

## 🔒 Security

### WebSocket
- Always use WSS (WebSocket Secure) in production
- Validate authentication tokens on server
- Implement rate limiting
- Sanitize all data

### Webhook
- Enable signature verification
- Use strong secrets (min 32 characters)
- Validate payload structure
- Implement idempotency

## 🐛 Debugging

```typescript
// Enable debug mode
const ws = initWebSocket({
  url: 'ws://localhost:8080/ws',
  debug: true, // Logs all events
});

// Listen to all events for debugging
ws.onAny((payload) => {
  console.log('[DEBUG]', payload.event, payload.data);
});

// Monitor connection state
ws.onConnectionStateChange((state) => {
  console.log('[CONNECTION]', state);
});

// Track reconnection attempts
ws.on('reconnect:attempt', (data) => {
  console.log('[RECONNECT] Attempt', data.attempt);
});
```

## 📈 Performance Tips

1. **Use Pattern Matching** - Instead of multiple `on()` calls
2. **Unsubscribe** - Always clean up event listeners
3. **Batch Updates** - Send multiple changes in one message
4. **Debounce** - For frequent events (typing, cursor movement)
5. **Priority Queue** - Use priority for critical messages

## 🔄 Migration from Fixed Events

If you had fixed event types before:

```typescript
// Before (fixed events)
ws.on(EventType.MESSAGE_NEW, handler);

// After (generic)
ws.on('message:new', handler);
// Or use your own naming
ws.on('chat:message', handler);
```

## 🌐 Perfect Sync

Web and Flutter implementations are **100% identical**:

| Feature | Web | Flutter |
|---------|-----|---------|
| Generic Events | ✅ | ✅ |
| Pattern Matching | ✅ | ✅ |
| Wildcard | ✅ | ✅ |
| Priority Queue | ✅ | ✅ |
| Auto-Reconnect | ✅ | ✅ |
| Metadata | ✅ | ✅ |
| Heartbeat | ✅ | ✅ |
| Debug Mode | ✅ | ✅ |

## 📝 License

MIT License

## 🤝 Support

For issues or questions, contact the development team.
