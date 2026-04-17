import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gap/flutter_gap.dart';
import 'package:shop/module%20chat/domain/chat/chat.dart';
import 'package:shop/module%20chat/ui/pages/chat_list/view_models/chat_list_viewmodel.dart';
import 'package:shop/module%20chat/ui/pages/chat_list/widgets/chat_list_item.dart';
import 'package:shop/utils/result.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({
    super.key,
    required this.viewModel,
  });

  final ChatListViewModel viewModel;

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Chat> _chats = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadChats();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadChats() {
    widget.viewModel.loadChats.execute();
    widget.viewModel.loadChats.addListener(_onChatsLoaded);
  }

  void _onChatsLoaded() {
    final result = widget.viewModel.loadChats.result;
    if (result != null && result is Ok) {
      setState(() {
        _chats = result.value;
      });
    }
  }

  void _onSearchChanged() {
    if (_searchController.text.isEmpty) {
      setState(() {
        _isSearching = false;
      });
      _loadChats();
    } else {
      setState(() {
        _isSearching = true;
      });
      widget.viewModel.searchChats.execute(_searchController.text);
      widget.viewModel.searchChats.addListener(_onSearchResult);
    }
  }

  void _onSearchResult() {
    final result = widget.viewModel.searchChats.result;
    if (result != null && result is Ok) {
      setState(() {
        _chats = result.value;
      });
    }
  }

  void _refreshChats() {
    widget.viewModel.syncChats.execute();
    widget.viewModel.syncChats.addListener(_onChatsLoaded);
  }

  void _onChatDismissed(String chatId, int index) {
    setState(() {
      _chats.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Chat archived'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              // Re-add the chat
              _loadChats();
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: EdgeInsets.all(16.w),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search chats...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),

          // Chats list
          Expanded(
            child: _chats.isEmpty
                ? Center(
                    child: Text(
                      _isSearching ? 'No chats found' : 'No chats',
                      style: TextStyle(fontSize: 16.sp),
                    ),
                  )
                : ListView.builder(
                    itemCount: _chats.length,
                    itemBuilder: (context, index) {
                      final chat = _chats[index];
                      return ChatListItem(
                        chat: chat,
                        onDismissed: () => _onChatDismissed(chat.id, index),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
