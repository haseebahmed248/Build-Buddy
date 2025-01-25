import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatelessWidget {
  final String chatId;
  final String otherUserId;
  final String otherUserName;

  ChatScreen({
    required this.chatId,
    required this.otherUserId,
    required this.otherUserName,
  });

  // Two predefined dummy chats with more extensive conversation
  final List<Map<String, dynamic>> dummyMessages = [
    {
      'senderId': 'currentUser',
      'message': 'Hey, I have some ideas for the new project design.',
      'timestamp':
          Timestamp.fromDate(DateTime.now().subtract(Duration(minutes: 15))),
    },
    {
      'senderId': 'otherUser',
      'message': 'Great! What are you thinking about?',
      'timestamp':
          Timestamp.fromDate(DateTime.now().subtract(Duration(minutes: 14))),
    },
    {
      'senderId': 'currentUser',
      'message':
          'I was considering a more minimalist approach with clean lines.',
      'timestamp':
          Timestamp.fromDate(DateTime.now().subtract(Duration(minutes: 13))),
    },
    {
      'senderId': 'otherUser',
      'message': 'That sounds interesting. Can you elaborate?',
      'timestamp':
          Timestamp.fromDate(DateTime.now().subtract(Duration(minutes: 12))),
    },
    {
      'senderId': 'otherUser',
      'message': 'Are we still meeting tomorrow at 2 PM?',
      'timestamp':
          Timestamp.fromDate(DateTime.now().subtract(Duration(minutes: 30))),
    },
    {
      'senderId': 'currentUser',
      'message': 'Yes, the conference room is booked.',
      'timestamp':
          Timestamp.fromDate(DateTime.now().subtract(Duration(minutes: 29))),
    },
    {
      'senderId': 'otherUser',
      'message': 'Perfect. I\'ll bring the project files.',
      'timestamp':
          Timestamp.fromDate(DateTime.now().subtract(Duration(minutes: 28))),
    },
    {
      'senderId': 'currentUser',
      'message': 'Sounds good. See you then!',
      'timestamp':
          Timestamp.fromDate(DateTime.now().subtract(Duration(minutes: 27))),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(otherUserName),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: dummyMessages.length,
              itemBuilder: (context, index) {
                final message = dummyMessages[dummyMessages.length - 1 - index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isCurrentUser = message['senderId'] == 'currentUser';
    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isCurrentUser ? Colors.blue[100] : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message['message'],
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 4),
            Text(
              _formatTimestamp(message['timestamp']),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              maxLines: null,
            ),
          ),
          SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.send, color: Colors.blue),
            onPressed: () {
              // Placeholder for send message functionality
            },
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hr ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
