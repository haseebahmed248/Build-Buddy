// message_bubble.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final Timestamp timestamp;
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
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
                bottomLeft: isMe ? Radius.circular(12) : Radius.circular(0),
                bottomRight: isMe ? Radius.circular(0) : Radius.circular(12),
              ),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
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
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
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

  String _formatTimestamp(Timestamp timestamp) {
    final now = DateTime.now();
    final date = timestamp.toDate();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
