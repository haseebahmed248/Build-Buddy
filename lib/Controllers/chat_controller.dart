import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/firebase_database.dart' as db;

class ChatController with ChangeNotifier {
  final FirebaseDatabase _db = FirebaseDatabase.instance;
  late DatabaseReference _chatRef;
  final String currentUserId;
  List<Map<String, dynamic>> _messages = [];

  ChatController(this.currentUserId, String chatId) {
    _chatRef = _db.ref().child('chatRooms').child(chatId).child('messages');
  }

  List<Map<String, dynamic>> get messages => _messages;

  // Fetch chat messages from Firebase Realtime Database
  Future<void> loadMessages() async {
    final snapshot = await _chatRef.get(); // Use get() instead of once()
    if (snapshot.exists) {
      final messagesMap = snapshot.value as Map;
      _messages = messagesMap.entries.map((entry) {
        return Map<String, dynamic>.from(entry.value);
      }).toList();
      notifyListeners();  // Notify the UI to rebuild
    }
  }

  // Send a message to the chat room
  Future<void> sendMessage(String message) async {
    if (message.isEmpty) return;

    final newMessage = {
      'senderId': currentUserId,
      'message': message,
      'timestamp': db.ServerValue.timestamp,  // Use Firebase's server timestamp
    };

    await _chatRef.push().set(newMessage);
    loadMessages();  // Refresh messages after sending
  }
}














// // chat_controller.dart
// import 'package:get/get.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../Services/chat/chat_service.dart';
// import '../Models/chat_room_model.dart';
// import '../Models/chat_message_model.dart';
// import '../Models/chat_user_model.dart';

// class ChatController extends GetxController {
//   // final ChatService _chatService = ChatService();
//   final _chatRooms = <ChatRoom>[].obs;
//   final _messages = <ChatMessage>[].obs;
//   final _currentUserRole = Rxn<String>();
//   final _isLoading = false.obs;
//   final _error = Rxn<String>();

//   // Getters
//   List<ChatRoom> get chatRooms => _chatRooms;
//   List<ChatMessage> get messages => _messages;
//   String? get currentUserRole => _currentUserRole.value;
//   bool get isLoading => _isLoading.value;
//   String? get error => _error.value;

//   @override
//   void onInit() {
//     super.onInit();
//     _initializeController();
//   }

//   Future<void> _initializeController() async {
//     try {
//       _isLoading.value = true;
//       _currentUserRole.value = await _chatService.getCurrentUserRole();
//       _setupChatRoomsListener();
//     } catch (e) {
//       _error.value = 'Failed to initialize chat: $e';
//     } finally {
//       _isLoading.value = false;
//     }
//   }

//   void _setupChatRoomsListener() {
//     _chatService.getChatRooms().listen(
//       (rooms) {
//         _chatRooms.assignAll(rooms);
//       },
//       onError: (error) {
//         _error.value = 'Failed to load chat rooms: $error';
//       },
//     );
//   }

//   void setupMessagesListener(String chatId) {
//     _chatService.getChatMessages(chatId).listen(
//       (messages) {
//         _messages.assignAll(messages);
//       },
//       onError: (error) {
//         _error.value = 'Failed to load messages: $error';
//       },
//     );
//   }

//   Future<void> sendMessage(String chatId, String message) async {
//     try {
//       _isLoading.value = true;
//       _error.value = null;
//       await _chatService.sendMessage(chatId, message);
//     } catch (e) {
//       _error.value = 'Failed to send message: $e';
//     } finally {
//       _isLoading.value = false;
//     }
//   }

//   Future<String?> createNewChat(String otherUserId) async {
//     try {
//       _isLoading.value = true;
//       _error.value = null;
//       return await _chatService.createChatRoom(otherUserId);
//     } catch (e) {
//       _error.value = 'Failed to create chat: $e';
//       return null;
//     } finally {
//       _isLoading.value = false;
//     }
//   }

//   Future<void> markMessagesAsRead(String chatId) async {
//     try {
//       await _chatService.markMessagesAsRead(chatId);
//     } catch (e) {
//       _error.value = 'Failed to mark messages as read: $e';
//     }
//   }

//   Future<ChatUser?> getUserData(String userId) async {
//     try {
//       return await _chatService.getUserData(userId);
//     } catch (e) {
//       _error.value = 'Failed to get user data: $e';
//       return null;
//     }
//   }

//   String getOtherParticipantId(ChatRoom chatRoom) {
//     final currentUserId = FirebaseAuth.instance.currentUser?.uid;
//     return chatRoom.participants.firstWhere(
//       (id) => id != currentUserId,
//       orElse: () => '',
//     );
//   }

//   String getOtherParticipantName(ChatRoom chatRoom) {
//     final currentUserId = FirebaseAuth.instance.currentUser?.uid;
//     final index = chatRoom.participants.indexOf(currentUserId!);
//     final otherIndex = index == 0 ? 1 : 0;
//     return chatRoom.participantNames[otherIndex];
//   }

//   String formatTimestamp(DateTime timestamp) {
//     final now = DateTime.now();
//     final difference = now.difference(timestamp);

//     if (difference.inDays == 0) {
//       return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
//     } else if (difference.inDays == 1) {
//       return 'Yesterday';
//     } else if (difference.inDays < 7) {
//       return '${difference.inDays}d ago';
//     } else {
//       return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
//     }
//   }

//   void clearError() {
//     _error.value = null;
//   }

//   @override
//   void onClose() {
//     _chatRooms.close();
//     _messages.close();
//     super.onClose();
//   }
// }
