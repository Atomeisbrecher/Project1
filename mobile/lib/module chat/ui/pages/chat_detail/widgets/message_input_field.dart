import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MessageInputField extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const MessageInputField({
    super.key,
    required this.controller,
    required this.onSend,
  });

  @override
  State<MessageInputField> createState() => _MessageInputFieldState();
}

class _MessageInputFieldState extends State<MessageInputField> {
  bool _isEmpty = true;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateEmptyState);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateEmptyState);
    super.dispose();
  }

  void _updateEmptyState() {
    setState(() {
      _isEmpty = widget.controller.text.isEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          // Attachment button (Files)
          IconButton(
            icon: const Icon(Icons.attachment),
            onPressed: () {
              // TODO: Implement file picker
            },
            tooltip: 'Attach file',
          ),
          
          // Message input field
          Expanded(
            child: TextField(
              controller: widget.controller,
              decoration: InputDecoration(
                hintText: 'Write a message',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.r),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              ),
              maxLines: null,
              minLines: 1,
            ),
          ),
          SizedBox(width: 8.w),
          
          // Emoji button
          IconButton(
            icon: const Icon(Icons.emoji_emotions_outlined),
            onPressed: () {
              // TODO: Implement emoji picker
            },
            tooltip: 'Emoji',
          ),
          
          // Send button
          IconButton(
            icon: Icon(
              Icons.send,
              color: _isEmpty ? Colors.grey : Colors.blueAccent,
            ),
            onPressed: _isEmpty ? null : widget.onSend,
            tooltip: 'Send',
          ),
        ],
      ),
    );
  }
}
