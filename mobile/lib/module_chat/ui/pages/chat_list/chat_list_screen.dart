import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shop/module_auth/ui/pages/logout/view_models/logout_viewmodel.dart';
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