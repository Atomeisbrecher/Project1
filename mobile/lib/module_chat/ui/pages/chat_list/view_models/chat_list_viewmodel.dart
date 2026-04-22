import 'package:shop/module_chat/domain/chat/chat.dart';
import 'package:shop/module_chat/domain/use_cases/get_chats.dart';
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
  })  : _getChatsUseCase = getChatsUseCase,
        _syncChatsUseCase = syncChatsUseCase,
        _searchChatsUseCase = searchChatsUseCase {
    loadChats = Command0(_loadChats);
    syncChats = Command0(_syncChats);
    searchChats = Command1<List<Chat>, String>(_searchChats);
  }

  final GetChatsUseCase _getChatsUseCase;
  final SyncChatsUseCase _syncChatsUseCase;
  final SearchChatsUseCase _searchChatsUseCase;
  final _log = Logger('ChatListViewModel');

  late Command0 loadChats;
  late Command0 syncChats;
  late Command1<List<Chat>, String> searchChats;

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

  Future<Result<List<Chat>>> _searchChats(String query) async {
    if (query.isEmpty) {
      return await _loadChats();
    }

    final result = await _searchChatsUseCase(query);
    switch (result) {
      case Ok():
        _log.info('Search completed with ${result.value.length} results for query: "$query"');
        return Result.ok([]);
      case Error():
        _log.warning('Failed to search chats for query: "$query"');
        return Result.ok([]);
    }
  }
}
