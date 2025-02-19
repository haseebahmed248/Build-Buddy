import 'package:get/get.dart';
import '../../Models/chatModels/architect_chat_model.dart';
import '../../Services/chat/architect_chat_service.dart';

class ArchitectChatController extends GetxController {
  final ArchitectChatService _chatService = ArchitectChatService();
  var messages = <ArchitectChatModel>[].obs;

  void fetchMessages(String chatId) {
    _chatService.getMessages(chatId).listen((data) {
      messages.value = data;
    });
  }

  void sendMessage(String chatId, String senderId, String receiverId, String message) {
    _chatService.sendMessage(chatId, senderId, receiverId, message);
  }
}







