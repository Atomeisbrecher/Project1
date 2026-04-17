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
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _loadMessages() {
    widget.viewModel.loadMessages.execute(widget.chat.id);
    widget.viewModel.loadMessages.addListener(_onMessagesLoaded);
  }

  void _onMessagesLoaded() {
    final result = widget.viewModel.loadMessages.result;
    if (result != null && result is Ok) {
      setState(() {
        _messages = result.value;
      });
    }
  }

  void _sendMessage() {
    if (_messageController.text.isEmpty) return;

    final text = _messageController.text;
    _messageController.clear();

    widget.viewModel.sendMessage.execute(widget.chat.id, text);
    widget.viewModel.sendMessage.addListener(_onMessageSent);
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
