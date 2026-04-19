import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:shop/module%20chat/domain/chat/chat.dart';

class ChatListItem extends StatelessWidget {
  final Chat chat;
  final VoidCallback onDismissed;
  final VoidCallback? onTap;

  const ChatListItem({
    super.key,
    required this.chat,
    required this.onDismissed,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final timeFormatter = DateFormat('HH:mm');
    final time = timeFormatter.format(chat.lastMessageTime);

    return Dismissible(
      key: ValueKey(chat.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (_) => onDismissed(),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 16.w),
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: 24.sp,
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        onTap: onTap,
        leading: CircleAvatar(
          radius: 28.r,
          backgroundImage: NetworkImage(chat.avatar),
        ),
        title: Text(
          chat.username,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          chat.lastMessage,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              time,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey,
              ),
            ),
            if (chat.unreadCount > 0)
              Container(
                margin: EdgeInsets.only(top: 4.h),
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  '${chat.unreadCount}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
