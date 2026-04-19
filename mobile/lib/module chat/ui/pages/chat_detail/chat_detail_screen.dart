import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gap/flutter_gap.dart';
import 'package:intl/intl.dart';
import 'package:shop/module%20chat/domain/chat/chat.dart';
import 'package:shop/module%20chat/domain/message/message.dart';
import 'package:shop/module%20chat/ui/pages/chat_detail/view_models/chat_detail_viewmodel.dart';
import 'package:shop/module%20chat/ui/pages/chat_detail/widgets/message_item.dart';
import 'package:shop/module%20chat/ui/pages/chat_detail/widgets/message_input_field.dart';
import 'package:shop/utils/result.dart';

class ChatDetailScreen extends StatefulWidget {
  final Chat chat;
  final ChatDetailViewModel viewModel;

  const ChatDetailScreen({
    super.key,
    required this.chat,
    required this.viewModel,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  late TextEditingController _messageController;
  List<Message> _messages = [];
  String? _replyingToMessageId;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _loadMessages();
    _initializeFakeMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _loadMessages() {
    // widget.viewModel.loadMessages.execute(widget.chat.id);
    // widget.viewModel.loadMessages.addListener(_onMessagesLoaded);
    _initializeFakeMessages();
  }

  void _onMessagesLoaded() {
    // final result = widget.viewModel.loadMessages.result;
    // if (result != null && result is Ok) {
    //   setState(() {
    //     _messages = result.value;
    //   });
    // }
    
  }

  void _initializeFakeMessages() {
    setState(() {
      _messages = [
        Message(
          id: '1',
          chatId: widget.chat.id,
          senderId: 'user_1',
          text: 'Hey! How are you doing?',
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          status: MessageStatus.read,
          messageNumber: 1,
        ),
        Message(
          id: '2',
          chatId: widget.chat.id,
          senderId: 'current_user',
          text: 'Hi! I\'m doing great, thanks for asking!',
          timestamp: DateTime.now().subtract(const Duration(minutes: 50)),
          status: MessageStatus.read,
          messageNumber: 2,
        ),
        Message(
          id: '3',
          chatId: widget.chat.id,
          senderId: 'user_1',
          text: 'That\'s awesome! Want to grab coffee later?',
          timestamp: DateTime.now().subtract(const Duration(minutes: 40)),
          status: MessageStatus.read,
          messageNumber: 3,
        ),
        Message(
          id: '4',
          chatId: widget.chat.id,
          senderId: 'current_user',
          text: 'Sure! What time works for you?',
          timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
          status: MessageStatus.read,
          messageNumber: 4,
        ),
        Message(
          id: '5',
          chatId: widget.chat.id,
          senderId: 'user_1',
          text: 'How about 3 PM at the coffee shop downtown?',
          timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
          status: MessageStatus.read,
          messageNumber: 5,
        ),
      ];
    });
  }

  void _sendMessage() {
    if (_messageController.text.isEmpty) return;

    final text = _messageController.text;
    _messageController.clear();

    // widget.viewModel.sendMessage.execute(widget.chat.id, text);
    // widget.viewModel.sendMessage.addListener(_onMessageSent);
        // Create a local message
    final newMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      chatId: widget.chat.id,
      senderId: 'current_user',
      text: text,
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
      messageNumber: _messages.length + 1,
    );

    setState(() {
      _messages.add(newMessage);
      _replyingToMessageId = null;
    });
  }

  void _onMessageSent() {
    final result = widget.viewModel.sendMessage.result;
    if (result != null && result is Ok) {
      setState(() {
        _messages.add(result.value);
        _replyingToMessageId = null;
      });
    }
  }

  void _editMessage(Message message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit message'),
        content: TextField(
          controller: TextEditingController(text: message.text),
          decoration: const InputDecoration(hintText: 'Message'),
          maxLines: null,
          onChanged: (value) {
            // Store the new text
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Execute edit
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteMessage(Message message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete message'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              widget.viewModel.deleteMessage
                  .execute(widget.chat.id, message.id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _replyToMessage(Message message) {
    setState(() {
      _replyingToMessageId = message.id;
    });
  }

  void _forwardMessage(Message message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Forward message'),
        content: const Text('Select a chat to forward this message to'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('dd MMM yyyy');
    final timeFormatter = DateFormat('HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.chat.username,
              style: TextStyle(fontSize: 16.sp),
            ),
            Text(
              'Last online: ${timeFormatter.format(widget.chat.lastOnlineTime)}',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey),
            ),
          ],
        ),
        leading: Padding(
          padding: EdgeInsets.all(8.w),
          child: CircleAvatar(
            backgroundImage: NetworkImage(widget.chat.avatar),
          ),
        ),
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Text(
                      'No messages yet',
                      style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    reverse: true,
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[_messages.length - 1 - index];
                      return MessageItem(
                        message: message,
                        onEdit: () => _editMessage(message),
                        onDelete: () => _deleteMessage(message),
                        onReply: () => _replyToMessage(message),
                        onForward: () => _forwardMessage(message),
                      );
                    },
                  ),
          ),

          // Reply preview
          if (_replyingToMessageId != null)
            Container(
              padding: EdgeInsets.all(8.w),
              color: Colors.grey[100],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Replying to a message',
                      style: TextStyle(fontSize: 12.sp),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _replyingToMessageId = null;
                      });
                    },
                  ),
                ],
              ),
            ),

          // Message input
          MessageInputField(
            controller: _messageController,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }
}