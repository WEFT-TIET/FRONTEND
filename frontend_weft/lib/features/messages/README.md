# Messages Feature

This feature provides real-time messaging functionality using Socket.IO integration with the backend.

## Architecture

### Models
- **ChatMessage**: Core message model with UUID tracking, delivery status, and read receipts
- **MessageReceivedResponse**: Response model for message acknowledgments
- **MessageDeliveredResponse**: Response model for delivery confirmations
- **MessageReadResponse**: Response model for read receipts
- **ConversationSummary**: Model for conversation list items

### Services
- **SocketService**: Handles Socket.IO connection, authentication, and real-time events
  - Connects to backend socket server
  - Handles authentication with JWT tokens
  - Manages message sending, receiving, and status updates
  - Provides streams for different event types

### Repository
- **MessageRepository**: Data layer for message operations
  - Local caching with SharedPreferences
  - Socket service integration
  - Conversation management

### ViewModels
- **ChatMessagesNotifier**: Manages chat state for individual conversations
  - Message list management
  - Real-time message updates
  - Status tracking (sending, sent, delivered, read)
  - Pagination support

- **ConversationsNotifier**: Manages the list of conversations
  - Conversation summaries
  - Unread message counts
  - Last message tracking
  - Local caching

### Views
- **MessagesListPage**: Shows list of conversations with unread counts
- **ChatPage**: Individual chat interface with message bubbles and status indicators
- **SocketTestWidget**: Development tool for testing socket connections

## Backend Integration

The frontend integrates with the Go backend socket.go file through these events:

### Outgoing Events (Frontend → Backend)
- `auth`: Authenticate with JWT token
- `message`: Send a message (receiverID, messageUUID, content)
- `message_read`: Mark message as read (senderID, messageUUID)
- `fetch_messages`: Fetch message history (pageNumber)

### Incoming Events (Backend → Frontend)
- `auth_success`: Authentication successful
- `auth_error`: Authentication failed
- `message`: New message received
- `message_received`: Message acknowledgment
- `message_delivered`: Message delivery confirmation
- `message_read`: Message read confirmation
- `error`: General error
- `fetch_error`: Message fetch error

## Features

### Real-time Messaging
- Instant message delivery
- Message status indicators (sending, sent, delivered, read)
- Optimistic updates for better UX
- Connection status indicators

### Message Management
- Message persistence with local caching
- Conversation list with last message preview
- Unread message counts
- Message pagination
- Automatic retry on connection failure

### UI/UX
- Modern chat interface with message bubbles
- Timestamp display
- Online/offline status indicators
- Pull-to-refresh for conversations
- Error handling with user feedback

## Usage

### Basic Setup
```dart
// Import the messages feature
import 'package:frontend_weft/features/messages/messages.dart';

// Navigate to messages list
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const MessagesListPage()),
);

// Navigate to specific chat
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ChatPage(
      receiverId: userId,
      receiverName: 'User Name',
    ),
  ),
);
```

### Testing Socket Connection
```dart
// Use the socket test widget for debugging
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const SocketTestWidget()),
);
```

### Accessing Socket Service
```dart
// In a ConsumerWidget
final socket = ref.read(socketServiceProvider);
final isConnected = socket.isConnected;

// Listen to connection status
final connectionState = ref.watch(socketConnectionProvider);
```

## Configuration

### Socket Connection
The socket service connects to the backend using the base URL from `ServerConstants.baseUrl`. Make sure this is properly configured in your app.

### Authentication
The socket service automatically uses the JWT token from `AuthLocalRepository` for authentication. Ensure the user is logged in before using messaging features.

## Error Handling

The messaging system includes comprehensive error handling:
- Connection failures with automatic retry
- Authentication errors with user feedback
- Message sending failures with retry options
- Network connectivity issues

## Performance Considerations

- Messages are cached locally for offline access
- Conversations are persisted between app sessions
- Optimistic updates reduce perceived latency
- Pagination prevents loading too many messages at once
- Stream subscriptions are properly disposed to prevent memory leaks

## Development

### Adding New Message Types
1. Extend the `ChatMessage` model with new fields
2. Update the backend integration in `SocketService`
3. Add UI components for the new message type
4. Update the repository for persistence

### Testing
Use the `SocketTestWidget` to test socket connections and message flow during development.

### Debugging
Enable debug prints in the socket service to trace message flow and connection issues.