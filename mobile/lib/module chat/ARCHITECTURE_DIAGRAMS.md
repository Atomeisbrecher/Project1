# Chat Module - Architecture Diagrams

## Data Flow Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                          UI LAYER                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ChatListScreen ◄──── ChatListViewModel                          │
│       │                      │                                    │
│       └──── loadChats() ─► Commands (Command0, Command1)        │
│       │      syncChats()     │                                    │
│       └──── searchChats()    │                                    │
│                              │                                    │
│                              ▼                                    │
│                     ┌──────────────────┐                         │
│                     │  Use Cases       │                         │
│                     ├──────────────────┤                         │
│                     │ GetChatsUseCase  │                         │
│                     │SyncChatsUseCase  │                         │
│                     │SearchChatsUseCase│                         │
│                     └────────┬─────────┘                         │
│                              │                                    │
│  ChatDetailScreen ◄─ ChatDetailViewModel                         │
│       │                      │                                    │
│       └──── sendMessage() ► Commands (Command0-3)               │
│       │      editMessage()   │                                    │
│       └──── deleteMessage()  │                                    │
│            forwardMessage()  │                                    │
│                              │                                    │
│                              ▼                                    │
│                     ┌──────────────────┐                         │
│                     │   Use Cases      │                         │
│                     ├──────────────────┤                         │
│                     │GetMessagesUseCase│                         │
│                     │SendMessageUseCase│                         │
│                     │EditMessageUseCase│                         │
│                     │DeleteMessageUseCase                        │
│                     │ForwardMessageUseCase                       │
│                     └────────┬─────────┘                         │
│                                                                   │
└────────────────────────────┬───────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                      DOMAIN LAYER                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │           Abstract Repositories                         │   │
│  ├─────────────────────────────────────────────────────────┤   │
│  │ ChatRepository          MessageRepository               │   │
│  │ - getChats()            - getMessages()                 │   │
│  │ - syncChats()           - sendMessage()                 │   │
│  │ - searchChats()         - editMessage()                 │   │
│  │ - archiveChat()         - deleteMessage()               │   │
│  │ - deleteChat()          - forwardMessage()              │   │
│  │ - hasNewMessages()      - watchMessages()               │   │
│  │ - watchChat()           - watchMessageUpdates()         │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                   │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              Models (Freezed)                           │   │
│  ├─────────────────────────────────────────────────────────┤   │
│  │ Chat              Message              MessageStatus    │   │
│  │ - id              - id                 - sending        │   │
│  │ - userId          - chatId             - sent           │   │
│  │ - username        - senderId           - delivered      │   │
│  │ - avatar          - text               - read           │   │
│  │ - lastMessage     - timestamp          - failed         │   │
│  │ - lastMessageTime - status                              │   │
│  │ - unreadCount     - messageNumber                       │   │
│  │ - lastOnlineTime  - replyToMessageId                    │   │
│  │ - lastMessageNum  - editedAt                            │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                   │
└────────────────────────────┬───────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                      DATA LAYER                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │      Concrete Repository Implementations                │  │
│  ├──────────────────────────────────────────────────────────┤  │
│  │  ChatRepositoryImpl                MessageRepositoryImpl   │  │
│  │  ├─ Uses ChatApiService           ├─ Uses MessageApiSvc  │  │
│  │  ├─ Uses ChatCacheService         ├─ Uses WebSocketSvc   │  │
│  │  └─ Uses WebSocketService         └─ Error handling      │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              Services (Implementations)                 │  │
│  ├──────────────────────────────────────────────────────────┤  │
│  │                                                          │  │
│  │  ChatApiServiceRemote       MessageApiServiceRemote      │  │
│  │  ├─ GET /api/chats          ├─ GET /messages            │  │
│  │  ├─ POST /archive           ├─ POST /messages           │  │
│  │  ├─ DELETE /chats           ├─ PUT /messages/:id        │  │
│  │  └─ POST /restore           ├─ DELETE /messages/:id     │  │
│  │                             └─ POST /forward            │  │
│  │                                                          │  │
│  │  ChatCacheServiceImpl        WebSocketServiceImpl         │  │
│  │  ├─ In-memory cache         ├─ WebSocket connect        │  │
│  │  ├─ Message number cache    ├─ Channel subscribe        │  │
│  │  └─ Sync from API           ├─ Stream handlers          │  │
│  │                             └─ Keep-alive ping          │  │
│  │                                                          │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                   │
└───────────┬────────────────────────────────────┬─────────────┬─┘
            │                                    │             │
            ▼                                    ▼             ▼
     ┌─────────────┐                   ┌────────────────┐  ┌─────────┐
     │  HTTP API   │                   │  Local Cache   │  │WebSocket│
     │             │                   │  (Memory/Hive) │  │ Server  │
     │ REST        │                   │  Persistent    │  │ Redis   │
     │ Endpoints   │                   │  Storage       │  │ Pub/Sub │
     └─────────────┘                   └────────────────┘  └─────────┘
```

## Message Synchronization Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                         USER FLOW                                │
└─────────────────────────────────────────────────────────────────┘

1. INITIAL LOAD
   ┌──────────────┐
   │ Open Chat    │
   │ Detail Screen│
   └──────┬───────┘
          │
          ▼
   ┌──────────────────────────────────────┐
   │ Load messages from cache/API          │
   │ Get lastMessageNumber from cache      │
   │ Example: cached = 150                 │
   └──────┬───────────────────────────────┘
          │
          ▼
   ┌──────────────────────────────────────┐
   │ Display cached messages 1-150         │
   └──────┬───────────────────────────────┘
          │
          │
2. CHECK FOR NEW MESSAGES
          │
          ▼
   ┌──────────────────────────────────────┐
   │ Call getLatestMessageNumber()         │
   │ Server responds: messageNumber = 156  │
   └──────┬───────────────────────────────┘
          │
          ▼
   ┌──────────────────────────────────────┐
   │ Compare: 156 vs cached 150            │
   │ 156 > 150 = True ✓                   │
   └──────┬───────────────────────────────┘
          │
          ▼
   ┌──────────────────────────────────────┐
   │ Display: "6 new messages"             │
   │ (Like Telegram)                       │
   └──────┬───────────────────────────────┘
          │
          │
3. SYNC NEW MESSAGES
          │
          ▼
   ┌──────────────────────────────────────┐
   │ Call syncMessages(from: 150)          │
   │ Server returns messages 151-156       │
   └──────┬───────────────────────────────┘
          │
          ▼
   ┌──────────────────────────────────────┐
   │ Add messages to list                  │
   │ Update cache: lastMessageNumber = 156 │
   │ Hide "new messages" indicator         │
   └──────┬───────────────────────────────┘
          │
          │
4. REAL-TIME UPDATES (WebSocket)
          │
          ▼
   ┌──────────────────────────────────────┐
   │ WebSocket connected                   │
   │ Subscribe to:                         │
   │ - chat:{chatId}:messages              │
   │ - chat:{chatId}:updates               │
   └──────┬───────────────────────────────┘
          │
          ├─────────────┬──────────────┐
          │             │              │
          ▼             ▼              ▼
   ┌─────────────┐ ┌──────────┐ ┌──────────────┐
   │ New Message │ │ Delivery │ │ Read Status  │
   │ msg 157     │ │ Status   │ │ Update msg   │
   │ From: John  │ │ Update   │ │ 155 -> read  │
   │ Automatic   │ │ message  │ │ Automatic    │
   │ append      │ │ checkmark│ │ UI update    │
   └─────────────┘ └──────────┘ └──────────────┘
```

## Message Context Menu Flow

```
┌─────────────────────────────────────────┐
│ User long-presses message               │
└─────────────────────┬───────────────────┘
                      │
                      ▼
            ┌─────────────────────┐
            │ Show Context Menu    │
            ├─────────────────────┤
            │ ✎ Edit              │
            │ ↩ Reply             │
            │ ⤴ Forward           │
            │ 🗑 Delete           │
            └──┬──┬──┬────────┬───┘
               │  │  │        │
        ╔──────┘  │  │        └──────╗
        │         │  │               │
        ▼         ▼  ▼               ▼
   ┌───────┐ ┌──────┐ ┌────────┐ ┌────────┐
   │ EDIT  │ │REPLY │ │FORWARD │ │ DELETE │
   └───┬───┘ └──┬───┘ └───┬────┘ └───┬────┘
       │        │         │          │
       ▼        ▼         ▼          ▼
   [Edit      [Reply    [Forward   [Confirm
    Dialog]   Preview]  Chat       Delete
               Select]  Dialog]    Dialog]
       │        │         │          │
       └───┬────┴─────┬───┴──────┬──┘
           │          │          │
           ▼          ▼          ▼
       [Send API Request]
       [Update Message List]
       [Show Success/Error]
```

## Component Dependency Graph

```
        ChatListViewModel
              │
        ┌─────┼─────┐
        │     │     │
        ▼     ▼     ▼
    GetChats  Sync Search
    UseCase   UseCase UseCase
        │     │     │
        └─────┴─────┘
              │
              ▼
       ChatRepository (interface)
              │
              ▼
       ChatRepositoryImpl
              │
        ┌─────┼─────┐
        │     │     │
        ▼     ▼     ▼
    ChatAPI  Cache  WebSocket
    Service  Service Service


      ChatDetailViewModel
            │
      ┌─────┼─────┬─────┬─────┐
      │     │     │     │     │
      ▼     ▼     ▼     ▼     ▼
    Send  Edit  Delete Forward Get
    Msg   Msg   Msg    Msg    Msg
    Use   Use   Use    Use    Use
    Case  Case  Case   Case   Case
      │     │     │     │     │
      └─────┴─────┴─────┴─────┘
            │
            ▼
    MessageRepository (interface)
            │
            ▼
    MessageRepositoryImpl
            │
      ┌─────┼─────┐
      │     │     │
      ▼     ▼     ▼
    Message WebSocket
    API     Service
    Service
```

## Offline & Real-time Strategy

```
┌─────────────────────────────────────────────────────────┐
│              MESSAGE STATE MACHINE                      │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  User composes                                          │
│  message locally                                        │
│      │                                                  │
│      ▼                                                  │
│  ┌─────────┐                                            │
│  │ SENDING │ ◄─── Status shown: clock icon              │
│  └────┬────┘                                            │
│       │                                                 │
│   API success                                           │
│       │                                                 │
│       ▼                                                 │
│  ┌─────────┐                                            │
│  │  SENT   │ ◄─── Status shown: single checkmark        │
│  └────┬────┘                                            │
│       │                                                 │
│  Server confirms                                        │
│  receipt                                                │
│       │                                                 │
│       ▼                                                 │
│  ┌───────────┐                                          │
│  │ DELIVERED │ ◄─── Status shown: double checkmark      │
│  └────┬──────┘                                          │
│       │                                                 │
│  Recipient reads                                        │
│  message                                                │
│       │                                                 │
│       ▼                                                 │
│  ┌─────────┐                                            │
│  │  READ   │ ◄─── Status shown: blue double checkmark   │
│  └─────────┘                                            │
│                                                         │
│  OR (if offline/error)                                  │
│      │                                                  │
│      ▼                                                  │
│  ┌─────────┐                                            │
│  │ FAILED  │ ◄─── Status shown: red exclamation         │
│  └────┬────┘      User can retry                        │
│       │                                                 │
│       └──► Cache message locally                        │
│           Retry on connection                           │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## Time Complexity & Performance

```
Operation                    Time      Space      Notes
─────────────────────────────────────────────────────
Load chat list (API)        O(n)      O(n)       n = number of chats
Load from cache             O(1)      O(n)       cached
Search chats                O(n)      O(m)       m = filtered results
Load messages (API)         O(n)      O(n)       n = messages
Sync messages (API)         O(k)      O(k)       k = new messages
Send message (API)          O(1)      O(1)       single write
Edit message (API)          O(1)      O(1)       single write
Delete message (API)        O(1)      O(1)       single write
WebSocket subscribe         O(1)      O(1)       per channel
Get message from cache      O(1)      O(1)       HashMap lookup
```

## State Management Flow

```
┌───────────────────────────────────────────┐
│     ChatListViewModel._loadChats()        │
└──────────────────┬──────────────────────┘
                   │
                   ▼
        ┌─────────────────────┐
        │ Command0.execute()  │
        │ - Set _running=true │
        │ - Clear _result     │
        │ - Notify listeners  │
        └──────────┬──────────┘
                   │
                   ▼
           ┌───────────────┐
           │ _loadChats()  │
           │ Returns       │
           │ Result<List>  │
           └───────┬───────┘
                   │
         ┌─────────┴─────────┐
         │                   │
         ▼                   ▼
    ┌────────┐          ┌───────┐
    │  Ok    │          │ Error │
    │ <List> │          │<void> │
    └────┬───┘          └───┬───┘
         │                  │
         ▼                  ▼
     setState()         Show error
     Update UI          to user
```

This comprehensive diagram set should help visualize how the chat module works!
