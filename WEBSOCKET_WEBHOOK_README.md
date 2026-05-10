# WebSocket & Webhook Services Documentation

## Overview

This document describes the robust WebSocket and Webhook services implemented for the HomeGuru platform. These services enable real-time bidirectional communication between clients (web and mobile) and the backend server.

## Architecture

```
┌─────────────────┐         WebSocket          ┌─────────────────┐
│                 │◄──────────────────────────►│                 │
│   Web Client    │                            │  Backend Server │
│   (Next.js)     │         Webhook            │   (Node.js)     │
│                 │◄───────────────────────────│                 │
└─────────────────┘                            └─────────────────┘
         ▲                                              ▲
         │                                              │
         │              WebSocket                       │
         │         ◄────────────────────►               │
         │                                              │
┌─────────────────┐                            ┌─────────────────┐
│                 │         Webhook            │                 │
│  Mobile Client  │◄───────────────────────────│  Backend Server │
│   (Flutter)     │                            │   (Node.js)     │
└─────────────────┘                            └─────────────────┘
```

## Features

### WebSocket Service

✅ **Auto-Reconnection**: Exponential backoff strategy with configurable max attempts
✅ **Heartbeat/Ping-Pong**: Keep-alive mechanism to detect connection issues
✅ **Message Queuing**: Queue messages when disconnected, send when reconnected
✅ **Event-Based Architecture**: Subscribe/unsubscribe to specific events
✅ **Connection State Management**: Track connection states (connecting, connected, disconnected, reconnecting, failed)
✅ **Type-Safe Events**: Predefined event types for common operations
✅ **Debug Logging**: Optional debug mode for development
✅ **Thread-Safe**: Handles concurrent operations safely

### Webhook Service

✅ **Signature Verification**: HMAC-SHA256 signature validation
✅ **Duplicate Detection**: Prevents processing same event multiple times
✅ **Event Handlers**: Register multiple handlers for same event
✅ **Async Processing**: Non-blocking webhook processing
✅ **Error Handling**: Graceful error handling with logging
✅ **Memory Management**: Automatic cleanup of old processed events

## Installation

### Web App (Next.js)

```bash
# No additional dependencies needed
# Services are already included in the project
```

### Flutter App

```bash
# Add to pubspec.yaml
dependencies:
  web_socket_channel: ^3.0.1
  crypto: ^3.0.3

# Install dependencies
flutter pub get
```

## Usage

### Web App

#### 1. Initialize Services (in app root)

```typescript
// app/layout.tsx or _app.tsx
import { initWebSocket } from '@/services/websocket.service';
import { initWebhook } from '@/services/webhook.service';

export default function RootLayout({ children }) {
  useEffect(() => {
    // Initialize WebSocket
    const ws = initWebSocket({
      url: process.env.NEXT_PUBLIC_WS_URL || 'ws://localhost:8080/ws',
      reconnectInterval: 3000,
      maxReconnectAttempts: 10,
      heartbeatInterval: 30000,
      debug: process.env.NODE_ENV === 'development',
    });

    // Initialize Webhook
    const webhook = initWebhook({
      secret: process.env.NEXT_PUBLIC_WEBHOOK_SECRET,
      debug: process.env.NODE_ENV === 'development',
    });

    // Connect when user is authenticated
    const userId = sessionStorage.getItem('hg_userId');
    const authToken = sessionStorage.getItem('hg_authToken');
    if (userId && authToken) {
      ws.connect(userId, authToken);
    }

    return () => {
      ws.disconnect();
    };
  }, []);

  return <html>{children}</html>;
}
```

#### 2. Use in Components

```typescript
import { useWebSocket, useWebSocketEvent } from '@/hooks/useWebSocket';
import { EventType } from '@/services/websocket.service';

function ChatComponent() {
  const { send, isConnected } = useWebSocket();

  // Subscribe to events
  useWebSocketEvent(EventType.MESSAGE_NEW, (data) => {
    console.log('New message:', data);
  });

  // Send message
  const sendMessage = (text: string) => {
    send(EventType.MESSAGE_NEW, { text, chatId: 'chat-123' });
  };

  return (
    <div>
      <p>Status: {isConnected ? 'Connected' : 'Disconnected'}</p>
      <button onClick={() => sendMessage('Hello!')}>Send</button>
    </div>
  );
}
```

### Flutter App

#### 1. Initialize Services (in main.dart)

```dart
import 'package:homeguru/services/websocket_service.dart';
import 'package:homeguru/services/webhook_service.dart';

void main() {
  // Initialize WebSocket
  initWebSocket(
    url: 'ws://localhost:8080/ws',
    reconnectInterval: 3000,
    maxReconnectAttempts: 10,
    heartbeatInterval: 30000,
    debug: true,
  );

  // Initialize Webhook
  initWebhook(
    secret: 'your-webhook-secret',
    debug: true,
  );

  runApp(const MyApp());
}
```

#### 2. Use in Widgets

```dart
class ChatScreen extends StatefulWidget {
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ws = getWebSocket();
  late final void Function() unsubscribe;

  @override
  void initState() {
    super.initState();
    
    // Subscribe to events
    unsubscribe = ws.on('message:new', (data) {
      print('New message: $data');
    });
  }

  @override
  void dispose() {
    unsubscribe();
    super.dispose();
  }

  void sendMessage(String text) {
    ws.send('message:new', {'text': text, 'chatId': 'chat-123'});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ElevatedButton(
        onPressed: () => sendMessage('Hello!'),
        child: Text('Send Message'),
      ),
    );
  }
}
```

## Event Types

### Connection Events
- `connect` - WebSocket connected
- `disconnect` - WebSocket disconnected
- `error` - Connection error occurred

### User Events
- `user:online` - User came online
- `user:offline` - User went offline
- `user:typing` - User is typing

### Chat Events
- `message:new` - New message received
- `message:delivered` - Message delivered
- `message:read` - Message read
- `message:deleted` - Message deleted

### Booking Events
- `booking:created` - New booking created
- `booking:updated` - Booking updated
- `booking:cancelled` - Booking cancelled
- `booking:confirmed` - Booking confirmed
- `booking:reminder` - Booking reminder

### Session Events
- `session:started` - Session started
- `session:ended` - Session ended
- `session:joined` - User joined session
- `session:left` - User left session

### Payment Events
- `payment:success` - Payment successful
- `payment:failed` - Payment failed
- `payment:refund` - Payment refunded

### Notification Events
- `notification:new` - New notification
- `notification:read` - Notification read

### System Events
- `system:maintenance` - System maintenance
- `system:announcement` - System announcement

## Configuration

### Environment Variables

```env
# Web App (.env.local)
NEXT_PUBLIC_WS_URL=ws://localhost:8080/ws
NEXT_PUBLIC_WEBHOOK_SECRET=your-webhook-secret

# Flutter App (config.dart)
const WS_URL = 'ws://localhost:8080/ws';
const WEBHOOK_SECRET = 'your-webhook-secret';
```

### WebSocket Configuration

```typescript
{
  url: string;                    // WebSocket server URL
  reconnectInterval: number;      // Base reconnect delay (ms)
  maxReconnectAttempts: number;   // Max reconnection attempts
  heartbeatInterval: number;      // Heartbeat interval (ms)
  debug: boolean;                 // Enable debug logging
}
```

### Webhook Configuration

```typescript
{
  secret: string;                 // Webhook secret for signature verification
  debug: boolean;                 // Enable debug logging
  validateSignature: boolean;     // Enable signature validation
}
```

## Best Practices

### 1. Connection Management
- Always disconnect WebSocket when user logs out
- Reconnect when user logs back in
- Handle connection state changes in UI

### 2. Event Handling
- Unsubscribe from events when component unmounts
- Use specific event types instead of wildcards
- Handle errors gracefully

### 3. Message Queuing
- Messages are automatically queued when disconnected
- Don't manually retry sending messages
- Trust the auto-reconnection mechanism

### 4. Security
- Always use WSS (WebSocket Secure) in production
- Validate webhook signatures
- Never expose webhook secrets in client code
- Use authentication tokens for WebSocket connections

### 5. Performance
- Batch multiple updates when possible
- Debounce frequent events (e.g., typing indicators)
- Clean up event listeners to prevent memory leaks

## Troubleshooting

### WebSocket won't connect
- Check if WebSocket URL is correct
- Verify authentication token is valid
- Check network connectivity
- Look for CORS issues in browser console

### Messages not being received
- Verify event name matches exactly
- Check if handler is registered before event fires
- Ensure WebSocket is connected
- Check debug logs

### Webhook signature validation fails
- Verify webhook secret matches backend
- Check timestamp is within acceptable range
- Ensure payload format is correct

## Backend Integration

### WebSocket Server (Node.js Example)

```javascript
const WebSocket = require('ws');
const wss = new WebSocket.Server({ port: 8080 });

wss.on('connection', (ws, req) => {
  const userId = new URL(req.url, 'http://localhost').searchParams.get('userId');
  const token = new URL(req.url, 'http://localhost').searchParams.get('token');
  
  // Authenticate user
  if (!authenticateUser(userId, token)) {
    ws.close(1008, 'Unauthorized');
    return;
  }

  // Handle messages
  ws.on('message', (data) => {
    const message = JSON.parse(data);
    
    // Handle ping
    if (message.event === 'ping') {
      ws.send(JSON.stringify({ event: 'pong', timestamp: Date.now() }));
      return;
    }

    // Process message
    handleMessage(userId, message);
  });

  // Send welcome message
  ws.send(JSON.stringify({
    event: 'connect',
    data: { userId, timestamp: Date.now() }
  }));
});
```

### Webhook Endpoint (Node.js Example)

```javascript
app.post('/webhook', (req, res) => {
  const payload = req.body;
  const signature = req.headers['x-webhook-signature'];
  
  // Verify signature
  const expectedSignature = generateSignature(payload, WEBHOOK_SECRET);
  if (signature !== expectedSignature) {
    return res.status(401).json({ error: 'Invalid signature' });
  }

  // Process webhook
  processWebhook(payload);
  
  res.json({ received: true });
});
```

## License

MIT License - See LICENSE file for details

## Support

For issues or questions, please contact the development team or create an issue in the repository.
