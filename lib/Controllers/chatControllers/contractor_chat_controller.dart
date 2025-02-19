/*
import 'package:get/get.dart';
import '../../Models/chatModels/contractor_chat_model.dart';
import '../../Services/chat/contractor_chat_service.dart';

class ContractorChatController extends GetxController {
  final ContractorChatService _chatService = ContractorChatService();
  var messages = <ContractorChatModel>[].obs;

  void fetchMessages(String chatId) {
    _chatService.getMessages(chatId).listen((data) {
      messages.value = data.cast<ContractorChatModel>();
    });
  }

  void sendMessage(String chatId, String senderId, String receiverId, String message) {
    _chatService.sendMessage(chatId, senderId, receiverId, message);
  }
}



*/

import 'dart:async';

import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../Models/chatModels/contractor_chat_model.dart';


class ContractorChatController extends GetxController {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final RxList<ContractorChatModel> messages = <ContractorChatModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Stream subscription for real-time updates
  StreamSubscription<DatabaseEvent>? _messagesSubscription;

  @override
  void onClose() {
    _messagesSubscription?.cancel();
    super.onClose();
  }

  // Fetch messages for a specific chat
  void fetchMessages(String chatId) {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Cancel any existing subscription
      _messagesSubscription?.cancel();

      // Set up real-time listener for messages
      _messagesSubscription = _database
          .child('chats')
          .child(chatId)
          .child('messages')
          .onValue
          .listen(
            (DatabaseEvent event) {
          if (event.snapshot.value != null) {
            // Convert the data to a list of messages
            Map<dynamic, dynamic> messagesMap =
            event.snapshot.value as Map<dynamic, dynamic>;

            messages.value = messagesMap.entries.map((entry) {
              return ContractorChatModel.fromJson({
                'id': entry.key,
                ...Map<String, dynamic>.from(entry.value as Map)
              });
            }).toList();

            // Sort messages by timestamp
            messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          } else {
            messages.clear();
          }
          isLoading.value = false;
        },
        onError: (error) {
          print('Error fetching messages: $error');
          errorMessage.value = 'Failed to load messages. Please try again.';
          isLoading.value = false;
        },
      );
    } catch (e) {
      print('Error in fetchMessages: $e');
      errorMessage.value = 'An unexpected error occurred.';
      isLoading.value = false;
    }
  }

  // Send a new message
  Future<void> sendMessage(
      String chatId,
      String senderId,
      String receiverId,
      String message,
      ) async {
    try {
      if (message.trim().isEmpty) {
        return;
      }

      // Create a new message reference
      final newMessageRef = _database
          .child('chats')
          .child(chatId)
          .child('messages')
          .push();

      // Create message data
      final messageData = {
        'senderId': senderId,
        'receiverId': receiverId,
        'message': message.trim(),
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Save the message
      await newMessageRef.set(messageData);

      // Update chat metadata
      await _database.child('chats').child(chatId).update({
        'lastMessage': message.trim(),
        'lastMessageTime': DateTime.now().toIso8601String(),
        'participants': {
          senderId: true,
          receiverId: true,
        },
      });

    } catch (e) {
      print('Error sending message: $e');
      errorMessage.value = 'Failed to send message. Please try again.';
      throw Exception('Failed to send message');
    }
  }

  // Get or create chat ID
  Future<String> getOrCreateChatId(String contractorId, String receiverId) async {
    try {
      // Query existing chats
      final chatsSnapshot = await _database
          .child('chats')
          .orderByChild('participants/$contractorId')
          .equalTo(true)
          .get();

      if (chatsSnapshot.value != null) {
        Map<dynamic, dynamic> chats =
        chatsSnapshot.value as Map<dynamic, dynamic>;

        // Look for a chat with both participants
        for (var entry in chats.entries) {
          Map<dynamic, dynamic> participants =
          (entry.value['participants'] ?? {}) as Map<dynamic, dynamic>;

          if (participants[receiverId] == true) {
            return entry.key;
          }
        }
      }

      // If no chat exists, create a new one
      final newChatRef = _database.child('chats').push();
      await newChatRef.set({
        'createdAt': DateTime.now().toIso8601String(),
        'participants': {
          contractorId: true,
          receiverId: true,
        },
        'lastMessageTime': DateTime.now().toIso8601String(),
      });

      return newChatRef.key!;
    } catch (e) {
      print('Error in getOrCreateChatId: $e');
      errorMessage.value = 'Failed to initialize chat. Please try again.';
      throw Exception('Failed to initialize chat');
    }
  }

  // Delete a message
  Future<void> deleteMessage(String chatId, String messageId) async {
    try {
      await _database
          .child('chats')
          .child(chatId)
          .child('messages')
          .child(messageId)
          .remove();
    } catch (e) {
      print('Error deleting message: $e');
      errorMessage.value = 'Failed to delete message. Please try again.';
      throw Exception('Failed to delete message');
    }
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String chatId, String userId) async {
    try {
      final messagesSnapshot = await _database
          .child('chats')
          .child(chatId)
          .child('messages')
          .get();

      if (messagesSnapshot.value != null) {
        Map<dynamic, dynamic> messages =
        messagesSnapshot.value as Map<dynamic, dynamic>;

        for (var entry in messages.entries) {
          if (entry.value['receiverId'] == userId &&
              entry.value['isRead'] != true) {
            await _database
                .child('chats')
                .child(chatId)
                .child('messages')
                .child(entry.key)
                .update({'isRead': true});
          }
        }
      }
    } catch (e) {
      print('Error marking messages as read: $e');
      errorMessage.value = 'Failed to update message status.';
    }
  }
}