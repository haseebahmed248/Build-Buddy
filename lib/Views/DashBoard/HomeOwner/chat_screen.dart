import 'package:buildbuddy/Controllers/projectController.dart';
import 'package:buildbuddy/Models/projectModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Added import for DateFormat

class ChatScreen extends StatefulWidget {
  final String projectId;
  final String projectTitle;

  const ChatScreen({
    required this.projectId,
    required this.projectTitle,
    Key? key,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

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
        backgroundColor: const Color(0xFF2196F3), // Consistent with other screens
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
                    userId: FirebaseAuth.instance.currentUser?.uid ?? '',
                    userType: controller.userType,
                    status: ProjectStatus.pending,
                    progress: 0,
                    date: null,
                    icon: 'work',
                    assignedContractorId: null,
                    assignedArchitectId: null,
                    messages: [],
                    reviewed: false,
                    createdAt: null,
                    lastUpdated: null,
                  ),
                );
                final messages = project.messages ?? [];
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == FirebaseAuth.instance.currentUser?.uid;
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue[100] : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${CustomStringExtension(message.senderType).capitalizeFirst} (${message.senderId})',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            const SizedBox(height: 4),
                            Text(message.content),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('yyyy-MM-dd HH:mm').format(message.timestamp), // timestamp is already a DateTime
                              style: const TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
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
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
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
      id: '', // ID will be generated by Firebase push()
      senderId: user.uid,
      senderType: Provider.of<ProjectController>(context, listen: false).userType,
      content: _messageController.text.trim(),
      timestamp: DateTime.now(), // Pass DateTime directly
      read: false, // Default to unread
    );

    await Provider.of<ProjectController>(context, listen: false).sendMessage(widget.projectId, message);
    _messageController.clear();
    // Scroll to the bottom after sending a message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 50,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }
}

// Extension to capitalize strings for UI (renamed to avoid GetX conflict)
extension CustomStringExtension on String {
  String get capitalizeFirst => '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
}



//////////////////////
/*
import 'package:buildbuddy/Controllers/projectController.dart';
import 'package:buildbuddy/Models/projectModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String projectId;
  final String projectTitle;

  const ChatScreen({
    required this.projectId,
    required this.projectTitle,
    Key? key,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

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
        backgroundColor: const Color(0xFF2196F3),
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
                    date: null,
                    icon: 'work',
                    assignedContractorId: null,
                    assignedArchitectId: null,
                    messages: null,
                    reviewed: false,
                    createdAt: DateTime.now(), // Fixed: Provide a default DateTime
                    lastUpdated: DateTime.now(), // Fixed: Provide a default DateTime
                  ),
                );
                final messages = project.messages ?? [];
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == FirebaseAuth.instance.currentUser?.uid;
                    // Determine sender type based on userType and message senderId
                    final userType = Provider.of<ProjectController>(context, listen: false).userType;
                    final senderType = isMe ? userType : (userType == 'homeowner' ? 'contractor' : 'homeowner');
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue[100] : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${CustomStringExtension(senderType).capitalizeFirst} (${message.senderId})',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            const SizedBox(height: 4),
                            Text(message.content),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('yyyy-MM-dd HH:mm').format(message.timestamp),
                              style: const TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
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
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _messageController.text.trim().isEmpty) return;

    // Find the project to determine the receiverId
    final controller = Provider.of<ProjectController>(context, listen: false);
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
        date: null,
        icon: 'work',
        assignedContractorId: null,
        assignedArchitectId: null,
        messages: null,
        reviewed: false,
        createdAt: DateTime.now(),
        lastUpdated: DateTime.now(),
      ),
    );

    // Determine receiverId based on userType
    final userType = controller.userType;
    final receiverId = userType == 'homeowner' ? project.assignedContractorId : project.userId;
    if (receiverId == null || receiverId.isEmpty) {
      Get.snackbar('Error', 'Cannot send message: No recipient found for this project',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
      return;
    }

    final message = Message(
      id: '', // Firebase will generate the ID
      senderId: user.uid,
      receiverId: receiverId,
      content: _messageController.text.trim(),
      timestamp: DateTime.now(), // Fixed: Pass DateTime directly
      type: 'homeowner_contractor',
      read: false,
    );

    await controller.sendMessage(widget.projectId, message);
    _messageController.clear();
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent + 50,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
}

// Extension to capitalize strings for UI
extension CustomStringExtension on String {
  String get capitalizeFirst => '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
}*/
