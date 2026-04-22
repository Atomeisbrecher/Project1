import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:shop/module_chat/domain/message/message.dart';

class MessageItem extends StatefulWidget {
  final Message message;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onReply;
  final VoidCallback onForward;

  const MessageItem({
    super.key,
    required this.message,
    required this.onEdit,
    required this.onDelete,
    required this.onReply,
    required this.onForward,
  });

  @override
  State<MessageItem> createState() => _MessageItemState();
}

class _MessageItemState extends State<MessageItem> {
  final timeFormatter = DateFormat('HH:mm');

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                widget.onEdit();
              },
            ),
            ListTile(
              leading: const Icon(Icons.reply),
              title: const Text('Reply'),
              onTap: () {
                Navigator.pop(context);
                widget.onReply();
              },
            ),
            ListTile(
              leading: const Icon(Icons.forward),
              title: const Text('Forward'),
              onTap: () {
                Navigator.pop(context);
                widget.onForward();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                widget.onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final time = timeFormatter.format(widget.message.timestamp);

    return GestureDetector(
      onLongPress: () => _showContextMenu(context),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              constraints: BoxConstraints(maxWidth: 250.w),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    widget.message.text,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        time,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12.sp,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      _buildStatusIcon(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    switch (widget.message.status) {
      case MessageStatus.sending:
        return Icon(
          Icons.schedule,
          size: 14.sp,
          color: Colors.white70,
        );
      case MessageStatus.sent:
        return Icon(
          Icons.check,
          size: 14.sp,
          color: Colors.white70,
        );
      case MessageStatus.delivered:
        return Icon(
          Icons.done_all,
          size: 14.sp,
          color: Colors.white70,
        );
      case MessageStatus.read:
        return Icon(
          Icons.done_all,
          size: 14.sp,
          color: Colors.blue[200],
        );
      case MessageStatus.failed:
        return Icon(
          Icons.error_outline,
          size: 14.sp,
          color: Colors.red,
        );
    }
  }
}
