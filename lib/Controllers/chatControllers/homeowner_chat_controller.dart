import 'package:get/get.dart';
import '../../Models/chatModels/homeowner_chat_model.dart';
import '../../Services/chat/homeowner_chat_service.dart';


class HomeownerChatController extends GetxController {
  final HomeownerChatService _chatService = HomeownerChatService();
  var messages = <HomeownerChatModel>[].obs;

  void fetchMessages(String chatId) {
    _chatService.getMessages(chatId).listen((data) {
      messages.value = data;
    });
  }

  void sendMessage(String chatId, String senderId, String receiverId, String message) {
    _chatService.sendMessage(chatId, senderId, receiverId, message);
  }
}
