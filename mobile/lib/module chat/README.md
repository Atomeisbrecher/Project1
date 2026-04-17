# Chat Module

A fully featured Flutter chat module built with MVVM architecture, following the same patterns as the auth module.

## Architecture Overview

The chat module follows Clean Architecture principles with three main layers:

### 1. Domain Layer (`domain/`)
Contains the business logic and use cases:
- **Models**: `Chat` and `Message` (using freezed for immutability)
- **Repositories** (Abstract): `ChatRepository` and `MessageRepository`
- **Use Cases**: Each use case encapsulates a single business logic operation

### 2. Data Layer (`data/`)
Handles data retrieval and caching:
- **Services**:
  - `ChatApiService`: Abstract API service for chat operations
  - `ChatApiServiceRemote`: Remote implementation
  - `MessageApiService`: Abstract API service for messages
  - `MessageApiServiceRemote`: Remote implementation
  - `ChatCacheService`: Caching layer for offline support
  - `ChatCacheServiceImpl`: In-memory cache implementation
  - `WebSocketService`: Real-time updates via WebSocket
  - `WebSocketServiceImpl`: WebSocket implementation (stub)

- **Repositories** (Implementations):
  - `ChatRepositoryImpl`: Implements `ChatRepository`
  - `MessageRepositoryImpl`: Implements `MessageRepository`

### 3. UI Layer (`ui/`)
Presentation layer with Views and ViewModels:
- **ViewModels**:
  - `ChatListViewModel`: Manages chat list state and actions
  - `ChatDetailViewModel`: Manages chat detail state and actions

- **Screens**:
  - `ChatListScreen`: Displays list of chats with search
  - `ChatDetailScreen`: Displays messages and message input

- **Widgets**:
  - `ChatListItem`: Individual chat list item (dismissible)
  - `MessageItem`: Individual message with context menu
  - `MessageInputField`: Message input with send button

## Features

### Chat List Screen
- ✅ Display list of chats
- ✅ Search chats by name or message content
- ✅ Dismissible chats (swipe to archive/delete)
- ✅ Unread message count indicator
- ✅ Last message preview
- ✅ Last online time
- ✅ Sync chats from server

### Chat Detail Screen
- ✅ Display messages in chronological order
- ✅ Message status indicators (sending, sent, delivered, read)
- ✅ Timestamp for each message
- ✅ Message context menu with options:
  - Edit message
  - Delete message (with confirmation dialog)
  - Reply to message
  - Forward message
- ✅ Reply preview
- ✅ Message input field with send button

## Implementation Guide

### 1. Setup Freezed Models (if not already done)
The Chat and Message models use freezed for code generation. Run:
```bash
flutter pub run build_runner build
```

### 2. Setup Dependency Injection
Choose your DI framework (GetIt, Riverpod, Provider, etc.) and update `chat_module_init.dart`:

Example with GetIt:
```dart
import 'package:get_it/get_it.dart';

void setupChatModule() {
  final getIt = GetIt.instance;

  // Services
  getIt.registerSingleton<ChatApiService>(ChatApiServiceRemote(
    // Pass your HTTP client
  ));
  getIt.registerSingleton<ChatCacheService>(ChatCacheServiceImpl());
  getIt.registerSingleton<WebSocketService>(WebSocketServiceImpl());
  
  // ... rest of the setup
}
```

### 3. Implement Remote API Services
Update `ChatApiServiceRemote` and `MessageApiServiceRemote` with actual HTTP calls:

```dart
@override
Future<Result<List<Chat>>> fetchChats({int offset = 0, int limit = 20}) async {
  try {
    final response = await httpClient.get(
      Uri.parse('$baseUrl/api/chats?offset=$offset&limit=$limit'),
      headers: {'Authorization': 'Bearer $token'},
    );
    
    if (response.statusCode == 200) {
      final chats = (jsonDecode(response.body) as List)
          .map((json) => Chat.fromJson(json))
          .toList();
      return Ok(chats);
    }
    
    return Error(Exception('Failed to fetch chats'));
  } catch (e) {
    return Error(Exception('Error: $e'));
  }
}
```

### 4. Implement WebSocket Service
Update `WebSocketServiceImpl` to connect to your WebSocket server:

```dart
@override
Future<void> connect() async {
  _webSocket = await WebSocket.connect(
    'ws://$host:$port/ws?token=$authToken',
  );
  _isConnected = true;
  
  _webSocket.listen((message) {
    final data = jsonDecode(message);
    // Handle incoming messages
    _handleMessage(data);
  });
}

@override
Stream<dynamic> onNewMessage(String chatId) {
  return _messageStreamController.stream
      .where((msg) => msg['chatId'] == chatId);
}
```

### 5. Setup Cache Storage
For production, replace the in-memory cache with persistent storage:

```dart
// Example with Hive
class ChatCacheServiceHive implements ChatCacheService {
  final Box<Chat> chatBox;
  
  @override
  Future<void> cacheChats(List<dynamic> chats) async {
    await chatBox.clear();
    for (final chat in chats) {
      await chatBox.add(chat as Chat);
    }
  }
}
```

### 6. Integration with Navigation
Update your routing to include chat screens:

```dart
GoRoute(
  path: '/chats',
  builder: (context, state) => ChatListScreen(
    viewModel: getIt<ChatListViewModel>(),
  ),
  routes: [
    GoRoute(
      path: 'detail/:chatId',
      builder: (context, state) {
        final chatId = state.pathParameters['chatId']!;
        // Get the chat object
        return ChatDetailScreen(
          chat: chat,
          viewModel: getIt<ChatDetailViewModel>(),
        );
      },
    ),
  ],
)
```

## Message Synchronization

The module implements smart message synchronization:

1. **Initial Load**: Fetch messages from API endpoint
2. **Cache Tracking**: Last message number is cached locally
3. **Checking for Updates**: 
   - When entering a chat, check if cached message number differs from latest
   - If different, fetch new messages from the server
   - Show "X new messages" indicator like Telegram
4. **Real-time Updates**: WebSocket stream for live message updates (via Redis pub/sub)

```dart
// Example flow
final cachedNumber = repository.getLastMessageNumberFromCache(chatId);
final hasNew = await repository.hasNewMessages(chatId, cachedNumber!);

if (hasNew.value) {
  // Sync new messages
  final newMessages = await messageRepository.syncMessages(
    chatId,
    fromMessageNumber: cachedNumber,
  );
}
```

## Backend Requirements

Your backend API should provide these endpoints:

### Chat Endpoints
- `GET /api/chats` - List chats
- `POST /api/chats/:chatId/archive` - Archive chat
- `DELETE /api/chats/:chatId` - Delete chat
- `POST /api/chats/:chatId/restore` - Restore chat
- `GET /api/chats/:chatId/latest-message-number` - Get latest message number

### Message Endpoints
- `GET /api/chats/:chatId/messages` - Get messages (paginated)
- `GET /api/chats/:chatId/messages/sync?from=:number` - Sync from message number
- `POST /api/chats/:chatId/messages` - Send message
- `PUT /api/chats/:chatId/messages/:messageId` - Edit message
- `DELETE /api/chats/:chatId/messages/:messageId` - Delete message
- `POST /api/chats/:targetChatId/messages/forward` - Forward message

### WebSocket
- Connection: `ws://host:port/ws?token=auth_token`
- Channels (Redis pub/sub):
  - `chat:{chatId}:messages` - New messages
  - `chat:{chatId}:updates` - Message updates (delivery, read status)
  - `user:{userId}:chats` - Chat updates

## File Structure

```
module chat/
├── domain/
│   ├── chat/
│   │   ├── chat.dart
│   │   ├── chat.freezed.dart (generated)
│   │   ├── chat.g.dart (generated)
│   │   └── chat_repository.dart
│   ├── message/
│   │   ├── message.dart
│   │   ├── message.freezed.dart (generated)
│   │   ├── message.g.dart (generated)
│   │   ├── message_enum.dart
│   │   └── message_repository.dart
│   └── use_cases/
│       ├── get_chats.dart
│       ├── sync_chats.dart
│       ├── search_chats.dart
│       ├── get_messages.dart
│       ├── send_message.dart
│       ├── edit_message.dart
│       ├── delete_message.dart
│       └── forward_message.dart
├── data/
│   ├── services/
│   │   ├── chat_api_service.dart
│   │   ├── chat_api_service_remote.dart
│   │   ├── message_api_service.dart
│   │   ├── message_api_service_remote.dart
│   │   ├── chat_cache_service.dart
│   │   ├── chat_cache_service_impl.dart
│   │   ├── websocket_service.dart
│   │   └── websocket_service_impl.dart
│   └── repository/
│       ├── chat_repository_impl.dart
│       └── message_repository_impl.dart
├── ui/
│   ├── core/
│   │   └── widgets/
│   ├── pages/
│   │   ├── chat_list/
│   │   │   ├── chat_list_screen.dart
│   │   │   ├── view_models/
│   │   │   │   └── chat_list_viewmodel.dart
│   │   │   └── widgets/
│   │   │       └── chat_list_item.dart
│   │   └── chat_detail/
│   │       ├── chat_detail_screen.dart
│   │       ├── view_models/
│   │       │   └── chat_detail_viewmodel.dart
│   │       └── widgets/
│   │           ├── message_item.dart
│   │           └── message_input_field.dart
└── chat_module_init.dart
```

## TODO Items (Implementation Tasks)

1. **API Services**: 
   - [ ] Implement HTTP calls in `ChatApiServiceRemote`
   - [ ] Implement HTTP calls in `MessageApiServiceRemote`
   - [ ] Add proper error handling and response parsing

2. **WebSocket**:
   - [ ] Implement WebSocket connection in `WebSocketServiceImpl`
   - [ ] Set up Redis pub/sub channel listeners
   - [ ] Implement message parsing and streaming

3. **Persistent Cache**:
   - [ ] Replace in-memory cache with Hive or sqlite
   - [ ] Implement offline message queue

4. **UI Polish**:
   - [ ] Add animations for message sending
   - [ ] Implement message search within a chat
   - [ ] Add typing indicators
   - [ ] Add read receipts UI
   - [ ] Implement image/media message support
   - [ ] Add emoji picker

5. **Testing**:
   - [ ] Unit tests for ViewModels
   - [ ] Unit tests for Repositories
   - [ ] Widget tests for Screens
   - [ ] Integration tests

6. **Dependency Injection**:
   - [ ] Choose and setup DI framework (GetIt, Riverpod, etc.)
   - [ ] Update `chat_module_init.dart` with actual implementation

## Bottom Navigation Integration

Since all screens after authentication have bottom navigation, make sure to wrap the ChatListScreen in your main app shell that includes the bottom navigation bar. The screens handle their own AppBars and content.

## Dependencies

Ensure these are in your `pubspec.yaml`:
- `freezed_annotation`
- `intl` - For date/time formatting
- `flutter_screenutil` - For responsive design
- `flutter_gap` - For spacing
- `logging` - For logging (already in project)

## Notes

- All Result types use `Ok<T>` and `Error<T>` from the utils
- Command classes (Command0, Command1, Command2, Command3) handle async operations
- Use the same patterns as the auth module for consistency
- The WebSocket connection should be managed globally or in a service provider
- Implement proper token refresh logic for WebSocket auth
