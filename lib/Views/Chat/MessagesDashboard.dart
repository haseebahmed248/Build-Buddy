
import 'package:flutter/material.dart';

import '../../Services/chat/chat_screen.dart';

class MessagesDashboard extends StatelessWidget {
  final String role;  // Role parameter (Homeowner, Contractor, etc.)

  const MessagesDashboard({Key? key, required this.role}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Stack(
        children: [
          // Background Decorative Circles
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFF9800).withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFF5722).withOpacity(0.1),
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: Column(
              children: [
                // Custom AppBar
                _buildCustomAppBar(),

                // Chat List (Dynamic based on user role)
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _getChatList(role).length,  // Dynamically load chat list
                    itemBuilder: (context, index) {
                      return _buildChatTile(
                        context: context,
                        name: _getChatList(role)[index].name,
                        lastMessage: _getChatList(role)[index].lastMessage,
                        time: _getChatList(role)[index].time,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFFFF9800),
        child: const Icon(Icons.message),
      ),
    );
  }

  // Custom app bar remains the same
  Widget _buildCustomAppBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.message_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Messages',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Your Conversations',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Create a dynamic list based on the role (Homeowner, Contractor, etc.)
  List<Chat> _getChatList(String role) {
    if (role == 'Homeowner') {
      return [
        Chat(name: 'John Contractor', lastMessage: 'Can we discuss the project details?', time: '10:30'),
        Chat(name: 'Sarah Architect', lastMessage: 'I\'ve uploaded the new blueprints.', time: 'Yesterday'),
      ];
    } else if (role == 'Contractor') {
      return [
        Chat(name: 'John Homeowner', lastMessage: 'When can we start?', time: '12:00'),
        Chat(name: 'Sarah Architect', lastMessage: 'Please review the plans.', time: '2 Days ago'),
      ];
    } else {
      return [];  // Empty list for any undefined role
    }
  }

  // Chat Tile UI Component
  Widget _buildChatTile({
    required BuildContext context,
    required String name,
    required String lastMessage,
    required String time,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(userName: name),
          ),
        ),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFFF9800).withOpacity(0.1),
          child: Text(
            name[0].toUpperCase(),
            style: const TextStyle(
              color: Color(0xFFFF9800),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          lastMessage,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        trailing: Text(
          time,
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class Chat {
  final String name;
  final String lastMessage;
  final String time;

  Chat({required this.name, required this.lastMessage, required this.time});
}
