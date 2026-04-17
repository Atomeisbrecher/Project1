# Chat Module - Quick Start Guide

## 5-Minute Setup

### Step 1: Generate Freezed Models
```bash
cd your_project
flutter pub run build_runner build
```

### Step 2: Setup Dependency Injection

Choose your DI framework. Here's an example with **GetIt** (simplest option):

**In pubspec.yaml:**
```yaml
dependencies:
  get_it: ^7.0.0
```

**In your utils/injection_container.dart (create this file):**
```dart
import 'package:get_it/get_it.dart';
import 'package:shop/module%20chat/chat_module_init.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  // Setup chat module
  setupChatModule();
}

void setupChatModule() {
  // Services
  getIt.registerSingleton<ChatApiService>(ChatApiServiceRemote());
  getIt.registerSingleton<ChatCacheService>(ChatCacheServiceImpl());
  getIt.registerSingleton<WebSocketService>(WebSocketServiceImpl());
  
  // Repositories
  getIt.registerSingleton<ChatRepository>(
    ChatRepositoryImpl(
      chatApiService: getIt<ChatApiService>(),
      chatCacheService: getIt<ChatCacheService>(),
      webSocketService: getIt<WebSocketService>(),
    ),
  );
  
  getIt.registerSingleton<MessageRepository>(
    MessageRepositoryImpl(
      messageApiService: getIt<MessageApiService>(),
      webSocketService: getIt<WebSocketService>(),
    ),
  );
  
  // Use Cases
  getIt.registerSingleton<GetChatsUseCase>(
    GetChatsUseCase(chatRepository: getIt<ChatRepository>()),
  );
  // ... add other use cases
  
  // ViewModels
  getIt.registerSingleton<ChatListViewModel>(
    ChatListViewModel(
      getChatsUseCase: getIt<GetChatsUseCase>(),
      syncChatsUseCase: getIt<SyncChatsUseCase>(),
      searchChatsUseCase: getIt<SearchChatsUseCase>(),
    ),
  );
  
  getIt.registerSingleton<ChatDetailViewModel>(
    ChatDetailViewModel(
      getMessagesUseCase: getIt<GetMessagesUseCase>(),
      sendMessageUseCase: getIt<SendMessageUseCase>(),
      editMessageUseCase: getIt<EditMessageUseCase>(),
      deleteMessageUseCase: getIt<DeleteMessageUseCase>(),
      forwardMessageUseCase: getIt<ForwardMessageUseCase>(),
    ),
  );
}
```

### Step 3: Call Setup in main.dart
```dart
import 'package:shop/utils/injection_container.dart';

void main() async {
  setupDependencies();  // Add this line
  runApp(const MyApp());
}
```

### Step 4: Add Chat to Navigation

In your routing configuration:
```dart
GoRoute(
  path: '/chats',
  name: 'chats',
  builder: (context, state) => ChatListScreen(
    viewModel: getIt<ChatListViewModel>(),
  ),
  routes: [
    GoRoute(
      path: 'detail/:chatId',
      name: 'chat-detail',
      builder: (context, state) {
        final chatId = state.pathParameters['chatId']!;
        // Get the chat from your data source
        final chat = Chat(
          id: chatId,
          userId: 'user_id',
          username: 'Chat Name',
          avatar: 'https://...',
          lastMessage: 'Last message',
          lastMessageTime: DateTime.now(),
          unreadCount: 0,
          lastOnlineTime: DateTime.now(),
          lastMessageNumber: 100,
        );
        return ChatDetailScreen(
          chat: chat,
          viewModel: getIt<ChatDetailViewModel>(),
        );
      },
    ),
  ],
)
```

### Step 5: Update API Services

Edit `ChatApiServiceRemote` to actually call your API:

```dart
@override
Future<Result<List<Chat>>> fetchChats({
  int offset = 0,
  int limit = 20,
}) async {
  try {
    final response = await http.get(
      Uri.parse('$apiBaseUrl/chats?offset=$offset&limit=$limit'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final chats = (json['data'] as List)
          .map((chat) => Chat.fromJson(chat))
          .toList();
      return Ok(chats);
    }

    return Error(Exception('Failed to fetch chats: ${response.statusCode}'));
  } catch (e) {
    _log.severe('Error fetching chats', e);
    return Error(Exception('Error: $e'));
  }
}
```

Similarly for `MessageApiServiceRemote`.

### Step 6: Implement WebSocket (Optional for MVP)

You can leave WebSocket as stubs for MVP and implement later.

For now, messages will work via polling/sync endpoint.

To implement later in `WebSocketServiceImpl`:

```dart
@override
Future<void> connect() async {
  try {
    _webSocket = await WebSocket.connect(
      'wss://$apiHost/ws?token=$authToken',
    );

    _webSocket.listen(
      (message) {
        _handleMessage(jsonDecode(message));
      },
      onError: (error) => _log.severe('WebSocket error', error),
      onDone: () => _isConnected = false,
    );

    _isConnected = true;
  } catch (e) {
    _log.severe('WebSocket connection error', e);
    rethrow;
  }
}
```

## Testing Without Backend

For quick testing without a backend:

1. **Mock API Service:**
```dart
class ChatApiServiceMock implements ChatApiService {
  @override
  Future<Result<List<Chat>>> fetchChats({...}) async {
    await Future.delayed(Duration(seconds: 1));
    return Ok([
      Chat(
        id: '1',
        userId: 'user1',
        username: 'John Doe',
        avatar: 'https://via.placeholder.com/150',
        lastMessage: 'Hey, how are you?',
        lastMessageTime: DateTime.now().subtract(Duration(minutes: 5)),
        unreadCount: 2,
        lastOnlineTime: DateTime.now().subtract(Duration(hours: 1)),
        lastMessageNumber: 100,
      ),
      // ... more chats
    ]);
  }
  // ... implement other methods
}
```

2. **Use mock in DI setup:**
```dart
getIt.registerSingleton<ChatApiService>(ChatApiServiceMock());
```

## File Organization Checklist

✅ Domain layer created
✅ Data layer created
✅ UI layer created
✅ Models with freezed
✅ Repositories defined
✅ Use cases created
✅ ViewModels implemented
✅ Screens built
✅ Widgets created

## Next: Full Implementation Checklist

- [ ] Add all required imports to fix red squiggles
- [ ] Run `flutter pub run build_runner build`
- [ ] Setup GetIt injection container
- [ ] Add routes to your GoRouter
- [ ] Implement ChatApiServiceRemote HTTP calls
- [ ] Implement MessageApiServiceRemote HTTP calls
- [ ] Test with mock data
- [ ] Connect to real backend
- [ ] Implement WebSocket (optional for MVP)
- [ ] Add offline support with persistent cache
- [ ] Add image/media support
- [ ] Add typing indicators
- [ ] Add read receipts

## Common Issues & Solutions

### Issue: "Cannot find Chat" errors
**Solution:** Run `flutter pub run build_runner build`

### Issue: DI injection not working
**Solution:** Make sure `setupDependencies()` is called before `runApp()`

### Issue: Screens showing empty
**Solution:** Check that your backend API is returning correct JSON format

### Issue: Messages not appearing
**Solution:** Verify API response format matches Message model

### Issue: WebSocket not connecting
**Solution:** For MVP, leave WebSocket stubs and use polling via sync endpoint

## Documentation

- **IMPLEMENTATION_SUMMARY.md** - What was created and overview
- **README.md** - Detailed implementation guide
- **BACKEND_API_SPEC.md** - API endpoint specifications
- **Module code** - Well-commented with TODO markers

## Resources

- Auth module - Reference for patterns used
- Utils (command.dart, result.dart) - Reusable utilities
- Main app routing - Integration point

## Support

1. Check the documented TODO comments in service implementations
2. Refer to BACKEND_API_SPEC.md for endpoint details
3. Look at auth module for similar implementations
4. Check logs (via Logger) for debug information

Good luck! 🚀
