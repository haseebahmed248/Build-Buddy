import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:buildbuddy/Controllers/chatController.dart';
import 'package:buildbuddy/Models/messageModel.dart';

class ContractorChatScreen extends StatefulWidget {
  final String homeownerId; // Define homeownerId as a named parameter
  final String projectId;
  final String projectTitle;

  const ContractorChatScreen({
    required this.homeownerId, // Ensure it's required
    required this.projectId,
    required this.projectTitle,
    Key? key,
  }) : super(key: key);

  @override
  _ContractorChatScreenState createState() => _ContractorChatScreenState();
}

class _ContractorChatScreenState extends State<ContractorChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ChatController _chatController = Get.find<ChatController>();

  @override
  void initState() {
    super.initState();
    // Ensure real-time messages are loaded for this homeowner
    _chatController.startRealTimeListeners(); // Ensure listener starts
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat for ${widget.projectTitle} with Homeowner'),
        backgroundColor: const Color(0xFF2196F3),
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildChatList(),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    return Obx(() {
      final messages = _chatController.conversations[widget.homeownerId] ?? [];
      if (_chatController.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      if (_chatController.errorMessage != null) {
        return Center(child: Text('Error: ${_chatController.errorMessage}', style: const TextStyle(color: Colors.red)));
      }
      if (messages.isEmpty) {
        return const Center(child: Text('No messages yet.', style: TextStyle(color: Colors.grey)));
      }
      return ListView.builder(
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];
          final isSentByMe = message.senderId == FirebaseAuth.instance.currentUser?.uid;
          return ListTile(
            title: Align(
              alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: isSentByMe ? Colors.blue : Colors.grey[300],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  message.content,
                  style: TextStyle(color: isSentByMe ? Colors.white : Colors.black),
                ),
              ),
            ),
            subtitle: Text(message.timestamp.toString()),
          );
        },
      );
    });
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              if (_messageController.text.isNotEmpty) {
                _chatController.sendMessageToHomeowner(widget.homeownerId, _messageController.text);
                _messageController.clear();
              } else {
                Get.snackbar('Error', 'Please enter a message',
                    snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
              }
            },
          ),
        ],
      ),
    );
  }
}








/*
import 'package:buildbuddy/Controllers/projectController.dart';
import 'package:buildbuddy/Models/projectModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class ContractorChatScreen extends StatefulWidget {
  final String projectId;
  final String projectTitle;

  const ContractorChatScreen({
    required this.projectId,
    required this.projectTitle,
    Key? key,
  }) : super(key: key);

  @override
  _ContractorChatScreenState createState() => _ContractorChatScreenState();
}

class _ContractorChatScreenState extends State<ContractorChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Ensure projects are loaded to access messages
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProjectController>(context, listen: false).loadProjects();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat - ${widget.projectTitle}'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ProjectController>(
              builder: (context, controller, _) {
                final project = controller.projects.firstWhere(
                      (p) => p.id == widget.projectId,
                  orElse: () => Project(
                    id: widget.projectId,
                    title: widget.projectTitle,
                    description: '',
                    userId: '',
                    userType: '',
                    status: ProjectStatus.pending,
                    progress: 0,
                   // date: '',
                    icon: 'work',
                  ),
                );
                final messages = project.messages ?? [];
                if (messages.isEmpty) {
                  return const Center(child: Text('No messages yet. Start the conversation!'));
                }
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  padding: const EdgeInsets.all(8.0),
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == FirebaseAuth.instance.currentUser?.uid;
                    return _buildMessageBubble(message, isMe);
                  },
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue[200] : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              '${GetStringUtils(message.senderType).capitalize!} (${message.senderId.substring(0, 6)}...)',
              style: TextStyle(
                fontSize: 12,
                color: isMe ? Colors.blue[800] : Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message.content,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTimestamp(message.timestamp),
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.blueGrey,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _messageController.text.trim().isEmpty) return;

    final message = Message(
      senderId: user.uid,
      senderType: 'contractor', // Hardcoded as this is the contractor's screen
      content: _messageController.text.trim(),
      timestamp: DateTime.now().toIso8601String(),
    );

    await Provider.of<ProjectController>(context, listen: false).sendMessage(widget.projectId, message);
    _messageController.clear();
    // Scroll to the bottom after sending
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  String _formatTimestamp(String timestamp) {
    final dateTime = DateTime.parse(timestamp);
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')} ${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}

// Extension for capitalizing strings
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}*/
