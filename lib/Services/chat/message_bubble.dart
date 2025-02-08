import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final DateTime timestamp;
  final bool read;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isMe,
    required this.timestamp,
    required this.read,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 8,
        bottom: 8,
        left: isMe ? 64 : 0,
        right: isMe ? 0 : 64,
      ),
      child: Column(
        crossAxisAlignment:
        isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: isMe ? Theme.of(context).primaryColor : Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Text(
              message,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black,
              ),
            ),
          ),
          SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formatTimestamp(timestamp),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              if (isMe) ...[
                SizedBox(width: 4),
                Icon(
                  read ? Icons.done_all : Icons.done,
                  size: 16,
                  color: read ? Colors.blue : Colors.grey[600],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} min ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} hr ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
