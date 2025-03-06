import 'package:buildbuddy/Controllers/projectController.dart';
import 'package:buildbuddy/Models/projectModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:buildbuddy/Controllers/authControllers.dart'; // Assuming AuthController exists

class ChatScreen extends StatefulWidget {
  final String projectId;
  final String projectTitle;
  final String userType; // Added userType parameter

  const ChatScreen({
    required this.projectId,
    required this.projectTitle,
    required this.userType,
    Key? key,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final ProjectController _projectController;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    _projectController = ProjectController(widget.userType); // Use the passed userType
    _projectController.loadProjects();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _projectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _projectController,
      child: Scaffold(
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
                  if (controller.errorMessage != null) {
                    return Center(
                      child: Text(
                        controller.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }
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
      ),
    );
  }

  Future<void> _sendMessage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _messageController.text.trim().isEmpty) return;

    final message = Message(
      id: '', // ID will be generated by Firebase push()
      senderId: user.uid,
      senderType: widget.userType, // Use the passed userType
      content: _messageController.text.trim(),
      timestamp: DateTime.now(),
      read: false,
    );

    await _projectController.sendMessage(widget.projectId, message);
    _messageController.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 50,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }
}

// Extension to capitalize strings for UI
extension CustomStringExtension on String {
  String get capitalizeFirst => '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
}

// Assuming UserRole enum exists in authControllers.dart or userModels.dart
enum UserRole {
  admin,
  homeowner,
  contractor,
  architect,
}