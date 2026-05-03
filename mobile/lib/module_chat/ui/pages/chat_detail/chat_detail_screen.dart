import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gap/flutter_gap.dart';
import 'package:intl/intl.dart';
import 'package:shop/module_chat/domain/chat/chat.dart';
import 'package:shop/module_chat/domain/message/message.dart';
import 'package:shop/module_chat/ui/pages/chat_detail/view_models/chat_detail_viewmodel.dart';
import 'package:shop/module_chat/ui/pages/chat_detail/widgets/message_item.dart';
import 'package:shop/module_chat/ui/pages/chat_detail/widgets/message_input_field.dart';
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
  String? _replyingToMessageId;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    widget.viewModel.loadMessages.execute(widget.chat.id);
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.isEmpty) return;

    final text = _messageController.text.trim();
    _messageController.clear();

    widget.viewModel.sendMessage.execute(widget.chat.id, text);

    if (_replyingToMessageId != null) {
      setState(() => _replyingToMessageId = null);
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
        leadingWidth: 80.w,
        leading: Row(
          children: [
            const BackButton(),
            CircleAvatar(
              radius: 18.r,
              backgroundColor: Colors.blueAccent,
              foregroundImage: widget.chat.avatar.isNotEmpty 
                  ? NetworkImage(widget.chat.avatar) 
                  : null,
              child: Text(
                widget.chat.username[0].toUpperCase(),
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
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
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: ListenableBuilder(
              listenable: widget.viewModel,
              builder: (context, _) {
                if (widget.viewModel.loadMessages.running && widget.viewModel.messages.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (widget.viewModel.currentUserId.isEmpty) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                if (widget.viewModel.messages.isEmpty) {
                  return Center(
                    child: Text(
                      'No messages yet',
                      style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                    reverse: true,
                    itemCount: widget.viewModel.messages.length,
                    itemBuilder: (context, index) {
                      final message = widget.viewModel.messages[index];
                      final bool isMe = (message.senderId == widget.viewModel.currentUserId);
                      return MessageItem(
                        message: message,
                        isMe: isMe,
                        onEdit: () => _editMessage(message),
                        onDelete: () => _deleteMessage(message),
                        onReply: () => _replyToMessage(message),
                        onForward: () => _forwardMessage(message),
                      );
                    },
                  );
                }
            ),
          ),

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