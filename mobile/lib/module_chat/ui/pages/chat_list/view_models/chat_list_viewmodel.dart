import 'package:shop/module_chat/data/repository/chat_repo/chat_repository_impl.dart';
import 'package:shop/module_chat/domain/chat/chat.dart';
import 'package:shop/module_chat/domain/use_cases/get_chats.dart';
import 'package:shop/module_chat/domain/use_cases/search_users_chats.dart';
import 'package:shop/module_chat/domain/use_cases/sync_chats.dart';
import 'package:shop/module_chat/domain/use_cases/search_chats.dart';
import 'package:shop/utils/command.dart';
import 'package:shop/utils/result.dart';
import 'package:logging/logging.dart';

class ChatListViewModel {
  ChatListViewModel({
    required GetChatsUseCase getChatsUseCase,
    required SyncChatsUseCase syncChatsUseCase,
    required SearchChatsUseCase searchChatsUseCase,
    required SearchUsersChatsUseCase searchUsersChatsUseCase,
  })  : _getChatsUseCase = getChatsUseCase,
        _syncChatsUseCase = syncChatsUseCase,
        _searchChatsUseCase = searchChatsUseCase,
        _searchUsersChatsUseCase = searchUsersChatsUseCase {
    loadChats = Command0(_loadChats);
    syncChats = Command0(_syncChats);
    searchChats = Command1<List<Chat>, String>(_searchChats);
    searchUsersChats = Command1<List<Chat>, String>(_searchUsersChats);
  }

  final GetChatsUseCase _getChatsUseCase;
  final SyncChatsUseCase _syncChatsUseCase;
  final SearchChatsUseCase _searchChatsUseCase;
  final SearchUsersChatsUseCase _searchUsersChatsUseCase;

  final _log = Logger('ChatListViewModel');

  late Command0 loadChats;
  late Command0 syncChats;
  late Command1<List<Chat>, String> searchChats;
  late Command1<List<Chat>, String> searchUsersChats;

  Future<Result<List<Chat>>> _loadChats() async {
    final result = await _getChatsUseCase();

    if (result is Error) {
      _log.severe('Failed to load chats');
    }

    return result;
  }

  Future<Result<List<Chat>>> _syncChats() async {
    final result = await _syncChatsUseCase();

    if (result is Error) {
      _log.severe('Failed to sync chats');
    }

    return result;
  }
  
  Future<void> onSearch(String query) async {
    if (query.startsWith('@')) {
      await searchUsersChats.execute(query);
    } else {
      await searchChats.execute(query);
    }
  }

  Future<Result<List<Chat>>> _searchChats(String query) async {
    final result = await _searchChatsUseCase(query);
    if (result is Ok<List<Chat>>) {
      _log.info('Search completed with ${result.value.length} results');
    }
    return result;
  }

  Future<Result<List<Chat>>> _searchUsersChats(String query) async {
    final result = await _searchUsersChatsUseCase(query);
    switch (result) {
      case Ok<List<Chat>>():
        _log.fine('Found users for $query');
      case Error():
         _log.warning('No user found for $query');
    }
    return result;
  }
}
