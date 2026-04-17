# Chat Module - Backend API Specification

This document outlines the API endpoints your backend should implement to support the Flutter chat module.

## Base URL
```
https://api.yoursite.com/api/v1
WebSocket: wss://api.yoursite.com/ws
```

## Authentication
All requests should include:
```
Authorization: Bearer {auth_token}
```

## Chat Endpoints

### 1. Get Chats List
**Endpoint:** `GET /chats`

**Query Parameters:**
- `offset`: (int, optional) Pagination offset, default: 0
- `limit`: (int, optional) Items per page, default: 20
- `archived`: (boolean, optional) Include archived chats, default: false

**Response (200 OK):**
```json
{
  "data": [
    {
      "id": "chat_uuid",
      "userId": "user_uuid",
      "username": "John Doe",
      "avatar": "https://...",
      "lastMessage": "Last message text",
      "lastMessageTime": "2024-04-15T10:30:00Z",
      "unreadCount": 3,
      "lastOnlineTime": "2024-04-15T09:45:00Z",
      "lastMessageNumber": 150
    }
  ],
  "total": 25,
  "offset": 0,
  "limit": 20
}
```

### 2. Get Latest Message Number
**Endpoint:** `GET /chats/{chatId}/latest-message-number`

**Response (200 OK):**
```json
{
  "messageNumber": 156,
  "timestamp": "2024-04-15T10:35:00Z"
}
```

### 3. Archive Chat
**Endpoint:** `POST /chats/{chatId}/archive`

**Request Body:**
```json
{}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Chat archived successfully"
}
```

### 4. Delete Chat
**Endpoint:** `DELETE /chats/{chatId}`

**Response (204 No Content or 200 OK):**
```json
{
  "success": true,
  "message": "Chat deleted successfully"
}
```

### 5. Restore Chat
**Endpoint:** `POST /chats/{chatId}/restore`

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Chat restored successfully"
}
```

## Message Endpoints

### 1. Get Messages
**Endpoint:** `GET /chats/{chatId}/messages`

**Query Parameters:**
- `offset`: (int, optional) Pagination offset, default: 0
- `limit`: (int, optional) Items per page, default: 50

**Response (200 OK):**
```json
{
  "data": [
    {
      "id": "message_uuid",
      "chatId": "chat_uuid",
      "senderId": "user_uuid",
      "text": "Message content",
      "timestamp": "2024-04-15T10:30:00Z",
      "status": "read",
      "messageNumber": 145,
      "replyToMessageId": null,
      "editedAt": null
    }
  ],
  "total": 256,
  "offset": 0,
  "limit": 50
}
```

### 2. Sync Messages
**Endpoint:** `GET /chats/{chatId}/messages/sync`

**Query Parameters:**
- `from`: (int, required) Sync messages from message number

**Description:** Returns all messages starting from the given message number. Used for catching up on new messages efficiently.

**Response (200 OK):**
```json
{
  "data": [
    {
      "id": "message_uuid",
      "chatId": "chat_uuid",
      "senderId": "user_uuid",
      "text": "New message",
      "timestamp": "2024-04-15T10:35:00Z",
      "status": "sent",
      "messageNumber": 151,
      "replyToMessageId": null,
      "editedAt": null
    }
  ],
  "total": 6,
  "from": 150,
  "to": 156
}
```

### 3. Send Message
**Endpoint:** `POST /chats/{chatId}/messages`

**Request Body:**
```json
{
  "text": "Message content",
  "replyToMessageId": null
}
```

**Response (201 Created):**
```json
{
  "id": "message_uuid",
  "chatId": "chat_uuid",
  "senderId": "current_user_id",
  "text": "Message content",
  "timestamp": "2024-04-15T10:40:00Z",
  "status": "sent",
  "messageNumber": 157,
  "replyToMessageId": null,
  "editedAt": null
}
```

### 4. Edit Message
**Endpoint:** `PUT /chats/{chatId}/messages/{messageId}`

**Request Body:**
```json
{
  "text": "Edited message content"
}
```

**Response (200 OK):**
```json
{
  "id": "message_uuid",
  "chatId": "chat_uuid",
  "senderId": "current_user_id",
  "text": "Edited message content",
  "timestamp": "2024-04-15T10:40:00Z",
  "status": "sent",
  "messageNumber": 157,
  "replyToMessageId": null,
  "editedAt": "2024-04-15T10:42:00Z"
}
```

### 5. Delete Message
**Endpoint:** `DELETE /chats/{chatId}/messages/{messageId}`

**Response (204 No Content or 200 OK):**
```json
{
  "success": true,
  "message": "Message deleted successfully"
}
```

### 6. Forward Message
**Endpoint:** `POST /chats/{targetChatId}/messages/forward`

**Request Body:**
```json
{
  "sourceChatId": "source_chat_uuid",
  "messageId": "message_uuid"
}
```

**Response (201 Created):**
```json
{
  "id": "new_message_uuid",
  "chatId": "target_chat_uuid",
  "senderId": "current_user_id",
  "text": "Forwarded: Original message text",
  "timestamp": "2024-04-15T10:45:00Z",
  "status": "sent",
  "messageNumber": 201,
  "replyToMessageId": null,
  "editedAt": null
}
```

### 7. Get Specific Message
**Endpoint:** `GET /chats/{chatId}/messages/{messageId}`

**Response (200 OK):**
```json
{
  "id": "message_uuid",
  "chatId": "chat_uuid",
  "senderId": "user_uuid",
  "text": "Message content",
  "timestamp": "2024-04-15T10:30:00Z",
  "status": "read",
  "messageNumber": 145,
  "replyToMessageId": null,
  "editedAt": null
}
```

## WebSocket Connection

### Connect to WebSocket
**URL:** `wss://api.yoursite.com/ws?token={auth_token}`

**Supported Commands:**
- Connection establishment: Automatic
- Keep-alive: Server sends ping every 30 seconds, client responds with pong

### Channels (Redis Pub/Sub)

#### New Messages Channel
**Channel:** `chat:{chatId}:messages`

**Message Format:**
```json
{
  "type": "new_message",
  "data": {
    "id": "message_uuid",
    "chatId": "chat_uuid",
    "senderId": "user_uuid",
    "text": "New message",
    "timestamp": "2024-04-15T10:50:00Z",
    "status": "delivered",
    "messageNumber": 158,
    "replyToMessageId": null,
    "editedAt": null
  }
}
```

#### Message Updates Channel
**Channel:** `chat:{chatId}:updates`

**Message Format (Delivery Status):**
```json
{
  "type": "message_delivered",
  "data": {
    "messageId": "message_uuid",
    "status": "delivered",
    "timestamp": "2024-04-15T10:50:15Z"
  }
}
```

**Message Format (Read Status):**
```json
{
  "type": "message_read",
  "data": {
    "messageId": "message_uuid",
    "status": "read",
    "timestamp": "2024-04-15T10:50:30Z"
  }
}
```

**Message Format (Message Edited):**
```json
{
  "type": "message_edited",
  "data": {
    "messageId": "message_uuid",
    "text": "Edited message content",
    "editedAt": "2024-04-15T10:52:00Z"
  }
}
```

**Message Format (Message Deleted):**
```json
{
  "type": "message_deleted",
  "data": {
    "messageId": "message_uuid"
  }
}
```

#### Chat Updates Channel
**Channel:** `user:{userId}:chats`

**Message Format:**
```json
{
  "type": "chat_updated",
  "data": {
    "id": "chat_uuid",
    "userId": "user_uuid",
    "username": "John Doe",
    "avatar": "https://...",
    "lastMessage": "Updated last message",
    "lastMessageTime": "2024-04-15T10:55:00Z",
    "unreadCount": 1,
    "lastOnlineTime": "2024-04-15T10:50:00Z",
    "lastMessageNumber": 158
  }
}
```

## Error Responses

### 400 Bad Request
```json
{
  "error": "bad_request",
  "message": "Invalid request parameters"
}
```

### 401 Unauthorized
```json
{
  "error": "unauthorized",
  "message": "Invalid or expired token"
}
```

### 403 Forbidden
```json
{
  "error": "forbidden",
  "message": "You don't have permission to access this resource"
}
```

### 404 Not Found
```json
{
  "error": "not_found",
  "message": "Resource not found"
}
```

### 500 Internal Server Error
```json
{
  "error": "internal_error",
  "message": "An error occurred on the server"
}
```

## Implementation Notes

### Message Synchronization Flow
1. App loads cached last message number (e.g., 150)
2. App requests `/chats/{chatId}/latest-message-number` and receives 156
3. If lastnumber != cached, app calls `/chats/{chatId}/messages/sync?from=150`
4. Server returns messages 151-156
5. App displays "6 new messages" indicator like Telegram
6. App updates cached message number to 156
7. WebSocket listens for new messages and real-time updates

### Real-time Updates
- Messages 151-156 are delivered via `/messages/sync`
- Messages 157+ are delivered via WebSocket `chat:{chatId}:messages` channel
- Status updates come via WebSocket `chat:{chatId}:updates` channel

### Offline Resilience
- Client caches messages locally
- Client tracks last message number
- On app resume, client syncs from cached number
- Misses are caught by sync endpoint
- WebSocket reconnects with exponential backoff

### Rate Limiting
Consider implementing rate limits:
- Message send: 5 messages per second per user
- API calls: 100 requests per minute per user
- WebSocket: Keep alive with 30-second pings

### Validation
Server should validate:
- Message text is not empty
- Message text length (max 5000 characters recommended)
- Message numbers are sequential
- User has permission to access chat
- User is not blocked by recipient

## Example WebSocket Connection (Pseudo-code)

```dart
// Connect
final webSocket = await WebSocket.connect(
  'wss://api.yoursite.com/ws?token=$authToken',
);

// Subscribe to channels
webSocket.add(jsonEncode({
  'action': 'subscribe',
  'channel': 'chat:$chatId:messages'
}));

// Listen to messages
webSocket.listen((message) {
  final data = jsonDecode(message);
  if (data['type'] == 'new_message') {
    // Handle new message
  }
});

// Keep alive - server sends ping, we respond with pong
webSocket.listen((message) {
  if (message == 'ping') {
    webSocket.add('pong');
  }
});
```

## Database Schema (Reference)

### Chats Table
```sql
CREATE TABLE chats (
  id UUID PRIMARY KEY,
  user_id_1 UUID NOT NULL,
  user_id_2 UUID NOT NULL,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL,
  archived_by JSONB, -- {"user_id": true}
  deleted_by JSONB,  -- {"user_id": true}
  last_message_id UUID,
  last_message_number INT,
  UNIQUE(user_id_1, user_id_2)
);
```

### Messages Table
```sql
CREATE TABLE messages (
  id UUID PRIMARY KEY,
  chat_id UUID NOT NULL REFERENCES chats(id),
  sender_id UUID NOT NULL,
  text TEXT NOT NULL,
  message_number INT NOT NULL, -- Sequential per chat
  reply_to_message_id UUID REFERENCES messages(id),
  created_at TIMESTAMP NOT NULL,
  edited_at TIMESTAMP,
  deleted_by JSONB, -- {"user_id": "deletion_time"}
  UNIQUE(chat_id, message_number)
);
```

### Message Status Table
```sql
CREATE TABLE message_status (
  id UUID PRIMARY KEY,
  message_id UUID NOT NULL REFERENCES messages(id),
  user_id UUID NOT NULL,
  status VARCHAR(20), -- sending, sent, delivered, read
  updated_at TIMESTAMP NOT NULL,
  UNIQUE(message_id, user_id)
);
```
