// import 'dart:async';
// import 'dart:ffi';

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_gap/flutter_gap.dart';
// import 'package:go_router/go_router.dart';
// import 'package:shop/module_auth/ui/pages/logout/view_models/logout_viewmodel.dart';
// import 'package:shop/module_auth/ui/pages/logout/widgets/logout_button.dart';
// import 'package:shop/module_chat/domain/chat/chat.dart';
// import 'package:shop/module_chat/ui/pages/chat_list/view_models/chat_list_viewmodel.dart';
// import 'package:shop/module_chat/ui/pages/chat_list/widgets/chat_list_item.dart';
// import 'package:shop/routing/routes.dart';
// import 'package:shop/utils/result.dart';

// class ChatListScreen extends StatefulWidget {
//   const ChatListScreen({
//     super.key,
//     required this.viewModel,
//     required this.logOutViewModel,
//   });

//   final ChatListViewModel viewModel;
//   final LogoutViewModel logOutViewModel;

//   @override
//   State<ChatListScreen> createState() => _ChatListScreenState();
// }

// class _ChatListScreenState extends State<ChatListScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   List<Chat> _chats = [];
//   List<Chat> _allChats = []; // Store all chats for searching
//   bool _isSearching = false;
//   int _selectedIndex = 1;
//   Timer? _debounce;
//   @override
//   void initState() {
//     super.initState();
//     _loadChats();
//     _searchController.addListener(_onSearchChanged);
//     //_initializeFakeChats(); // Add fake chats for testing
//   }

//   void _initializeFakeChats() {
//     // Temporarily add fake chats for testing functionality
//     final fakeChats = [
//       Chat(
//         id: '1',
//         userId: '1',
//         username: 'John Doe',
//         avatar: 'https://picsum.photos/id/1/100/100',
//         lastMessage: 'Hey, how are you?',
//         lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
//         unreadCount: 2,
//         lastOnlineTime: DateTime.now().subtract(const Duration(minutes: 10)),
//         lastMessageNumber: 42,
//       ),
//       Chat(
//         id: '2',
//         userId: '2',
//         username: 'Sarah Smith',
//         avatar: 'https://picsum.photos/id/2/100/100',
//         lastMessage: 'See you tomorrow!',
//         lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
//         unreadCount: 0,
//         lastOnlineTime: DateTime.now().subtract(const Duration(hours: 3)),
//         lastMessageNumber: 89,
//       ),
//       Chat(
//         id: '3',
//         userId: '3',
//         username: 'Mike Johnson',
//         avatar: 'https://picsum.photos/id/3/100/100',
//         lastMessage: 'Thanks for the help!',
//         lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
//         unreadCount: 5,
//         lastOnlineTime: DateTime.now().subtract(const Duration(days: 1)),
//         lastMessageNumber: 156,
//       ),
//       Chat(
//         id: '4',
//         userId: '4',
//         username: 'Emily Brown',
//         avatar: 'https://picsum.photos/id/4/100/100',
//         lastMessage: 'That sounds great!',
//         lastMessageTime: DateTime.now().subtract(const Duration(days: 2)),
//         unreadCount: 1,
//         lastOnlineTime: DateTime.now().subtract(const Duration(days: 3)),
//         lastMessageNumber: 203,
//       ),
//       Chat(
//         id: '5',
//         userId: '5',
//         username: 'Alex Wilson',
//         avatar: 'https://picsum.photos/id/5/100/100',
//         lastMessage: 'Let me know when you\'re free',
//         lastMessageTime: DateTime.now().subtract(const Duration(days: 3)),
//         unreadCount: 0,
//         lastOnlineTime: DateTime.now().subtract(const Duration(days: 5)),
//         lastMessageNumber: 78,
//       ),
//     ];
    
//     setState(() {
//       _allChats = fakeChats;
//       _chats = fakeChats;
//     });
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     _debounce?.cancel();
//     super.dispose();
//   }

//   void _loadChats() {
//     // widget.viewModel.loadChats.execute();
//     // widget.viewModel.loadChats.addListener(_onChatsLoaded);
//     //_initializeFakeChats();
//   }

//   void _onChatsLoaded() {
//     // final result = widget.viewModel.loadChats.result;
//     // if (result != null && result is Ok) {
//     //   setState(() {
//     //     _chats = result.value;
//     //   });
//     // }
//   }

//   void _onSearchChanged() {
//     // if (_searchController.text.isEmpty) {
//     //   setState(() {
//     //     _isSearching = false;
//     //   });
//     //   _loadChats();
//     // } else {
//     //   setState(() {
//     //     _isSearching = true;
//     //   });
//     //   widget.viewModel.searchChats.execute(_searchController.text);
//     //   widget.viewModel.searchChats.addListener(_onSearchResult);
//     //   _onSearchResult();
//     // }
//     if (_debounce?.isActive ?? false) _debounce!.cancel();

//     _debounce = Timer(const Duration(milliseconds: 500), () async {
//       final query = _searchController.text;
//       await widget.viewModel.onSearch(query);
//     });
//   }

//   void _performLocalSearch(String query) {
//     final lowercaseQuery = query.toLowerCase();
//     final filteredChats = _allChats.where((chat) {
//       return chat.username!.toLowerCase().contains(lowercaseQuery) ||
//           chat.lastMessage!.toLowerCase().contains(lowercaseQuery);
//     }).toList();

//     setState(() {
//       _chats = filteredChats;
//     });
//   }

//   void _onSearchResult() {
//     // final result = widget.viewModel.searchChats.result;
//     // if (result != null && result is Ok) {
//     //   setState(() {
//     //     _chats = result.value;
//     //   });
//     // }
//     final query = _searchController.text.toLowerCase();
//     final filteredChats = _allChats.where((chat) {
//       return chat.username.toLowerCase().contains(query) ||
//           chat.lastMessage.toLowerCase().contains(query);
//     }).toList();
    
//     setState(() {
//       _chats = filteredChats;
//     });
//   }

//   void _refreshChats() {
//     // widget.viewModel.syncChats.execute();
//     // widget.viewModel.syncChats.addListener(_onChatsLoaded);
//     _loadChats();
//   }

//   void _onChatDismissed(String chatId, int index) {
//     setState(() {
//       _chats.removeAt(index);
//     });
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: const Text('Chat archived'),
//         action: SnackBarAction(
//           label: 'Undo',
//           onPressed: () {
//             setState(() {
//               // Re-add the chat
//               _loadChats();
//             });
//           },
//         ),
//       ),
//     );
//   }

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
    
//     // Navigate based on selected index
//     switch (index) {
//       case 0:
//         context.go(UserRoutes.homeScreen);
//         break;
//       case 1:
//         context.go(UserRoutes.chatsScreen);
//         break;
//       case 2:
//         context.go(UserRoutes.profileScreen);
//         break;
//       case 3:
//         context.go(UserRoutes.settingsScreen);
//         break;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Chats'),
//         elevation: 0,
//       ),
//       body: Column(
//         children: [
//           // Search bar
//           Padding(
//             padding: EdgeInsets.all(16.w),
//             child: TextField(
//               controller: _searchController,
//               decoration: InputDecoration(
//                 hintText: 'Search chats...',
//                 prefixIcon: const Icon(Icons.search),
//                 suffixIcon: _searchController.text.isNotEmpty
//                     ? IconButton(
//                         icon: const Icon(Icons.clear),
//                         onPressed: () {
//                           _searchController.clear();
//                         },
//                       )
//                     : null,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12.r),
//                 ),
//               ),
//             ),
//           ),

//           // Chats list
//           Expanded(
//             child: _chats.isEmpty
//                 ? Center(
//                     child: Text(
//                       _isSearching ? 'No chats found' : 'No chats',
//                       style: TextStyle(fontSize: 16.sp),
//                     ),
//                   )
//                 : ListView.builder(
//                     itemCount: _chats.length,
//                     itemBuilder: (context, index) {
//                       final chat = _chats[index];
//                       return ChatListItem(
//                         chat: chat,
//                         onDismissed: () => _onChatDismissed(chat.id, index),
//                         onTap: () => context.go(
//                           '${UserRoutes.chatsScreen}/${chat.id}',
//                           extra: chat,
//                         ),
//                       );
//                     },
//                   ),
//           ),
//           SafeArea( //LogOut Button
//             top: false,
//             child: Padding(
//               padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
//               child: LogoutButton(viewModel: widget.logOutViewModel),
//             ),
//           ),
//         ],
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: "Главная"),
//           BottomNavigationBarItem(
//               icon: Icon(Icons.chat_bubble_outline_rounded),
//               label: "Сообщения"),
//           BottomNavigationBarItem(
//               icon: Icon(Icons.person_outline_rounded), label: "Профиль"),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.settings_rounded),
//             label: "Настройки",
//           ),
//         ],
//         currentIndex: _selectedIndex,
//         selectedItemColor: Colors.blueAccent,
//         unselectedItemColor: Colors.grey,
//         type: BottomNavigationBarType.fixed,
//         onTap: _onItemTapped,
//       ),
//     );
//   }
// }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shop/module_auth/ui/pages/logout/view_models/logout_viewmodel.dart';
import 'package:shop/module_auth/ui/pages/logout/widgets/logout_button.dart';
import 'package:shop/module_chat/domain/chat/chat.dart';
import 'package:shop/module_chat/ui/pages/chat_list/view_models/chat_list_viewmodel.dart';
import 'package:shop/module_chat/ui/pages/chat_list/widgets/chat_list_item.dart';
import 'package:shop/routing/routes.dart';
import 'package:shop/utils/result.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({
    super.key,
    required this.viewModel,
    required this.logOutViewModel,
  });

  final ChatListViewModel viewModel;
  final LogoutViewModel logOutViewModel;

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    widget.viewModel.loadChats.execute();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      final query = _searchController.text;
      widget.viewModel.onSearch(query);
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0: context.go(UserRoutes.homeScreen); break;
      case 1: context.go(UserRoutes.chatsScreen); break;
      case 2: context.go(UserRoutes.profileScreen); break;
      case 3: context.go(UserRoutes.settingsScreen); break;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Сообщения'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Поле поиска (всегда активно)
          Padding(
            padding: EdgeInsets.all(16.w),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Поиск или @username',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: ListenableBuilder(
                  listenable: _searchController,
                  builder: (context, _) => _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => _searchController.clear(),
                        )
                      : const SizedBox.shrink(),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
          //Найденные чаты
          Expanded(
            child: ListenableBuilder(
              listenable: Listenable.merge([
                widget.viewModel.loadChats,
                widget.viewModel.searchChats,
                widget.viewModel.searchUsersChats,
              ]),
              builder: (context, _) {
                final query = _searchController.text;
                final bool isGlobalSearch = query.startsWith('@');
                final dynamic activeCommand = isGlobalSearch 
                    ? widget.viewModel.searchUsersChats 
                    : (query.isEmpty ? widget.viewModel.loadChats : widget.viewModel.searchChats);

                if (activeCommand.running == true) {
                  return const Center(child: CircularProgressIndicator());
                }

                final result = activeCommand.result;

                final List<Chat> displayChats = (result is Ok<List<Chat>>) 
                    ? result.value 
                    : [];

                if (displayChats.isEmpty) {
                  return Center(
                    child: Text(
                      query.isNotEmpty ? 'Ничего не найдено' : 'У вас пока нет чатов',
                      style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                    ),
                  );
                }

                // 4. Список данных
                return RefreshIndicator(
                  onRefresh: () => widget.viewModel.syncChats.execute(),
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    itemCount: displayChats.length,
                    itemBuilder: (context, index) {
                      final chat = displayChats[index];
                      return ChatListItem(
                        chat: chat,
                        onDismissed: () {

                        },
                        onTap: () => context.push(
                          '${UserRoutes.chatsScreen}/${chat.id}',
                          extra: chat,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ), //Навигация
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: "Главная"),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), activeIcon: Icon(Icons.chat_bubble), label: "Чаты"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: "Профиль"),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings), label: "Настройки"),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
    );
  }
}